import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/widgets/frequency_time_plot.dart';

import '../controllers/wave_data_controller.dart';

class TimeSensitiveTuningFrequencyDisplay extends StatelessWidget {
  TimeSensitiveTuningFrequencyDisplay({super.key});
  final WaveDataController waveDataController = Get.find();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // width: MediaQuery.of(context).size.width,
      // height: MediaQuery.of(context).size.height * 0.3,
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: FrequencyTimePlot(),
      ),
    );
  }
}
