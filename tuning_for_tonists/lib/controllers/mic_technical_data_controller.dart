import 'package:get/get.dart';

import '../models/mic_technical_data.dart';

class MicTechnicalDataController extends GetxController {
  Rx<MicTechnicalData>? micTechnicalData;
  void setMicTechnicalData(
      int bytesPerSample, int samplesPerSecond, int bufferSize) {
    micTechnicalData = MicTechnicalData(
            bytesPerSample: bytesPerSample,
            samplesPerSecond: samplesPerSecond,
            bufferSize: bufferSize)
        .obs;
  }

  int get samplesPerSecond =>
      micTechnicalData == null ? 0 : micTechnicalData!.value.samplesPerSecond;
  int get bytesPerSample =>
      micTechnicalData == null ? 0 : micTechnicalData!.value.bytesPerSample;
  int get bufferSize =>
      micTechnicalData == null ? 0 : micTechnicalData!.value.bufferSize;
}
