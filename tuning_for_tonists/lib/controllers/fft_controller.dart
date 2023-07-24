import 'dart:math';
import 'dart:typed_data';

import 'package:fftea/fftea.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/controllers/mic_technical_data_controller.dart';

class FftController extends GetxController {
  Rx<FFT> _fft = FFT(1024).obs;

  FFT get fft => _fft.value;

  Rx<int> _fftLength = 1024.obs;

  int get fftLength => _fftLength.value;
  MicTechnicalDataController micTechnicalDataController = Get.find();

  void setFftLength(int newFftLength) {
    _fftLength = newFftLength.obs;
  }

  void setFft(FFT newFft) {
    _fft = newFft.obs;
  }

  Float64List applyRealFft(List<double> waveData) {
    return fft.realFft(waveData).discardConjugates().squareMagnitudes();
  }

  double getMaxFrequency(List<double> frequencyData) {
    var maxFreq = frequencyData.reduce(max);
    var tmp = frequencyData.indexOf(maxFreq);
    final freqValue = frequencyData.indexOf(maxFreq) *
        (micTechnicalDataController.samplesPerSecond) /
        fftLength /
        micTechnicalDataController.bytesPerSample;
    print(
        'maxFreq: $maxFreq, tmp: $tmp, samplesPS: ${micTechnicalDataController.samplesPerSecond}, fftLength: $fftLength, freqValue: $freqValue');
    return freqValue;
  }
}
