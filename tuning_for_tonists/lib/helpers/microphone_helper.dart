import 'dart:math';
import 'dart:typed_data';

import 'package:fftea/fftea.dart';
import 'package:get/get.dart';
import 'package:mic_stream/mic_stream.dart';
import 'package:tuning_for_tonists/controllers/mic_initialization_values_controller.dart';
import 'package:tuning_for_tonists/controllers/mic_technical_data_controller.dart';

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

  static void calculateDisplayData(dynamic samples) {
    WaveDataController waveDataController = Get.find();
    MicTechnicalDataController micTechnicalDataController = Get.find();
    bool first = true;
    int tmp = 0;
    List<int> waveData = [];
    for (int sample in samples) {
      if (sample > 128) sample -= 255;
      if (first) {
        tmp = sample * 128;
      } else {
        tmp += sample;
        waveData.add(tmp);
        tmp = 0;
      }
      first = !first;
    }
    waveDataController.addCurrentSamples(waveData);

    List<double> doubleWaveData =
        waveDataController.currentSamples.map((e) => e.toDouble()).toList();
    final fftLength = micTechnicalDataController.samplesPerSecond;
    // print('fftLength: $fftLength');
    final fft = FFT(fftLength);
    if (doubleWaveData.length < fftLength) {
      return;
    }
    final freq = fft
        .realFft(doubleWaveData.sublist(doubleWaveData.length - fftLength))
        .discardConjugates();
    var realFreq = freq
        .map((e) => sqrt(pow(e.x.toDouble(), 2) + pow(e.y.toDouble(), 2)))
        .where((element) => element.isNaN ? false : true)
        .toList();
    waveDataController.fftCurrentSamples =
        realFreq.sublist(0, realFreq.length ~/ 2).obs;
    var maxFreq = realFreq.reduce(max);
    final freqValue = realFreq.indexOf(maxFreq) *
        (micTechnicalDataController.samplesPerSecond) /
        fftLength;
    // print('freqValue: $freqValue');
    waveDataController.addVisibleSamples([freqValue > 0 ? freqValue : 0]);
    waveDataController.recalulateMinMax();
  }
}
