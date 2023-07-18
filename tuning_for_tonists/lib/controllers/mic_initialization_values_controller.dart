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
  void setAudioFormat(AudioFormat newAudioFormat) {
    audioFormat = newAudioFormat.obs;
    refresh();
  }

  void setSampleRate(int newSampleRate) {
    sampleRate = newSampleRate.obs;
  }

  void setChannelConfig(ChannelConfig newChannelConfig) {
    channelConfig = newChannelConfig.obs;
  }

  void setAudioSource(AudioSource newAudioSource) {
    audioSource = newAudioSource.obs;
  }
}
