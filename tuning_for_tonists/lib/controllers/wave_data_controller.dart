import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/constants/calculation_type.dart';
import '../controllers/mic_technical_data_controller.dart';
import '../controllers/tuning_controller.dart';

class WaveDataController extends GetxController {
  final RxList<double> visibleSamples =
      <double>[0].obs; // strongest frequency in fft Data interval

  Rx<int> _waveDataLength = 4096.obs;
  RxList<double> waveData = List.filled(4096, 0.0).obs;
  final RxList<double> fftData = <double>[0].obs;
  final RxList<double> autocorrelationData = <double>[1].obs;
  final RxList<double> hpsData = <double>[0].obs;
  final RxList<double> zeroCrossingData = <double>[0].obs;
  final RxDouble _peakStrength = 0.0.obs;
  Rx<CalculationType> calculationType = CalculationType.Cepstrum.obs;

  final MicTechnicalDataController micTechnicalDataController = Get.find();

  List<double> get doubleWaveData =>
      waveData.map((element) => element.toDouble()).toList();

  int get waveDataLength => _waveDataLength.value;

  set waveDataLength(int newLength) {
    _waveDataLength = newLength.obs;
    waveData = RxList.filled(_waveDataLength.value, 0, growable: true);
    refresh();
  }

  void resetVisibleData() {
    visibleSamples.addAll(RxList.filled(200, 0));
    refresh();
  }

  void addWaveData(List<double> newWaveData) {
    waveData.addAll(newWaveData);
    setNumberOfWaveData();
    refresh();
    update();
  }

  void setCalculationType(CalculationType newCalculationType) {
    calculationType = newCalculationType.obs;
    refresh();
    update();
  }

  set frequencyData(List<double> newFrequencyData) {
    fftData.value = newFrequencyData;
    refresh();
  }

  List<double> get frequencyData => fftData;

  double get peakStrength => _peakStrength.value;

  void setPeakStrength(double newPeakStrength) {
    _peakStrength.value = newPeakStrength;
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
    if (waveData.length > _waveDataLength.value) {
      waveData.value =
          waveData.sublist(waveData.length - _waveDataLength.value);
    }
  }

  void addVisibleSamples(List<double> newVisibleSamples) {
    visibleSamples.addAll(newVisibleSamples);

    setNumberOfVisibleDataPoints();
    update();
  }

  void addVisibleSample(double newVisibleSample) {
    visibleSamples.add(newVisibleSample);
    setNumberOfVisibleDataPoints();
    update();
  }

  void setNumberOfVisibleDataPoints() {
    if (visibleSamples.length > 200) {
      visibleSamples.value = visibleSamples.sublist(
          visibleSamples.length - 200, visibleSamples.length);
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
