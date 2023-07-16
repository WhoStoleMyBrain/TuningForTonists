import 'package:fftea/fftea.dart';
import 'package:flutter/material.dart';
import 'package:mic_stream/mic_stream.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../controllers/mic_initialization_values_controller.dart';
import '../models/mic_technical_data.dart';
import '../models/wave_data.dart';
import '../providers/mic_technical_data.dart';
import '../widgets/mic_calculation_widget.dart';
import 'dart:math';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

// void _calculateDisplayData(dynamic samples) {

//   print('Calculating data...');
// }

class _MainScreenState extends State<MainScreen> {
  WaveData waveData = WaveData();
  void _calculateDisplayData(dynamic samples) {
    bool first = true;
    waveData.visibleSamples = [];
    int tmp = 0;
    for (int sample in samples) {
      if (sample > 128) sample -= 255;
      if (first) {
        tmp = sample * 128;
      } else {
        tmp += sample;
        waveData.visibleSamples?.add(tmp);

        waveData.localMax ??= waveData.visibleSamples?.last;
        waveData.localMin ??= waveData.visibleSamples?.last;
        waveData.localMax =
            max(waveData.localMax!, waveData.visibleSamples?.last ?? 0);
        waveData.localMin =
            min(waveData.localMin!, waveData.visibleSamples?.last ?? 0);
        tmp = 0;
      }
      first = !first;
    }
    waveData.currentSamples ??= [];
    List<double> doubleSamples =
        waveData.visibleSamples?.map((e) => e.toDouble()).toList() ?? [];
    final fft = FFT(doubleSamples.length);
    final freq = fft.realFft(doubleSamples).discardConjugates();
    var realFreq = freq
        .map((e) => sqrt(pow(e.x.toDouble(), 2) + pow(e.y.toDouble(), 2)))
        .where((element) => element.isNaN ? false : true)
        .toList();
    waveData.fftCurrentSamples = realFreq.sublist(0, realFreq.length ~/ 2);
    var maxFreq = realFreq.reduce(max);
    MicTechnicalData? micTechnicalData =
        Provider.of<MicTechnicalDataProvider>(context, listen: false)
            .micTechnicalData;
    final freqValue = realFreq.indexOf(maxFreq) *
        (Provider.of<MicTechnicalDataProvider>(context)
                .micTechnicalData
                ?.samplesPerSecond ??
            1) /
        doubleSamples.length;
    waveData.fftVisibleSamples?.add(freqValue > 0 ? log(freqValue.toInt()) : 0);
    if ((waveData.fftVisibleSamples?.length ?? 0) >
        (micTechnicalData?.samplesPerSecond ?? 1) *
            10 /
            (micTechnicalData?.bufferSize ?? 1)) {
      waveData.fftVisibleSamples = waveData.fftVisibleSamples?.sublist(1);
    }
    waveData.fftLocalMax ??= waveData.fftVisibleSamples?.reduce(max);
    waveData.fftLocalMin ??= waveData.fftVisibleSamples?.reduce(min);
    waveData.fftLocalMax =
        max(waveData.fftLocalMax!, waveData.fftVisibleSamples?.last ?? 1);
    waveData.fftLocalMin =
        min(waveData.fftLocalMin!, waveData.fftVisibleSamples?.last ?? 0);
    waveData.fftCurrentSamples = [];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.ac_unit_rounded),
      ),
      body: Column(
        children: [
          Text('Text before calculation Widget'),
          MicData(
            micInitializationValues: MicInitializationValuesController(
                audioFormat: AudioFormat.ENCODING_PCM_16BIT.obs,
                sampleRate: 48000.obs,
                channelConfig: ChannelConfig.CHANNEL_IN_MONO.obs,
                audioSource: AudioSource.DEFAULT.obs),
            calculateDisplayData: _calculateDisplayData,
            child: Text('Displaying data...'),
          )
        ],
      ),
    );
  }
}
