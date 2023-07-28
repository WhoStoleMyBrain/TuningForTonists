import 'dart:math';

import 'package:fftea/fftea.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/controllers/mic_technical_data_controller.dart';

class FftController extends GetxController {
  Rx<FFT> _fft = FFT(4096).obs;

  FFT get fft => _fft.value;

  Rx<int> _fftLength = 4096.obs;

  int get fftLength => _fftLength.value;
  MicTechnicalDataController micTechnicalDataController = Get.find();

  void setFftLength(int newFftLength) {
    _fftLength = newFftLength.obs;
  }

  void setFft(FFT newFft) {
    _fft = newFft.obs;
  }

  Float64List applyRealFft(List<double> waveData) {
    // fft.realInverseFft(complexArray)
    print('length fft: ${_fft.value.size}');
    print('length wavedata: ${waveData.length}');
    return fft.realFft(waveData).discardConjugates().squareMagnitudes();
  }

  double getMaxFrequency(List<double> frequencyData) {
    var maxFreq = frequencyData.reduce(max);
    var tmp = frequencyData.indexOf(maxFreq);
    final freqValue = frequencyData.indexOf(maxFreq) *
        (micTechnicalDataController.samplesPerSecond) /
        fftLength /
        micTechnicalDataController.bytesPerSample;
    if (kDebugMode) {
      print(
          'maxFreq: $maxFreq, tmp: $tmp, samplesPS: ${micTechnicalDataController.samplesPerSecond}, fftLength: $fftLength, freqValue: $freqValue');
    }
    return freqValue;
  }
}
