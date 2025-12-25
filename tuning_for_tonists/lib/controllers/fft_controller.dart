import 'dart:math';

import 'package:fftea/fftea.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/controllers/mic_technical_data_controller.dart';
import 'package:tuning_for_tonists/controllers/wave_data_controller.dart';

class FftController extends GetxController {
  final Rx<FFT> _fft = FFT(4096).obs;

  final Rx<FFT> _fftHalf = FFT(2048).obs;

  FFT get fft => _fft.value;
  FFT get fftHalf => _fftHalf.value;

  final Rx<int> _fftLength = 4096.obs;
  final RxBool lockFftToWaveData = true.obs;

  int get fftLength => _fftLength.value;
  MicTechnicalDataController micTechnicalDataController = Get.find();
  WaveDataController waveDataController = Get.find();

  set fftLength(int newFftLength) {
    _fftLength.value = newFftLength;
    _setFft(FFT(fftLength));
    fftHalf = FFT(fftLength ~/ 2);
    if (lockFftToWaveData.value) {
      waveDataController.waveDataLength = newFftLength;
    }
    refresh();
  }

  void setWaveDataLength(int newLength) {
    waveDataController.waveDataLength = newLength;
    if (lockFftToWaveData.value) {
      _fftLength.value = newLength;
      _setFft(FFT(newLength));
      fftHalf = FFT(newLength ~/ 2);
    }
    refresh();
  }

  void setLockFftToWaveData(bool isLocked) {
    lockFftToWaveData.value = isLocked;
    if (isLocked) {
      setWaveDataLength(waveDataController.waveDataLength);
    }
    refresh();
  }

  double get fftResolution {
    final sampleRate = micTechnicalDataController.samplesPerSecond;
    if (fftLength == 0 || sampleRate <= 1) {
      return 0.0;
    }
    return sampleRate / fftLength;
  }

  void _setFft(FFT newFft) {
    _fft.value = newFft;
  }

  set fftHalf(FFT newFft) {
    _fftHalf.value = newFft;
  }

  List<double> _prepareWaveData(List<double> waveData, int targetLength) {
    if (waveData.length == targetLength) {
      return waveData;
    }
    if (waveData.length > targetLength) {
      return waveData.sublist(0, targetLength);
    }
    final padded = List<double>.filled(targetLength, 0.0);
    padded.setRange(0, waveData.length, waveData);
    return padded;
  }

  Float64List applyRealFft(List<double> waveData) {
    final preparedWaveData = _prepareWaveData(waveData, fftLength);
    return fft.realFft(preparedWaveData).discardConjugates().squareMagnitudes();
  }

  Float64List applyRealFftHalf(List<double> waveData) {
    final preparedWaveData = _prepareWaveData(waveData, fftLength ~/ 2);
    return fftHalf
        .realFft(preparedWaveData)
        .discardConjugates()
        .squareMagnitudes();
  }

  double getMaxFrequency(List<double> frequencyData) {
    var maxFreq = frequencyData.reduce(max);
    final freqValue = (frequencyData.indexOf(maxFreq) + 1) *
        (micTechnicalDataController.samplesPerSecond) /
        fftLength;
    return freqValue;
  }
}
