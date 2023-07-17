import 'dart:core';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mic_stream/mic_stream.dart';

import './bindings/info_binding.dart';
import './bindings/home_binding.dart';
import './bindings/settings_binding.dart';
import './controllers/mic_initialization_values_controller.dart';
import './controllers/mic_technical_data_controller.dart';
import './controllers/wave_data_controller.dart';
import './screens/info_screen.dart';
import './screens/main_screen.dart';
import './screens/settings_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    Get.put(MicInitializationValuesController(
        audioFormat: AudioFormat.ENCODING_PCM_16BIT.obs,
        sampleRate: 48000.obs,
        channelConfig: ChannelConfig.CHANNEL_IN_MONO.obs,
        audioSource: AudioSource.DEFAULT.obs));
    Get.put(MicTechnicalDataController());
    Get.put(WaveDataController());
    return GetMaterialApp(
        title: 'Tuning for Tonists',
        // The theme of your application.
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        navigatorKey: Get.key,
        initialRoute: '/home',
        getPages: [
          GetPage(
              name: '/home', page: () => MainScreen(), binding: HomeBinding()),
          GetPage(
              name: '/settings',
              page: () => SettingsScreen(),
              binding: SettingsBinding()),
          GetPage(
              name: '/info', page: () => InfoScreen(), binding: InfoBinding()),
        ]);
  }
}
