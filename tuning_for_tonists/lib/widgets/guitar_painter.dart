import 'package:flutter/material.dart';
import 'package:tuning_for_tonists/helpers/guitar_size_helper.dart';
import 'package:tuning_for_tonists/helpers/predefined_matrices.dart';
import 'package:tuning_for_tonists/models/guitar_head.dart';
import 'package:tuning_for_tonists/models/guitar_knob.dart';
import 'package:tuning_for_tonists/models/guitar_string.dart';
import '../constants/app_colors.dart';

import '../helpers/guitar_drawer_helper.dart';
import '../models/note.dart';

class GuitarPainter extends CustomPainter {
  List<Note> allNotes;
  bool oneSided;

  GuitarPainter({required this.allNotes, required this.oneSided});

  @override
  void paint(Canvas canvas, Size size) {
    GuitarKnob guitarKnob = GuitarSizeHelper.getDefaultGuitarKnob();
    GuitarHead guitarHead = GuitarSizeHelper.getDefaultGuitarHead();
    GuitarString guitarString = GuitarSizeHelper.getDefaultGuitarString();

    final Paint knobPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = AppColors.onPrimaryColor;

    final Paint guitarHeadPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = AppColors.onBackgroundColor;
    var scaleDownMatrix = PredefinedMatrices.getScalingMatrix(0.5, 0.5);

    for (var i = 0; i < allNotes.length; i++) {
      Path knobPath = GuitarDrawerHelper.drawGuitarKnobPath(guitarKnob)
          .transform(scaleDownMatrix);
      Path guitarStringPath = GuitarDrawerHelper.drawGuitarString(
          GuitarSizeHelper.getDefaultGuitarString());
      knobPath = GuitarDrawerHelper.moveAndScaleKnobPath(
          knobPath, guitarKnob, i, size, GuitarSizeHelper.yOffset);
      guitarStringPath = GuitarDrawerHelper.moveAndScaleStringPath(
          guitarStringPath,
          guitarHead,
          guitarString,
          i,
          size,
          GuitarSizeHelper.yOffset);
      knobPath = knobPath.shift(Offset(
          0, 80.0 * i.remainder(GuitarSizeHelper.getNotesLengthHalved())));
      canvas.drawPath(knobPath, knobPaint);
      canvas.drawPath(guitarStringPath, guitarHeadPaint);
    }

    Path guitarHeadPath = GuitarDrawerHelper.drawGuitarHead(guitarHead);
    guitarHeadPath = GuitarDrawerHelper.moveAndScaleGuitarHead(guitarHeadPath);

    canvas.drawPath(guitarHeadPath, guitarHeadPaint);
  }

  @override
  bool shouldRepaint(covariant GuitarPainter oldDelegate) {
    return oldDelegate.allNotes != allNotes || oldDelegate.oneSided != oneSided;
  }
}
