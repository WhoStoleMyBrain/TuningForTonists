import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/models/guitar_knob.dart';

import '../constants/app_colors.dart';
import '../controllers/tuning_controller.dart';
import '../models/guitar_head.dart';
import '../models/guitar_string.dart';
import '../models/note.dart';

abstract class GuitarSizeHelper {
  static TuningController tuningController = Get.find();
  static double yOffset = 30;
  static double neckThickness = 30;
  static double neckLength = 25;
  static double headThickness = 20;
  static double headLength = 25;
  static double guitarNeckLength = 80;
  static double guitarNeckWidth = 90;
  static double guitarHeadLength = 200;
  static double guitarHeadPointLength = 25;
  static double guitarHeadWidth = 15;
  static double stringCircleRadius = 10;
  static double stringLength = 300;
  static Size getSizedBoxSize(Size guitarSize) {
    return Size(guitarSize.width * 0.1, guitarSize.height * 0.1);
  }

  static double stringButtonHeight(Note note) {
    return tuningController.targetNote == note ? 57 : 45;
  }

  static double stringButtonWidth(Note note) {
    return tuningController.targetNote == note ? 57 : 45;
  }

  static ButtonStyle stringButtonStyle(Note note) {
    return TextButton.styleFrom(
        side: BorderSide(
            width: tuningController.targetNote == note ? 8 : 1.5,
            color: AppColors.primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        elevation: 0,
        backgroundColor: tuningController.targetNote == note
            ? AppColors.onPrimaryColor
            : AppColors.backgroundColor,
        foregroundColor: tuningController.targetNote == note
            ? AppColors.black
            : AppColors.white);
  }

  static double getLeftPositionStringButton(
      bool oneSided, int index, Size guitarSize, Note note) {
    return (oneSided
            ? 25
            : index < getNotesLengthHalved()
                ? guitarSize.width * 0.2
                : guitarSize.width * 1.5) +
        (tuningController.targetNote == note ? -6 : 0);
  }

  static int getNotesLengthHalved() {
    return tuningController.allNotes.length > 1
        ? tuningController.allNotes.length ~/ 2
        : 1;
  }

  static double getTopPositionStringButton(
      bool oneSided, int index, Size guitarSize, Note note) {
    return (oneSided
            ? 25
            : index < getNotesLengthHalved()
                ? guitarSize.height * (0.8 - index * 0.35)
                : guitarSize.height *
                    (0.1 + index.remainder(getNotesLengthHalved()) * 0.35)) +
        (tuningController.targetNote == note ? -6 : 0);
  }

  static GuitarKnob getDefaultGuitarKnob() {
    return GuitarKnob(
        neckThickness: neckThickness,
        neckLength: neckLength,
        headThickness: headThickness,
        headLength: headLength);
  }

  static GuitarString getDefaultGuitarString() {
    return GuitarString(
        circleRadius: stringCircleRadius, stringLength: stringLength);
  }

  static GuitarHead getDefaultGuitarHead() {
    return GuitarHead(
        neckLength: guitarNeckLength,
        neckWidth: guitarNeckWidth,
        headLength: guitarHeadLength,
        headPointLength: guitarHeadPointLength,
        headWidth: guitarHeadWidth);
  }
}
