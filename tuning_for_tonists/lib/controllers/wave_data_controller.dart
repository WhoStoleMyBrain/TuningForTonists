import 'dart:math';

import 'package:get/get.dart';

class WaveDataController extends GetxController {
  Rx<List<int>>? currentSamples;
  Rx<List<double>>? fftCurrentSamples;
  Rx<List<int>>? visibleSamples;
  Rx<int>? localMax;
  Rx<int>? localMin;

  void addCurrentSamples(List<int> newCurrentSamples) {
    currentSamples?.value = newCurrentSamples;
  }

  void recalulateMinMax() {
    localMax = visibleSamples?.value.reduce(max).obs;
    localMin = visibleSamples?.value.reduce(min).obs;
    if ((localMax?.value ?? 1) < 3) {
      localMax?.value = 2;
    }
    if ((localMin?.value ?? 0) < 1) {
      localMin?.value = 1;
    }
  }
}
