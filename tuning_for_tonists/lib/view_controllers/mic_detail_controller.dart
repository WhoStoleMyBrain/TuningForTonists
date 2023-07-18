import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MicDetailController extends GetxController {
  final title = 'MicDetail';

  var scaffoldKey = GlobalKey<ScaffoldState>();

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  void closeDrawer() {
    scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  void onInit() {
    print('>>> MicDetailController init');
    super.onInit();
  }

  @override
  void onReady() {
    print('>>> MicDetailController ready');
    super.onReady();
  }

  @override
  void onClose() {
    print('>>> MicDetailController close');
    super.onClose();
  }
}
