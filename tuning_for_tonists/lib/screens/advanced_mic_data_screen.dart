import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/view_controllers/advanced_mic_data_controller.dart';
import 'package:tuning_for_tonists/widgets/hps_data_display.dart';
import 'package:tuning_for_tonists/widgets/performance_display.dart';

import '../widgets/app_drawer.dart';
import '../widgets/autocorrelation_data_display.dart';
import '../widgets/frequency_data_display.dart';
import '../widgets/frequency_number_display.dart';
import '../widgets/main_data_display.dart';
import '../widgets/mic_stream_control_button.dart';
import '../widgets/string_display.dart';
import '../widgets/wave_data_display.dart';
import '../widgets/zero_crossing_display.dart';

class AdvancedMicDataScreen extends GetView<AdvancedMicDataController> {
  const AdvancedMicDataScreen({super.key});

  Widget getMicDisplay() {
    return const SingleChildScrollView(
      child: Column(
        children: [
          PerformanceDisplay(),
          SizedBox(
            height: 48,
          ),
          WaveDataDisplay(),
          SizedBox(
            height: 48,
          ),
          AutocorrelationDataDisplay(),
          SizedBox(
            height: 48,
          ),
          FrequencyDataDisplay(),
          SizedBox(
            height: 48,
          ),
          HPSDataDisplay(),
          SizedBox(
            height: 48,
          ),
          ZeroCrossingDisplay(),
          SizedBox(
            height: 48,
          ),
          MainDataDisplay(),
          SizedBox(
            height: 48,
          ),
          FrequencyNumberDisplay(),
          StringDisplay(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      appBar: AppBar(
          title: const Text('Advanced Microphone info'),
          leading: IconButton(
            icon: const Icon(Icons.menu_sharp),
            onPressed: () => controller.openDrawer(),
          )),
      body: getMicDisplay(),
      drawer: const AppDrawer(),
      floatingActionButton: const MicStreamControlButton(),
    );
  }
}
