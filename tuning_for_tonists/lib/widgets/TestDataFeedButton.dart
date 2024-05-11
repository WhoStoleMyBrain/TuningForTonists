import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/controllers/microphone_controller.dart';
import 'package:tuning_for_tonists/controllers/performance_controller.dart';
import 'package:tuning_for_tonists/controllers/testing_controller.dart';

class TestDataFeedButton extends StatefulWidget {
  const TestDataFeedButton({super.key});

  @override
  State<TestDataFeedButton> createState() => _TestDataFeedButtonState();
}

class _TestDataFeedButtonState extends State<TestDataFeedButton> {
  // MicrophoneController microphoneController = Get.find();
  PerformanceController performanceController = Get.find();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TestingController>(builder: (testingController) {
      return GetBuilder<MicrophoneController>(
        builder: (microphoneController) => FloatingActionButton(
          onPressed: () {
            performanceController.resetCalculationDuration();
            // microphoneController.calculateDisplayData =
            microphoneController.controlMicStream();
          },
          tooltip: (microphoneController.isRecording.isTrue)
              ? "Stop recording"
              : "Start recording",
          child: (microphoneController.isRecording.isTrue)
              ? const Icon(Icons.stop)
              : const Icon(Icons.keyboard_voice),
        ),
      );
    });
  }
}
