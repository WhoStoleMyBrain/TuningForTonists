import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../helpers/microphone_helper.dart';
import '../controllers/mic_initialization_values_controller.dart';
import '../controllers/mic_technical_data_controller.dart';
import '../controllers/testing_controller.dart';

enum Command {
  start,
  stop,
  change,
}

enum StreamSource {
  microphone,
  audioFile,
}

class MicrophoneController extends FullLifeCycleController
    with FullLifeCycleMixin {
  MicrophoneController({required this.calculateDisplayData});

  Stream? stream;
  late StreamSubscription listener;

  RxBool isRecording = false.obs;
  RxBool memRecordingState = false.obs;
  RxBool isActive = false.obs;
  Function calculateDisplayData;
  RxBool isCapturing = false.obs;
  RxString lastCapturePath = ''.obs;
  RxString lastCaptureStatus = ''.obs;
  BytesBuilder? _captureBuffer;
  int _captureTargetBytes = 0;

  Rx<StreamSource> _streamSource = StreamSource.microphone.obs;

  StreamSource get streamSource => _streamSource.value;

  set streamSource(StreamSource newStreamSource) {
    _streamSource = newStreamSource.obs;
    refresh();
  }

  @override
  void onDetached() {
    if (kDebugMode) {
      print('HomeController - onDetached called');
    }
    if (isActive.isTrue) {
      memRecordingState = isRecording;
      controlMicStream(command: Command.stop);
      isActive.toggle();
      update();
    }
  }

  @override
  void onInactive() {
    if (kDebugMode) {
      print('HomeController - onInative called');
    }
    if (isActive.isTrue) {
      memRecordingState = isRecording;
      controlMicStream(command: Command.stop);
      isActive.toggle();
      update();
    }
  }

  @override
  void onPaused() {
    if (kDebugMode) {
      print('HomeController - onPaused called');
    }
    if (isActive.isTrue) {
      memRecordingState = isRecording;
      controlMicStream(command: Command.stop);
      isActive.toggle();
      update();
    }
  }

  @override
  void onResumed() {
    if (kDebugMode) {
      print('HomeController - onResumed called');
    }
    isActive = true.obs;
    controlMicStream(
        command: memRecordingState.value ? Command.start : Command.stop);
    update();
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    if (kDebugMode) {
      print(
          'HomeController - the routeInformation $routeInformation was pushed');
    }
    return super.didPushRouteInformation(routeInformation);
  }

  @override
  Future<bool> didPopRoute() {
    if (kDebugMode) {
      print('HomeController - the current route will be closed');
    }
    return super.didPopRoute();
  }

  @override
  void didChangeMetrics() {
    if (kDebugMode) {
      print('HomeController - the window size did change');
    }
    super.didChangeMetrics();
  }

  @override
  void didChangePlatformBrightness() {
    if (kDebugMode) {
      print('HomeController - platform change ThemeMode');
    }
    super.didChangePlatformBrightness();
  }

  void controlMicStream({Command command = Command.change}) async {
    if (kDebugMode) {
      print("Switching command: $command, recording: $isRecording");
    }
    switch (command) {
      case Command.change:
        _changeListening();
        break;
      case Command.start:
        _startListening();
        break;
      case Command.stop:
        _stopListening();
        break;
    }
  }

  Future<bool> _changeListening() async =>
      isRecording.isFalse ? await _startListening() : await _stopListening();

  Future<bool> _startListening() async {
    stream = await MicrophoneHelper.getMicStream(source: streamSource);
    isActive = true.obs;
    isRecording = true.obs;
    listener = stream!.listen((data) {
      calculateDisplayData(data);
      if (data is Uint8List) {
        _handlePcmCapture(data);
      }
    });
    if (streamSource == StreamSource.audioFile) {
      TestingController testingController = Get.find();
      if (testingController.useSyntheticTone.isTrue) {
        MicInitializationValuesController micInitializationValuesController =
            Get.find();
        MicrophoneHelper.setSyntheticTechnicalData(
            bytesPerSample: 2,
            samplesPerSecond: micInitializationValuesController.sampleRate,
            bufferSize: testingController.syntheticFrameSize);
      } else {
        await MicrophoneHelper.setMicTechnicalData();
      }
    } else {
      await MicrophoneHelper.setMicTechnicalData();
    }
    update();
    return true;
  }

  Future<bool> _stopListening() async {
    if (isRecording.isFalse) return false;
    _stopCapture();
    await listener.cancel();
    isActive = false.obs;
    isRecording = false.obs;
    update();
    refresh();
    print('canceled stream and set everything to false');
    return true;
  }

  void startPcmCapture({int durationSeconds = 3}) {
    if (streamSource != StreamSource.microphone) {
      lastCaptureStatus.value =
          'Capture is only available when using the microphone.';
      return;
    }
    if (isRecording.isFalse) {
      lastCaptureStatus.value = 'Start the microphone stream before capturing.';
      return;
    }
    MicTechnicalDataController micTechnicalDataController = Get.find();
    if (micTechnicalDataController.bytesPerSample == 0 ||
        micTechnicalDataController.samplesPerSecond == 0) {
      lastCaptureStatus.value =
          'Microphone technical data not initialized yet.';
      return;
    }
    _captureTargetBytes = micTechnicalDataController.samplesPerSecond *
        micTechnicalDataController.bytesPerSample *
        durationSeconds;
    _captureBuffer = BytesBuilder(copy: false);
    isCapturing.value = true;
    lastCaptureStatus.value = 'Capturing ${durationSeconds}s of raw PCM...';
  }

  void _handlePcmCapture(Uint8List data) {
    if (isCapturing.isFalse || _captureBuffer == null) return;
    _captureBuffer!.add(data);
    if (_captureBuffer!.length >= _captureTargetBytes) {
      _finalizeCapture();
    }
  }

  Future<void> _finalizeCapture() async {
    if (_captureBuffer == null) return;
    final bytes = _captureBuffer!.takeBytes();
    _captureBuffer = null;
    isCapturing.value = false;
    final directory = await getApplicationDocumentsDirectory();
    MicTechnicalDataController micTechnicalDataController = Get.find();
    final fileName = 'capture_${micTechnicalDataController.samplesPerSecond}hz_'
        '${micTechnicalDataController.bytesPerSample * 8}bit_mono_'
        '${DateTime.now().millisecondsSinceEpoch}.pcm';
    final filePath = path.join(directory.path, fileName);
    await File(filePath).writeAsBytes(bytes);
    lastCapturePath.value = filePath;
    lastCaptureStatus.value = 'Saved raw PCM to $filePath';
  }

  void _stopCapture() {
    _captureBuffer = null;
    _captureTargetBytes = 0;
    isCapturing.value = false;
  }

  @override
  void dispose() {
    if (isRecording.isTrue) {
      listener.cancel();
      isActive.isFalse ? isActive.toggle() : null;
      isRecording.isFalse ? isRecording.toggle() : null;
      update();
    }
    super.dispose();
  }

  @override
  void onHidden() {
    if (kDebugMode) {
      print('HomeController - onHidden called');
    }
  }
}
