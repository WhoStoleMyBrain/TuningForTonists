import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppDrawer extends StatelessWidget {
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
            tileColor: Get.currentRoute == '/home' ? Colors.grey[300] : null,
            onTap: () {
              print(Get.currentRoute);
              Get.back();
              Get.offNamed('/home');
            },
          ),
          ListTile(
            title: const Text('Settings'),
            tileColor:
                Get.currentRoute == '/settings' ? Colors.grey[300] : null,
            onTap: () {
              Get.back();
              Get.offNamed('/settings');
            },
          ),
          ListTile(
            title: const Text('Info'),
            tileColor: Get.currentRoute == '/info' ? Colors.grey[300] : null,
            onTap: () {
              Get.back();
              Get.offNamed('/info');
            },
          ),
        ],
      ),
    );
  }
}
