import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/controllers/mic_technical_data_controller.dart';
import 'package:tuning_for_tonists/controllers/performance_controller.dart';

class PerformanceDisplay extends StatelessWidget {
  const PerformanceDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GetBuilder<PerformanceController>(
        builder: (performanceController) =>
            GetBuilder<MicTechnicalDataController>(
          builder: (micTechnicalDataController) => Column(
            children: [
              Row(
                children: [
                  const Text("Frequency: "),
                  Text(micTechnicalDataController.samplesPerSecond.toString())
                ],
              ),
              Row(
                children: [
                  const Text("Buffer Size: "),
                  Text(micTechnicalDataController.bufferSize.toString())
                ],
              ),
              Row(
                children: [
                  const Text("Time per calculation: "),
                  Text(
                      "${micTechnicalDataController.bufferSize / micTechnicalDataController.samplesPerSecond}")
                ],
              ),
              Row(
                children: [
                  const Text("Calculation Percentage: "),
                  Text((performanceController.getAverageCalculationDuration() /
                          (micTechnicalDataController.bufferSize /
                              micTechnicalDataController.samplesPerSecond) *
                          100)
                      .toStringAsFixed(2))
                ],
              ),
              Row(
                children: [
                  const Text("CalculationTime: "),
                  Text(performanceController
                      .getAverageCalculationDuration()
                      .toString())
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
