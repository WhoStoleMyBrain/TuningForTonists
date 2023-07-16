import 'package:flutter/foundation.dart';

import '../models/mic_technical_data.dart';

class MicTechnicalDataProvider with ChangeNotifier {
  MicTechnicalData? _micTechnicalData;

  void setMicTechnicalData(
      int bytesPerSample, int samplesPerSecond, int bufferSize) {
    _micTechnicalData = MicTechnicalData(
        bytesPerSample: bytesPerSample,
        samplesPerSecond: samplesPerSecond,
        bufferSize: bufferSize);
  }

  MicTechnicalData? get micTechnicalData => _micTechnicalData;
}
