import 'package:get/get.dart';
import 'package:mic_stream/mic_stream.dart';

class MicInitializationValuesController extends GetxController {
  Rx<AudioFormat> audioFormat;
  Rx<int> _sampleRate;
  Rx<ChannelConfig> channelConfig;
  Rx<AudioSource> audioSource;
  MicInitializationValuesController(this._sampleRate,
      {required this.audioFormat,
      required this.channelConfig,
      required this.audioSource});
  void setAudioFormat(AudioFormat newAudioFormat) {
    audioFormat = newAudioFormat.obs;
    refresh();
  }

  set sampleRate(int newSampleRate) {
    _sampleRate = newSampleRate.obs;
  }

  int get sampleRate => _sampleRate.value;

  void setChannelConfig(ChannelConfig newChannelConfig) {
    channelConfig = newChannelConfig.obs;
  }

  void setAudioSource(AudioSource newAudioSource) {
    audioSource = newAudioSource.obs;
  }
}
