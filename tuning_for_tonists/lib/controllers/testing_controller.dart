import 'dart:io';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tuning_for_tonists/controllers/mic_technical_data_controller.dart';

class TestingController extends GetxController {
  final guitarBasePath = "/guitar";
  final MicTechnicalDataController micTechnicalDataController = Get.find();

  // load all audio files
  // order audio files by note and octave and stuff -> need basically any note
  // for note: need also a frequency, that I am expecting
  // maybe external python analysis script?
  final _player = AudioPlayer();
  void initFiles() async {
    final testFile = File("assets/samples/guitar/A2.mp3");
    final testFileAudio = await testFile.readAsBytes();
  }

  Stream<Uint8List> streamFile(String fileName) async* {
    final testFile = File(fileName);
    final fileContent = await testFile.readAsBytes();
    var bufferSize = micTechnicalDataController.bufferSize;
    var sampleRate = micTechnicalDataController.samplesPerSecond;
    var durationForBuffer = 100 * bufferSize ~/ sampleRate;
    for (int chunkSize = 0;
        chunkSize <= fileContent.length;
        chunkSize += bufferSize) {
      await Future.delayed(Duration(milliseconds: 500));
    }
  }
}
