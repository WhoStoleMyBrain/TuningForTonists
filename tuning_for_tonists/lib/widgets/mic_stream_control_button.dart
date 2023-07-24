import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/controllers/microphone_controller.dart';

class MicStreamControlButton extends StatefulWidget {
  const MicStreamControlButton({super.key});

  @override
  State<MicStreamControlButton> createState() => _MicStreamControlButtonState();
}

class _MicStreamControlButtonState extends State<MicStreamControlButton> {
  // MicrophoneController microphoneController = Get.find();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MicrophoneController>(
      builder: (microphoneController) => FloatingActionButton(
        onPressed: microphoneController.controlMicStream,
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        tooltip: (microphoneController.isRecording.isTrue)
            ? "Stop recording"
            : "Start recording",
        child: (microphoneController.isRecording.isTrue)
            ? const Icon(Icons.stop)
            : const Icon(Icons.keyboard_voice),
      ),
    );
  }
}
