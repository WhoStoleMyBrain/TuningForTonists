import 'dart:core';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mic_stream/mic_stream.dart';
import 'package:provider/provider.dart';
import 'package:tuning_for_tonists/controllers/mic_initialization_values_controller.dart';
import 'package:tuning_for_tonists/controllers/mic_technical_data_controller.dart';
import 'package:tuning_for_tonists/controllers/wave_data_controller.dart';
import 'package:tuning_for_tonists/providers/mic_technical_data.dart';
import 'package:tuning_for_tonists/screens/main_screen.dart';

enum Command {
  start,
  stop,
  change,
}

// ignore: constant_identifier_names
const AUDIO_FORMAT = AudioFormat.ENCODING_PCM_16BIT;

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final MicInitializationValuesController micInitializationValuesController =
        Get.put(MicInitializationValuesController(
            audioFormat: AudioFormat.ENCODING_PCM_16BIT.obs,
            sampleRate: 48000.obs,
            channelConfig: ChannelConfig.CHANNEL_IN_MONO.obs,
            audioSource: AudioSource.DEFAULT.obs));
    final MicTechnicalDataController micTechnicalDataController =
        Get.put(MicTechnicalDataController());
    final WaveDataController waveDataController = Get.put(WaveDataController());
    return GetMaterialApp(
      title: 'Provider Package',
      // The theme of your application.
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home:
          const MainScreen(), // the widget below which in the widget-tree this provider is available
    );
  }
}

class AppHomePage extends StatefulWidget {
  const AppHomePage({super.key});

  @override
  State<AppHomePage> createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage> {
  late Stream<Uint8List>? stream;

  Stream<Uint8List>? fetchMicrophoneData() {
    return stream;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        stream = await MicStream.microphone(
            audioFormat: AudioFormat.ENCODING_PCM_16BIT,
            sampleRate: 48000,
            channelConfig: ChannelConfig.CHANNEL_IN_MONO,
            audioSource: AudioSource.DEFAULT);
        var bytesPerSample = (await MicStream.bitDepth)! ~/ 8;
        var samplesPerSecond = (await MicStream.sampleRate)!.toInt();
        var bufferSize = (await MicStream.bufferSize)!.toInt();
        Provider.of<MicTechnicalDataProvider>(context)
            .setMicTechnicalData(bytesPerSample, samplesPerSecond, bufferSize);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<Uint8List>(
          initialData: Uint8List.fromList([0, 1]),
          create: (_) => fetchMicrophoneData(),
        ),
        ChangeNotifierProvider(
          create: (_) => MicTechnicalDataProvider(),
        ),
      ],
      child: const MainScreen(),
    );
  }
}
