class WaveData {
  List<int>? currentSamples;
  List<double>? fftCurrentSamples;
  List<int>? visibleSamples;
  List<double>? fftVisibleSamples;
  int? localMax;
  int? localMin;
  double? fftLocalMax;
  double? fftLocalMin;

  WaveData({
    this.currentSamples,
    this.fftCurrentSamples,
    this.visibleSamples,
    this.fftVisibleSamples,
    this.localMax,
    this.localMin,
    this.fftLocalMax,
    this.fftLocalMin,
  });
}
