import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/controllers/tuning_controller.dart';

class StringDisplay extends StatelessWidget {
  const StringDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TuningController>(
      builder: (tuningController) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          ...tuningController.allNotes.map((element) => GestureDetector(
                onTap: () => tuningController.setTargetNote(element),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              '${tuningController.allNotes.indexOf(element)}:'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${element.name}'),
                        ),
                      ],
                    ),
                    Text('Tuned',
                        style: TextStyle(
                            color: element.tuned ? Colors.green : Colors.red)),
                  ],
                ),
              ))
        ]),
      ),
    );
  }
}
