import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/controllers/tuning_controller.dart';
import 'package:tuning_for_tonists/controllers/wave_data_controller.dart';

// ignore: must_be_immutable
class TuningFrequencyPointerDisplay extends StatelessWidget {
  TuningFrequencyPointerDisplay({super.key});

  // TuningController tuningController = Get.find();
  WaveDataController waveDataController = Get.find();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TuningController>(builder: (tuningController) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomPaint(
          painter: FrequencyDialPainter(
              currentFrequency: waveDataController.visibleSamples.last,
              targetFrequency: tuningController.targetFrequency,
              frequencyRange: tuningController.frequencyRange,
              tuningColor: tuningController.tuningColor.value),
          size: Size(MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height / 2),
          willChange: true,
          // child: ,
        ),
      );
    });
  }
}

class FrequencyDialPainter extends CustomPainter {
  final double currentFrequency;
  final double targetFrequency;
  final double frequencyRange;
  final Color tuningColor;

  FrequencyDialPainter({
    required this.currentFrequency,
    required this.targetFrequency,
    required this.frequencyRange,
    required this.tuningColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    final Paint dialPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.grey;

    final Paint acceptanceBandPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = Colors.green;

    final Paint pointerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = tuningColor;

    // Draw the full dial
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      degreesToRadians(-60 - 90),
      degreesToRadians(120),
      false,
      dialPaint,
    );

    // Draw the acceptance band
    double lowerBoundAngle =
        calculateAngle(targetFrequency - frequencyRange) - 90 - 60;
    double upperBoundAngle =
        calculateAngle(targetFrequency + frequencyRange) - 90 - 60;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      degreesToRadians(lowerBoundAngle),
      degreesToRadians(upperBoundAngle - lowerBoundAngle),
      false,
      acceptanceBandPaint,
    );

    // Draw the pointer
    double currentAngle = calculateAngle(currentFrequency) - 90 - 60;
    if (currentAngle > -30) {
      currentAngle = -30;
    }
    final Offset end = Offset(
      center.dx + radius * cos(degreesToRadians(currentAngle)),
      center.dy + radius * sin(degreesToRadians(currentAngle)),
    );
    canvas.drawLine(center, end, pointerPaint);
  }

  double degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  double calculateAngle(double frequency) {
    // Your logic here to map the frequency to an angle from -60 to +60 degrees
    // For example:
    return (frequency / targetFrequency) * 60;
    // return 0.0;
  }

  @override
  bool shouldRepaint(covariant FrequencyDialPainter oldDelegate) {
    return oldDelegate.currentFrequency != currentFrequency ||
        oldDelegate.targetFrequency != targetFrequency ||
        oldDelegate.frequencyRange != frequencyRange ||
        oldDelegate.tuningColor != tuningColor;
  }
}
