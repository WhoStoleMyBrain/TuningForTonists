import 'package:fftea/fftea.dart';
import 'package:get/get.dart';
import 'package:iirjdart/butterworth.dart';
import 'package:tuning_for_tonists/controllers/fft_controller.dart';

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
    butterworth.lowPass(4, samplesPerSecond.toDouble(), 1200);
    // butterworth.lowPass(4, 250, 50);
    FftController fftController = Get.find();
    fftController.setFft(FFT(bufferSize ~/ bytesPerSample));
    fftController.setFftLength(bufferSize ~/ bytesPerSample);
    // fftController.setFft(FFT(4096));
    // fftController.setFftLength(4096);
    refresh();
  }

  Butterworth butterworth = Butterworth();
  // butterworth.lowPass(10,
  //     micInitializationValuesController.sampleRate.value.toDouble(), 1200);

  int get samplesPerSecond =>
      micTechnicalData == null ? 0 : micTechnicalData!.value.samplesPerSecond;
  int get bytesPerSample =>
      micTechnicalData == null ? 0 : micTechnicalData!.value.bytesPerSample;
  int get bufferSize =>
      micTechnicalData == null ? 0 : micTechnicalData!.value.bufferSize;
}
