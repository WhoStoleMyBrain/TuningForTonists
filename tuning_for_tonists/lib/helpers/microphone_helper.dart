import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mic_stream/mic_stream.dart';
import 'package:scidart/numdart.dart';
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
    final MicTechnicalDataController micTechnicalDataController = Get.find();
    MicStream.shouldRequestPermission(true);
    Stream<Uint8List>? stream = await MicStream.microphone(
        audioSource: micInitializationValuesController.audioSource.value,
        sampleRate: micInitializationValuesController.sampleRate.value,
        channelConfig: micInitializationValuesController.channelConfig.value,
        audioFormat: micInitializationValuesController.audioFormat.value);
    var bytesPerSample = (await MicStream.bitDepth)! ~/ 8;
    var samplesPerSecond = (await MicStream.sampleRate)!.toInt();
    var bufferSize = (await MicStream.bufferSize)!.toInt();
    micTechnicalDataController.setMicTechnicalData(
        bytesPerSample, samplesPerSecond, bufferSize);
    return stream;
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
    MicTechnicalDataController micTechnicalDataController = Get.find();
    List<double> fft = waveDataController.fftData;
    int N = 3;
    List<double> hps = List.from(fft);
    for (var downSampling = 2; downSampling <= N; downSampling++) {
      for (var i = 0; i < fft.length; i++) {
        hps[i] = hps[i] * fft[(i * downSampling).remainder(fft.length)];
      }
    }
    waveDataController.setHPSData(hps.sublist(0, 50));
    var maxValue = hps.reduce(max);
    var maxIdx = hps.indexOf(maxValue);
    var freq = maxIdx *
        micInitializationValuesController.sampleRate.value /
        micTechnicalDataController.bufferSize;

    waveDataController.addHPSVisibleSamples([freq]);
  }

  static void calculateFrequency() {
    WaveDataController waveDataController = Get.find();
    FftController fftController = Get.find();
    final frequenciesList =
        fftController.applyRealFft(waveDataController.doubleWaveData);
    // waveDataController.setFrequencyData(frequenciesList.sublist(2, 100));
    waveDataController.setFrequencyData(
        frequenciesList.sublist(2, frequenciesList.length ~/ 2));
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
    WaveDataController waveDataController = Get.find();
    List<double> autocorrelations = [];
    double autocorrelation = 0;
    for (var i = 0; i < waveDataController.waveData.length; i++) {
      for (var k = 0; k < waveDataController.waveData.length - 1 - i; k++) {
        autocorrelation +=
            waveDataController.waveData[k] * waveDataController.waveData[i + k];
      }
      autocorrelations
          .add(autocorrelation / (waveDataController.waveData.length - i));
      // autocorrelations
      //     .add(autocorrelation);
      autocorrelation = 0;
    }
    // print('autocorrelations: $autocorrelations');

    var maxIdx = autocorrelations.indexOf(
        autocorrelations.sublist(30, 530).reduce(max), 30);
    var frequency = 1 / maxIdx * 44100;
    // print('autocorrelations: $autocorrelations');
    waveDataController.setAutocorrelationData(autocorrelations);
    waveDataController.addAutocorrelationVisibleSamples(frequency);
  }

  static void calculateDisplayData(dynamic samples) {
    WaveDataController waveDataController = Get.find();
    Stopwatch stopwatch = Stopwatch()..start();
    waveDataController.addWaveData(calculateWaveData(samples));
    calculateFrequency();
    // calculateHPSManually();
    // calculateAutocorrelation();
    // calculateZeroCrossing();
    TuningController tuningController = Get.find();
    tuningController.checkIfNoteTuned();
    if (kDebugMode) {
      print('done with all calculations: ${stopwatch.elapsed}');
    }
  }

  static void stopMicrophone() {
    MicrophoneController microphoneController = Get.find();
    microphoneController.controlMicStream(command: Command.stop);
  }
}
