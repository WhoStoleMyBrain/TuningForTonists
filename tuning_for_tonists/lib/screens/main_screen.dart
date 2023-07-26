import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/widgets/frequency_number_display.dart';
import 'package:tuning_for_tonists/widgets/mic_stream_control_button.dart';
import 'package:tuning_for_tonists/widgets/string_display.dart';
import '../view_controllers/home_controller.dart';
import '../widgets/app_drawer.dart';
import '../widgets/main_data_display.dart';

// ignore: must_be_immutable
class MainScreen extends GetView<HomeController> {
  /// Calculate the wave data from the input mic stream.

  HomeController homeController = Get.find();

  MainScreen({super.key});

  Widget getMicDisplay() {
    return const SingleChildScrollView(
      child: Column(
        children: [
          MainDataDisplay(),
          SizedBox(
            height: 48,
          ),
          FrequencyNumberDisplay(),
          StringDisplay(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      appBar: AppBar(
          leading: IconButton(
        icon: const Icon(Icons.menu_sharp),
        onPressed: () => controller.openDrawer(),
      )),
      body: getMicDisplay(),
      drawer: const AppDrawer(),
      floatingActionButton: const MicStreamControlButton(),
    );
  }
}
