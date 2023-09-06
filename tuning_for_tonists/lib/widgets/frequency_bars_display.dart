import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/constants/app_colors.dart';
import 'package:tuning_for_tonists/controllers/tuning_controller.dart';

enum BarSizes {
  big,
  medium,
  small,
  frequency,
}

class FrequencyBarsDisplay extends StatelessWidget {
  FrequencyBarsDisplay({super.key});

  final TuningController tuningController = Get.find();

  List<Widget> getBars(BoxConstraints size) {
    return List.generate(5 * 5, (i) => i + 1)
        .map((e) => getBar(e, size))
        .toList();
  }

  Widget getBarWidget(BarSizes myCase, BoxConstraints constraints) {
    switch (myCase) {
      case BarSizes.big:
        return Padding(
          padding:
              EdgeInsets.all((constraints.maxWidth * (1 / 25) * 0.95 - 5) / 2),
          child: Container(
            width: 5,
            height: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: AppColors.onBackgroundColor),
          ),
        );
      case BarSizes.medium:
        return Padding(
          padding:
              EdgeInsets.all((constraints.maxWidth * (1 / 25) * 0.95 - 4) / 2),
          child: Container(
            width: 4,
            height: constraints.maxHeight * 0.65,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: AppColors.onBackgroundColor),
          ),
        );
      case BarSizes.small:
        return Padding(
          padding:
              EdgeInsets.all((constraints.maxWidth * (1 / 25) * 0.95 - 3) / 2),
          child: Container(
            width: 3,
            height: constraints.maxHeight * 0.3,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: AppColors.onBackgroundColor),
          ),
        );
      case BarSizes.frequency:
        return Container(
          width: 4,
          height: constraints.maxHeight * 0.65,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: tuningController.tuningColor),
        );
      default:
        return Padding(
          padding:
              EdgeInsets.all((constraints.maxWidth * (1 / 25) * 0.95 - 3) / 2),
          child: Container(
            width: 3,
            height: constraints.maxHeight * 0.3,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: AppColors.onBackgroundColor),
          ),
        );
    }
  }

  Widget getBar(int index, BoxConstraints constraints) {
    if (index == 13) {
      return getBarWidget(BarSizes.big, constraints);
    } else if ((index + 2).remainder(5) == 0) {
      return getBarWidget(BarSizes.medium, constraints);
    } else {
      return getBarWidget(BarSizes.small, constraints);
    }
  }

  Widget drawBars(Size size) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: size.height * 0.2,
        width: double.infinity,
        child: LayoutBuilder(builder: (context, BoxConstraints constraints) {
          return Stack(clipBehavior: Clip.none, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...getBars(constraints),
              ],
            ),
            drawCurrentFrequency(constraints),
          ]);
        }),
      ),
    );
  }

  Widget drawCurrentFrequency(BoxConstraints constraints) {
    return Positioned(
      left: getCurrentFrequencyPosition(constraints),
      top: constraints.maxHeight * 0.3 / 2 +
          (constraints.maxWidth * (1 / 25) * 0.95 - 4) / 2 -
          1,
      child: getBarWidget(BarSizes.frequency, constraints),
    );
  }

  double frequencyToCents() {
    var sign = tuningController.tuningDistance.sign;
    if (kDebugMode) {
      print('Tuning distance sign: $sign');
    }
    var d = tuningController.tuningDistance + tuningController.targetFrequency;
    var dT = d / tuningController.targetFrequency;
    var lnAlpha = log(1.000577789);
    var lnVal = log(dT);
    var x = lnVal / lnAlpha;
    if (kDebugMode) {
      print(
          'd: $d; T: ${tuningController.targetFrequency}; dT: $dT, lnAlpha: $lnAlpha, lnVal: $lnVal');
    }
    // double valueInCents = actualValue;
    if (kDebugMode) {
      print('calculated cents: $x');
    }
    return x + tuningController.centRange;
  }

  double getCurrentFrequencyPosition(BoxConstraints constraints) {
    if (tuningController.tuningDistance > tuningController.frequencyRange) {
      return constraints.maxWidth;
    } else if (tuningController.tuningDistance <
        -tuningController.frequencyRange) {
      return 0;
    } else {
      return constraints.maxWidth *
          frequencyToCents() /
          (2 * tuningController.centRange);
    }
  }

  Widget displayTargetFrequency() {
    return Center(
      child: Column(
        children: [
          Transform.rotate(
            angle: -0.5 * pi,
            child: const Icon(
              Icons.play_arrow,
              color: AppColors.onBackgroundColor,
              size: 16,
            ),
          ),
          //TODO Check if I want to display frequency with digits after the . or not
          Text(
            '${tuningController.targetFrequency.toStringAsFixed(0)} Hz',
            style: const TextStyle(color: AppColors.onBackgroundColor),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        drawBars(MediaQuery.of(context).size),
        displayTargetFrequency(),
      ],
    );
  }
}
