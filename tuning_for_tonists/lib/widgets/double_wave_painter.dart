import 'dart:math';

import 'package:flutter/material.dart';

class DoubleWavePainter extends CustomPainter {
  double? localMax;
  double? localMin;
  List<double>? samples;
  late List<Offset> points;
  Color? color;
  BuildContext? context;
  Size? size;
  DoubleWavePainter(
      {this.samples, this.color, this.context, this.localMax, this.localMin});

  @override
  void paint(Canvas canvas, Size? size) {
    this.size = context!.size;
    size = this.size;

    Paint paint = Paint()
      ..color = color!
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    if (samples!.isEmpty) return;

    points = toPoints(samples);

    Path path = Path();
    path.addPolygon(points, false);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  /// Maps a list of ints and their indices to a list of points on a cartesian grid
  List<Offset> toPoints(List<double>? samples) {
    List<Offset> points = [];
    samples ??= List<double>.filled(size!.width.toInt(), 0.5);
    double pixelsPerSample = size!.width / samples.length;
    for (int i = 0; i < samples.length; i++) {
      var point = Offset(
          i * pixelsPerSample,
          0.5 *
              size!.height *
              pow((samples[i] - localMin!) / (localMax! - localMin!), 1));
      points.add(point);
    }
    return points;
  }

  double project(int val, int max, double height) {
    double waveHeight =
        (max == 0) ? val.toDouble() : (val / max) * 0.5 * height;
    return waveHeight + 0.5 * height;
  }
}
