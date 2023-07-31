import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/controllers/mic_technical_data_controller.dart';
import 'package:tuning_for_tonists/controllers/wave_data_controller.dart';
import 'dart:math';

import '../models/note.dart';
import '../models/tuning_configuration.dart';

class TuningController extends GetxController {
  Rx<Note> _targetNote = Note(frequency: 440, name: 'A4', tuned: false).obs;
  Rx<double> _frequencyRange = 30.0.obs;
  Rx<double> _percentageRight = 0.0.obs;
  Rx<double> _percentageWrong = 0.0.obs;
  Rx<double> _tuningThreshold = 0.95.obs;
  Rx<double> tuningDistance = 0.0.obs;
  Rx<Color> tuningColor = const Color.fromRGBO(255, 0, 0, 1.0).obs;

  Rx<TuningConfiguration>? _tuningConfiguration;

  WaveDataController waveDataController = Get.find();
  MicTechnicalDataController micTechnicalDataController = Get.find();

  void setTuningConfiguration(TuningConfiguration newTuningConfiguration) {
    _tuningConfiguration = newTuningConfiguration.obs;
    _targetNote = _tuningConfiguration!.value.notes.first.obs;
    refresh();
  }

  TuningConfiguration get tuningConfiguration => _tuningConfiguration!.value;

  double get frequencyRange => _frequencyRange.value;

  double get percentageRight => _percentageRight.value;
  double get percentageWrong => _percentageWrong.value;

  double get tuningThreshold => _tuningThreshold.value;

  set frequencyRange(double newFrequencyRange) {
    _frequencyRange = newFrequencyRange.obs;
    update();
  }

  set percentageRight(double newPercentage) {
    _percentageRight = newPercentage.obs;
    // refresh();
  }

  set percentageWrong(double newPercentage) {
    _percentageWrong = newPercentage.obs;
    // refresh();
  }

  set tuningThreshold(double newTuningThreshold) {
    _tuningThreshold = newTuningThreshold.obs;
    refresh();
  }

  double get targetFrequency => _targetNote.value.frequency;

  set targetNote(Note note) {
    _targetNote = note.obs;
    update();
  }

  Note get targetNote => _targetNote.value;

  List<Note> get allNotes => _tuningConfiguration!.value.notes;

  void checkIfNoteTuned() {
    // if (!_targetNote.value.tuned) {
    var tuned = checkWaveData();
    print('tuned: $tuned');
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
    tuningDistance = (lastSeconds.reduce(
                (value, element) => value + (element - targetFrequency).abs()) /
            lastSeconds.length)
        .obs;
    setTuningColor();
    if (percentageRight >= tuningThreshold) {
      return true;
    } else {
      return false;
    }
  }

  void setTuningColor() {
    var averageDistance =
        tuningDistance > frequencyRange ? frequencyRange : tuningDistance.value;
    int factor = (255 * (averageDistance / tuningDistance.value)).toInt();
    tuningColor = Color.fromRGBO(255 - factor, 0 + factor, 0, 1.0).obs;
    refresh();
  }
}
