import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';
import '../controllers/tuning_configurations_controller.dart';
import '../controllers/tuning_controller.dart';
import '../models/tuning_configuration.dart';

class SideScrollingTuningConfigurations extends StatelessWidget {
  SideScrollingTuningConfigurations({super.key});

  final TuningConfigurationsController tuningConfigurationsController =
      Get.find();
  final TuningController tuningController = Get.find();

  Color getElevatedButtonForegroundColor(TuningConfiguration conf) {
    return tuningController.tuningConfiguration == conf
        ? AppColors.onPrimaryColor
        : AppColors.primaryColor;
  }

  Color getElevatedButtonBackgroundColor(TuningConfiguration conf) {
    return tuningController.tuningConfiguration == conf
        ? AppColors.primaryColor
        : AppColors.backgroundColor;
  }

  Widget getTuningsRow() {
    Widget row;
    var tuningConfigurations =
        tuningConfigurationsController.getTuningConfigurations();
    var activeInstrumentGroup = tuningController.activeInstrumentGroup;
    var tunings = tuningConfigurations[activeInstrumentGroup];

    row = Row(
      children: tunings!
          .map((e) => Padding(
                padding: const EdgeInsets.all(2.0),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: const EdgeInsets.only(
                        bottom: 0,
                        top: 0,
                        left: 8,
                        right: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      foregroundColor: getElevatedButtonForegroundColor(e),
                      backgroundColor: getElevatedButtonBackgroundColor(e),
                    ),
                    onPressed: () {
                      // print('setting tuning conf to ${e.configurationName}');
                      tuningController.setTuningConfiguration(e);
                    },
                    child: Text(e.configurationName)),
              ))
          .toList(),
    );

    return row;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: getTuningsRow(),
    );
  }
}
