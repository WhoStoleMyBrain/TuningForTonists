import 'dart:core';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mic_stream/mic_stream.dart';
import 'package:tuning_for_tonists/controllers/mic_initialization_values_controller.dart';
import 'package:tuning_for_tonists/controllers/mic_technical_data_controller.dart';
import 'package:tuning_for_tonists/controllers/wave_data_controller.dart';
import 'package:tuning_for_tonists/screens/main_screen.dart';

enum Command {
  start,
  stop,
  change,
}

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
      title: 'Provider Package',
      // The theme of your application.
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home:
          const MainScreen(), // the widget below which in the widget-tree this provider is available
    );
  }
}
