import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/controllers/mic_technical_data_controller.dart';

class WaveDataController extends GetxController {
  RxList<int> currentSamples = <int>[].obs; // waveData
  RxList<double> fftCurrentSamples = <double>[].obs; // fft Data
  RxList<double> visibleSamples =
      <double>[].obs; // strongest frequency in fft Data interval
  //TODO: localMax and localMin will be either redundant or handled differently in the future.
  //TODO: therefore they must be removed
  Rx<double>? _localMax;
  Rx<double>? _localMin;

  double get localMax => _localMax?.value ?? 1;
  double get localMin => _localMin?.value ?? 1;

  // List<int> get currentSamples => currentSamples.iterator;

  void addCurrentSamples(List<int> newCurrentSamples) {
    currentSamples.addAll(newCurrentSamples);
    setNumberOfWaveDataPoints();
    update();
  }

  void addFftCurrentSamples(List<double> newFftCurrentSamples) {
    fftCurrentSamples.addAll(newFftCurrentSamples);
    setNumberOfFftDataPoints();
    update();
  }

  void addVisibleSamples(List<double> newVisibleSamples) {
    newVisibleSamples.removeWhere((element) => element == 0);
    visibleSamples.addAll(newVisibleSamples);
    if (kDebugMode) {
      print('length of visible Samples: ${visibleSamples.length}');
      print(
          'just added the following data to visible samples: $newVisibleSamples');
    }
    setNumberOfVisibleDataPoints();
    update();
  }

  void recalulateMinMax() {
    if (visibleSamples.isEmpty) {
      return;
    }
    _localMax = visibleSamples.reduce(max).obs;
    _localMin = visibleSamples.reduce(min).obs;
    if ((_localMax?.value ?? 1) < 3) {
      _localMax?.value = 2;
    }
    if ((_localMin?.value ?? 0) < 1) {
      _localMin?.value = 1;
    }
  }

  void setNumberOfVisibleDataPoints() {
    MicTechnicalDataController micTechnicalDataController = Get.find();
    if (visibleSamples.length > 200) {
      if (kDebugMode) {
        print(
            'Setting visible data length back to ${micTechnicalDataController.samplesPerSecond * 1}');
      }
      visibleSamples = visibleSamples
          .sublist(visibleSamples.length - 200, visibleSamples.length)
          .obs;
    }
  }

  void setNumberOfFftDataPoints() {
    MicTechnicalDataController micTechnicalDataController = Get.find();
    if (fftCurrentSamples.length >
        micTechnicalDataController.samplesPerSecond * 1) {
      if (kDebugMode) {
        print(
            'Setting fft data length back to ${micTechnicalDataController.samplesPerSecond * 1}');
      }
      fftCurrentSamples = fftCurrentSamples
          .sublist(
              fftCurrentSamples.length -
                  micTechnicalDataController.samplesPerSecond * 1,
              fftCurrentSamples.length)
          .obs;
    }
  }

  void setNumberOfWaveDataPoints() {
    MicTechnicalDataController micTechnicalDataController = Get.find();
    if (currentSamples.length >
        micTechnicalDataController.samplesPerSecond * 1) {
      if (kDebugMode) {
        print(
            'Setting wave data length back to ${micTechnicalDataController.samplesPerSecond * 1}');
      }
      currentSamples = currentSamples
          .sublist(
              currentSamples.length -
                  micTechnicalDataController.samplesPerSecond * 1,
              currentSamples.length)
          .obs;
    }
  }

  List<FlSpot> visibleDataToSpots() {
    List<FlSpot> result = [];
    visibleSamples.asMap().forEach(
      (key, value) {
        result.add(FlSpot(key.toDouble(), value));
      },
    );
    return result;
  }
}
