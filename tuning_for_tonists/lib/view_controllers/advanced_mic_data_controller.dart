import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdvancedMicDataController extends GetxController {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  void closeDrawer() {
    scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  void onInit() {
    if (kDebugMode) {
      print('>>> AdvancedMicController init');
    }
    super.onInit();
  }

  @override
  void onReady() {
    if (kDebugMode) {
      print('>>> AdvancedMicController ready');
    }
    super.onReady();
  }
}
