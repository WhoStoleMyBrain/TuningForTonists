import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/controllers/mic_technical_data_controller.dart';
import 'package:tuning_for_tonists/controllers/tuning_controller.dart';

class WaveDataController extends GetxController {
  RxList<double> visibleSamples =
      <double>[0].obs; // strongest frequency in fft Data interval

  RxList<double> waveData = <double>[0].obs;
  RxList<double> fftData = <double>[0].obs;
  RxList<double> autocorrelationData = <double>[0].obs;

  MicTechnicalDataController micTechnicalDataController = Get.find();

  TuningController tuningController = Get.find();

  List<double> get doubleWaveData =>
      waveData.map((element) => element.toDouble()).toList();

  void addWaveData(List<double> newWaveData) {
    waveData = newWaveData.obs;
  }

  void setFrequencyData(List<double> newFrequencyData) {
    fftData = newFrequencyData.obs;
  }

  void setAutocorrelationData(List<double> newCorrelationData) {
    autocorrelationData = newCorrelationData.obs;
  }

  void setNumberOfWaveData() {
    if (waveData.length > micTechnicalDataController.bufferSize * 2) {
      print('waveData length exceeded 48000: ${waveData.length}');
      waveData = waveData
          .sublist(waveData.length - micTechnicalDataController.bufferSize * 2)
          .obs;
    }
  }

  void addVisibleSamples(List<double> newVisibleSamples) {
    newVisibleSamples.removeWhere((element) => element == 0);
    visibleSamples.addAll(newVisibleSamples);

    setNumberOfVisibleDataPoints();
    update();
  }

  void addVisibleSample(double newVisibleSample) {
    // newVisibleSamples.removeWhere((element) => element == 0);
    visibleSamples.add(newVisibleSample);

    setNumberOfVisibleDataPoints();
    update();
  }

  void setNumberOfVisibleDataPoints() {
    if (visibleSamples.length > 200) {
      if (kDebugMode) {
        print('Setting visible data length back to 200');
      }
      visibleSamples = visibleSamples
          .sublist(visibleSamples.length - 200, visibleSamples.length)
          .obs;
    }
  }

  List<FlSpot> visibleDataToSpots() {
    List<FlSpot> result = [];
    visibleSamples.asMap().forEach(
      (key, value) {
        if (value >
            tuningController.targetFrequency +
                tuningController.frequencyRange) {
          result.add(FlSpot(
              key.toDouble(),
              tuningController.targetFrequency +
                  tuningController.frequencyRange));
        } else if (value <
            tuningController.targetFrequency -
                tuningController.frequencyRange) {
          result.add(FlSpot(
              key.toDouble(),
              tuningController.targetFrequency -
                  tuningController.frequencyRange));
        } else {
          result.add(FlSpot(key.toDouble(), value));
        }
      },
    );
    return result;
  }

  List<FlSpot> waveDataToSpots() {
    List<FlSpot> result = [];
    waveData.asMap().forEach(
      (key, value) {
        result.add(FlSpot(key.toDouble(), value.toDouble()));
      },
    );
    return result;
  }

  List<FlSpot> frequencyDataToSpots() {
    List<FlSpot> result = [];
    fftData.asMap().forEach(
      (key, value) {
        result.add(FlSpot(key.toDouble(), value.toDouble()));
      },
    );
    return result;
  }

  List<FlSpot> autocorrelationDataToSpots() {
    List<FlSpot> result = [];
    autocorrelationData.asMap().forEach(
      (key, value) {
        result.add(FlSpot(key.toDouble(), value.toDouble()));
      },
    );
    return result;
  }
}
