import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/controllers/tuning_controller.dart';
import 'package:tuning_for_tonists/controllers/wave_data_controller.dart';

import 'dart:math';

import '../fl_chart_data/app_resources.dart';
import 'package:fl_chart/fl_chart.dart';

class MainDataDisplay extends StatelessWidget {
  const MainDataDisplay({super.key});
  // String title = 'Main Data Display';

  Widget bottomTitleWidgets(double value, TitleMeta meta, double chartWidth) {
    if (value % 1 != 0) {
      return Container();
    }
    final style = TextStyle(
      color: AppColors.contentColorBlue,
      fontWeight: FontWeight.bold,
      fontSize: min(18, 18 * chartWidth / 300),
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: Text(meta.formattedValue, style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta, double chartWidth) {
    final style = TextStyle(
      color: AppColors.contentColorYellow,
      fontWeight: FontWeight.bold,
      fontSize: min(18, 18 * chartWidth / 300),
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: Text(meta.formattedValue, style: style),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Center(
          child: Text(
            'Main Data Display',
            style: TextStyle(fontSize: 24),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(
            left: 24,
            bottom: 24,
            right: 40,
            top: 40,
          ),
        ),
        AspectRatio(
          aspectRatio: 1,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GetBuilder<TuningController>(builder: (tuningController) {
                return GetBuilder<WaveDataController>(
                  builder: (waveDataController) => LineChart(
                    duration: const Duration(milliseconds: 0),
                    LineChartData(
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          maxContentWidth: 100,
                          tooltipBgColor: Colors.black,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((LineBarSpot touchedSpot) {
                              final textStyle = TextStyle(
                                color: touchedSpot.bar.gradient?.colors[0] ??
                                    touchedSpot.bar.color,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              );
                              return LineTooltipItem(
                                '${touchedSpot.x}, ${touchedSpot.y.toStringAsFixed(2)}',
                                textStyle,
                              );
                            }).toList();
                          },
                        ),
                        handleBuiltInTouches: true,
                        getTouchLineStart: (data, index) => 0,
                      ),

                      lineBarsData: [
                        LineChartBarData(
                          color: AppColors.contentColorPink,
                          spots: waveDataController.visibleDataToSpots(),
                          isCurved: true,
                          isStrokeCapRound: true,
                          barWidth: 2,
                          belowBarData: BarAreaData(
                            show: false,
                          ),
                          dotData: const FlDotData(show: false),
                        ),
                      ],

                      minY: tuningController.targetFrequency -
                          tuningController.frequencyRange,
                      // maxY: waveDataController.visibleSamples.reduce(max),
                      maxY: tuningController.targetFrequency +
                          tuningController.frequencyRange,
                      minX: 0,
                      maxX: waveDataController.visibleSamples.length.toDouble(),
                      titlesData: const FlTitlesData(
                        show: false,
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawHorizontalLine: true,
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
                );
              });
            },
          ),
        ),
      ],
    );
  }
}
