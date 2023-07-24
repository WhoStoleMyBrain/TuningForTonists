import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/controllers/wave_data_controller.dart';

import 'dart:math';

import '../fl_chart_data/app_resources.dart';
import 'package:fl_chart/fl_chart.dart';

class FrequencyDataDisplay extends StatelessWidget {
  const FrequencyDataDisplay({super.key});

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
            'Frequency Data Display',
            style: TextStyle(fontSize: 24),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 12,
            bottom: 12,
            right: 20,
            top: 20,
          ),
          child: AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GetBuilder<WaveDataController>(
                  builder: (waveDataController) => LineChart(
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
                          spots: waveDataController.frequencyDataToSpots(),
                          isCurved: true,
                          isStrokeCapRound: true,
                          barWidth: 2,
                          belowBarData: BarAreaData(
                            show: false,
                          ),
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                      // minY: 0,
                      minY: waveDataController.fftData.reduce(min).toDouble(),
                      maxY: waveDataController.fftData.reduce(max).toDouble(),
                      minX: 0,
                      maxX: waveDataController.fftData.length.toDouble(),
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
              },
            ),
          ),
        ),
      ],
    );
  }
}
