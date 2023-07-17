import 'dart:async';
import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tuning_for_tonists/helpers/get_mic_stream.dart';

enum Command {
  start,
  stop,
  change,
}

class MicData extends StatefulWidget {
  const MicData(
      {super.key, required this.calculateDisplayData, required this.child});
  final Function? calculateDisplayData;
  final Widget child;
  @override
  State<MicData> createState() => _MicDataState();
}

class _MicDataState extends State<MicData>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Stream? stream;
  late StreamSubscription listener;

  bool isRecording = false;
  bool memRecordingState = false;
  late bool isActive;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setState(() {
      initPlatformState();
    });
  }

  /// Responsible for switching between recording / idle state
  void _controlMicStream({Command command = Command.change}) async {
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
    stream = await GetMicStream.getMicStream();
    setState(() {
      isRecording = true;
    });
    listener = stream!.listen((data) => widget.calculateDisplayData!(data));
    return true;
  }

  bool _stopListening() {
    if (!isRecording) return false;
    listener.cancel();
    setState(() {
      isRecording = false;
    });
    return true;
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;
    isActive = true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      widget.child,
      FloatingActionButton(
        onPressed: _controlMicStream,
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        tooltip: (isRecording) ? "Stop recording" : "Start recording",
        child: (isRecording)
            ? const Icon(Icons.stop)
            : const Icon(Icons.keyboard_voice),
      )
    ]);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      isActive = true;
      _controlMicStream(
          command: memRecordingState ? Command.start : Command.stop);
    } else if (isActive) {
      memRecordingState = isRecording;
      _controlMicStream(command: Command.stop);
      isActive = false;
    }
  }

  @override
  void dispose() {
    listener.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
