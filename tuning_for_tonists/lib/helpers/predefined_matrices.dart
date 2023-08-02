import 'dart:math';
import 'dart:typed_data';

import '../enums/rotation_axis.dart';

abstract class PredefinedMatrices {
  static Float64List getScalingMatrix(double factorX, double factorY) {
    return Float64List.fromList(
        [factorX, 0, 0, 0, 0, factorY, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]);
  }

  static Float64List getRotationMatrix(RotationAxis axis, double radians) {
    return Float64List.fromList([
      (axis == RotationAxis.Z || axis == RotationAxis.Y) ? cos(radians) : 1,
      axis == RotationAxis.Z ? sin(radians) : 1,
      0,
      0,
      axis == RotationAxis.Z ? -sin(radians) : 1,
      (axis == RotationAxis.Z || axis == RotationAxis.X) ? cos(radians) : 1,
      axis == RotationAxis.X ? sin(radians) : 1,
      0,
      axis == RotationAxis.Y ? sin(radians) : 1,
      axis == RotationAxis.X ? -sin(radians) : 1,
      (axis == RotationAxis.X || axis == RotationAxis.Y) ? cos(radians) : 1,
      0,
      0,
      0,
      0,
      1
    ]);
  }
}
