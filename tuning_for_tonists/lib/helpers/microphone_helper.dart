import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mic_stream/mic_stream.dart';
import 'package:scidart/numdart.dart';
import 'package:tuning_for_tonists/constants/calculation_type.dart';
import 'package:tuning_for_tonists/controllers/performance_controller.dart';
import '../controllers/fft_controller.dart';
import '../controllers/tuning_controller.dart';
import '../controllers/mic_initialization_values_controller.dart';
import '../controllers/mic_technical_data_controller.dart';
import '../controllers/microphone_controller.dart';

import '../controllers/wave_data_controller.dart';

abstract class MicrophoneHelper {
  static Future<Stream<Uint8List>?> getMicStream() async {
    final MicInitializationValuesController micInitializationValuesController =
        Get.find();
    MicStream.shouldRequestPermission(true);
    Stream<Uint8List> stream = MicStream.microphone(
        audioSource: micInitializationValuesController.audioSource.value,
        sampleRate: micInitializationValuesController.sampleRate.value,
        channelConfig: micInitializationValuesController.channelConfig.value,
        audioFormat: micInitializationValuesController.audioFormat.value);
    return stream;
  }

  static Future<void> setMicTechnicalData() async {
    final MicTechnicalDataController micTechnicalDataController = Get.find();
    var bytesPerSample = (await MicStream.bitDepth) ~/ 8;
    var samplesPerSecond = (await MicStream.sampleRate);
    var bufferSize = (await MicStream.bufferSize);
    micTechnicalDataController.setMicTechnicalData(
        bytesPerSample, samplesPerSecond, bufferSize);
  }

  static List<double> eightBitWaveDataCalculation(Uint8List samples) {
    List<double> waveData = [];
    Uint8List newSamples = samples.buffer.asUint8List(samples.offsetInBytes);
    for (int sample in newSamples) {
      double newSample = (sample - 128) / 128.0;
      waveData.add(newSample);
    }
    return waveData;
  }

  static List<double> sixteenBitWaveDataCalculation(Uint8List samples) {
    MicTechnicalDataController micTechnicalDataController = Get.find();
    List<double> waveData = [];
    List<int> newSamples = [];
    if (micTechnicalDataController.bytesPerSample == 2) {
      newSamples = samples.buffer.asUint8List(4);
    } else {
      newSamples = samples.buffer.asUint8List();
    }
    double tmpSample = 0;
    bool first = false;
    for (int sample in newSamples.sublist(1)) {
      if (sample > 128) sample -= 255;
      if (first) {
        tmpSample = sample * 128;
      } else {
        tmpSample += sample;
        tmpSample /= 32768;
        waveData.add(tmpSample.toDouble());
        tmpSample = 0;
      }
      first = !first;
    }

    return waveData;
  }

  static List<double> calculateWaveData(Uint8List samples) {
    MicInitializationValuesController micInitializationValuesController =
        Get.find();
    List<double> waveData = [];
    if (micInitializationValuesController.audioFormat.value ==
        AudioFormat.ENCODING_PCM_8BIT) {
      waveData = eightBitWaveDataCalculation(samples);
    } else if (micInitializationValuesController.audioFormat.value ==
        AudioFormat.ENCODING_PCM_16BIT) {
      waveData = sixteenBitWaveDataCalculation(samples);
    } else {
      if (kDebugMode) {
        print(
            'Major error in wave data calculation. The defined audio format ${micInitializationValuesController.audioFormat.value} is not implemented!!');
      }
    }
    return waveData;
  }

  static void calculateHPSManually() {
    WaveDataController waveDataController = Get.find();
    MicInitializationValuesController micInitializationValuesController =
        Get.find();
    // MicTechnicalDataController micTechnicalDataController = Get.find();
    List<double> fft = waveDataController.fftData;
    int N = 5;
    List<double> hps = List.from(fft);
    for (var downSampling = 2; downSampling <= N; downSampling++) {
      for (var i = 0; i < fft.length; i++) {
        hps[i] = hps[i] * fft[(i * downSampling).remainder(fft.length)];
      }
    }
    waveDataController.setHPSData(
        hps.sublist(0, hps.length < 5 ? hps.length : hps.length ~/ N));
    // waveDataController.setHPSData(hps);
    // waveDataController.setHPSData(hps.sublist(0, 100));
    var maxValue = hps.reduce(max);
    var maxIdx = hps.indexOf(maxValue);
    var freq = (maxIdx + 1) *
        micInitializationValuesController.sampleRate.value /
        waveDataController.waveData.length;

    waveDataController.addHPSVisibleSamples([freq]);
  }

  static void calculateFrequency() {
    WaveDataController waveDataController = Get.find();
    FftController fftController = Get.find();
    final frequenciesList =
        fftController.applyRealFft(waveDataController.doubleWaveData);
    if (kDebugMode) {
      print('fftlength: ${fftController.fftLength}');
      print('length of frequencies: ${frequenciesList.length}');
    }
    waveDataController.setFrequencyData(frequenciesList.sublist(1));
    if (kDebugMode) {
      print('length of freq data: ${waveDataController.fftData.length}');
    }
    var freqValue = fftController.getMaxFrequency(waveDataController.fftData);
    waveDataController.addVisibleSample(freqValue);
  }

  static void calculateFrequency2() {
    WaveDataController waveDataController = Get.find();
    FftController fftController = Get.find();
    MicTechnicalDataController micTechnicalDataController = Get.find();
    final frequenciesList =
        fftController.applyRealFft(waveDataController.doubleWaveData);
    List<double> filteredFrequencies = [];
    for (var freq in frequenciesList) {
      filteredFrequencies.add(micTechnicalDataController.butterworthHighpass
          .filter(micTechnicalDataController.butterworthLowpass.filter(freq)));
    }
    waveDataController.setFrequencyData(frequenciesList.sublist(1));
    var freqValue = fftController.getMaxFrequency(waveDataController.fftData);
    waveDataController.addVisibleSample(freqValue);
  }

  static void calculateZeroCrossing() {
    WaveDataController waveDataController = Get.find();
    int zeroCrossingCount = 0;
    for (var i = 0; i < waveDataController.waveData.length; i += 2) {
      if (waveDataController.waveData[i].sign !=
          waveDataController.waveData[i + 1].sign) {
        zeroCrossingCount++;
      }
    }
    var frequency =
        zeroCrossingCount / waveDataController.waveData.length / 2 * 44100.0;
    waveDataController.addZeroCrossingData(frequency);
  }

  static void calculateAutocorrelation() {
    Stopwatch stopwatch = Stopwatch()..start();
    WaveDataController waveDataController = Get.find();
    List<double> autocorrelations = [];
    double autocorrelation = 0;
    for (var i = 0; i < waveDataController.waveData.length; i++) {
      // print('Iteration $i start elapsed: ${stopwatch.elapsed}');

      for (var k = 0; k < waveDataController.waveData.length - 1 - i; k++) {
        autocorrelation +=
            waveDataController.waveData[k] * waveDataController.waveData[i + k];
      }
      // 78
      // print('Iteration $i inner loop elapsed: ${stopwatch.elapsed}');
      autocorrelations
          .add(autocorrelation / (waveDataController.waveData.length - i));
      // autocorrelations
      //     .add(autocorrelation);
      autocorrelation = 0;
      // 431
      // print('Iteration $i list division stuff elapsed: ${stopwatch.elapsed}');
    }
    // print('autocorrelations: $autocorrelations');

    var maxIdx = autocorrelations.indexOf(
        autocorrelations.sublist(30, 530).reduce(max), 30);
    // var frequency = 1 / maxIdx * 44100;
    var frequency = 1 / maxIdx * 8192;
    // print('autocorrelations: $autocorrelations');
    waveDataController.setAutocorrelationData(autocorrelations);
    waveDataController.addAutocorrelationVisibleSamples(frequency);
  }

  static void calculateDisplayData(dynamic samples) {
    WaveDataController waveDataController = Get.find();
    Stopwatch stopwatch = Stopwatch()..start();
    MicrophoneController microphoneController = Get.find();
    PerformanceController performanceController = Get.find();
    waveDataController.addWaveData(calculateWaveData(samples));
    switch (waveDataController.calculationType.value) {
      case CalculationType.Autocorrelation:
        calculateAutocorrelation();
        break;
      case CalculationType.HPS:
        calculateFrequency();
        calculateHPSManually();
        break;
      case CalculationType.ZeroCrossing:
        calculateZeroCrossing();
        break;
    }
    TuningController tuningController = Get.find();
    tuningController.checkIfNoteTuned();
    // if (kDebugMode) {
    //   print('done with all calculations: ${stopwatch.elapsed}');
    // }
    microphoneController.samplesCalculated++;
    // print(
    //     'set microphone counter to: ${microphoneController.samplesCalculated}');
    if (true) {
      // todo: only do this if a screen where performance is needed is used
      performanceController
          .addCalculationDuration(stopwatch.elapsed.inMilliseconds / 1000.0);
    }
    if (microphoneController.samplesCalculated.value >
        microphoneController.totalSamplesToCalculate.value) {
      stopMicrophone();
      microphoneController.samplesCalculated = 0.obs;
    } else {
      print(
          "Calculated sample: ${microphoneController.samplesCalculated.value}/${microphoneController.totalSamplesToCalculate.value}");
    }
  }

  static void stopMicrophone() {
    MicrophoneController microphoneController = Get.find();
    microphoneController.controlMicStream(command: Command.stop);
  }
}
