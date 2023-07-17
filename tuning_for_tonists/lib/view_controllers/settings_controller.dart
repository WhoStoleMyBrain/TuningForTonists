import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class SettingsController extends GetxController {
  final title = 'Settings';

  var scaffoldKey = GlobalKey<ScaffoldState>();

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  void closeDrawer() {
    scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  void onInit() {
    print('>>> SettingsController init');
    super.onInit();
  }

  @override
  void onReady() {
    print('>>> SettingsController ready');
    super.onReady();
  }

  @override
  void onClose() {
    print('>>> SettingsController close');
    super.onClose();
  }
}
