import 'package:get/get.dart';
import 'package:tuning_for_tonists/controllers/mic_technical_data_controller.dart';
import 'package:tuning_for_tonists/controllers/wave_data_controller.dart';

import '../models/note.dart';

class TuningController extends GetxController {
  Rx<Note> targetNote = Note(frequency: 440, name: 'A4', tuned: false).obs;
  Rx<double> _frequencyRange = 100.0.obs;
  RxList<Note> allNotes = <Note>[
    Note(frequency: 200, name: '200', tuned: false),
    Note(frequency: 300, name: '300', tuned: false),
    Note(frequency: 400, name: '400', tuned: false),
    Note(frequency: 500, name: '500', tuned: false),
    Note(frequency: 600, name: '600', tuned: false),
    Note(frequency: 700, name: '700', tuned: false),
  ].obs;

  double get frequencyRange => _frequencyRange.value;

  void setFrequencyRange(double newFrequencyRange) {
    _frequencyRange = newFrequencyRange.obs;
    update();
  }

  double get targetFrequency => targetNote.value.frequency;

  void setTargetNote(Note note) {
    targetNote = note.obs;
    update();
  }

  void checkIfNoteTuned() {
    if (!targetNote.value.tuned) {
      targetNote.value.tuned = checkWaveData();
      update();
    }
  }

  bool checkWaveData() {
    if (targetNote.value.tuned) {
      return true;
    }
    WaveDataController waveDataController = Get.find();
    MicTechnicalDataController micTechnicalDataController = Get.find();
    int visibleSamplesPerSecond = micTechnicalDataController.samplesPerSecond ~/
        micTechnicalDataController.bufferSize;
    List<double> lastSeconds = waveDataController.visibleSamples.sublist(
        waveDataController.visibleSamples.length - visibleSamplesPerSecond,
        waveDataController.visibleSamples.length);
    for (var element in lastSeconds) {
      if (element > targetNote.value.frequency - 100 ||
          element < targetNote.value.frequency + 100) {
        return false;
      }
    }
    return true;
  }
}
