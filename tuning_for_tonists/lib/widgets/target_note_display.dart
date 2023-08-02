import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/constants/app_colors.dart';
import 'package:tuning_for_tonists/controllers/tuning_controller.dart';

class TargetNoteDisplay extends StatelessWidget {
  TargetNoteDisplay({super.key});

  final TuningController tuningController = Get.find();

  String getNoteDistanceName() {
    double threshold = tuningController.tuningThreshold;
    double distance = tuningController.tuningDistance;
    print('distance: $distance, threshold: $threshold');
    if (distance < threshold) {
      return 'Low';
    } else if (distance < -threshold) {
      return 'Very Low';
    } else if (distance < (-threshold * 0.5)) {
      return 'Slightly Low';
    } else if (distance < (-threshold * 0.25)) {
      return 'Good';
    } else if (distance < (-threshold * 0.1)) {
      return 'Very Good';
    } else if (distance > threshold) {
      return 'Very High';
    } else if (distance > (threshold * 0.5)) {
      return 'Slightly High';
    } else if (distance > (threshold * 0.25)) {
      return 'Good';
    } else if (distance > (threshold * 0.1)) {
      return 'Very Good';
    } else {
      return 'Default';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            tuningController.targetNote.name,
            style: TextStyle(color: tuningController.tuningColor, fontSize: 48),
          ),
          Divider(
            thickness: 0.75,
            indent: MediaQuery.of(context).size.width / 3,
            endIndent: MediaQuery.of(context).size.width / 3,
            color: AppColors.onBackgroundColor,
          ),
          Text(
            getNoteDistanceName(),
            style: TextStyle(color: tuningController.tuningColor, fontSize: 28),
          ),
        ],
      ),
    );
  }
}
