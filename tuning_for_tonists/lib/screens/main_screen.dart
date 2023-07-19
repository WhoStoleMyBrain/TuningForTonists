import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/widgets/frequency_number_display.dart';
import 'package:tuning_for_tonists/widgets/mic_stream_control_button.dart';
import '../view_controllers/home_controller.dart';
import '../widgets/app_drawer.dart';

// ignore: must_be_immutable
class MainScreen extends GetView<HomeController> {
  /// Calculate the wave data from the input mic stream.

  HomeController homeController = Get.find();

  MainScreen({super.key});

  Widget getMicDisplay() {
    return Column(
      children: [
        MicStreamControlButton(),
        const Text('Displaying data...'),
        const FrequencyNumberDisplay(),
      ],
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
      drawer: AppDrawer(),
    );
  }
}
