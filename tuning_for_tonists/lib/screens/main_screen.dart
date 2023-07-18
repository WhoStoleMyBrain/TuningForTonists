import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../view_controllers/home_controller.dart';
import '../widgets/app_drawer.dart';
import '../widgets/mic_calculation_widget.dart';

class MainScreen extends GetView<HomeController> {
  /// Calculate the wave data from the input mic stream.

  Widget getMicDisplay() {
    return const Column(
      children: [
        Text('Text before calculation Widget'),
        MicData(
          child: Text('Displaying data...'),
        )
      ],
    );
  }

  Future<bool> checkMicSettingsData() async {
    return false;
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
