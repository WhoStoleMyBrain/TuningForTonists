import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:mic_stream/mic_stream.dart';
import 'package:tuning_for_tonists/controllers/calculation_controller.dart';
import 'package:tuning_for_tonists/controllers/testing_controller.dart';
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

  static Future<Stream<Uint8List>?> getMicStream(
      {StreamSource source = StreamSource.microphone}) async {
    switch (source) {
      case StreamSource.microphone:
        MicStream.shouldRequestPermission(true);
        Stream<Uint8List> stream = MicStream.microphone(
            audioSource: micInitializationValuesController.audioSource.value,
            sampleRate: micInitializationValuesController.sampleRate,
            channelConfig:
                micInitializationValuesController.channelConfig.value,
            audioFormat: micInitializationValuesController.audioFormat.value);
        return stream;
      case StreamSource.audioFile:
        TestingController testingController = Get.find();
        if (testingController.useSyntheticTone.isTrue) {
          return testingController.createSyntheticToneStream(
              frequency: testingController.syntheticFrequency.value,
              sampleRate: micInitializationValuesController.sampleRate);
        }
        Uint8List audioBytes = await testingController.loadCurrentAudioFile();
        MicTechnicalDataController micTechnicalDataController = Get.find();
        Stream<Uint8List> audioStream = testingController.createAudioFileStream(
            audioBytes,
            delay: Duration(
                microseconds: 1000000 ~/
                    (micInitializationValuesController.sampleRate *
                        micTechnicalDataController.bytesPerSample)),
            bufferLength: micTechnicalDataController.bufferSize);
        return audioStream;
    }
  }

  static Future<void> setMicTechnicalData() async {
    var bytesPerSample = (await MicStream.bitDepth) ~/ 8;
    var samplesPerSecond = (await MicStream.sampleRate);
    var bufferSize = (await MicStream.bufferSize);
    micTechnicalDataController.setMicTechnicalData(
        bytesPerSample, samplesPerSecond, bufferSize);
    calculationController.hanningWindow = samplesPerSecond ~/ 2;
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
    List<double> waveData = [];
    final byteData =
        samples.buffer.asByteData(samples.offsetInBytes, samples.lengthInBytes);
    for (int i = 0; i + 1 < byteData.lengthInBytes; i += 2) {
      final sample = byteData.getInt16(i, Endian.little);
      waveData.add(sample / 32768.0);
    }

    return waveData;
  }

  static List<double> calculateWaveData(dynamic samples) {
    MicrophoneController microphoneController = Get.find();
    if (microphoneController.streamSource == StreamSource.audioFile) {
      if (samples is List<double>) {
        return samples;
      }
      if (samples is Uint8List) {
        return List.from(samples);
      }
    }
    if (samples is! Uint8List) {
      return [];
    }
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

  static void setSyntheticTechnicalData(
      {required int bytesPerSample,
      required int samplesPerSecond,
      required int bufferSize}) {
    micTechnicalDataController.setMicTechnicalData(
        bytesPerSample, samplesPerSecond, bufferSize);
    calculationController.hanningWindow = samplesPerSecond ~/ 2;
  }

  static void stopMicrophone() {
    MicrophoneController microphoneController = Get.find();
    microphoneController.controlMicStream(command: Command.stop);
  }
}
