import 'package:get/get.dart';
import 'package:iirjdart/butterworth.dart';
// import 'package:tuning_for_tonists/controllers/fft_controller.dart';

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
    // butterworth.lowPass(4, samplesPerSecond.toDouble(), 1200);

    // butterworth.bandPass(5, samplesPerSecond.toDouble(), );
    butterworthLowpass.lowPass(5, samplesPerSecond.toDouble(), 1320);
    butterworthHighpass.highPass(5, samplesPerSecond.toDouble(), 75);

    refresh();
    update();
  }

  Butterworth butterworthLowpass = Butterworth();
  Butterworth butterworthHighpass = Butterworth();

  // var window = Window.hamming(1024);

  int get samplesPerSecond =>
      micTechnicalData == null ? 0 : micTechnicalData!.value.samplesPerSecond;
  int get bytesPerSample =>
      micTechnicalData == null ? 0 : micTechnicalData!.value.bytesPerSample;
  int get bufferSize =>
      micTechnicalData == null ? 0 : micTechnicalData!.value.bufferSize;
}
