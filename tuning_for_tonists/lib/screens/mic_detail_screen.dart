import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mic_stream/mic_stream.dart';
import 'package:tuning_for_tonists/constants/app_colors.dart';
import 'package:tuning_for_tonists/controllers/fft_controller.dart';
import 'package:tuning_for_tonists/controllers/mic_initialization_values_controller.dart';
import 'package:tuning_for_tonists/controllers/mic_technical_data_controller.dart';
import 'package:tuning_for_tonists/controllers/microphone_controller.dart';
import 'package:tuning_for_tonists/controllers/wave_data_controller.dart';
import 'package:tuning_for_tonists/controllers/tuning_controller.dart';
import 'package:tuning_for_tonists/widgets/data_display.dart';
import 'package:tuning_for_tonists/widgets/mic_stream_control_button.dart';
import '../view_controllers/mic_detail_controller.dart';
import '../widgets/app_drawer.dart';

class MicDetailScreen extends StatefulWidget {
  const MicDetailScreen({super.key});

  @override
  State<MicDetailScreen> createState() => _MicDetailScreenState();
}

class _MicDetailScreenState extends State<MicDetailScreen> {
  @override
  Widget build(BuildContext context) {
    MicTechnicalDataController micTechnicalDataController = Get.find();
    MicInitializationValuesController micInitializationValuesController =
        Get.find();
    MicDetailController micDetailController = Get.find();
    WaveDataController waveDataController = Get.find();
    FftController fftController = Get.find();
    MicrophoneController microphoneController = Get.find();
    TuningController tuningController = Get.find();
    return Scaffold(
      key: micDetailController.scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.menu_sharp,
            color: AppColors.onPrimaryColor,
          ),
          onPressed: () => micDetailController.openDrawer(),
        ),
        title: Text(
          'Your Microphone Settings',
          style: const TextStyle()..apply(color: AppColors.onPrimaryColor),
        ),
      ),
      body: Obx(() {
        final latestFrequency = waveDataController.visibleSamples.isNotEmpty
            ? waveDataController.visibleSamples.last
            : 0.0;
        final confidence = waveDataController.confidence;
        final calculationType = waveDataController.calculationType.value;
        String runtimeValue(int value) =>
            value <= 1 ? 'Not Initialized' : value.toString();

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Initialization values:'),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Audio Format:'),
                      Text(
                          key: UniqueKey(),
                          ' ${micInitializationValuesController.audioFormat.value}'),
                    ],
                  ),
                  DropdownButton(
                    hint: const Text('Encoding'),
                    onChanged: (value) {
                      micInitializationValuesController.setAudioFormat(
                          value ?? AudioFormat.ENCODING_PCM_8BIT);
                      setState(
                        () {},
                      );
                    },
                    value: micInitializationValuesController.audioFormat.value,
                    items: AudioFormat.values
                        .map(
                          (e) => DropdownMenuItem(value: e, child: Text('$e')),
                        )
                        .toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Audio Source:'),
                      Text(
                          ' ${micInitializationValuesController.audioSource.value}')
                    ],
                  ),
                  DropdownButton(
                    hint: const Text('Audio Source'),
                    onChanged: (value) {
                      micInitializationValuesController
                          .setAudioSource(value ?? AudioSource.DEFAULT);
                      setState(
                        () {},
                      );
                    },
                    value: micInitializationValuesController.audioSource.value,
                    items: AudioSource.values
                        .map(
                          (e) => DropdownMenuItem(value: e, child: Text('$e')),
                        )
                        .toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Channel Config:'),
                      Text(
                          ' ${micInitializationValuesController.channelConfig.value}')
                    ],
                  ),
                  DropdownButton(
                    hint: const Text('Channel Config'),
                    onChanged: (value) {
                      micInitializationValuesController.setChannelConfig(
                          value ?? ChannelConfig.CHANNEL_IN_MONO);
                      setState(
                        () {},
                      );
                    },
                    value:
                        micInitializationValuesController.channelConfig.value,
                    items: ChannelConfig.values
                        .map(
                          (e) => DropdownMenuItem(value: e, child: Text('$e')),
                        )
                        .toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Sample Rate:'),
                      Text(' ${micInitializationValuesController.sampleRate}')
                    ],
                  ),
                  TextField(
                    decoration: InputDecoration(
                      label: const Text(
                        "Sample Rate 2",
                      ),
                      labelStyle: const TextStyle()
                        ..apply(color: AppColors.onPrimaryColor),
                      floatingLabelStyle: const TextStyle()
                        ..apply(color: AppColors.onPrimaryColor),
                      prefixStyle: const TextStyle()
                        ..apply(color: AppColors.onPrimaryColor),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onSubmitted: (value) {
                      micInitializationValuesController.sampleRate =
                          int.tryParse(value) ?? 0;
                      setState(
                        () {},
                      );
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(
                      label: const Text(
                        "Wave Data Length",
                      ),
                      labelStyle: const TextStyle()
                        ..apply(color: AppColors.onPrimaryColor),
                      floatingLabelStyle: const TextStyle()
                        ..apply(color: AppColors.onPrimaryColor),
                      prefixStyle: const TextStyle()
                        ..apply(color: AppColors.onPrimaryColor),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onSubmitted: (value) {
                      fftController
                          .setWaveDataLength(int.tryParse(value) ?? 4096);
                      setState(
                        () {},
                      );
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(
                      label: const Text(
                        "FFT Length",
                      ),
                      labelStyle: const TextStyle()
                        ..apply(color: AppColors.onPrimaryColor),
                      floatingLabelStyle: const TextStyle()
                        ..apply(color: AppColors.onPrimaryColor),
                      prefixStyle: const TextStyle()
                        ..apply(color: AppColors.onPrimaryColor),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onSubmitted: (value) {
                      fftController.fftLength = int.tryParse(value) ?? 0;
                      setState(
                        () {},
                      );
                    },
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Lock FFT length to wave data length'),
                    value: fftController.lockFftToWaveData.value,
                    onChanged: (value) {
                      fftController.setLockFftToWaveData(value ?? true);
                      setState(
                        () {},
                      );
                    },
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  const Text('Mic Config Data:'),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Buffer Size:'),
                      Text(
                          ' ${micTechnicalDataController.bufferSize == 0 ? "Not Initialized" : micTechnicalDataController.bufferSize}')
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('BytesPerSample:'),
                      Text(
                          ' ${micTechnicalDataController.bytesPerSample == 0 ? "Not Initialized" : micTechnicalDataController.bytesPerSample}')
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('SamplesPerSecond:'),
                      Text(
                          '${micTechnicalDataController.samplesPerSecond == 0 ? "Not Initialized" : micTechnicalDataController.samplesPerSecond}')
                    ],
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(
                      height: 32,
                    ),
                    const Text('Debug (runtime):'),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Runtime Sample Rate:'),
                        Text(
                            ' ${runtimeValue(micTechnicalDataController.samplesPerSecond)}')
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Runtime Buffer Size:'),
                        Text(
                            ' ${runtimeValue(micTechnicalDataController.bufferSize)}')
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Runtime Bit Depth:'),
                        Text(
                            ' ${micTechnicalDataController.bytesPerSample <= 1 ? "Not Initialized" : micTechnicalDataController.bytesPerSample * 8}')
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('FFT Resolution:'),
                        Text(
                            ' ${fftController.fftResolution.toStringAsFixed(2)} Hz/bin')
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Channel Config:'),
                        Text(
                            ' ${micInitializationValuesController.channelConfig.value}')
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Calculation Method:'),
                        Text(' $calculationType')
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Detected Frequency:'),
                        Text(' ${latestFrequency.toStringAsFixed(2)} Hz')
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Confidence (PAR):'),
                        Text(' ${confidence.toStringAsFixed(2)}')
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Confidence Threshold:'),
                        Text(
                            ' ${tuningController.confidenceThreshold.toStringAsFixed(2)}')
                      ],
                    ),
                  ],
                  const SizedBox(
                    height: 32,
                  ),
                  const Text('PCM Capture:'),
                  const SizedBox(
                    height: 8,
                  ),
                  ElevatedButton(
                    onPressed: microphoneController.isCapturing.isTrue
                        ? null
                        : () {
                            microphoneController.startPcmCapture();
                          },
                    child: Text(microphoneController.isCapturing.isTrue
                        ? 'Capturing...'
                        : 'Capture 3s Raw PCM'),
                  ),
                  if (microphoneController.lastCaptureStatus.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        microphoneController.lastCaptureStatus.value,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (microphoneController.lastCapturePath.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Last file: ${microphoneController.lastCapturePath.value}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(
                    height: 100,
                  ),
                  const MicStreamControlButton(),
                  const DataDisplay(),
                ],
              ),
            ),
          ),
        );
      }),
      drawer: const AppDrawer(),
    );
  }
}
