import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:tuning_for_tonists/enums/tuning_method.dart';
import '../controllers/mic_technical_data_controller.dart';
import '../controllers/wave_data_controller.dart';

import '../models/note.dart';
import '../models/tuning_configuration.dart';

class TuningController extends GetxController {
  Rx<Note> _targetNote = Note(frequency: 440, name: 'A4', tuned: false).obs;
  final Rx<double> _frequencyRange = 30.0.obs;
  final Rx<double> _centRange = 60.0.obs;
  final double _oneCent = 1.000577789;
  final double _oneCentLog = log(1.000577789);
  final double _oneHalfStep = 1.059463;
  double _centFactor = 0;
  final Rx<TuningMethod> _tuningMethod = TuningMethod.frequency.obs;
  final Rx<double> _percentageRight = 0.0.obs;
  final Rx<double> _percentageWrong = 0.0.obs;
  final Rx<double> _tuningThreshold = 0.95.obs;
  final Rx<double> _confidenceThreshold = 2.0.obs;
  final Rx<double> _tuningDistance = 0.0.obs;
  final Rx<Color> _tuningColor = const Color.fromRGBO(255, 0, 0, 1.0).obs;
  Logger logger = Logger(filter: DevelopmentFilter());

  Rx<String>? _activeInstrumentGroup;
  Rx<TuningConfiguration>? _tuningConfiguration;

  WaveDataController waveDataController = Get.find();
  MicTechnicalDataController micTechnicalDataController = Get.find();

  set tuningConfiguration(TuningConfiguration newTuningConfiguration) {
    _tuningConfiguration = newTuningConfiguration.obs;
    _targetNote = _tuningConfiguration!.value.notes.first.obs;
    refresh();
  }

  set activeInstrumentGroup(String newInstrumentGroup) {
    _activeInstrumentGroup = newInstrumentGroup.obs;
    refresh();
  }

  set tuningMethod(TuningMethod newTuningMethod) {
    _tuningMethod.value = newTuningMethod;
    refresh();
  }

  TuningMethod get tuningMethod => _tuningMethod.value;

  Color get tuningColor => _tuningColor.value;

  double get tuningDistance => _tuningDistance.value;

  double get centRange => _centRange.value;

  String get activeInstrumentGroup => _activeInstrumentGroup!.value;

  TuningConfiguration get tuningConfiguration => _tuningConfiguration!.value;

  double get frequencyRange => _frequencyRange.value;

  double get percentageRight => _percentageRight.value;
  double get percentageWrong => _percentageWrong.value;

  double get tuningThreshold => _tuningThreshold.value;
  double get confidenceThreshold => _confidenceThreshold.value;

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
    _centFactor = pow(_oneCent, _centRange.value).toDouble();
    update();
  }

  set percentageRight(double newPercentage) {
    _percentageRight.value = newPercentage;
  }

  set percentageWrong(double newPercentage) {
    _percentageWrong.value = newPercentage;
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
    if (waveDataController.confidence < confidenceThreshold) {
      percentageRight = 0.0;
      percentageWrong = 1.0;
      tuningDistance = 0.0;
      tuningColor = const Color.fromRGBO(255, 0, 0, 1.0);
      _targetNote.value.tuned = false;
      update();
      return;
    }
    var tuned = checkWaveData();
    _targetNote.value.tuned = tuned;
    update();
  }

  void unsetTunedNotes() {
    for (var element in _tuningConfiguration!.value.notes) {
      element.tuned = false;
    }
  }

  bool _inCentRange(double element) {
    return element / targetFrequency < _centFactor ||
        element / targetFrequency > 1 / _centFactor;
  }

  bool _inFrequencyRange(double element) {
    return element > (targetFrequency - frequencyRange) ||
        element < (targetFrequency + frequencyRange);
  }

  void _calculateCentDistance(List<double> lastSeconds) {
    tuningDistance = (lastSeconds.fold(
            0.0,
            (previousValue, element) =>
                previousValue + logCent(element / targetFrequency)) /
        lastSeconds.length);
  }

  double logCent(num x) => log(x) / _oneCentLog;

  void _calculateFrequencyDistance(List<double> lastSeconds) {
    tuningDistance = (lastSeconds
            .reduce((value, element) => value + (element - targetFrequency)) /
        lastSeconds.length);
  }

  List<double> _getLastSeconds() {
    List<double> lastSeconds = [];
    int visibleSamplesPerSecond = micTechnicalDataController.samplesPerSecond ~/
        micTechnicalDataController.bufferSize;
    lastSeconds = waveDataController.visibleSamples.sublist(
        waveDataController.visibleSamples.length - visibleSamplesPerSecond,
        waveDataController.visibleSamples.length);
    return lastSeconds;
  }

  void _calculateRightAndWrongPercentage(List<bool> sampleInFrequencyBand) {
    percentageRight = sampleInFrequencyBand.where((element) => element).length /
        sampleInFrequencyBand.length;
    percentageWrong = 1.0 - percentageRight;
  }

  bool _calculateTuningDistance(
      bool Function(double element) conditionCallback,
      Function(List<double> lastSeconds) distanceCalculationCallback,
      Function() setTuningColor) {
    List<double> lastSeconds;
    try {
      lastSeconds = _getLastSeconds();
    } catch (e) {
      logger.d('error occured: $e');
      waveDataController.resetVisibleData();
      return false;
    }
    List<bool> sampleInFrequencyBand =
        lastSeconds.map((e) => conditionCallback(e)).toList();
    _calculateRightAndWrongPercentage(sampleInFrequencyBand);
    distanceCalculationCallback(lastSeconds);
    setTuningColor();
    return percentageRight >= tuningThreshold;
  }

  bool checkWaveData() {
    switch (_tuningMethod.value) {
      case TuningMethod.cent:
        return _calculateTuningDistance(
            _inCentRange, _calculateCentDistance, setTuningColorCent);
      case TuningMethod.frequency:
        return _calculateTuningDistance(_inFrequencyRange,
            _calculateFrequencyDistance, setTuningColorFrequency);
      default:
        logger.d(
            "Tuning method did not match any of the enum values: ${_tuningMethod.value}");
        return false;
    }
  }

  void setTuningColorCent() {
    double averageDistance =
        tuningDistance.abs() > centRange ? centRange : tuningDistance.abs();
    int factor = (255 * (averageDistance / centRange)).toInt();
    tuningColor = Color.fromRGBO(0 + factor, 255 - factor, 0, 1.0);
    refresh();
  }

  void setTuningColorFrequency() {
    double averageDistance = tuningDistance.abs() > frequencyRange
        ? frequencyRange
        : tuningDistance.abs();
    int factor = (255 * (averageDistance / frequencyRange)).toInt();
    tuningColor = Color.fromRGBO(0 + factor, 255 - factor, 0, 1.0);
    refresh();
  }

  Color getTuningColorFromFrequency(double inputFrequency) {
    double averageDistance =
        (inputFrequency - targetFrequency).abs() > frequencyRange
            ? frequencyRange
            : (inputFrequency - targetFrequency).abs();
    int factor = (255 * (averageDistance / frequencyRange).abs()).toInt();
    Color newColor = Color.fromRGBO(0 + factor, 255 - factor, 0, 1.0);
    return newColor;
  }

  Color getTuningColorFromCent(double inputFrequency) {
    double averageDistance =
        (logCent(inputFrequency / targetFrequency)).abs() > centRange
            ? centRange
            : (logCent(inputFrequency / targetFrequency)).abs();
    int factor = (255 * (averageDistance / centRange).abs()).toInt();
    Color newColor = Color.fromRGBO(0 + factor, 255 - factor, 0, 1.0);
    return newColor;
  }

  List<ScatterSpot> getScatterData() {
    switch (_tuningMethod.value) {
      case TuningMethod.cent:
        return waveDataController.visibleSamples
            .asMap()
            .entries
            .map<ScatterSpot>((entry) => ScatterSpot(
                  entry.value,
                  entry.key.toDouble(),
                  show: true,
                  dotPainter: FlDotCirclePainter(
                      color: getTuningColorFromCent(entry.value), radius: 3),
                ))
            .toList();
      case TuningMethod.frequency:
        return waveDataController.visibleSamples
            .asMap()
            .entries
            .map<ScatterSpot>((entry) => ScatterSpot(
                  entry.value,
                  entry.key.toDouble(),
                  show: true,
                  dotPainter: FlDotCirclePainter(
                      color: getTuningColorFromFrequency(entry.value),
                      radius: 3),
                ))
            .toList();
      default:
        logger.d(
            "Tuning method did not match any values of the enum: ${_tuningMethod.value}");
        return [];
    }
  }
}
