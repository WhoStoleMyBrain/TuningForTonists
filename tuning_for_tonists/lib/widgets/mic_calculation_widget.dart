import 'dart:core';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/microphone_controller.dart';

enum Command {
  start,
  stop,
  change,
}

class MicData extends StatefulWidget {
  const MicData({super.key, required this.child});
  // final Function? calculateDisplayData;
  final Widget child;
  @override
  State<MicData> createState() => _MicDataState();
}

class _MicDataState extends State<MicData>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  MicrophoneController microphoneController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      widget.child,
      FloatingActionButton(
        onPressed: microphoneController.controlMicStream,
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        tooltip: (microphoneController.isRecording)
            ? "Stop recording"
            : "Start recording",
        child: (microphoneController.isRecording)
            ? const Icon(Icons.stop)
            : const Icon(Icons.keyboard_voice),
      )
    ]);
  }
}
