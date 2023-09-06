import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/controllers/tuning_controller.dart';
import 'package:tuning_for_tonists/controllers/wave_data_controller.dart';

import 'dart:math';

import '../fl_chart_data/app_resources.dart';
import 'package:fl_chart/fl_chart.dart';

class FrequencyTimePlot extends StatelessWidget {
  const FrequencyTimePlot({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 24,
        bottom: 24,
        right: 40,
        top: 40,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GetBuilder<TuningController>(builder: (tuningController) {
            return GetBuilder<WaveDataController>(
              builder: (waveDataController) => SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.15,
                child: ScatterChart(
                  swapAnimationDuration: const Duration(milliseconds: 0),
                  swapAnimationCurve: Curves.linear,
                  ScatterChartData(
                    scatterSpots: tuningController.getScatterData(),
                    minX: waveDataController.visibleSamples.reduce(min),
                    maxX: waveDataController.visibleSamples.reduce(max),
                    minY: 0,
                    maxY: waveDataController.visibleSamples.length.toDouble(),
                    titlesData: const FlTitlesData(
                      show: false,
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawHorizontalLine: false,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: AppColors.contentColorBlue.withOpacity(1),
                        dashArray: [8, 0],
                        strokeWidth: 0.8,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
