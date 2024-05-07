import 'dart:math';

import 'package:fftea/fftea.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/controllers/mic_technical_data_controller.dart';
import 'package:tuning_for_tonists/controllers/wave_data_controller.dart';

class FftController extends GetxController {
  final Rx<FFT> _fft = FFT(4096).obs;

  FFT get fft => _fft.value;

  final Rx<int> _fftLength = 4096.obs;

  int get fftLength => _fftLength.value;
  MicTechnicalDataController micTechnicalDataController = Get.find();
  WaveDataController waveDataController = Get.find();

  void setFftLength(int newFftLength) {
    _fftLength.value = newFftLength;
    _setFft(FFT(fftLength));
    waveDataController.waveDataLength = newFftLength;
    waveDataController.waveData.value = List.filled(newFftLength, 0);
    refresh();
  }

  void _setFft(FFT newFft) {
    _fft.value = newFft;
  }

  Float64List applyRealFft(List<double> waveData) {
    return fft.realFft(waveData).discardConjugates().squareMagnitudes();
  }

  double getMaxFrequency(List<double> frequencyData) {
    var maxFreq = frequencyData.reduce(max);
    final freqValue = (frequencyData.indexOf(maxFreq) + 1) *
        (micTechnicalDataController.samplesPerSecond) /
        fftLength;
    return freqValue;
  }
}
