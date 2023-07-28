import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuning_for_tonists/constants/constants.dart';
import 'package:tuning_for_tonists/models/tuning_configuration.dart';

import '../constants/preference_names.dart';

class TuningConfigurationsController extends GetxController {
  Map<String, List<TuningConfiguration>>? defaultTuningConfigurations;
  Map<String, List<TuningConfiguration>>? customTuningConfigurations;

  void loadDefaultTuningConfigurations() {
    if (kDebugMode) {
      print('Loading default tuning configurations');
    }
    defaultTuningConfigurations = {
      'Guitar': Constants.defaultGuitarTuningConfigurations,
      'Ukulele': Constants.defaultUkuleleTuningConfigurations,
    };
    refresh();
  }

  void loadCustomTuningConfigurations() async {
    if (kDebugMode) {
      print('Loading custom tuning configurations');
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.getString(PreferenceNames.customTunings);
    data ??= '[]';
    Iterable jsonData = jsonDecode(data) as List;
    var tmp = List<TuningConfiguration>.from(
        jsonData.map((e) => TuningConfiguration.fromJson(e)));
    customTuningConfigurations = {'Custom Configurations': tmp};
    refresh();
  }

  Map<String, List<TuningConfiguration>> getTuningConfigurations() {
    return defaultTuningConfigurations!..addAll(customTuningConfigurations!);
  }
}
