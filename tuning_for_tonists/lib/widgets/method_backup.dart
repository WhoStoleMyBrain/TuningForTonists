// void _calculateFrequencyOfSamples(dynamic samples) {
//   bool first = true;
//   waveData.visibleSamples = [];
//   int tmp = 0;
//   for (int sample in samples) {
//     if (sample > 128) sample -= 255;
//     if (first) {
//       tmp = sample * 128;
//     } else {
//       tmp += sample;
//       waveData.visibleSamples?.add(tmp);

//       waveData.localMax ??= waveData.visibleSamples?.last;
//       waveData.localMin ??= waveData.visibleSamples?.last;
//       waveData.localMax =
//           max(waveData.localMax!, waveData.visibleSamples?.last ?? 0);
//       waveData.localMin =
//           min(waveData.localMin!, waveData.visibleSamples?.last ?? 0);
//       tmp = 0;
//     }
//     first = !first;
//   }
//   waveData.currentSamples ??= [];
//   List<double> doubleSamples =
//       waveData.visibleSamples?.map((e) => e.toDouble()).toList() ?? [];
//   final fft = FFT(doubleSamples.length);
//   final freq = fft.realFft(doubleSamples).discardConjugates();
//   var realFreq = freq
//       .map((e) => sqrt(pow(e.x.toDouble(), 2) + pow(e.y.toDouble(), 2)))
//       .where((element) => element.isNaN ? false : true)
//       .toList();
//   waveData.fftCurrentSamples = realFreq.sublist(0, realFreq.length ~/ 2);
//   var maxFreq = realFreq.reduce(max);
//   final freqValue = realFreq.indexOf(maxFreq) *
//       micTechnicalData.samplesPerSecond /
//       doubleSamples.length;
//   waveData.fftVisibleSamples?.add(freqValue > 0 ? log(freqValue.toInt()) : 0);
//   if ((waveData.fftVisibleSamples?.length ?? 0) >
//       micTechnicalData.samplesPerSecond * 10 / micTechnicalData.bufferSize) {
//     waveData.fftVisibleSamples = waveData.fftVisibleSamples?.sublist(1);
//   }
//   waveData.fftLocalMax ??= waveData.fftVisibleSamples?.reduce(max);
//   waveData.fftLocalMin ??= waveData.fftVisibleSamples?.reduce(min);
//   waveData.fftLocalMax =
//       max(waveData.fftLocalMax!, waveData.fftVisibleSamples?.last ?? 1);
//   waveData.fftLocalMin =
//       min(waveData.fftLocalMin!, waveData.fftVisibleSamples?.last ?? 0);
//   waveData.fftCurrentSamples = [];
//   setState(() {});
// }
