class MicTechnicalData {
  int bytesPerSample;
  int samplesPerSecond;
  int bufferSize;

  MicTechnicalData(
      {required this.bytesPerSample,
      required this.samplesPerSecond,
      required this.bufferSize});
}
