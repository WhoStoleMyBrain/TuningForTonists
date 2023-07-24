import 'dart:math';
import 'dart:typed_data';

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
    List<double> waveData = [];
    // MicTechnicalDataController micTechnicalDataController = Get.find();
    // Uint8List newSamples = samples.buffer.asUint8List();
    Uint8List newSamples = samples.buffer.asUint8List(samples.offsetInBytes);
    double tmpSample = 0;
    // bool first = true;
    for (int sample in newSamples) {
      if (sample > 255) sample -= 255;
      // if (first) {
      //   tmpSample = sample * 128;
      // } else {
      tmpSample += sample;
      // tmpSample =
      //     micTechnicalDataController.butterworth.filter(sample.toDouble());
      waveData.add(sample.toDouble());
      tmpSample = 0;
      // }
      // first = !first;
    }
    calculateAutocorrelation(waveData);
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
      tmpSample = sample / 32768;
      tmpSample =
          micTechnicalDataController.butterworth.filter(tmpSample.toDouble());
      // if (first) {
      // tmp =
      // tmp = sample * 32768;
      // } else {
      // tmp += sample;
      waveData.add(tmpSample.toDouble());
      // tmp = 0;
    }
    // first = !first;
    // }
    calculateAutocorrelation(waveData);
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

  static List<double> calculateWaveData(Uint8List samples) {
    MicInitializationValuesController micInitializationValuesController =
        Get.find();

    List<double> waveData = [];
    if (micInitializationValuesController.audioFormat.value ==
        AudioFormat.ENCODING_PCM_8BIT) {
      // print('Äcalculationg with 8 bit data');
      waveData = eightBitWaveDataCalculation(samples);
    } else if (micInitializationValuesController.audioFormat.value ==
        AudioFormat.ENCODING_PCM_16BIT) {
      waveData = sixteenBitWaveDataCalculation(samples);
    } else {
      print(
          'Major error in wave data calculation. The defined audio format ${micInitializationValuesController.audioFormat.value} is not implemented!!');
    }
    return waveData;
  }

  static void calculateDisplayData(dynamic samples) {
    WaveDataController waveDataController = Get.find();
    FftController fftController = Get.find();
    waveDataController.addWaveData(calculateWaveData(samples));
    final freq = fftController.applyRealFft(waveDataController.doubleWaveData);

    // Sublist: 2 removes first to instances, needed for 8 bit data. length/2
    // refers to the nyquist frequency cutoff
    waveDataController.setFrequencyData(freq.sublist(2, freq.length ~/ 2));
    var freqValue = fftController.getMaxFrequency(waveDataController.fftData);
    waveDataController.addVisibleSample(freqValue);
  }

  static void stopMicrophone() {
    MicrophoneController microphoneController = Get.find();
    microphoneController.controlMicStream(command: Command.stop);
  }
}
