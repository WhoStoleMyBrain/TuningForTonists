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
    print('>>> InfoController init');
    super.onInit();
  }

  @override
  void onReady() {
    print('>>> InfoController ready');
    super.onReady();
  }

  @override
  void onClose() {
    print('>>> InfoController close');
    super.onClose();
  }
}
