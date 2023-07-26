import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/constants/routes.dart';
import '../view_controllers/settings_controller.dart';
import '../widgets/app_drawer.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  void navigateToTuningsPage() {
    Get.toNamed(Routes.allTunings);
  }

  @override
  Widget build(BuildContext context) {
    // TuningConfigurationsController tuningConfigurationsController = Get.find();
    return Scaffold(
      key: controller.scaffoldKey,
      appBar: AppBar(
          title: const Text('Settings'),
          leading: IconButton(
            icon: const Icon(Icons.menu_sharp),
            onPressed: () => controller.openDrawer(),
          )),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 48,
            ),
            ElevatedButton(
                onPressed: () => navigateToTuningsPage(),
                child: const Text('Set currently used tuning')),
          ],
        ),
      ),
      drawer: const AppDrawer(),
    );
  }
}
