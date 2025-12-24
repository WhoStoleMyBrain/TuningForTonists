import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../constants/app_colors.dart';
import '../controllers/testing_controller.dart';
import '../view_controllers/info_controller.dart';
import '../widgets/test_data_feed_button.dart';
import '../widgets/app_drawer.dart';
import '../widgets/mic_stream_control_button.dart';

class TestingScreen extends GetView<InfoController> {
  TestingScreen({super.key});

  final Logger logger = Logger(filter: DevelopmentFilter());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      appBar: AppBar(
          title: const Text('Testing'),
          leading: IconButton(
            icon: const Icon(
              Icons.menu_sharp,
              color: AppColors.onPrimaryColor,
            ),
            onPressed: () => controller.openDrawer(),
          )),
      body: GetBuilder<TestingController>(builder: (testingController) {
        return Center(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Use synthetic tone'),
                value: testingController.useSyntheticTone.value,
                onChanged: (enabled) =>
                    testingController.setUseSyntheticTone(enabled),
              ),
              if (testingController.useSyntheticTone.value)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: DropdownButton<double>(
                    value: testingController.syntheticFrequency.value,
                    isExpanded: true,
                    items: testingController.syntheticFrequencies
                        .map((frequency) => DropdownMenuItem<double>(
                              value: frequency,
                              child: Text('${frequency.toStringAsFixed(1)} Hz'),
                            ))
                        .toList(),
                    onChanged: (frequency) {
                      if (frequency != null) {
                        testingController.setSyntheticFrequency(frequency);
                      }
                    },
                  ),
                ),
              ...testingController.guitarAudioFilePaths
                  .map((e) => Text(e))
                  .toList(),
              ElevatedButton(
                  onPressed: () async {
                    await testingController.initAssets();
                    logger.d(
                        "all Audio Files: ${testingController.guitarAudioFilePaths}");
                  },
                  child: const Text("Output found files!"))
            ],
          ),
        );
      }),
      drawer: const AppDrawer(),
      floatingActionButton: const Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TestDataFeedButton(),
          SizedBox(width: 16),
          MicStreamControlButton(),
          SizedBox(width: 16),
        ],
      ),
    );
  }
}
