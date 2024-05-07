import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:mic_stream/mic_stream.dart';
import 'package:tuning_for_tonists/controllers/calculation_controller.dart';
import '../controllers/mic_initialization_values_controller.dart';
import '../controllers/mic_technical_data_controller.dart';
import '../controllers/microphone_controller.dart';

abstract class MicrophoneHelper {
  static final MicTechnicalDataController micTechnicalDataController =
      Get.find();
  static final MicInitializationValuesController
      micInitializationValuesController = Get.find();
  static final CalculationController calculationController = Get.find();

  static Logger logger = Logger(filter: DevelopmentFilter());

  static Future<Stream<Uint8List>?> getMicStream() async {
    MicStream.shouldRequestPermission(true);
    Stream<Uint8List> stream = MicStream.microphone(
        audioSource: micInitializationValuesController.audioSource.value,
        sampleRate: micInitializationValuesController.sampleRate.value,
        channelConfig: micInitializationValuesController.channelConfig.value,
        audioFormat: micInitializationValuesController.audioFormat.value);
    return stream;
  }

  static Future<void> setMicTechnicalData() async {
    var bytesPerSample = (await MicStream.bitDepth) ~/ 8;
    var samplesPerSecond = (await MicStream.sampleRate);
    var bufferSize = (await MicStream.bufferSize);
    micTechnicalDataController.setMicTechnicalData(
        bytesPerSample, samplesPerSecond, bufferSize);
    calculationController.hanningWindow = samplesPerSecond ~/ 2;
    // logger.d("Did in fact set hanning window!");
    // logger.d(calculationController.getHanningWindow());
  }

  static List<double> eightBitWaveDataCalculation(Uint8List samples) {
    List<double> waveData = [];
    Uint8List newSamples = samples.buffer.asUint8List(samples.offsetInBytes);
    for (int sample in newSamples) {
      double newSample = (sample - 128) / 128.0;
      waveData.add(newSample);
    }
    return waveData;
  }

  static List<double> sixteenBitWaveDataCalculation(Uint8List samples) {
    MicTechnicalDataController micTechnicalDataController = Get.find();
    List<double> waveData = [];
    List<int> newSamples = [];
    if (micTechnicalDataController.bytesPerSample == 2) {
      newSamples = samples.buffer.asUint8List(4);
    } else {
      newSamples = samples.buffer.asUint8List();
    }
    double tmpSample = 0;
    bool first = false;
    for (int sample in newSamples.sublist(1)) {
      if (sample > 128) sample -= 255;
      if (first) {
        tmpSample = sample * 128;
      } else {
        tmpSample += sample;
        tmpSample /= 32768;
        waveData.add(tmpSample.toDouble());
        tmpSample = 0;
      }
      first = !first;
    }

    return waveData;
  }

  static List<double> calculateWaveData(Uint8List samples) {
    MicInitializationValuesController micInitializationValuesController =
        Get.find();
    List<double> waveData = [];
    if (micInitializationValuesController.audioFormat.value ==
        AudioFormat.ENCODING_PCM_8BIT) {
      waveData = eightBitWaveDataCalculation(samples);
    } else if (micInitializationValuesController.audioFormat.value ==
        AudioFormat.ENCODING_PCM_16BIT) {
      waveData = sixteenBitWaveDataCalculation(samples);
    } else {
      if (kDebugMode) {
        print(
            'Major error in wave data calculation. The defined audio format ${micInitializationValuesController.audioFormat.value} is not implemented!!');
      }
    }
    return waveData;
  }

  static void stopMicrophone() {
    MicrophoneController microphoneController = Get.find();
    microphoneController.controlMicStream(command: Command.stop);
  }
}
