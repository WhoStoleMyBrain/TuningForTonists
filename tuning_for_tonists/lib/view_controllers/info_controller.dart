import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InfoController extends GetxController {
  final title = 'Info';

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
      print('>>> InfoController init');
    }
    super.onInit();
  }

  @override
  void onReady() {
    if (kDebugMode) {
      print('>>> InfoController ready');
    }
    super.onReady();
  }

  @override
  void onClose() {
    if (kDebugMode) {
      print('>>> InfoController close');
    }
    super.onClose();
  }
}
