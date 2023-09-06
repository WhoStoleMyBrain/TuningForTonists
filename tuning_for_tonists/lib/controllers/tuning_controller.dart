import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/mic_technical_data_controller.dart';
import '../controllers/wave_data_controller.dart';

import '../models/note.dart';
import '../models/tuning_configuration.dart';

class TuningController extends GetxController {
  Rx<Note> _targetNote = Note(frequency: 440, name: 'A4', tuned: false).obs;
  final Rx<double> _frequencyRange = 30.0.obs;
  final Rx<double> _centRange = 60.0.obs;
  final Rx<double> _percentageRight = 0.0.obs;
  final Rx<double> _percentageWrong = 0.0.obs;
  final Rx<double> _tuningThreshold = 0.95.obs;
  final Rx<double> _tuningDistance = 0.0.obs;
  final Rx<Color> _tuningColor = const Color.fromRGBO(255, 0, 0, 1.0).obs;

  Rx<String>? _activeInstrumentGroup;
  Rx<TuningConfiguration>? _tuningConfiguration;

  WaveDataController waveDataController = Get.find();
  MicTechnicalDataController micTechnicalDataController = Get.find();

  void setTuningConfiguration(TuningConfiguration newTuningConfiguration) {
    _tuningConfiguration = newTuningConfiguration.obs;
    _targetNote = _tuningConfiguration!.value.notes.first.obs;
    refresh();
  }

  void setActiveInstrumentGroup(String newInstrumentGroup) {
    _activeInstrumentGroup = newInstrumentGroup.obs;
    refresh();
  }

  Color get tuningColor => _tuningColor.value;

  double get tuningDistance => _tuningDistance.value;

  double get centRange => _centRange.value;

  String get activeInstrumentGroup => _activeInstrumentGroup!.value;

  TuningConfiguration get tuningConfiguration => _tuningConfiguration!.value;

  double get frequencyRange => _frequencyRange.value;

  double get percentageRight => _percentageRight.value;
  double get percentageWrong => _percentageWrong.value;

  double get tuningThreshold => _tuningThreshold.value;

  set tuningColor(Color newColor) {
    _tuningColor.value = newColor;
    refresh();
  }

  set tuningDistance(double newTuningDistance) {
    _tuningDistance.value = newTuningDistance;
    refresh();
  }

  set frequencyRange(double newFrequencyRange) {
    _frequencyRange.value = newFrequencyRange;
    update();
  }

  set centRange(double newCentRange) {
    _centRange.value = newCentRange;
    update();
  }

  set percentageRight(double newPercentage) {
    _percentageRight.value = newPercentage;
    // refresh();
  }

  set percentageWrong(double newPercentage) {
    _percentageWrong.value = newPercentage;
    // refresh();
  }

  set tuningThreshold(double newTuningThreshold) {
    _tuningThreshold.value = newTuningThreshold;
    refresh();
  }

  double get targetFrequency => _targetNote.value.frequency;

  set targetNote(Note note) {
    _targetNote.value = note;
    update();
  }

  Note get targetNote => _targetNote.value;

  List<Note> get allNotes => _tuningConfiguration!.value.notes;

  void checkIfNoteTuned() {
    // if (!_targetNote.value.tuned) {
    var tuned = checkWaveData();
    if (kDebugMode) {
      print('tuned: $tuned');
    }
    _targetNote.value.tuned = tuned;
    update();
    // }
  }

  void unsetTunedNotes() {
    for (var element in _tuningConfiguration!.value.notes) {
      element.tuned = false;
    }
  }

  bool checkWaveData() {
    List<bool> sampleInFrequencyBand = [];

    int visibleSamplesPerSecond = micTechnicalDataController.samplesPerSecond ~/
        micTechnicalDataController.bufferSize;
    List<double> lastSeconds = waveDataController.visibleSamples.sublist(
        waveDataController.visibleSamples.length - visibleSamplesPerSecond,
        waveDataController.visibleSamples.length);
    for (var element in lastSeconds) {
      if (element < (targetFrequency - frequencyRange) ||
          element > (targetFrequency + frequencyRange)) {
        sampleInFrequencyBand.add(false);
      } else {
        sampleInFrequencyBand.add(true);
      }
    }
    double newPercentageRight =
        sampleInFrequencyBand.where((element) => element == true).length /
            sampleInFrequencyBand.length;
    double newPercentageWrong =
        sampleInFrequencyBand.where((element) => element == false).length /
            sampleInFrequencyBand.length;
    percentageRight = newPercentageRight;
    percentageWrong = newPercentageWrong;
    tuningDistance = (lastSeconds
            .reduce((value, element) => value + (element - targetFrequency)) /
        lastSeconds.length);

    setTuningColor();
    if (percentageRight >= tuningThreshold) {
      return true;
    } else {
      return false;
    }
  }

  void setTuningColor() {
    var averageDistance = tuningDistance.abs() > frequencyRange
        ? frequencyRange
        : tuningDistance.abs();
    int factor = (255 * (averageDistance / frequencyRange)).toInt();
    tuningColor = Color.fromRGBO(0 + factor, 255 - factor, 0, 1.0);
    refresh();
  }

  Color getTuningColorFromFrequency(double inputFrequency) {
    var averageDistance =
        (inputFrequency - targetFrequency).abs() > frequencyRange
            ? frequencyRange
            : (inputFrequency - targetFrequency).abs();
    int factor = (255 * (averageDistance / frequencyRange.abs())).toInt();
    var newColor = Color.fromRGBO(0 + factor, 255 - factor, 0, 1.0);
    return newColor;
  }

  List<ScatterSpot> getScatterData() {
    return waveDataController.visibleSamples
        // .sublist(150)
        .asMap()
        .entries
        .map<ScatterSpot>((entry) => ScatterSpot(
            entry.value, entry.key.toDouble(),
            show: true,
            radius: 3,
            color: getTuningColorFromFrequency(entry.value)))
        .toList();
  }
}
