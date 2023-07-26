import 'dart:core';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mic_stream/mic_stream.dart';
import 'package:tuning_for_tonists/bindings/mic_detail_binding.dart';
import 'package:tuning_for_tonists/constants/routes.dart';
import 'package:tuning_for_tonists/controllers/fft_controller.dart';
import 'package:tuning_for_tonists/controllers/tuning_configurations_controller.dart';
import 'package:tuning_for_tonists/controllers/tuning_controller.dart';
import 'package:tuning_for_tonists/screens/advanced_mic_data_screen.dart';
import 'package:tuning_for_tonists/screens/all_tunings_screen.dart';
import 'package:tuning_for_tonists/screens/create_tuning_screen.dart';
import 'package:tuning_for_tonists/screens/mic_detail_screen.dart';
import 'package:tuning_for_tonists/view_controllers/mic_detail_controller.dart';
import 'package:tuning_for_tonists/controllers/microphone_controller.dart';

import './bindings/info_binding.dart';
import './bindings/home_binding.dart';
import './bindings/settings_binding.dart';
import './controllers/mic_initialization_values_controller.dart';
import './controllers/mic_technical_data_controller.dart';
import './controllers/wave_data_controller.dart';
import './screens/info_screen.dart';
import './screens/main_screen.dart';
import './screens/settings_screen.dart';
import 'bindings/advanced_mic_data_binding.dart';
import 'helpers/microphone_helper.dart';

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
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
    TuningConfigurationsController tuningConfigurationsController =
        TuningConfigurationsController()
          ..loadDefaultTuningConfigurations()
          ..loadCustomTuningConfigurations();
    Get.put(MicInitializationValuesController(
        audioFormat: AudioFormat.ENCODING_PCM_8BIT.obs,
        sampleRate: 44100.obs,
        channelConfig: ChannelConfig.CHANNEL_IN_MONO.obs,
        audioSource: AudioSource.DEFAULT.obs));

    Get.put(MicTechnicalDataController());
    Get.put(tuningConfigurationsController);

    //TODO: Recheck this call, there has to be a way better way
    Get.put(TuningController()
      ..setTuningConfiguration(tuningConfigurationsController
          .defaultTuningConfigurations!.values.first.first));
    Get.put(WaveDataController());
    Get.put(MicDetailController());
    Get.put(MicrophoneController(
        calculateDisplayData: MicrophoneHelper.calculateDisplayData));
    Get.put(FftController());
    return GetMaterialApp(
      title: 'Tuning for Tonists',
      // The theme of your application.
      theme: ThemeData(
          // primarySwatch:
          //     createMaterialColor(const Color.fromRGBO(32, 32, 32, 0.7)),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: createMaterialColor(
              const Color.fromRGBO(23, 23, 120, 1.0),
            ),
            backgroundColor: const Color.fromRGBO(32, 32, 32, 0.7),
            accentColor: Colors.white,
          ),
          // canvasColor: Colors.black45,
          textTheme: const TextTheme()),
      navigatorKey: Get.key,
      initialRoute: Routes.home,
      getPages: [
        GetPage(
            name: Routes.home,
            page: () => MainScreen(),
            binding: HomeBinding()),
        GetPage(
            name: Routes.settings,
            page: () => const SettingsScreen(),
            binding: SettingsBinding()),
        GetPage(
            name: Routes.info,
            page: () => const InfoScreen(),
            binding: InfoBinding()),
        GetPage(
            name: Routes.micDetail,
            page: () => const MicDetailScreen(),
            binding: MicDetailBinding()),
        GetPage(
            name: Routes.advancedMicData,
            page: () => const AdvancedMicDataScreen(),
            binding: AdvancedMicDataBinding()),
        GetPage(name: Routes.allTunings, page: () => const AllTuningsScreen()),
        GetPage(
            name: Routes.createCustomTuning,
            page: () => const CreateTuningScreen()),
      ],
    );
  }
}
