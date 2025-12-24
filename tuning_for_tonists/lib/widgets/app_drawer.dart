import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/constants/app_colors.dart';

import '../constants/routes.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Color selectedColor() {
    return AppColors.onBackgroundColor;
  }

  Widget getListTile(String name, String route) {
    return ListTile(
      selectedColor: AppColors.white,
      textColor: AppColors.onPrimaryColor,
      title: Text(name),
      tileColor: Get.currentRoute == route ? selectedColor() : null,
      onTap: () {
        if (kDebugMode) {
          print(Get.currentRoute);
        }
        Get.back();
        Get.offNamed(route);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.backgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            child: Text('Tuning for Tonists \nNavigation'),
          ),
          getListTile('Home', Routes.home),
          getListTile('Mic Details', Routes.micDetail),
          getListTile('Settings', Routes.settings),
          getListTile('Info', Routes.info),
          getListTile('Advanced Microphone', Routes.advancedMicData),
          getListTile('Knowledgebase', Routes.knowledgebase),
          getListTile('Testing', Routes.testing),
        ],
      ),
    );
  }
}
