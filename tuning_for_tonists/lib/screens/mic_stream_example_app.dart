import 'dart:async';
import 'dart:math';

import 'package:fftea/fftea.dart';
import 'package:flutter/material.dart';
import 'package:mic_stream/mic_stream.dart';

import '../widgets/double_wave_painter.dart';
import '../widgets/statistics.dart';

enum Command {
  start,
  stop,
  change,
}

const AUDIO_FORMAT = AudioFormat.ENCODING_PCM_16BIT;

class MicStreamExampleApp extends StatefulWidget {
  const MicStreamExampleApp({super.key});

  @override
  _MicStreamExampleAppState createState() => _MicStreamExampleAppState();
}

class _MicStreamExampleAppState extends State<MicStreamExampleApp>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Stream? stream;
  late StreamSubscription listener;
  // WaveData waveData = WaveData();
  List<int>? currentSamples = [];
  List<double>? fftCurrentSamples = [];
  List<int> visibleSamples = [];
  List<double> fftVisibleSamples = [];
  int? localMax;
  int? localMin;
  double? fftLocalMax;
  double? fftLocalMin;

  // Random rng = Random();

  // Refreshes the Widget for every possible tick to force a rebuild of the sound wave
  late AnimationController controller;

  final Color _iconColor = Colors.white;
  bool isRecording = false;
  bool memRecordingState = false;
  late bool isActive;
  DateTime? startTime;

  int page = 0;
  List state = ["InformationPage"];

  @override
  void initState() {
    print("Init application");
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setState(() {
      initPlatformState();
    });
  }

  // Responsible for switching between recording / idle state
  void _controlMicStream({Command command: Command.change}) async {
    switch (command) {
      case Command.change:
        _changeListening();
        break;
      case Command.start:
        _startListening();
        break;
      case Command.stop:
        _stopListening();
        break;
    }
  }

  Future<bool> _changeListening() async =>
      !isRecording ? await _startListening() : _stopListening();

  late int bytesPerSample;
  late int samplesPerSecond;
  late int bufferSize;

  Future<bool> _startListening() async {
    print("START LISTENING");
    if (isRecording) return false;
    // if this is the first time invoking the microphone()
    // method to get the stream, we don't yet have access
    // to the sampleRate and bitDepth properties
    print("wait for stream");

    // Default option. Set to false to disable request permission dialogue
    MicStream.shouldRequestPermission(true);

    stream = await MicStream.microphone(
        audioSource: AudioSource.DEFAULT,
        // sampleRate: 1000 * (rng.nextInt(50) + 30),
        sampleRate: 48000,
        channelConfig: ChannelConfig.CHANNEL_IN_MONO,
        audioFormat: AUDIO_FORMAT);
    // after invoking the method for the first time, though, these will be available;
    // It is not necessary to setup a listener first, the stream only needs to be returned first
    print(
        "Start Listening to the microphone, sample rate is ${await MicStream.sampleRate}, bit depth is ${await MicStream.bitDepth}, bufferSize: ${await MicStream.bufferSize}");
    bytesPerSample = (await MicStream.bitDepth)! ~/ 8;
    samplesPerSecond = (await MicStream.sampleRate)!.toInt();
    bufferSize = (await MicStream.bufferSize)!.toInt();
    // localMax = null;
    // localMin = null;

    setState(() {
      isRecording = true;
      startTime = DateTime.now();
    });
    // visibleSamples = [];
    listener = stream!.listen(_calculateFrequencyOfSamples);
    return true;
  }

  void _calculateWaveSamples(samples) {
    bool first = true;

    visibleSamples = [];
    int tmp = 0;
    for (int sample in samples) {
      if (sample > 128) sample -= 255;
      if (first) {
        tmp = sample * 128;
      } else {
        tmp += sample;
        visibleSamples.add(tmp);

        localMax ??= visibleSamples.last;
        localMin ??= visibleSamples.last;
        localMax = max(localMax!, visibleSamples.last);
        localMin = min(localMin!, visibleSamples.last);

        tmp = 0;
      }
      first = !first;
    }
  }

  void _calculateFrequencyOfSamples(dynamic samples) {
    _calculateWaveSamples(samples);
    currentSamples ??= [];
    List<double> doubleSamples =
        visibleSamples.map((e) => e.toDouble()).toList();
    final fft = FFT(doubleSamples.length);
    final freq = fft.realFft(doubleSamples).discardConjugates();
    var realFreq = freq
        .map((e) => sqrt(pow(e.x.toDouble(), 2) + pow(e.y.toDouble(), 2)))
        .where((element) => element.isNaN ? false : true)
        .toList();
    fftCurrentSamples = realFreq.sublist(0, realFreq.length ~/ 2);
    var maxFreq = realFreq.reduce(max);
    final freqValue =
        realFreq.indexOf(maxFreq) * samplesPerSecond / doubleSamples.length;
    fftVisibleSamples.add(freqValue > 0 ? log(freqValue.toInt()) : 0);
    if (fftVisibleSamples.length > samplesPerSecond * 10 / bufferSize) {
      fftVisibleSamples = fftVisibleSamples.sublist(1);
    }
    fftLocalMax ??= fftVisibleSamples.reduce(max);
    fftLocalMin ??= fftVisibleSamples.reduce(min);
    fftLocalMax = max(fftLocalMax!, fftVisibleSamples.last);
    fftLocalMin = min(fftLocalMin!, fftVisibleSamples.last);
    fftCurrentSamples = [];
    setState(() {});
  }

  bool _stopListening() {
    if (!isRecording) return false;
    print("Stop Listening to the microphone");
    listener.cancel();

    setState(() {
      isRecording = false;
      currentSamples = null;
      startTime = null;
    });
    return true;
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if (!mounted) return;
    isActive = true;

    Statistics(false);

    controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this)
          ..addListener(() {
            if (isRecording) setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              controller.reverse();
            } else if (status == AnimationStatus.dismissed) {
              controller.forward();
            }
          })
          ..forward();
  }

  Color _getBgColor() => (isRecording) ? Colors.red : Colors.cyan;
  Icon _getIcon() =>
      (isRecording) ? const Icon(Icons.stop) : const Icon(Icons.keyboard_voice);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin: mic_stream :: Debug'),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _controlMicStream,
            foregroundColor: _iconColor,
            backgroundColor: _getBgColor(),
            tooltip: (isRecording) ? "Stop recording" : "Start recording",
            child: _getIcon(),
          ),
          body:
              // CustomPaint(
              //     painter: WavePainter(
              //       samples: visibleSamples,
              //       color: _getBgColor(),
              //       localMax: localMax,
              //       localMin: localMin,
              //       context: context,
              //     ),
              //   )
              // : (page == 2)
              CustomPaint(
            painter: DoubleWavePainter(
              samples: fftVisibleSamples,
              color: _getBgColor(),
              localMax: fftLocalMax,
              localMin: fftLocalMin,
              context: context,
            ),
          )),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      isActive = true;
      print("Resume app");

      _controlMicStream(
          command: memRecordingState ? Command.start : Command.stop);
    } else if (isActive) {
      memRecordingState = isRecording;
      _controlMicStream(command: Command.stop);

      print("Pause app");
      isActive = false;
    }
  }

  @override
  void dispose() {
    listener.cancel();
    controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
