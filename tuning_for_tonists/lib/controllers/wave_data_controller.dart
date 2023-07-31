import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/controllers/mic_technical_data_controller.dart';
import 'package:tuning_for_tonists/controllers/tuning_controller.dart';

class WaveDataController extends GetxController {
  RxList<double> visibleSamples =
      <double>[0].obs; // strongest frequency in fft Data interval
  RxList<double> hpsVisibleData = <double>[0].obs;
  RxList<double> autocorrelationVisibleData = <double>[0].obs;

  RxList<double> waveData = RxList.filled(2048, 0);
  RxList<double> fftData = <double>[0].obs;
  RxList<double> autocorrelationData = <double>[1].obs;
  RxList<double> hpsData = <double>[0].obs;
  RxList<double> zeroCrossingData = <double>[0].obs;

  MicTechnicalDataController micTechnicalDataController = Get.find();

  List<double> get doubleWaveData =>
      waveData.map((element) => element.toDouble()).toList();

  void addWaveData(List<double> newWaveData) {
    // waveData = newWaveData.obs;
    waveData.addAll(newWaveData);
    setNumberOfWaveData();
    refresh();
    update();
  }

  void setFrequencyData(List<double> newFrequencyData) {
    fftData = newFrequencyData.obs;
    refresh();
  }

  void setAutocorrelationData(List<double> newCorrelationData) {
    autocorrelationData = newCorrelationData.obs;
    refresh();
  }

  void setHPSData(List<double> newHPSData) {
    hpsData = newHPSData.obs;
    refresh();
  }

  void addZeroCrossingData(double newZeroCrossingData) {
    zeroCrossingData.add(newZeroCrossingData);
    setNumberOfZeroCrossingData();
    refresh();
  }

  void setNumberOfZeroCrossingData() {
    if (zeroCrossingData.length > 200) {
      zeroCrossingData =
          zeroCrossingData.sublist(zeroCrossingData.length - 200).obs;
    }
  }

  void setNumberOfWaveData() {
    if (waveData.length > 2048) {
      // if (waveData.length > micTechnicalDataController.bufferSize * 2) {
      if (kDebugMode) {
        print('waveData length exceeded ${2048}: ${waveData.length}');
      }
      waveData = waveData.sublist(waveData.length - 2048).obs;
      // MicrophoneHelper.stopMicrophone();
      // waveData = waveData
      //     .sublist(waveData.length - micTechnicalDataController.bufferSize * 2)
      //     .obs;
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

    setNumberOfVisibleDataPoints();
    update();
  }

  void setNumberOfVisibleDataPoints() {
    if (visibleSamples.length > 200) {
      visibleSamples = visibleSamples
          .sublist(visibleSamples.length - 200, visibleSamples.length)
          .obs;
    }
  }

  void setNumberOfVisibleHPSDataPoints() {
    if (hpsVisibleData.length > 200) {
      if (kDebugMode) {
        print('Setting visible data length back to 200');
      }
      hpsVisibleData = hpsVisibleData
          .sublist(hpsVisibleData.length - 200, hpsVisibleData.length)
          .obs;
    }
  }

  void setNumberOfVisibleAutocorrelationDataPoints() {
    if (autocorrelationVisibleData.length > 200) {
      if (kDebugMode) {
        print('Setting visible data length back to 200');
      }
      autocorrelationVisibleData = autocorrelationVisibleData
          .sublist(autocorrelationVisibleData.length - 200,
              autocorrelationVisibleData.length)
          .obs;
    }
  }

  // List<FlSpot> visibleDataToSpots(bool capped) {
  //   TuningController tuningController = Get.find();
  //   List<FlSpot> result = [];
  //   if (capped) {
  //     visibleSamples.asMap().forEach(
  //       (key, value) {
  //         if (value >
  //             tuningController.targetFrequency +
  //                 tuningController.frequencyRange) {
  //           result.add(FlSpot(
  //               key.toDouble(),
  //               tuningController.targetFrequency +
  //                   tuningController.frequencyRange));
  //         } else if (value <
  //             tuningController.targetFrequency -
  //                 tuningController.frequencyRange) {
  //           result.add(FlSpot(
  //               key.toDouble(),
  //               tuningController.targetFrequency -
  //                   tuningController.frequencyRange));
  //         } else {
  //           result.add(FlSpot(key.toDouble(), value));
  //         }
  //       },
  //     );
  //     return result;
  //   } else {
  //     visibleSamples.asMap().forEach(
  //       (key, value) {
  //         result.add(FlSpot(key.toDouble(), value.toDouble()));
  //       },
  //     );
  //     return result;
  //   }
  // }

  // List<FlSpot> hpsVisibleDataToSpots(bool capped) {
  //   TuningController tuningController = Get.find();
  //   List<FlSpot> result = [];
  //   if (capped) {
  //     hpsVisibleData.asMap().forEach(
  //       (key, value) {
  //         if (value >
  //             tuningController.targetFrequency +
  //                 tuningController.frequencyRange) {
  //           result.add(FlSpot(
  //               key.toDouble(),
  //               tuningController.targetFrequency +
  //                   tuningController.frequencyRange));
  //         } else if (value <
  //             tuningController.targetFrequency -
  //                 tuningController.frequencyRange) {
  //           result.add(FlSpot(
  //               key.toDouble(),
  //               tuningController.targetFrequency -
  //                   tuningController.frequencyRange));
  //         } else {
  //           result.add(FlSpot(key.toDouble(), value));
  //         }
  //       },
  //     );
  //     return result;
  //   } else {
  //     hpsVisibleData.asMap().forEach(
  //       (key, value) {
  //         result.add(FlSpot(key.toDouble(), value.toDouble()));
  //       },
  //     );
  //     return result;
  //   }
  // }

  // List<FlSpot> waveDataToSpots() {
  //   List<FlSpot> result = [];
  //   waveData.asMap().forEach(
  //     (key, value) {
  //       result.add(FlSpot(key.toDouble(), value.toDouble()));
  //     },
  //   );
  //   return result;
  // }

  // List<FlSpot> frequencyDataToSpots() {
  //   List<FlSpot> result = [];
  //   fftData.asMap().forEach(
  //     (key, value) {
  //       result.add(FlSpot(key.toDouble(), value.toDouble()));
  //     },
  //   );
  //   return result;
  // }

  // List<FlSpot> autocorrelationDataToSpots() {
  //   List<FlSpot> result = [];
  //   autocorrelationData.asMap().forEach(
  //     (key, value) {
  //       result.add(FlSpot(key.toDouble(), value.toDouble()));
  //     },
  //   );
  //   return result;
  // }

  // List<FlSpot> hpsDataToSpots() {
  //   List<FlSpot> result = [];
  //   hpsData.asMap().forEach(
  //     (key, value) {
  //       result.add(FlSpot(key.toDouble(), value.toDouble()));
  //     },
  //   );
  //   return result;
  // }

  // List<FlSpot> zeroCrossingDataToSpots(bool capped) {
  //   TuningController tuningController = Get.find();
  //   List<FlSpot> result = [];
  //   if (capped) {
  //     zeroCrossingData.asMap().forEach(
  //       (key, value) {
  //         if (value >
  //             tuningController.targetFrequency +
  //                 tuningController.frequencyRange) {
  //           result.add(FlSpot(
  //               key.toDouble(),
  //               tuningController.targetFrequency +
  //                   tuningController.frequencyRange));
  //         } else if (value <
  //             tuningController.targetFrequency -
  //                 tuningController.frequencyRange) {
  //           result.add(FlSpot(
  //               key.toDouble(),
  //               tuningController.targetFrequency -
  //                   tuningController.frequencyRange));
  //         } else {
  //           result.add(FlSpot(key.toDouble(), value));
  //         }
  //       },
  //     );
  //     return result;
  //   } else {
  //     zeroCrossingData.asMap().forEach(
  //       (key, value) {
  //         result.add(FlSpot(key.toDouble(), value.toDouble()));
  //       },
  //     );
  //     return result;
  //   }
  // }

  List<FlSpot> dataToSpots(List<double> data, bool capped) {
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
    } else {
      data.asMap().forEach(
        (key, value) {
          result.add(FlSpot(key.toDouble(), value.toDouble()));
        },
      );
      return result;
    }
  }
}
