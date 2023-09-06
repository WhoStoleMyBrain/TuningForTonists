import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/widgets/guitar_display.dart';
import 'package:tuning_for_tonists/widgets/time_sensitive_tuning_frequency_display.dart';
import 'package:tuning_for_tonists/widgets/tuning_frequency_pointer_display.dart';
import '../constants/app_colors.dart';
import '../widgets/frequency_bars_display.dart';
import '../widgets/mic_stream_control_button.dart';
import '../widgets/side_scrolling_tuning_configurations.dart';
import '../widgets/target_note_display.dart';
import '../controllers/tuning_configurations_controller.dart';
import '../controllers/tuning_controller.dart';
import '../view_controllers/home_controller.dart';
import '../widgets/app_drawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final HomeController homeController = Get.find();

  final TuningConfigurationsController tuningConfigurationsController =
      Get.find();

  final TuningController tuningController = Get.find();

  Widget getMicDisplay() {
    return SingleChildScrollView(
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragEnd: (details) {
              // print(details.primaryVelocity);
              if (details.primaryVelocity! > 0) {
                if (homeController.canReduceFrequencyDisplay()) {
                  homeController.frequencyDisplay--;
                  setState(() {});
                }
              } else if (details.primaryVelocity! <= 0) {
                if (homeController.canIncreaseFrequencyDisplay()) {
                  homeController.frequencyDisplay++;
                  setState(() {});
                }
              }
            },
            child: SizedBox(
                // width: MediaQuery.of(context).size.width,
                // height: MediaQuery.of(context).size.height * 0.5,
                child: Column(
              children: [...getFrequencyDisplay()],
            )),
          ),
          GuitarDisplay()
        ],
      ),
    );
  }

  List<Widget> getFrequencyDisplay() {
    if (homeController.frequencyDisplay == 1) {
      return [
        SideScrollingTuningConfigurations(),
        const SizedBox(
          height: 24,
        ),
        TargetNoteDisplay(),
        FrequencyBarsDisplay(),
      ];
    } else if (homeController.frequencyDisplay == 2) {
      return [
        SideScrollingTuningConfigurations(),
        const SizedBox(
          height: 24,
        ),
        TargetNoteDisplay(),
        TuningFrequencyPointerDisplay(),
      ];
    } else if (homeController.frequencyDisplay == 3) {
      return [
        SideScrollingTuningConfigurations(),
        const SizedBox(
          height: 24,
        ),
        TargetNoteDisplay(),
        TimeSensitiveTuningFrequencyDisplay(),
      ];
    } else {
      return [];
    }
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
            if (kDebugMode) {
              print('New Value: $value');
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TuningController>(builder: (tuningController) {
      return Scaffold(
        key: homeController.scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu_sharp),
            onPressed: () => homeController.openDrawer(),
          ),
          title: getMenuDropdownButton(),
          actions: [
            IconButton(
                onPressed: () {
                  if (homeController.canReduceFrequencyDisplay()) {
                    homeController.frequencyDisplay--;
                    setState(() {});
                  }
                },
                icon: const Icon(Icons.arrow_left)),
            IconButton(
                onPressed: () {
                  if (homeController.canIncreaseFrequencyDisplay()) {
                    homeController.frequencyDisplay++;
                    setState(() {});
                  }
                },
                icon: const Icon(Icons.arrow_right))
          ],
        ),
        body: getMicDisplay(),
        drawer: const AppDrawer(),
        floatingActionButton: const MicStreamControlButton(),
      );
    });
  }
}
