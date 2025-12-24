import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tuning_controller.dart';
import '../enums/guitar_side.dart';
import '../helpers/guitar_size_helper.dart';
import '../models/note.dart';
import '../widgets/guitar_painter.dart';

class GuitarDisplay extends StatelessWidget {
  GuitarDisplay({super.key});

  final TuningController tuningController = Get.find();

  final bool oneSided = false;

  Widget getSizedBoxForClickableAreas(Size guitarSize) {
    return SizedBox.fromSize(
        size: GuitarSizeHelper.getSizedBoxSize(guitarSize));
  }

  Widget getGuitarDisplay(Size guitarSize) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            getSizedBoxForClickableAreas(guitarSize),
            CustomPaint(
              painter: GuitarPainter(
                allNotes: tuningController.allNotes,
                oneSided: oneSided,
              ),
              size: guitarSize,
            ),
            getSizedBoxForClickableAreas(guitarSize),
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
      height: GuitarSizeHelper.stringButtonHeight(note),
      width: GuitarSizeHelper.stringButtonWidth(note),
      child: TextButton(
          style: GuitarSizeHelper.stringButtonStyle(note),
          onPressed: () {
            tuningController.targetNote = note;
          },
          child: Text(note.name)),
    );
  }

  Widget getPositionedStringButton(int index, Size guitarSize, Note note) {
    return Positioned(
        left: GuitarSizeHelper.getLeftPositionStringButton(
            oneSided, index, guitarSize, note),
        top: GuitarSizeHelper.getTopPositionStringButton(
            oneSided, index, guitarSize, note),
        child: getStringButton(note));
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
