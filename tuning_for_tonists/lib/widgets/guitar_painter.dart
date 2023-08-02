import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tuning_for_tonists/helpers/predefined_matrices.dart';
import '../constants/app_colors.dart';

import '../enums/rotation_axis.dart';
import '../models/note.dart';

class GuitarPainter extends CustomPainter {
  List<Note> targetNotes;
  bool oneSided;

  GuitarPainter({required this.targetNotes, required this.oneSided});

  Path guitarKnob({
    double neckThickness = 30,
    double neckLength = 25,
    double headThickness = 20,
    double headLength = 25,
  }) {
    Path path = Path();
    path.moveTo(0, headThickness);
    path.lineTo(neckLength, headThickness);
    path.lineTo(neckLength, 0);
    path.lineTo(neckLength + headLength, 0);
    path.lineTo(neckLength + headLength, neckThickness + 2 * headThickness);
    path.lineTo(neckLength, neckThickness + 2 * headThickness);
    path.lineTo(neckLength, neckThickness + headThickness);
    path.lineTo(0, neckThickness + headThickness);
    return path;
  }

  Path guitarString({
    double circleRadius = 10,
    double stringLength = 100,
  }) {
    Path path = Path();

    path.addOval(
        Rect.fromCircle(center: const Offset(0, 0), radius: circleRadius));
    // path.moveTo(circleRadius, y)
    path.lineTo(circleRadius, stringLength);
    return path;
  }

  Path guitarHead({
    double neckLength = 40,
    double neckWidth = 90,
    double headLength = 200,
    double headPointLength = 25,
    double headWidth = 15,
  }) {
    Path path = Path();

    path.moveTo(0, headWidth);
    path.lineTo(neckLength, headWidth);
    path.lineTo(neckLength, 0);
    path.lineTo(neckLength + headLength, 0);
    path.lineTo(
        neckLength + headLength + headPointLength, (headWidth + neckWidth) / 2);
    path.lineTo(neckLength + headLength, headWidth + neckWidth);
    path.lineTo(neckLength, headWidth + neckWidth);
    path.lineTo(neckLength, neckWidth);
    path.lineTo(0, neckWidth);
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const double neckThickness = 30;
    const double neckLength = 25;
    const double headThickness = 20;
    const double headLength = 25;
    const double yOffset = 50;
    const double guitarNeckLength = 80;
    const double guitarNeckWidth = 90;
    const double guitarHeadLength = 200;
    const double guitarHeadPointLength = 25;
    const double guitarHeadWidth = 15;
    const double stringCircleRadius = 10;
    const double stringLength = 300;

    final Paint knobPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = AppColors.onPrimaryColor;

    final Paint guitarHeadPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = AppColors.onBackgroundColor;

    var rotationFlipMatrix =
        PredefinedMatrices.getRotationMatrix(RotationAxis.Z, 180 * pi / 180);
    // var rotationRightMatrix = getRotationMatrix(RotationAxis.Z, 90 * pi / 180);
    var rotationLeftMatrix =
        PredefinedMatrices.getRotationMatrix(RotationAxis.Z, -90 * pi / 180);
    var scaleDownMatrix = PredefinedMatrices.getScalingMatrix(0.5, 0.5);
    // var scaleUpMatrix = getScalingMatrix(2, 2);
    for (var i = 0; i < targetNotes.length; i++) {
      var knobPath = guitarKnob(
              headLength: headLength,
              headThickness: headThickness,
              neckLength: neckLength,
              neckThickness: neckThickness)
          .transform(scaleDownMatrix);
      Path guitarStringPath = guitarString(
          circleRadius: stringCircleRadius, stringLength: stringLength);
      // canvas.drawPath(guitarStringPath, guitarHeadPaint);
      if (i >= targetNotes.length ~/ 2) {
        knobPath = knobPath.shift(Offset(size.width / 4 * 3, yOffset));
        // guitarStringPath =
        //     guitarStringPath.shift(Offset(size.width / 4 * 3, yOffset));
        guitarStringPath = guitarStringPath
            .transform(PredefinedMatrices.getScalingMatrix(-1, 1));
        guitarStringPath = guitarStringPath.shift(Offset(
            size.width / 4 * 3 - (guitarNeckWidth + guitarHeadWidth) * 0.25,
            yOffset));
        guitarStringPath = guitarStringPath.shift(Offset(
            i.remainder(targetNotes.length ~/ 2) * stringCircleRadius * 0.5,
            80.0 * i.remainder(targetNotes.length ~/ 2) +
                stringCircleRadius * 1.5));
      } else {
        knobPath = knobPath.transform(rotationFlipMatrix).shift(Offset(
            size.width / 4 * 1,
            (neckThickness + 2 * headThickness) / 2 + yOffset));
        guitarStringPath = guitarStringPath.shift(Offset(
            size.width / 4 * 1 + (guitarNeckWidth + guitarHeadWidth) * 0.25,
            yOffset));
        guitarStringPath = guitarStringPath.shift(Offset(
            -i * stringCircleRadius * 0.5,
            80.0 * i.remainder(targetNotes.length ~/ 2) +
                stringCircleRadius * 1.5));
      }
      knobPath = knobPath
          .shift(Offset(0, 80.0 * i.remainder(targetNotes.length ~/ 2)));
      canvas.drawPath(knobPath, knobPaint);
      canvas.drawPath(guitarStringPath, guitarHeadPaint);
    }
    Path guitarHeadPath = guitarHead(
        headLength: guitarHeadLength,
        headPointLength: guitarHeadPointLength,
        headWidth: guitarHeadWidth,
        neckLength: guitarNeckLength,
        neckWidth: guitarNeckWidth);
    guitarHeadPath = guitarHeadPath.transform(rotationLeftMatrix);
    guitarHeadPath = guitarHeadPath.shift(const Offset(45, 315));
    Path secondGuitarHeadPath = guitarHead(
        headLength: guitarHeadLength,
        headPointLength: guitarHeadPointLength,
        headWidth: guitarHeadWidth,
        neckLength: guitarNeckLength,
        neckWidth: guitarNeckWidth);
    secondGuitarHeadPath = secondGuitarHeadPath.transform(rotationLeftMatrix);
    secondGuitarHeadPath = secondGuitarHeadPath
        .transform(PredefinedMatrices.getScalingMatrix(0.8, 0.8));
    secondGuitarHeadPath = secondGuitarHeadPath.shift(const Offset(55, 275));
    canvas.drawPath(guitarHeadPath, guitarHeadPaint);
    // canvas.drawPath(secondGuitarHeadPath, guitarHeadPaint);
  }

  @override
  bool shouldRepaint(covariant GuitarPainter oldDelegate) {
    return oldDelegate.targetNotes != targetNotes ||
        oldDelegate.oneSided != oneSided;
  }
}
