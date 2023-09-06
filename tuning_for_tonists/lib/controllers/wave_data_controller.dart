import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../controllers/mic_technical_data_controller.dart';
import '../controllers/tuning_controller.dart';

class WaveDataController extends GetxController {
  final RxList<double> visibleSamples =
      <double>[0].obs; // strongest frequency in fft Data interval
  final RxList<double> hpsVisibleData = RxList.filled(200, 0);
  final RxList<double> autocorrelationVisibleData = RxList.filled(200, 0);

  final Rx<int> waveDataLength = 4096.obs;
  final RxList<double> waveData = RxList.filled(4096, 0);
  final RxList<double> fftData = <double>[0].obs;
  final RxList<double> autocorrelationData = <double>[1].obs;
  final RxList<double> hpsData = <double>[0].obs;
  final RxList<double> zeroCrossingData = <double>[0].obs;

  final MicTechnicalDataController micTechnicalDataController = Get.find();

  List<double> get doubleWaveData =>
      waveData.map((element) => element.toDouble()).toList();

  void addWaveData(List<double> newWaveData) {
    waveData.addAll(newWaveData);
    setNumberOfWaveData();
    refresh();
    update();
  }

  void setFrequencyData(List<double> newFrequencyData) {
    fftData.value = newFrequencyData;
    refresh();
  }

  void setAutocorrelationData(List<double> newCorrelationData) {
    autocorrelationData.value = newCorrelationData;
    refresh();
  }

  void setHPSData(List<double> newHPSData) {
    hpsData.value = newHPSData;
    refresh();
  }

  void addZeroCrossingData(double newZeroCrossingData) {
    zeroCrossingData.add(newZeroCrossingData);
    setNumberOfZeroCrossingData();
    refresh();
  }

  void setNumberOfZeroCrossingData() {
    if (zeroCrossingData.length > 200) {
      zeroCrossingData.value =
          zeroCrossingData.sublist(zeroCrossingData.length - 200);
    }
  }

  void setNumberOfWaveData() {
    if (waveData.length > waveDataLength.value) {
      if (kDebugMode) {
        print(
            'waveData length exceeded ${waveDataLength.value}: ${waveData.length}');
      }
      waveData.value = waveData.sublist(waveData.length - waveDataLength.value);
    }
  }

  void addVisibleSamples(List<double> newVisibleSamples) {
    visibleSamples.addAll(newVisibleSamples);

    setNumberOfVisibleDataPoints();
    update();
  }

  void addHPSVisibleSamples(List<double> newVisibleSamples) {
    hpsVisibleData.addAll(newVisibleSamples);

    setNumberOfVisibleHPSDataPoints();
    update();
  }

  void addAutocorrelationVisibleSamples(double newVisibleSamples) {
    autocorrelationVisibleData.add(newVisibleSamples);

    setNumberOfVisibleAutocorrelationDataPoints();
    update();
  }

  void addVisibleSample(double newVisibleSample) {
    visibleSamples.add(newVisibleSample);
    if (kDebugMode) {
      print('Added $newVisibleSample to frequencies');
    }

    setNumberOfVisibleDataPoints();
    update();
  }

  void setNumberOfVisibleDataPoints() {
    if (visibleSamples.length > 200) {
      visibleSamples.value = visibleSamples.sublist(
          visibleSamples.length - 200, visibleSamples.length);
    }
  }

  void setNumberOfVisibleHPSDataPoints() {
    if (hpsVisibleData.length > 200) {
      if (kDebugMode) {
        print('Setting visible data length back to 200');
      }
      hpsVisibleData.value = hpsVisibleData.sublist(
          hpsVisibleData.length - 200, hpsVisibleData.length);
    }
  }

  void setNumberOfVisibleAutocorrelationDataPoints() {
    if (autocorrelationVisibleData.length > 200) {
      if (kDebugMode) {
        print('Setting visible data length back to 200');
      }
      autocorrelationVisibleData.value = autocorrelationVisibleData.sublist(
          autocorrelationVisibleData.length - 200,
          autocorrelationVisibleData.length);
    }
  }

  double valueToDisplay(double value, bool toLog) {
    return toLog ? log(value) / log(2) : value;
  }

  List<FlSpot> dataToSpots(List<double> data, bool capped, bool log) {
    TuningController tuningController = Get.find();
    List<FlSpot> result = [];
    if (capped) {
      data.asMap().forEach(
        (key, value) {
          if (value >
              tuningController.targetFrequency +
                  tuningController.frequencyRange) {
            result.add(FlSpot(
                key.toDouble(),
                valueToDisplay(
                    tuningController.targetFrequency +
                        tuningController.frequencyRange,
                    log)));
          } else if (value <
              tuningController.targetFrequency -
                  tuningController.frequencyRange) {
            result.add(FlSpot(
                key.toDouble(),
                valueToDisplay(
                    tuningController.targetFrequency -
                        tuningController.frequencyRange,
                    log)));
          } else {
            result.add(FlSpot(key.toDouble(), valueToDisplay(value, log)));
          }
        },
      );
      return result;
    } else {
      data.asMap().forEach(
        (key, value) {
          result.add(FlSpot(key.toDouble(), value.toDouble()));
        },
      );
      return result;
    }
  }

  void applyFilterToFft(List<double> filter) {
    fftData.value = fftData.map((element) => element).toList();
  }

  double applyHamming(int bin, int lowerBound, int upperBound, int bandwidth) {
    return 0.54 - 0.46 * cos(2 * pi * bin / (fftData.length - 1));
  }
}
