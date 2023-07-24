import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/controllers/tuning_controller.dart';
import 'package:tuning_for_tonists/controllers/wave_data_controller.dart';

class FrequencyNumberDisplay extends StatelessWidget {
  const FrequencyNumberDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TuningController>(
      builder: (tuningController) => GetBuilder<WaveDataController>(
        builder: (waveDataController) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  'Goal Frequency: ${tuningController.targetNote.value.frequency.toStringAsFixed(2)}'),
              Text(
                  'Current Frequency: ${waveDataController.visibleSamples.isNotEmpty ? waveDataController.visibleSamples.last.toStringAsFixed(2) : 0}'),
            ],
          ),
        ),
      ),
    );
  }
}
