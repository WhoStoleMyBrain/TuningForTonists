import 'dart:core';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mic_stream/mic_stream.dart';
import 'package:tuning_for_tonists/bindings/knowledgebase_binding.dart';
import 'package:tuning_for_tonists/bindings/mic_detail_binding.dart';
import 'package:tuning_for_tonists/constants/app_colors.dart';
import 'package:tuning_for_tonists/constants/routes.dart';
import 'package:tuning_for_tonists/controllers/calculation_controller.dart';
import 'package:tuning_for_tonists/controllers/fft_controller.dart';
import 'package:tuning_for_tonists/controllers/performance_controller.dart';
import 'package:tuning_for_tonists/controllers/tuning_configurations_controller.dart';
import 'package:tuning_for_tonists/controllers/tuning_controller.dart';
import 'package:tuning_for_tonists/screens/advanced_mic_data_screen.dart';
import 'package:tuning_for_tonists/screens/all_tunings_screen.dart';
import 'package:tuning_for_tonists/screens/create_tuning_screen.dart';
import 'package:tuning_for_tonists/screens/knowledgebase_screen.dart';
import 'package:tuning_for_tonists/screens/loading_page.dart';
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
    Get.lazyPut(() => PerformanceController(), fenix: true);
    TuningConfigurationsController tuningConfigurationsController =
        TuningConfigurationsController()
          ..loadDefaultTuningConfigurations()
          ..loadCustomTuningConfigurations();
    //TODO: Recheck this call, there has to be a way better way
    Get.lazyPut(
        () => MicInitializationValuesController(
            audioFormat: AudioFormat.ENCODING_PCM_16BIT.obs,
            sampleRate: 8192.obs,
            // sampleRate: 44100.obs,
            channelConfig: ChannelConfig.CHANNEL_IN_MONO.obs,
            audioSource: AudioSource.DEFAULT.obs),
        fenix: true);

    Get.lazyPut(() => MicTechnicalDataController(), fenix: true);
    Get.lazyPut(() => WaveDataController(), fenix: true);
    TuningController tuningController = TuningController()
      ..tuningConfiguration = tuningConfigurationsController
          .defaultTuningConfigurations!.values.first.first
      ..activeInstrumentGroup = tuningConfigurationsController
          .defaultTuningConfigurations!.keys.first;

    Get.lazyPut(() => tuningConfigurationsController, fenix: true);
    Get.lazyPut(() => tuningController, fenix: true);
    Get.lazyPut(() => MicDetailController(), fenix: true);
    Get.lazyPut(() => FftController(), fenix: true);
    CalculationController calculationController = CalculationController();
    Get.lazyPut(() => CalculationController(), fenix: true);
    Get.lazyPut(
        () => MicrophoneController(
            calculateDisplayData: calculationController.calculateDisplayData),
        fenix: true);
    return GetMaterialApp(
      title: 'Tuning for Tonists',
      // The theme of your application.

      theme: ThemeData(
        primarySwatch: createMaterialColor(AppColors.colorForSwatch),
        dropdownMenuTheme: const DropdownMenuThemeData(
          textStyle: TextStyle(
              color: AppColors.onPrimaryColor,
              backgroundColor: AppColors.backgroundColor),
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: createMaterialColor(AppColors.colorForSwatch),
          backgroundColor: AppColors.backgroundColor,
        ),
        canvasColor: AppColors.backgroundColor,
        appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.backgroundColor,
            shadowColor: AppColors.backgroundColor,
            elevation: 0.0),
        scaffoldBackgroundColor: AppColors.backgroundColor,
        // canvasColor: Colors.black45,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(),
          bodyMedium: TextStyle(),
          bodySmall: TextStyle(),
          labelLarge: TextStyle(),
          labelMedium: TextStyle(),
          labelSmall: TextStyle(),
          displayLarge: TextStyle(),
          displayMedium: TextStyle(),
          displaySmall: TextStyle(),
          headlineLarge: TextStyle(),
          headlineMedium: TextStyle(),
          headlineSmall: TextStyle(),
          titleLarge: TextStyle(),
          titleMedium: TextStyle(),
          titleSmall: TextStyle(),
        ).apply(
          displayColor: AppColors.onPrimaryColor,
          bodyColor: AppColors.onPrimaryColor,
          decorationColor: AppColors.onPrimaryColor,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: AppColors.onPrimaryColor,
              backgroundColor: AppColors.primaryColor),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.onPrimaryColor,
              backgroundColor: AppColors.primaryColor),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: AppColors.primaryColor,
          colorScheme: ColorScheme.fromSwatch(
              primarySwatch: createMaterialColor(AppColors.colorForSwatch),
              backgroundColor: AppColors.primaryColor),
        ),
      ),
      navigatorKey: Get.key,
      initialRoute: Routes.loadingPage,
      getPages: [
        GetPage(
          name: Routes.loadingPage,
          page: () => const LoadingPage(),
        ),
        GetPage(
            name: Routes.home,
            page: () => const MainScreen(),
            binding: HomeBinding()),
        GetPage(
            name: Routes.settings,
            page: () => SettingsScreen(),
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
        GetPage(
          name: Routes.knowledgebase,
          page: () => const KnowledgebaseScreen(),
          binding: KnowledgebaseBinding(),
        )
      ],
    );
  }
}
