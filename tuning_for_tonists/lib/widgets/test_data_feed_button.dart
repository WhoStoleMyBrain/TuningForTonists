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
  PerformanceController performanceController = Get.find();
  TestingController testingController = Get.find();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TestingController>(builder: (testingController) {
      return GetBuilder<MicrophoneController>(
        builder: (microphoneController) => FloatingActionButton(
          heroTag: null,
          onPressed: () async {
            performanceController.resetCalculationDuration();
            microphoneController.streamSource = StreamSource.audioFile;
            if (testingController.useSyntheticTone.isFalse &&
                testingController.guitarAudioFilePaths.isEmpty) {
              await testingController.initAssets();
            }
            if (testingController.useSyntheticTone.isFalse &&
                testingController.guitarAudioFilePaths.isNotEmpty) {
              testingController.currentAudioFile =
                  testingController.guitarAudioFilePaths.first;
            }
            microphoneController.controlMicStream();
          },
          tooltip: (microphoneController.isRecording.isTrue)
              ? "Stop recording"
              : "Start recording",
          child: (microphoneController.isRecording.isTrue)
              ? const Icon(Icons.one_x_mobiledata)
              : const Icon(Icons.four_g_plus_mobiledata),
        ),
      );
    });
  }
}
