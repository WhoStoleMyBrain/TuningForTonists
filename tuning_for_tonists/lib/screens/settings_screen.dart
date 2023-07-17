import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../view_controllers/settings_controller.dart';
import '../widgets/app_drawer.dart';

class SettingsScreen extends GetView<SettingsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      appBar: AppBar(
          leading: IconButton(
        icon: const Icon(Icons.menu_sharp),
        onPressed: () => controller.openDrawer(),
      )),
      body: const Center(
        child: Column(
          children: [Text('SETTINGS')],
        ),
      ),
      drawer: AppDrawer(),
    );
  }
}
