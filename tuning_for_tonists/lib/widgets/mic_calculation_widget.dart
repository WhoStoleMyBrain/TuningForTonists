import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mic_stream/mic_stream.dart';
import '../controllers/mic_initialization_values_controller.dart';
import '../models/mic_technical_data.dart';
import '../models/wave_data.dart';

enum Command {
  start,
  stop,
  change,
}

class MicData extends StatefulWidget {
  const MicData(
      {super.key,
      required this.micInitializationValues,
      required this.calculateDisplayData,
      required this.child});
  final MicInitializationValuesController micInitializationValues;
  final Function? calculateDisplayData;
  final Widget child;
  @override
  State<MicData> createState() => _MicDataState();
}

class _MicDataState extends State<MicData>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Stream? stream;
  late StreamSubscription listener;
  WaveData waveData = WaveData();
  late MicTechnicalData micTechnicalData;

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

  // Responsible for switching between recording / idle state
  void _controlMicStream({Command command = Command.change}) async {
    print("Switching command: $command, recording: $isRecording");
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
    if (isRecording) return false;
    MicStream.shouldRequestPermission(true);
    stream = await MicStream.microphone(
        audioSource: widget.micInitializationValues.audioSource.value,
        sampleRate: widget.micInitializationValues.sampleRate.value,
        channelConfig: widget.micInitializationValues.channelConfig.value,
        audioFormat: widget.micInitializationValues.audioFormat.value);

    var bytesPerSample = (await MicStream.bitDepth)! ~/ 8;
    var samplesPerSecond = (await MicStream.sampleRate)!.toInt();
    var bufferSize = (await MicStream.bufferSize)!.toInt();
    micTechnicalData = MicTechnicalData(
        bytesPerSample: bytesPerSample,
        samplesPerSecond: samplesPerSecond,
        bufferSize: bufferSize);

    setState(() {
      isRecording = true;
    });
    waveData.visibleSamples = [];
    listener = stream!.listen((data) => widget.calculateDisplayData!(data));
    return true;
  }

  bool _stopListening() {
    if (!isRecording) return false;
    listener.cancel();
    setState(() {
      isRecording = false;
      waveData.currentSamples = null;
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
