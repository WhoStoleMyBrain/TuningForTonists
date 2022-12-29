import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
// import 'dart:async';
// import 'dart:typed_data';
// import 'package:sound_stream/sound_stream.dart';

import 'package:mic_stream/mic_stream.dart';

const audioFormat = AudioFormat.ENCODING_PCM_16BIT;

class MicrophoneData {
  MicrophoneData(this.time, this.frequency);
  final DateTime time;
  final double frequency;
}

enum Command {
  start,
  stop,
  change,
}

class FrequencyDisplay extends StatefulWidget {
  const FrequencyDisplay({super.key});

  @override
  State<FrequencyDisplay> createState() => _FrequencyDisplayState();
}

class _FrequencyDisplayState extends State<FrequencyDisplay>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final List<MicrophoneData> microphoneData = [
    MicrophoneData(DateTime.fromMillisecondsSinceEpoch(0), 2.0),
    MicrophoneData(DateTime.fromMillisecondsSinceEpoch(1), 1.0),
    MicrophoneData(DateTime.fromMillisecondsSinceEpoch(2), 4.0),
    MicrophoneData(DateTime.fromMillisecondsSinceEpoch(3), 3.0),
    MicrophoneData(DateTime.fromMillisecondsSinceEpoch(4), 2.0),
  ];
  Stream? stream;
  late StreamSubscription listener;
  List<int>? currentSamples = [];
  List<int> visibleSamples = [];
  int? localMax;
  int? localMin;
  Random rng = Random();

  // Refreshes the Widget for every possible tick to force a rebuild of the sound wave
  late AnimationController controller;

  final Color _iconColor = Colors.white;
  bool isRecording = false;
  bool memRecordingState = false;
  late bool isActive;
  DateTime? startTime;

  // int page = 0;
  List state = ["SoundWavePage", "IntensityWavePage", "InformationPage"];
  @override
  void initState() {
    // print("Init application");
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setState(() {
      initPlatformState();
    });
  }

  // Responsible for switching between recording / idle state
  void _controlMicStream({Command command = Command.change}) async {
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

  Future<bool> _startListening() async {
    // print("START LISTENING");
    if (isRecording) return false;
    // if this is the first time invoking the microphone()
    // method to get the stream, we don't yet have access
    // to the sampleRate and bitDepth properties
    // print("wait for stream");

    // Default option. Set to false to disable request permission dialogue
    MicStream.shouldRequestPermission(true);

    stream = await MicStream.microphone(
        audioSource: AudioSource.DEFAULT,
        // sampleRate: 1000 * (rng.nextInt(50) + 30),
        sampleRate: 16000,
        channelConfig: ChannelConfig.CHANNEL_IN_MONO,
        audioFormat: audioFormat);
    // after invoking the method for the first time, though, these will be available;
    // It is not necessary to setup a listener first, the stream only needs to be returned first
    print(
        "Start Listening to the microphone, sample rate is ${await MicStream.sampleRate}, bit depth is ${await MicStream.bitDepth}, bufferSize: ${await MicStream.bufferSize}");
    bytesPerSample = (await MicStream.bitDepth)! ~/ 8;
    samplesPerSecond = (await MicStream.sampleRate)!.toInt();
    localMax = null;
    localMin = null;

    setState(() {
      isRecording = true;
      startTime = DateTime.now();
    });
    visibleSamples = [];
    listener = stream!.listen(_calculateIntensitySamples);
    return true;
  }

  // void _calculateSamples(samples) {
  //   _calculateIntensitySamples(samples);
  // }

  void _calculateIntensitySamples(samples) {
    print(samples);
    print('samples: ${samples.length}');
    currentSamples ??= [];
    int currentSample = 0;
    eachWithIndex(samples, (i, int sample) {
      currentSample += sample;
      if ((i % bytesPerSample) == bytesPerSample - 1) {
        currentSamples!.add(currentSample);
        currentSample = 0;
      }

      // print('currentSamples : ${currentSamples?.length}');
      // if ((currentSamples?.length ?? 0) > samplesPerSecond * 10) {
      //   print('currentSamples too long: ${currentSamples?.length}');
      //   currentSamples = currentSamples!.sublist(0, samplesPerSecond * 10);
      // }
    });

    if (currentSamples!.length >= samplesPerSecond / 10) {
      print(currentSamples);
      print('current samples:${currentSamples?.length}');
      visibleSamples
          .add(currentSamples!.map((i) => i).toList().reduce((a, b) => a + b));
      print(visibleSamples);
      print('visible samples${visibleSamples.length}');
      localMax ??= visibleSamples.last;
      localMin ??= visibleSamples.last;
      localMax = max(localMax!, visibleSamples.last);
      localMin = min(localMin!, visibleSamples.last);
      currentSamples = [];
      // print('visible samples length: ${visibleSamples.length}');

      // print('samplesPerSecond: $samplesPerSecond');
      if (visibleSamples.length >= 10 * 10) {
        visibleSamples =
            visibleSamples.skip(visibleSamples.length - 10 * 10).toList();
        // visibleSamples.
      }
      setState(() {});
    }
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      isActive = true;
      // print("Resume app");

      _controlMicStream(
          command: memRecordingState ? Command.start : Command.stop);
    } else if (isActive) {
      memRecordingState = isRecording;
      _controlMicStream(command: Command.stop);

      // print("Pause app");
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            FloatingActionButton(
              onPressed: _controlMicStream,
              foregroundColor: _iconColor,
              backgroundColor: _getBgColor(),
              tooltip: (isRecording) ? "Stop recording" : "Start recording",
              child: _getIcon(),
            ),
          ],
        ),
        // Container(
        //   height: MediaQuery.of(context).size.height * 0.3,
        //   child: SfCartesianChart(
        //       isTransposed: true,
        //       primaryXAxis: DateTimeAxis(isInversed: true),
        //       series: <ChartSeries>[
        //         LineSeries<MicrophoneData, DateTime>(
        //           dataSource: microphoneData,
        //           xValueMapper: (MicrophoneData item, _) => item.time,
        //           yValueMapper: (MicrophoneData item, _) => item.frequency,
        //         )
        //       ]),
        // ),
        Container(
          height: MediaQuery.of(context).size.height * 0.2,
          child: CustomPaint(
            painter: WavePainter(
              samples: visibleSamples,
              color: _getBgColor(),
              localMax: localMax,
              localMin: localMin,
              context: context,
            ),
          ),
        )
      ],
    );
  }
}

class WavePainter extends CustomPainter {
  int? localMax;
  int? localMin;
  List<int>? samples;
  late List<Offset> points;
  Color? color;
  BuildContext? context;
  Size? size;

  // Set max val possible in stream, depending on the config
  int absMax =
      255 * 4; //(audioFormat == AudioFormat.ENCODING_PCM_8BIT) ? 127 : 32767;
  int absMin = (audioFormat == AudioFormat.ENCODING_PCM_8BIT) ? 127 : 32767;

  WavePainter(
      {this.samples, this.color, this.context, this.localMax, this.localMin});

  @override
  void paint(Canvas canvas, Size? size) {
    this.size = context!.size;
    size = this.size;

    Paint paint = Paint()
      ..color = color!
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    if (samples!.isEmpty) return;

    points = toPoints(samples);

    Path path = Path();
    path.addPolygon(points, false);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  // Maps a list of ints and their indices to a list of points on a cartesian grid
  List<Offset> toPoints(List<int>? samples) {
    List<Offset> points = [];
    samples ??= List<int>.filled(size!.width.toInt(), (0.5).toInt());
    double pixelsPerSample = size!.width / samples.length;
    if (localMin == localMax) {
      localMin = localMin! - 1;
    }
    for (int i = 0; i < samples.length; i++) {
      var point = Offset(
        0.5 *
            size!.height *
            pow((samples[i] - localMin!) / (localMax! - localMin!), 5),
        i * pixelsPerSample,
      );
      points.add(point);
    }

    // print(points);
    return points;
  }

  double project(int val, int max, double height) {
    double waveHeight =
        (max == 0) ? val.toDouble() : (val / max) * 0.5 * height;
    return waveHeight + 0.5 * height;
  }
}

Iterable<T> eachWithIndex<E, T>(
    Iterable<T> items, E Function(int index, T item) f) {
  var index = 0;

  for (final item in items) {
    f(index, item);
    index = index + 1;
  }

  return items;
}
