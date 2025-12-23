// Feed your own stream of bytes into the player
import 'package:just_audio/just_audio.dart';

class MyCustomAudioSource extends StreamAudioSource {
  final List<int> bytes;
  MyCustomAudioSource(this.bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}

// await player.setAudioSource(MyCustomSource());
// player.play();