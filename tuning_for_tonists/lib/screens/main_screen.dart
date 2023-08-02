import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/widgets/guitar_display.dart';
import '../constants/app_colors.dart';
import '../widgets/frequency_bars_display.dart';
import '../widgets/mic_stream_control_button.dart';
import '../widgets/side_scrolling_tuning_configurations.dart';
import '../widgets/target_note_display.dart';
import '../controllers/tuning_configurations_controller.dart';
import '../controllers/tuning_controller.dart';
import '../view_controllers/home_controller.dart';
import '../widgets/app_drawer.dart';

class MainScreen extends GetView<HomeController> {
  final HomeController homeController = Get.find();

  final TuningConfigurationsController tuningConfigurationsController =
      Get.find();
  final TuningController tuningController = Get.find();
  MainScreen({super.key});

  Widget getMicDisplay() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SideScrollingTuningConfigurations(),
          const SizedBox(
            height: 24,
          ),
          TargetNoteDisplay(),
          FrequencyBarsDisplay(),
          GuitarDisplay(),
        ],
      ),
    );
  }

  List<String> getInstrumentTypes() {
    return tuningConfigurationsController
        .getTuningConfigurations()
        .keys
        .toList();
  }

  Widget getMenuDropdownButton() {
    return Center(
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          style: const TextStyle().apply(color: AppColors.white),
          value: tuningController.activeInstrumentGroup,
          items: getInstrumentTypes()
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (value) {
            tuningController.setActiveInstrumentGroup(value ?? 'Guitar');
            print('New Value: $value');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TuningController>(builder: (tuningController) {
      return Scaffold(
        key: controller.scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu_sharp),
            onPressed: () => controller.openDrawer(),
          ),
          title: getMenuDropdownButton(),
        ),
        body: getMicDisplay(),
        drawer: const AppDrawer(),
        floatingActionButton: const MicStreamControlButton(),
      );
    });
  }
}
