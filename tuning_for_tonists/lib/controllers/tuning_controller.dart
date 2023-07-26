import 'package:get/get.dart';
import 'package:tuning_for_tonists/controllers/mic_technical_data_controller.dart';
import 'package:tuning_for_tonists/controllers/wave_data_controller.dart';

import '../models/note.dart';
import '../models/tuning_configuration.dart';

class TuningController extends GetxController {
  Rx<Note> _targetNote = Note(frequency: 440, name: 'A4', tuned: false).obs;
  Rx<double> _frequencyRange = 100.0.obs;

  Rx<TuningConfiguration>? _tuningConfiguration;

  void setTuningConfiguration(TuningConfiguration newTuningConfiguration) {
    _tuningConfiguration = newTuningConfiguration.obs;
    _targetNote = _tuningConfiguration!.value.notes.first.obs;
    refresh();
  }

  TuningConfiguration get tuningConfiguration => _tuningConfiguration!.value;

  double get frequencyRange => _frequencyRange.value;

  set frequencyRange(double newFrequencyRange) {
    _frequencyRange = newFrequencyRange.obs;
    update();
  }

  double get targetFrequency => _targetNote.value.frequency;

  set targetNote(Note note) {
    _targetNote = note.obs;
    update();
  }

  Note get targetNote => _targetNote.value;

  List<Note> get allNotes => _tuningConfiguration!.value.notes;

  void checkIfNoteTuned() {
    if (!_targetNote.value.tuned) {
      _targetNote.value.tuned = checkWaveData();
      update();
    }
  }

  bool checkWaveData() {
    if (_targetNote.value.tuned) {
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
      if (element > _targetNote.value.frequency - 100 ||
          element < _targetNote.value.frequency + 100) {
        return false;
      }
    }
    return true;
  }
}
