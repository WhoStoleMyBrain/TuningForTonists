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

  bool isRecording = false;
  bool memRecordingState = false;
  bool isActive = false;
  Function calculateDisplayData;

  // Mandatory
  @override
  void onDetached() {
    print('HomeController - onDetached called');
    if (isActive) {
      memRecordingState = isRecording;
      controlMicStream(command: Command.stop);
      isActive = false;
    }
  }

  // Mandatory
  @override
  void onInactive() {
    print('HomeController - onInative called');
    if (isActive) {
      memRecordingState = isRecording;
      controlMicStream(command: Command.stop);
      isActive = false;
    }
  }

  // Mandatory
  @override
  void onPaused() {
    print('HomeController - onPaused called');
    if (isActive) {
      memRecordingState = isRecording;
      controlMicStream(command: Command.stop);
      isActive = false;
    }
  }

  // Mandatory
  @override
  void onResumed() {
    print('HomeController - onResumed called');
    isActive = true;
    controlMicStream(command: memRecordingState ? Command.start : Command.stop);
  }

  // Optional
  @override
  Future<bool> didPushRoute(String route) {
    print('HomeController - the route $route will be open');
    return super.didPushRoute(route);
  }

  // Optional
  @override
  Future<bool> didPopRoute() {
    print('HomeController - the current route will be closed');
    return super.didPopRoute();
  }

  // Optional
  @override
  void didChangeMetrics() {
    print('HomeController - the window size did change');
    super.didChangeMetrics();
  }

  // Optional
  @override
  void didChangePlatformBrightness() {
    print('HomeController - platform change ThemeMode');
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
      !isRecording ? await _startListening() : _stopListening();

  Future<bool> _startListening() async {
    stream = await MicrophoneHelper.getMicStream();
    // setState(() {
    isActive = true;
    isRecording = true;
    // });
    listener = stream!.listen((data) => calculateDisplayData(data));
    return true;
  }

  bool _stopListening() {
    if (!isRecording) return false;
    listener.cancel();
    // setState(() {
    isActive = false;
    isRecording = false;
    // });
    return true;
  }

  @override
  void dispose() {
    if (isRecording) {
      listener.cancel();
      isActive = false;
      isRecording = false;
    }
    super.dispose();
  }
}
