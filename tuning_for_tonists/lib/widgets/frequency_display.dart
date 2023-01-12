// import 'dart:typed_data';

import 'package:flutter/material.dart';

// import 'package:audio_session/audio_session.dart';
import 'package:flutter_fft/flutter_fft.dart';
// import 'package:flutter_sound/flutter_sound.dart';

import 'dart:async';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'frequency_display_flutter_sound.dart';

// const audioFormat = AudioFormat.ENCODING_PCM_16BIT;

// const int tSampleRate = 44100;

// ///
// const int tBlockSize = 4096;

// typedef _Fn = void Function();

class FrequencyDisplay extends StatefulWidget {
  const FrequencyDisplay({super.key});

  @override
  State<FrequencyDisplay> createState() => _FrequencyDisplayState();
}

class _FrequencyDisplayState extends State<FrequencyDisplay> {
  double? frequency;
  String? note;
  int? octave;
  bool? isRecording;

  List<FrequencyData> frequencyHistory2 = [FrequencyData(DateTime.now(), 0.0)];
  List<FrequencyData> frequencyHistory =
      List.filled(100, FrequencyData(DateTime.now(), 0.0), growable: true);

  FlutterFft flutterFft = FlutterFft();

  _initialize() async {
    print("Starting recorder...");
    // print("Before");
    // bool hasPermission = await flutterFft.checkPermission();
    // print("After: " + hasPermission.toString());

    // Keep asking for mic permission until accepted
    while (!(await flutterFft.checkPermission())) {
      flutterFft.requestPermission();
      // IF DENY QUIT PROGRAM
    }

    // await flutterFft.checkPermissions();
    await flutterFft.startRecorder();
    print("Recorder started...");
    setState(() => isRecording = flutterFft.getIsRecording);
    final periodicTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (DateTime.now()
              .difference(frequencyHistory.last.datetime)
              .inMilliseconds >
          100) {
        // print(DateTime.now()
        //     .difference(frequencyHistory.last.datetime)
        //     .inMilliseconds);
        setState(() {
          addDataToFrequencyDisplay(frequencyHistory.last.frequency);
          // frequencyHistory
          //     .add(FrequencyData.fromDouble(frequencyHistory.last.frequency));
        });
      }
    });
    DateTime.now().difference(DateTime.now()).inMilliseconds > 100;
    flutterFft.onRecorderStateChanged.listen(
        (data) => {
              print("Changed state, received: $data"),
              setState(
                () => {
                  frequency = data[1] as double,
                  note = data[2] as String,
                  octave = data[5] as int,
                },
              ),
              flutterFft.setNote = note!,
              flutterFft.setFrequency = frequency!,
              flutterFft.setOctave = octave!,
              // frequencyHistory.add(FrequencyData.fromDouble(
              //     frequency ?? frequencyHistory.last.frequency)),
              addDataToFrequencyDisplay(frequency),
              // print(frequencyHistory.length),
              // print("Octave: ${octave!.toString()}")
            },
        onError: (err) {
          print("Error: $err");
        },
        onDone: () => {print("Isdone")});
  }

  void addDataToFrequencyDisplay(double? frequency) {
    frequencyHistory.add(
        FrequencyData.fromDouble(frequency ?? frequencyHistory.last.frequency));
    if (frequencyHistory.length > 100) {
      frequencyHistory = frequencyHistory.sublist(
          frequencyHistory.length - 100, frequencyHistory.length);
    }
  }

  @override
  void initState() {
    isRecording = flutterFft.getIsRecording;
    frequency = flutterFft.getFrequency;
    note = flutterFft.getNote;
    octave = flutterFft.getOctave;
    super.initState();
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    Widget makeBody() {
      return Column(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isRecording!
                    ? Text("Current note: ${note!},${octave!.toString()}",
                        style: TextStyle(fontSize: 30))
                    : Text("Not Recording", style: TextStyle(fontSize: 35)),
                isRecording!
                    ? Text(
                        "Current frequency: ${frequency!.toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 30))
                    : Text("Not Recording", style: TextStyle(fontSize: 35))
              ],
            ),
          ),
          // Text('length of information saved in sink2:${sink2.length}'),
          Container(
            child: SfCartesianChart(
              // isTransposed: true,
              enableAxisAnimation: true,
              isTransposed: false,

              primaryXAxis: NumericAxis(),
              primaryYAxis: NumericAxis(isInversed: true),
              series: <LineSeries<FrequencyData, double>>[
                LineSeries<FrequencyData, double>(
                  dataSource: frequencyHistory,
                  xValueMapper: (FrequencyData frequencyData, _) =>
                      frequencyData.frequency,
                  yValueMapper: (FrequencyData frequencyData, _) =>
                      frequencyHistory.indexOf(frequencyData),
                )
              ],
            ),
          ),
          RecordToStreamExample()
        ],
      );
    }

    return makeBody();
  }
}

class FrequencyData {
  FrequencyData(this.datetime, this.frequency);
  final DateTime datetime;
  final double frequency;
  // factory FrequencyData.fromUint8List(Uint8List data) {
  //   return FrequencyData(DateTime.now(),
  //       data.toList().reduce((value, element) => value + element).toDouble());
  // }
  factory FrequencyData.fromDouble(double data) {
    return FrequencyData(DateTime.now(), data);
  }
}
