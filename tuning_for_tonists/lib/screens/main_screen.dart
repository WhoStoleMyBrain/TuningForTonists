import 'package:fftea/fftea.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuning_for_tonists/controllers/mic_technical_data_controller.dart';
import 'package:tuning_for_tonists/view_controllers/home_controller.dart';
import 'package:tuning_for_tonists/widgets/app_drawer.dart';
import '../controllers/wave_data_controller.dart';
import '../widgets/mic_calculation_widget.dart';
import 'dart:math';

class MainScreen extends GetView<HomeController> {
  /// Calculate the wave data from the input mic stream.
  void _calculateDisplayData(dynamic samples) {
    WaveDataController waveDataController = Get.find();
    MicTechnicalDataController micTechnicalDataController = Get.find();
    bool first = true;
    int tmp = 0;
    List<int> waveData = [];
    for (int sample in samples) {
      if (sample > 128) sample -= 255;
      if (first) {
        tmp = sample * 128;
      } else {
        tmp += sample;
        waveData.add(tmp);
        tmp = 0;
      }
      first = !first;
    }
    waveDataController.addCurrentSamples(waveData);

    List<double> doubleWaveData =
        waveDataController.currentSamples.map((e) => e.toDouble()).toList();
    final fftLength = micTechnicalDataController.samplesPerSecond;
    // print('fftLength: $fftLength');
    final fft = FFT(fftLength);
    if (doubleWaveData.length < fftLength) {
      return;
    }
    final freq = fft
        .realFft(doubleWaveData.sublist(doubleWaveData.length - fftLength))
        .discardConjugates();
    var realFreq = freq
        .map((e) => sqrt(pow(e.x.toDouble(), 2) + pow(e.y.toDouble(), 2)))
        .where((element) => element.isNaN ? false : true)
        .toList();
    waveDataController.fftCurrentSamples =
        realFreq.sublist(0, realFreq.length ~/ 2).obs;
    var maxFreq = realFreq.reduce(max);
    final freqValue = realFreq.indexOf(maxFreq) *
        (micTechnicalDataController.samplesPerSecond) /
        fftLength;
    // print('freqValue: $freqValue');
    waveDataController.addVisibleSamples([freqValue > 0 ? freqValue : 0]);
    waveDataController.recalulateMinMax();
  }

  Widget getMicDisplay() {
    return Column(
      children: [
        const Text('Text before calculation Widget'),
        MicData(
          calculateDisplayData: _calculateDisplayData,
          child: const Text('Displaying data...'),
        )
      ],
    );
  }

  Future<bool> checkMicSettingsData() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      appBar: AppBar(
          leading: IconButton(
        icon: const Icon(Icons.menu_sharp),
        onPressed: () => controller.openDrawer(),
      )),
      body: getMicDisplay(),
      drawer: AppDrawer(),
    );
  }
}
