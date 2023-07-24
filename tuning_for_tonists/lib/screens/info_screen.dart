import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/view_controllers/info_controller.dart';

import '../widgets/app_drawer.dart';

class InfoScreen extends GetView<InfoController> {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      appBar: AppBar(
          title: const Text('Info'),
          leading: IconButton(
            icon: const Icon(Icons.menu_sharp),
            onPressed: () => controller.openDrawer(),
          )),
      body: const Center(
        child: Column(
          children: [Text.rich(TextSpan(text: 'Info Screen'))],
        ),
      ),
      drawer: const AppDrawer(),
    );
  }
}
