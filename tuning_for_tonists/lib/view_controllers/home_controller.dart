import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  int _frequencyDisplay = 1;

  int get frequencyDisplay => _frequencyDisplay;

  set frequencyDisplay(int newValue) {
    if (newValue > 3 || newValue < 1) {
      if (kDebugMode) {
        print(
            'tried to set frequency display to a value higher than 2 or lower than 1, which is not supported');
      }
    } else {
      if (kDebugMode) {
        print(
            'set frequencydisplay to new value: $newValue from old value: $_frequencyDisplay');
      }
      _frequencyDisplay = newValue;
      refresh();
      update();
    }
  }

  bool canReduceFrequencyDisplay() {
    if (_frequencyDisplay <= 1) {
      return false;
    } else {
      return true;
    }
  }

  bool canIncreaseFrequencyDisplay() {
    if (_frequencyDisplay >= 3) {
      return false;
    } else {
      return true;
    }
  }

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  void closeDrawer() {
    scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  void onInit() {
    if (kDebugMode) {
      print('>>> HomeController init');
    }
    super.onInit();
  }

  @override
  void onReady() {
    if (kDebugMode) {
      print('>>> HomeController ready');
    }
    super.onReady();
  }
}
