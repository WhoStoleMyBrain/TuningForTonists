import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mic_stream/mic_stream.dart';
import 'package:tuning_for_tonists/controllers/fft_controller.dart';
import '../controllers/mic_initialization_values_controller.dart';
import '../controllers/mic_technical_data_controller.dart';
import '../controllers/microphone_controller.dart';

import '../controllers/wave_data_controller.dart';

class MicrophoneHelper {
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
    Stopwatch stopwatch = Stopwatch()..start();
    print('start 8bit calc: ${stopwatch.elapsed}');
    List<double> waveData = [];
    Uint8List newSamples = samples.buffer.asUint8List(samples.offsetInBytes);
    print('new samples uint8list: ${stopwatch.elapsed}');
    for (int sample in newSamples) {
      if (sample > 255) sample -= 255;
      waveData.add(sample.toDouble());
    }
    print('wavedata added: ${stopwatch.elapsed}');
    calculateNewAutocorrelation(waveData);
    print('autocorrelation calculated: ${stopwatch.elapsed}');
    // calculateAutocorrelation(waveData);
    return waveData;
  }

  static List<double> sixteenBitWaveDataCalculation(Uint8List samples) {
    MicTechnicalDataController micTechnicalDataController = Get.find();
    List<double> waveData = [];
    List<int> newSamples;
    //TODO Need to check if input data actually is 16 byte list. Check documentation of microphone...
    //TODO Need to check if little endian encoding is relevant here...

    if (micTechnicalDataController.bytesPerSample == 2) {
      newSamples = samples.buffer.asUint16List();
    } else {
      newSamples = samples.buffer.asUint8List();
    }
    double tmpSample = 0;
    for (int sample in newSamples) {
      // if (sample > 32768) sample -= 65536;
      tmpSample =
          micTechnicalDataController.butterworth.filter(sample.toDouble());
      waveData.add(tmpSample.toDouble());
    }
    // calculateAutocorrelation(waveData);
    calculateNewAutocorrelation(waveData);
    return waveData;
  }

  static void calculateAutocorrelation(List<double> samples) {
    WaveDataController waveDataController = Get.find();
    double mean =
        samples.reduce((value, element) => value + element) / samples.length;
    double sum =
        samples.reduce((value, element) => value + pow((element - mean), 2));
    List<double> autocorrelation = [];
    for (int k = 0; k < samples.length; k++) {
      double value = 0;
      for (int i = 1; i < samples.length - k; i++) {
        value += (samples[i] - mean) * (samples[k] - mean);
      }
      value /= sum;
      autocorrelation.add(value);
    }
    waveDataController.setAutocorrelationData(autocorrelation.sublist(1));
  }

  static void calculateNewAutocorrelation(List<double> samples) {
    Stopwatch stopwatch = Stopwatch()..start();
    print('autocorrelation start: ${stopwatch.elapsed}');
    WaveDataController waveDataController = Get.find();
    List<double> autocorrelation = [];
    // List<double> waveData = waveDataController.waveData;
    double integral = 0;
    for (var i = 0; i < waveDataController.waveData.length; i++) {
      for (var j = i; j < waveDataController.waveData.length - i; j++) {
        integral +=
            waveDataController.waveData[i] * waveDataController.waveData[j];
      }
      autocorrelation.add(integral);
      integral = 0;
    }
    print('autocorrelation after loop calculation: ${stopwatch.elapsed}');
    waveDataController.setAutocorrelationData(autocorrelation.sublist(1));
    print(
        'autocorrelation after setting controller data: ${stopwatch.elapsed}');
  }

  static List<double> calculateWaveData(Uint8List samples) {
    Stopwatch stopwatch = Stopwatch()..start();
    print('start: ${stopwatch.elapsed}');
    MicInitializationValuesController micInitializationValuesController =
        Get.find();
    print('found mic init controller: ${stopwatch.elapsed}');

    List<double> waveData = [];
    if (micInitializationValuesController.audioFormat.value ==
        AudioFormat.ENCODING_PCM_8BIT) {
      print('before calculate 8bit: ${stopwatch.elapsed}');
      waveData = eightBitWaveDataCalculation(samples);
      print('after calculate 8bit: ${stopwatch.elapsed}');
    } else if (micInitializationValuesController.audioFormat.value ==
        AudioFormat.ENCODING_PCM_16BIT) {
      print('before calculate 16bit: ${stopwatch.elapsed}');
      waveData = sixteenBitWaveDataCalculation(samples);
      print('after calculate 16bit: ${stopwatch.elapsed}');
    } else {
      if (kDebugMode) {
        print(
            'Major error in wave data calculation. The defined audio format ${micInitializationValuesController.audioFormat.value} is not implemented!!');
      }
    }
    return waveData;
  }

  static void calculateDisplayData(dynamic samples) {
    WaveDataController waveDataController = Get.find();
    FftController fftController = Get.find();
    Stopwatch stopwatch = Stopwatch()..start();
    waveDataController.addWaveData(calculateWaveData(samples));
    print('calculate Wavedata executed: ${stopwatch.elapsed}');
    final frequenciesList =
        fftController.applyRealFft(waveDataController.doubleWaveData);
    print('realFft: ${stopwatch.elapsed}');

    // Sublist: 2 removes first to instances, needed for 8 bit data. length/2
    // refers to the nyquist frequency cutoff
    waveDataController.setFrequencyData(
        frequenciesList.sublist(2, frequenciesList.length ~/ 2));
    print('set frequency data: ${stopwatch.elapsed}');
    var freqValue = fftController.getMaxFrequency(waveDataController.fftData);
    print('get max frequency: ${stopwatch.elapsed}');
    waveDataController.addVisibleSample(freqValue);
    print('add visible sample: ${stopwatch.elapsed}');
    stopMicrophone();
  }

  static void stopMicrophone() {
    MicrophoneController microphoneController = Get.find();
    microphoneController.controlMicStream(command: Command.stop);
  }
}
