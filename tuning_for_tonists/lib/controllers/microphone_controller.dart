import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../helpers/microphone_helper.dart';

enum Command {
  start,
  stop,
  change,
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

  // Mandatory
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

  // Mandatory
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

  // Mandatory
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

  // Mandatory
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

  // Optional
  @override
  Future<bool> didPushRoute(String route) {
    if (kDebugMode) {
      print('HomeController - the route $route will be open');
    }
    return super.didPushRoute(route);
  }

  // Optional
  @override
  Future<bool> didPopRoute() {
    if (kDebugMode) {
      print('HomeController - the current route will be closed');
    }
    return super.didPopRoute();
  }

  // Optional
  @override
  void didChangeMetrics() {
    if (kDebugMode) {
      print('HomeController - the window size did change');
    }
    super.didChangeMetrics();
  }

  // Optional
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
      isRecording.isFalse ? await _startListening() : _stopListening();

  Future<bool> _startListening() async {
    stream = await MicrophoneHelper.getMicStream();
    isActive = true.obs;
    isRecording = true.obs;
    listener = stream!.listen((data) => calculateDisplayData(data));
    update();
    return true;
  }

  bool _stopListening() {
    if (isRecording.isFalse) return false;
    listener.cancel();
    isActive.toggle();
    isRecording.toggle();
    update();
    return true;
  }

  @override
  void dispose() {
    if (isRecording.isTrue) {
      listener.cancel();
      isActive.toggle();
      isRecording.toggle();
      update();
    }
    super.dispose();
  }
}
