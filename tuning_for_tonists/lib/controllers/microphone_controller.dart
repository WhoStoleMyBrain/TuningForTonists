import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    listener = stream!.listen((data) => calculateDisplayData(data));
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
    await listener.cancel();
    isActive = false.obs;
    isRecording = false.obs;
    update();
    refresh();
    print('canceled stream and set everything to false');
    return true;
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
