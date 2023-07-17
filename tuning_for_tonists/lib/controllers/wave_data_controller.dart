import 'dart:math';

import 'package:get/get.dart';
import 'package:tuning_for_tonists/controllers/mic_technical_data_controller.dart';

class WaveDataController extends GetxController {
  RxList<int> currentSamples = <int>[].obs; // waveData
  RxList<double> fftCurrentSamples = <double>[].obs; // fft Data
  RxList<double> visibleSamples =
      <double>[].obs; // strongest frequency in fft Data interval
  //TODO: localMax and localMin will be either redundant or handled differently in the future.
  //TODO: therefore they must be removed
  Rx<double>? localMax;
  Rx<double>? localMin;

  void addCurrentSamples(List<int> newCurrentSamples) {
    currentSamples.addAll(newCurrentSamples);
    setNumberOfWaveDataPoints();
  }

  void addFftCurrentSamples(List<double> newFftCurrentSamples) {
    fftCurrentSamples.addAll(newFftCurrentSamples);
    setNumberOfFftDataPoints();
  }

  void addVisibleSamples(List<double> newVisibleSamples) {
    visibleSamples.addAll(newVisibleSamples);
    setNumberOfVisibleDataPoints();
  }

  void recalulateMinMax() {
    localMax = visibleSamples.reduce(max).obs;
    localMin = visibleSamples.reduce(min).obs;
    if ((localMax?.value ?? 1) < 3) {
      localMax?.value = 2;
    }
    if ((localMin?.value ?? 0) < 1) {
      localMin?.value = 1;
    }
  }

  void setNumberOfVisibleDataPoints() {
    MicTechnicalDataController micTechnicalDataController = Get.find();
    if (visibleSamples.length >
        micTechnicalDataController.samplesPerSecond * 1) {
      print(
          'Setting visible data length back to ${micTechnicalDataController.samplesPerSecond * 1}');
      visibleSamples = visibleSamples
          .sublist(
              visibleSamples.length -
                  micTechnicalDataController.samplesPerSecond * 1,
              visibleSamples.length)
          .obs;
    }
  }

  void setNumberOfFftDataPoints() {
    MicTechnicalDataController micTechnicalDataController = Get.find();
    if (fftCurrentSamples.length >
        micTechnicalDataController.samplesPerSecond * 1) {
      print(
          'Setting fft data length back to ${micTechnicalDataController.samplesPerSecond * 1}');
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
      print(
          'Setting wave data length back to ${micTechnicalDataController.samplesPerSecond * 1}');
      currentSamples = currentSamples
          .sublist(
              currentSamples.length -
                  micTechnicalDataController.samplesPerSecond * 1,
              currentSamples.length)
          .obs;
    }
  }
}
