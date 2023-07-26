import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/routes.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Tuning for Tonists'),
          ),
          ListTile(
            title: const Text('Home'),
            tileColor:
                Get.currentRoute == Routes.home ? Colors.grey[300] : null,
            onTap: () {
              if (kDebugMode) {
                print(Get.currentRoute);
              }
              Get.back();
              Get.offNamed(Routes.home);
            },
          ),
          ListTile(
            title: const Text('Mic Details'),
            tileColor:
                Get.currentRoute == Routes.micDetail ? Colors.grey[300] : null,
            onTap: () {
              Get.back();
              Get.offNamed(Routes.micDetail);
            },
          ),
          ListTile(
            title: const Text('Settings'),
            tileColor:
                Get.currentRoute == Routes.settings ? Colors.grey[300] : null,
            onTap: () {
              Get.back();
              Get.offNamed(Routes.settings);
            },
          ),
          ListTile(
            title: const Text('Info'),
            tileColor:
                Get.currentRoute == Routes.info ? Colors.grey[300] : null,
            onTap: () {
              Get.back();
              Get.offNamed(Routes.info);
            },
          ),
          ListTile(
            title: const Text('Advanced Microphone'),
            tileColor: Get.currentRoute == Routes.advancedMicData
                ? Colors.grey[300]
                : null,
            onTap: () {
              Get.back();
              Get.offNamed(Routes.advancedMicData);
            },
          ),
        ],
      ),
    );
  }
}
