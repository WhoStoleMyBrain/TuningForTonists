import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class PerformanceController extends GetxController {
  final RxList<double> calculationDuration = <double>[0].obs;
  final Rx<int> calculationDurationLength = 200.obs;

  void addCalculationDurationList(List<double> newCalculationDuration) {
    calculationDuration.addAll(newCalculationDuration);
    setNumberOfCalculationDurationData();
    calculationDuration.refresh();
    update();
  }

  void addCalculationDuration(double newCalculationDuration) {
    calculationDuration.add(newCalculationDuration);
    setNumberOfCalculationDurationData();
    calculationDuration.refresh();
    update();
  }

  void resetCalculationDuration() {
    calculationDuration.value = <double>[0].obs;
  }

  void setNumberOfCalculationDurationData() {
    if (calculationDuration.length > calculationDurationLength.value) {
      if (kDebugMode) {
        print(
            'waveData length exceeded ${calculationDurationLength.value}: ${calculationDuration.length}');
      }
      calculationDuration.value = calculationDuration.sublist(
          calculationDuration.length - calculationDurationLength.value);
    }
  }

  double getAverageCalculationDuration() {
    if (calculationDuration.isEmpty) {
      return 0;
    }
    return calculationDuration
            .reduce((previousValue, element) => previousValue + element) /
        calculationDuration.length.toDouble();
  }
}
