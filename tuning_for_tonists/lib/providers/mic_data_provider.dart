import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class MicDataProvider with ChangeNotifier {
  List<int> _waveData = [];
  List<double> _frequencyData = [];
  List<double> _maxFrequencyData = [];
  int _samplesPerSecond = 48000;

  List<int> get waveData => _waveData;
  List<double> get frequencyData => _frequencyData;
  List<double> get maxFrequencyData => _maxFrequencyData;

  void _checkDataLengths() {
    if (_frequencyData.length > _samplesPerSecond) {
      _frequencyData = _frequencyData.sublist(1);
    }
    if (_maxFrequencyData.length > _samplesPerSecond) {
      _maxFrequencyData = _maxFrequencyData.sublist(1);
    }
  }

  void setSamplesPerSecond(int newSamplesPerSecond) {
    _samplesPerSecond = newSamplesPerSecond;
  }

  void addWaveData(List<int> newWaveData) {
    _waveData.addAll(waveData);
    notifyListeners();
  }

  void setWaveData(List<int> newWaveData) {
    _waveData = newWaveData;
    notifyListeners();
  }

  void addFrequencyData(List<double> newFrequencyData) {
    _frequencyData.addAll(newFrequencyData);
    notifyListeners();
  }

  void addMaxFrequencyData(List<double> newMaxFrequencyData) {
    _maxFrequencyData.addAll(newMaxFrequencyData);
    notifyListeners();
  }

  int get localMax => _waveData.isNotEmpty ? _waveData.reduce(max) : 1;
  int get localMin => _waveData.isNotEmpty ? _waveData.reduce(min) : 0;
  double get fftLocalMax =>
      _maxFrequencyData.isNotEmpty ? _maxFrequencyData.reduce(max) : 1;
  double get fftLocalMin =>
      _maxFrequencyData.isNotEmpty ? _maxFrequencyData.reduce(min) : 0;
}
