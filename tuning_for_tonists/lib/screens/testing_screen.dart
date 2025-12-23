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

  Logger logger = Logger(filter: DevelopmentFilter());

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
