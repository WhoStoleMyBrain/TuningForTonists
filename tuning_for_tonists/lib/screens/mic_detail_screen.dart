import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mic_stream/mic_stream.dart';
import 'package:tuning_for_tonists/controllers/mic_initialization_values_controller.dart';
import 'package:tuning_for_tonists/controllers/mic_technical_data_controller.dart';
import 'package:tuning_for_tonists/controllers/wave_data_controller.dart';

import '../controllers/microphone_controller.dart';
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
    MicrophoneController microphoneController = Get.find();
    return Scaffold(
      key: micDetailController.scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_sharp),
          onPressed: () => micDetailController.openDrawer(),
        ),
        title: const Text('Your Microphone Settings'),
      ),
      body: Obx(
        () => Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
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
                        value ?? AudioFormat.ENCODING_PCM_16BIT);
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
                  value: micInitializationValuesController.channelConfig.value,
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
                    Text(
                        ' ${micInitializationValuesController.sampleRate.value}')
                  ],
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Sample Rate'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onSubmitted: (value) {
                    micInitializationValuesController
                        .setSampleRate(int.tryParse(value) ?? 0);
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
                const SizedBox(
                  height: 100,
                ),
                FloatingActionButton(
                  onPressed: microphoneController.controlMicStream,
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  tooltip: (microphoneController.isRecording)
                      ? "Stop recording"
                      : "Test microphone settings",
                  child: (microphoneController.isRecording)
                      ? const Icon(Icons.stop)
                      : const Icon(Icons.keyboard_voice),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: AppDrawer(),
    );
  }
}
