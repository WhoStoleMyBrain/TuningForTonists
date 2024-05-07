import 'package:get/get.dart';

import '../models/mic_technical_data.dart';

class MicTechnicalDataController extends GetxController {
  Rx<MicTechnicalData>? micTechnicalData;
  // WaveDataController waveDataController = Get.find();
  void setMicTechnicalData(
      int bytesPerSample, int samplesPerSecond, int bufferSize) {
    micTechnicalData = MicTechnicalData(
            bytesPerSample: bytesPerSample,
            samplesPerSecond: samplesPerSecond,
            bufferSize: bufferSize)
        .obs;
    // waveDataController.waveDataLength = samplesPerSecond ~/ 2;
    refresh();
    update();
  }

  int get samplesPerSecond =>
      micTechnicalData == null ? 1 : micTechnicalData!.value.samplesPerSecond;
  int get bytesPerSample =>
      micTechnicalData == null ? 1 : micTechnicalData!.value.bytesPerSample;
  int get bufferSize =>
      micTechnicalData == null ? 1 : micTechnicalData!.value.bufferSize;
}
