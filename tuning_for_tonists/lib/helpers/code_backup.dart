  // static void calculateHPS() {
  //   WaveDataController waveDataController = Get.find();
  //   List<double> audio = waveDataController.waveData;
  //   const chunkSize = 1024;
  //   final stft = STFT(chunkSize, Window.hamming(chunkSize));
  //   Float64List hps = Float64List(0);
  //   List<double> hpsMaxes = [];
  //   stft.run(audio, (Float64x2List freq) {
  //     List<double> tmp = freq.discardConjugates().magnitudes();
  //     hps = Float64List.fromList(tmp);
  //     int N = 2;
  //     List<double> newTmp = [];
  //     for (var element in tmp) {
  //       newTmp.add(element);
  //     }

  //     newTmp.addAll(List.filled(tmp.length * N, 0.0));
  //     for (int downsamplingFactor = 2;
  //         downsamplingFactor <= N;
  //         downsamplingFactor++) {
  //       hps.asMap().forEach((key, value) {
  //         hps[key] = value * newTmp[key * downsamplingFactor];
  //       });
  //     }
  //     var hpsMax = hps.reduce(max);
  //     var hpsMaxBin = hps.indexWhere((element) => element == hpsMax);
  //     hpsMaxes.add(hpsMaxBin.toDouble() + 31);
  //   }, chunkSize ~/ 2);
  //   var meanHpsMax =
  //       hpsMaxes.reduce((value, element) => value + element) / hpsMaxes.length;
  //   MicInitializationValuesController micInitializationValuesController =
  //       Get.find();
  //   var maxFreqHPS = (meanHpsMax) *
  //       micInitializationValuesController.sampleRate.value /
  //       chunkSize;

  //   waveDataController.setHPSData(hps.sublist(0, 100));
  // }