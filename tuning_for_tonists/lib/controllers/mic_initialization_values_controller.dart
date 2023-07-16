import 'package:get/get.dart';
import 'package:mic_stream/mic_stream.dart';

class MicInitializationValuesController extends GetxController {
  Rx<AudioFormat> audioFormat;
  Rx<int> sampleRate;
  Rx<ChannelConfig> channelConfig;
  Rx<AudioSource> audioSource;

  MicInitializationValuesController(
      {required this.audioFormat,
      required this.sampleRate,
      required this.channelConfig,
      required this.audioSource});
}
