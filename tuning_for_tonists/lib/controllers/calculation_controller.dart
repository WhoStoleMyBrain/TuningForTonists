import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:scidart/numdart.dart';
import 'package:scidart/scidart.dart';

import '../helpers/microphone_helper.dart';
import '../constants/calculation_type.dart';
import 'fft_controller.dart';
import 'mic_initialization_values_controller.dart';
import 'mic_technical_data_controller.dart';
import 'performance_controller.dart';
import 'tuning_controller.dart';
import 'wave_data_controller.dart';

class CalculationController extends GetxController {
  WaveDataController waveDataController = Get.find();
  MicInitializationValuesController micInitializationValuesController =
      Get.find();
  FftController fftController = Get.find();
  MicTechnicalDataController micTechnicalDataController = Get.find();
  PerformanceController performanceController = Get.find();
  TuningController tuningController = Get.find();

  RxInt samplesCalculated = 0.obs;
  RxInt totalSamplesToCalculate = 201.obs;
  Logger logger = Logger(filter: DevelopmentFilter());

  Array? _hanningWindow;

  double _calculatePeakStrength(List<double> data) {
    if (data.isEmpty) {
      return 0.0;
    }
    final magnitudes = data.map((value) => value.abs()).toList();
    final maxValue = magnitudes.reduce(max);
    final average =
        magnitudes.reduce((value, element) => value + element) /
            magnitudes.length;
    if (average == 0.0) {
      return 0.0;
    }
    return maxValue / average;
  }

  void _setPeakStrengthFrom(List<double> data) {
    waveDataController.setPeakStrength(_calculatePeakStrength(data));
  }

  set hanningWindow(int hanningLength) {
    _hanningWindow = hann(hanningLength);
    logger.d("Setting hanning window to length: $hanningLength");
    refresh();
    // update();
  }

  void setSamplesToCalculate(int newSamplesToCalculate) {
    totalSamplesToCalculate = newSamplesToCalculate.obs;
    refresh();
  }

  void calculateFrequency() {
    final frequenciesList =
        fftController.applyRealFft(waveDataController.doubleWaveData);
    waveDataController.frequencyData = frequenciesList.sublist(1);
  }

  Array getHanningWindow() {
    if (_hanningWindow != null) {
      if (waveDataController.waveDataLength != _hanningWindow!.length) {
        logger.d(
            "hanning window length did not equal wavedata length. Needed to create one instance.");
        _hanningWindow = hann(waveDataController.waveDataLength);
      }
      return _hanningWindow!;
    }
    logger.d("hanning window was null. Needed to create one instance.");
    _hanningWindow = hann(waveDataController.waveDataLength);
    return _hanningWindow!;
  }

  void calculateFrequency2() {
    // List<double> waveDataListHanninged = [];
    // for (var waveData in waveDataController.doubleWaveData) {
    //   waveDataListHanninged.add(micTechnicalDataController.butterworthHighpass
    //       .filter(
    //           micTechnicalDataController.butterworthLowpass.filter(waveData)));
    // }
    Array waveDat = Array(waveDataController.doubleWaveData);
    Array hanningedWaveData = getHanningWindow() * waveDat;
    final frequenciesList = fftController.applyRealFft(hanningedWaveData);
    // final frequenciesList = fftController.applyRealFft(waveDataListHanninged);
    // final frequenciesList =
    //     fftController.applyRealFft(waveDataController.doubleWaveData);
    // List<double> filteredFrequencies = [];
    // for (var freq in frequenciesList) {
    //   filteredFrequencies.add(micTechnicalDataController.butterworthHighpass
    //       .filter(micTechnicalDataController.butterworthLowpass.filter(freq)));
    // }
    // waveDataController.setFrequencyData(filteredFrequencies.sublist(1));
    waveDataController.frequencyData = frequenciesList.sublist(31);
    _setPeakStrengthFrom(waveDataController.frequencyData);
  }

  void calculateHPSManually() {
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
    _setPeakStrengthFrom(waveDataController.hpsData);
    var maxValue = hps.reduce(max);
    var maxIdx = hps.indexOf(maxValue);
    var freq = (maxIdx + 31) *
        micInitializationValuesController.sampleRate /
        waveDataController.waveData.length;
    waveDataController.addVisibleSample(freq);
  }

  void calculateZeroCrossing() {
    int zeroCrossingCount = 0;
    for (var i = 0; i < waveDataController.waveData.length; i += 2) {
      if (waveDataController.waveData[i].sign !=
          waveDataController.waveData[i + 1].sign) {
        zeroCrossingCount++;
      }
    }
    var frequency = zeroCrossingCount /
        waveDataController.waveData.length /
        2 *
        micTechnicalDataController.samplesPerSecond;
    waveDataController.addZeroCrossingData(frequency);
    waveDataController.setPeakStrength(0.0);
    waveDataController.addVisibleSample(frequency);
  }

  void calculateAutocorrelation() {
    List<double> autocorrelations = [];
    double autocorrelation = 0;
    int autocorrLength = min(waveDataController.waveData.length,
        137); //530 from 44100 / 80 Hz. 137 = 8192/80 Hz
    for (var i = 0; i < autocorrLength; i++) {
      for (var k = 0; k < waveDataController.waveData.length - 1 - i; k++) {
        autocorrelation +=
            waveDataController.waveData[k] * waveDataController.waveData[i + k];
      }
      autocorrelations
          .add(autocorrelation / (waveDataController.waveData.length - i));
      autocorrelation = 0;
    }
    int maxIdx = autocorrelations.indexOf(
        autocorrelations.sublist(20, autocorrLength).reduce(max), 20);
    double frequency = micTechnicalDataController.samplesPerSecond / maxIdx;
    waveDataController.setAutocorrelationData(autocorrelations);
    _setPeakStrengthFrom(waveDataController.autocorrelationData);
    waveDataController.addVisibleSample(frequency);
  }

  void calculateCepstrum() {
    calculateFrequenciesCepstrum();
    _setPeakStrengthFrom(waveDataController.frequencyData);
    final maximum = waveDataController.frequencyData
            .indexOf(waveDataController.frequencyData.reduce(max)) +
        20;
    final freq = micTechnicalDataController.samplesPerSecond / maximum;
    if (freq.isInfinite || freq.isNaN) {
      waveDataController.addVisibleSample(0.0);
    } else {
      waveDataController.addVisibleSample(freq);
    }
  }

  void calculateFrequenciesCepstrum() {
    Array waveDat = Array(waveDataController.doubleWaveData);
    Array hanningedWaveData = getHanningWindow() * waveDat;
    Float64List frequenciesList1 =
        fftController.applyRealFft(hanningedWaveData).sublist(1);
    frequenciesList1 =
        Float64List.fromList(frequenciesList1.map((e) => log(e)).toList());
    Float64List frequenciesList2 =
        fftController.applyRealFftHalf(frequenciesList1).sublist(1);
    waveDataController.frequencyData = frequenciesList2.sublist(20);
  }

  void calculateDisplayData(dynamic samples) {
    Stopwatch stopwatch = Stopwatch()..start();
    waveDataController.addWaveData(MicrophoneHelper.calculateWaveData(samples));
    switch (waveDataController.calculationType.value) {
      case CalculationType.Autocorrelation:
        calculateAutocorrelation();
        break;
      case CalculationType.HPS:
        calculateFrequency2();
        calculateHPSManually();
        break;
      case CalculationType.ZeroCrossing:
        calculateZeroCrossing();
        break;
      case CalculationType.Cepstrum:
        calculateCepstrum();
        break;
    }

    tuningController.checkIfNoteTuned();
    samplesCalculated++;
    if (true) {
      // todo: only do this if a screen where performance is needed is used
      performanceController
          .addCalculationDuration(stopwatch.elapsed.inMilliseconds / 1000.0);
    }
    if (samplesCalculated.value > totalSamplesToCalculate.value) {
      MicrophoneHelper.stopMicrophone();
      samplesCalculated = 0.obs;
    } else {
      if (samplesCalculated % 100 == 0) {
        print(
            "Calculated sample: ${samplesCalculated.value}/${totalSamplesToCalculate.value}");
      }
    }
  }
}
