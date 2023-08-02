import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../controllers/tuning_controller.dart';
import '../models/note.dart';
import '../widgets/guitar_painter.dart';

enum GuitarSide { left, right, all }

class GuitarDisplay extends StatelessWidget {
  GuitarDisplay({super.key});

  final TuningController tuningController = Get.find();

  final bool oneSided = false;

  Widget getGuitarDisplay(Size guitarSize) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: guitarSize.width * 0.1,
              height: guitarSize.height * 0.1,
            ),
            CustomPaint(
              painter: GuitarPainter(
                targetNotes: tuningController.allNotes,
                oneSided: false,
              ),
              size: guitarSize,
              willChange: true,
            ),
            SizedBox(
              width: guitarSize.width * 0.1,
              height: guitarSize.height * 0.1,
            ),
          ],
        ),
        ...getStringButtons(guitarSize),
      ],
    );
  }

  List<Widget> getStringButtons(Size guitarSize) {
    return oneSided
        ? [getOnesidedStringButtons(guitarSize)]
        : getTwoSidedStringButtons(guitarSize);
  }

  Widget getStringButton(Note note) {
    return SizedBox(
      height: tuningController.targetNote == note ? 57 : 45,
      width: tuningController.targetNote == note ? 57 : 45,
      child: TextButton(
          style: TextButton.styleFrom(
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
                  : AppColors.white),
          onPressed: () {
            tuningController.targetNote = note;
          },
          child: Text(note.name)),
    );
  }

  Widget getPositionedStringButton(int index, Size guitarSize, Note note) {
    return Positioned(
        left: getPositionedLeft(index, guitarSize, note),
        top: getPositionedTop(index, guitarSize, note),
        child: getStringButton(note));
  }

  double getPositionedLeft(int index, Size guitarSize, Note note) {
    return (oneSided
            ? 25
            : index < tuningController.allNotes.length ~/ 2
                ? guitarSize.width * 0.2
                : guitarSize.width * 1.5) +
        (tuningController.targetNote == note ? -6 : 0);
  }

  double getPositionedTop(int index, Size guitarSize, Note note) {
    return (oneSided
            ? 25
            : index < tuningController.allNotes.length ~/ 2
                ? guitarSize.height * (0.875 - index * 0.35)
                : guitarSize.height *
                    (0.175 +
                        index.remainder(tuningController.allNotes.length ~/ 2) *
                            0.35)) +
        (tuningController.targetNote == note ? -6 : 0);
  }

  List<Widget> getTwoSidedStringButtons(Size guitarSize) {
    List<Widget> allButtons = [];
    for (var i = 0; i < tuningController.allNotes.length; i++) {
      allButtons.add(getPositionedStringButton(
          i, guitarSize, tuningController.allNotes[i]));
    }
    return allButtons;
  }

  Widget getOnesidedStringButtons(Size guitarSize) {
    return Column(
      children:
          getNotes(GuitarSide.all).map((e) => getStringButton(e)).toList(),
    );
  }

  List<Note> getNotes(GuitarSide side) {
    var notes = tuningController.allNotes;
    if (side == GuitarSide.left) {
      return notes.sublist(0, notes.length ~/ 2);
    } else if (side == GuitarSide.right) {
      return notes.sublist(notes.length ~/ 2);
    } else if (side == GuitarSide.all) {
      return notes;
    } else {}
    return notes;
  }

  Size getGuitarSize(Size mediaQuerySize) {
    return Size(mediaQuerySize.width * 0.5, mediaQuerySize.height * 0.3);
  }

  @override
  Widget build(BuildContext context) {
    return getGuitarDisplay(getGuitarSize(MediaQuery.of(context).size));
  }
}
