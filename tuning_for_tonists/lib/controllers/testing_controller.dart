import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:tuning_for_tonists/controllers/mic_technical_data_controller.dart';
import 'package:tuning_for_tonists/controllers/microphone_controller.dart';

class TestingController extends GetxController {
  Logger logger = Logger(filter: DevelopmentFilter());
  final guitarBasePath = "guitar";
  Rx<String> _currentAudioFile = ''.obs;
  List<String> guitarAudioFilePaths = [];
  final MicTechnicalDataController micTechnicalDataController = Get.find();

  String get currentAudioFile => _currentAudioFile.value;

  set currentAudioFile(String newAudioFile) {
    _currentAudioFile = newAudioFile.obs;
  }

  Future<Uint8List> loadAudioFile(String path) async {
    if (path == "") {
      final ByteData data = await rootBundle.load(guitarAudioFilePaths.first);
      return data.buffer.asUint8List();
    }
    final ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

  Future<Uint8List> loadCurrentAudioFile() async {
    return loadAudioFile(currentAudioFile);
  }

  Future<void> _initGuitarAssets() async {
    final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final guitarAssetPaths = assetManifest
        .listAssets()
        .where((string) =>
            string.startsWith("assets/samples/$guitarBasePath") &&
            string.endsWith(".mp3"))
        .toList();
    guitarAudioFilePaths = guitarAssetPaths;
  }

  Future<void> initAssets() async {
    await _initGuitarAssets();
  }

  Stream<Uint8List> createAudioFileStream(Uint8List audioBytes,
      {Duration delay = const Duration(milliseconds: 100),
      int bufferLength = 1024}) {
    List<int> buffer = audioBytes.toList();
    // var buffer = <int>[];

    var streamController = StreamController<Uint8List>();
    // streamController.add(audioBytes);
    Timer.periodic(delay, (timer) {
      // logger.d(
      //     "Emitting from timer within stream! ${timer.tick}/${buffer.length ~/ bufferLength}");
      if (buffer.isEmpty || timer.tick >= buffer.length ~/ bufferLength) {
        logger.d("Cancelling stream! ${timer.tick}");
        timer
            .cancel(); // Cancel the timer once the entire audio has been buffered
        streamController.add(Uint8List.fromList(buffer
            .sublist(bufferLength * timer.tick))); // Emit the buffered data
        streamController.close(); // Close the controller after emitting
      } else {
        streamController.add(Uint8List.fromList(buffer.sublist(
            bufferLength * timer.tick, bufferLength * (timer.tick + 1))));
        // audioBytes[bufferLength]); // Buffer the next chunk of audio data
      }
    });
    return streamController.stream;
  }

  void processAudioStream(Stream<Uint8List> audioStream) {
    audioStream.listen((audioChunk) {
      // Perform your analysis or manipulation on the audioChunk here
      logger.d('Received audio chunk: ${audioChunk.length} bytes');
    }, onError: (error) {
      logger.d('Error occurred: $error');
      MicrophoneController microphoneController = Get.find();
      microphoneController.controlMicStream(command: Command.stop);
    }, onDone: () {
      logger.d('Audio stream completed.');
      MicrophoneController microphoneController = Get.find();
      microphoneController.controlMicStream(command: Command.stop);
    });
  }

  void test() async {
    // Load the audio file
    Uint8List audioBytes = await loadAudioFile('assets/audio_file.mp3');

    // Create a stream from the audio file with custom delay and buffer length
    Stream<Uint8List> audioStream = createAudioFileStream(audioBytes,
        delay: const Duration(milliseconds: 50), bufferLength: 512);

    // Process the audio stream
    processAudioStream(audioStream);
  }
}
