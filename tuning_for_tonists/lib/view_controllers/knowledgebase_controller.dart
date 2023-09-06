import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KnowledgebaseController extends GetxController {
  final title = 'Knowledgebase';

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
      print('>>> KnowledgebaseController init');
    }
    super.onInit();
  }

  @override
  void onReady() {
    if (kDebugMode) {
      print('>>> KnowledgebaseController ready');
    }
    super.onReady();
  }

  @override
  void onClose() {
    if (kDebugMode) {
      print('>>> KnowledgebaseController close');
    }
    super.onClose();
  }
}
