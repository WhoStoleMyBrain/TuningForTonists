import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/helpers/predefined_matrices.dart';
import 'package:tuning_for_tonists/models/guitar_knob.dart';

import '../controllers/tuning_controller.dart';
import '../enums/rotation_axis.dart';
import '../models/guitar_head.dart';
import '../models/guitar_string.dart';
import 'guitar_size_helper.dart';

abstract class GuitarDrawerHelper {
  static TuningController tuningController = Get.find();
  static Path drawGuitarKnobPath(GuitarKnob guitarKnob) {
    Path path = Path();
    path.moveTo(0, guitarKnob.headThickness);
    path.lineTo(guitarKnob.neckLength, guitarKnob.headThickness);
    path.lineTo(guitarKnob.neckLength, 0);
    path.lineTo(guitarKnob.neckLength + guitarKnob.headLength, 0);
    path.lineTo(guitarKnob.neckLength + guitarKnob.headLength,
        guitarKnob.neckThickness + 2 * guitarKnob.headThickness);
    path.lineTo(guitarKnob.neckLength,
        guitarKnob.neckThickness + 2 * guitarKnob.headThickness);
    path.lineTo(guitarKnob.neckLength,
        guitarKnob.neckThickness + guitarKnob.headThickness);
    path.lineTo(0, guitarKnob.neckThickness + guitarKnob.headThickness);
    return path;
  }

  static Path drawGuitarString(GuitarString guitarString) {
    Path path = Path();

    path.addOval(Rect.fromCircle(
        center: const Offset(0, 0), radius: guitarString.circleRadius));
    path.lineTo(guitarString.circleRadius, guitarString.stringLength);
    return path;
  }

  static Path drawGuitarHead(GuitarHead guitarHead) {
    Path path = Path();
    path.moveTo(0, guitarHead.headWidth);
    path.lineTo(guitarHead.neckLength, guitarHead.headWidth);
    path.lineTo(guitarHead.neckLength, 0);
    path.lineTo(guitarHead.neckLength + guitarHead.headLength, 0);
    path.lineTo(
        guitarHead.neckLength +
            guitarHead.headLength +
            guitarHead.headPointLength,
        (guitarHead.headWidth + guitarHead.neckWidth) / 2);
    path.lineTo(guitarHead.neckLength + guitarHead.headLength,
        guitarHead.headWidth + guitarHead.neckWidth);
    path.lineTo(
        guitarHead.neckLength, guitarHead.headWidth + guitarHead.neckWidth);
    path.lineTo(guitarHead.neckLength, guitarHead.neckWidth);
    path.lineTo(0, guitarHead.neckWidth);
    return path;
  }

  static Path moveAndScaleKnobPath(
      Path path, GuitarKnob guitarKnob, int index, Size size, double yOffset) {
    var rotationFlipMatrix =
        PredefinedMatrices.getRotationMatrix(RotationAxis.Z, 180 * pi / 180);
    if (index >= GuitarSizeHelper.getNotesLengthHalved()) {
      path = path.shift(Offset(size.width / 4 * 3 + 5, yOffset));
    } else {
      path = path.transform(rotationFlipMatrix).shift(Offset(
          size.width / 4 * 1 - 5,
          (guitarKnob.neckThickness + 2 * guitarKnob.headThickness) / 2 +
              yOffset));
    }
    return path;
  }

  static Path moveAndScaleStringPath(Path path, GuitarHead guitarHead,
      GuitarString guitarString, int index, Size size, double yOffset) {
    if (index >= GuitarSizeHelper.getNotesLengthHalved()) {
      path = path.transform(PredefinedMatrices.getScalingMatrix(-1, 1));
      path = path.shift(Offset(
          size.width / 4 * 3 -
              (guitarHead.neckWidth + guitarHead.headWidth) * 0.25,
          yOffset));
      path = path.shift(Offset(
          index.remainder(GuitarSizeHelper.getNotesLengthHalved()) *
              guitarString.circleRadius *
              0.5,
          80.0 * index.remainder(GuitarSizeHelper.getNotesLengthHalved()) +
              guitarString.circleRadius * 1.5));
    } else {
      path = path.shift(Offset(
          size.width / 4 * 1 +
              (guitarHead.neckWidth + guitarHead.headWidth) * 0.25,
          yOffset));
      path = path.shift(Offset(
          -index * guitarString.circleRadius * 0.5,
          80.0 * index.remainder(GuitarSizeHelper.getNotesLengthHalved()) +
              guitarString.circleRadius * 1.5));
    }
    return path;
  }

  static Path moveAndScaleGuitarHead(
    Path path,
  ) {
    path = path.transform(
        PredefinedMatrices.getRotationMatrix(RotationAxis.Z, -90 * pi / 180));
    path = path.shift(const Offset(45, 305));
    return path;
  }
}
