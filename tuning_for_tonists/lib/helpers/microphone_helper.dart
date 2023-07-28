import 'dart:typed_data';

import 'package:fftea/fftea.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mic_stream/mic_stream.dart';
import 'package:scidart/numdart.dart';
import 'package:scidart/scidart.dart';
import 'package:tuning_for_tonists/controllers/fft_controller.dart';
import '../controllers/mic_initialization_values_controller.dart';
import '../controllers/mic_technical_data_controller.dart';
import '../controllers/microphone_controller.dart';

import '../controllers/wave_data_controller.dart';

class MicrophoneHelper {
  static Future<Stream<Uint8List>?> getMicStream() async {
    final MicInitializationValuesController micInitializationValuesController =
        Get.find();
    final MicTechnicalDataController micTechnicalDataController = Get.find();
    MicStream.shouldRequestPermission(true);
    Stream<Uint8List>? stream = await MicStream.microphone(
        audioSource: micInitializationValuesController.audioSource.value,
        sampleRate: micInitializationValuesController.sampleRate.value,
        channelConfig: micInitializationValuesController.channelConfig.value,
        audioFormat: micInitializationValuesController.audioFormat.value);

    var bytesPerSample = (await MicStream.bitDepth)! ~/ 8;
    var samplesPerSecond = (await MicStream.sampleRate)!.toInt();
    var bufferSize = (await MicStream.bufferSize)!.toInt();
    micTechnicalDataController.setMicTechnicalData(
        bytesPerSample, samplesPerSecond, bufferSize);
    return stream;
  }

  static List<double> eightBitWaveDataCalculation(Uint8List samples) {
    Stopwatch stopwatch = Stopwatch()..start();
    print('start 8bit calc: ${stopwatch.elapsed}');
    List<double> waveData = [];
    Uint8List newSamples = samples.buffer.asUint8List(samples.offsetInBytes);
    print('new samples uint8list: ${stopwatch.elapsed}');
    for (int sample in newSamples) {
      double newSample = sample.toDouble();
      // if (newSample > 128) {
      newSample -= 128;
      // }
      newSample = newSample / 128;
      waveData.add(newSample);
    }
    print('wavedata added: ${stopwatch.elapsed}');
    // calculateNewAutocorrelation(waveData);
    // calculateAutocorrelation(waveData);
    print('autocorrelation calculated: ${stopwatch.elapsed}');
    return waveData;
  }

  static void intToByte(List<int> result, int i) {
    result.add(i & 0x00FF);
    result.add((i >> 8) & 0x000000FF);
    result.add((i >> 16) & 0x000000FF);
    result.add((i >> 24) & 0x000000FF);
  }

  static List<double> sixteenBitWaveDataCalculation(Uint8List samples) {
    MicTechnicalDataController micTechnicalDataController = Get.find();
    List<double> waveData = [];
    List<int> newSamples = [];
    if (micTechnicalDataController.bytesPerSample == 2) {
      newSamples = samples.buffer.asUint8List(4);
    } else {
      newSamples = samples.buffer.asUint8List(4);
    }
    double tmpSample = 0;
    bool first = true;
    for (int sample in newSamples) {
      if (sample > 128) sample -= 255;
      if (first) {
        tmpSample = sample * 128;
      } else {
        tmpSample += sample;
        // tmpSample =
        //     micTechnicalDataController.butterworth.filter(sample.toDouble());
        tmpSample /= 32768;
        waveData.add(tmpSample.toDouble());
        tmpSample = 0;
      }
      first = !first;
    }

    return waveData;
  }

  static void calculateAutocorrelation(List<double> samples) {
    WaveDataController waveDataController = Get.find();
    double mean =
        samples.reduce((value, element) => value + element) / samples.length;
    double sum =
        samples.reduce((value, element) => value + pow((element - mean), 2));
    List<double> autocorrelation = [];
    for (int k = 0; k < samples.length; k++) {
      double value = 0;
      for (int i = 1; i < samples.length - k; i++) {
        value += (samples[i] - mean) * (samples[k] - mean);
      }
      value /= sum;
      autocorrelation.add(value);
    }
    waveDataController.setAutocorrelationData(autocorrelation.sublist(1));
  }

  static void calculateNewAutocorrelation(List<double> samples) {
    Stopwatch stopwatch = Stopwatch()..start();
    print('autocorrelation start: ${stopwatch.elapsed}');
    WaveDataController waveDataController = Get.find();
    List<double> autocorrelation = [];
    double integral = 0;

    print('directly before loop: ${stopwatch.elapsed}');
    for (var i = 0; i < waveDataController.waveData.length ~/ 2; i++) {
      for (var j = i; j < waveDataController.waveData.length - i; j++) {
        integral +=
            waveDataController.waveData[i] * waveDataController.waveData[j];
      }
      autocorrelation.add(integral);
    }
    print('autocorrelation after loop calculation: ${stopwatch.elapsed}');
    waveDataController.setAutocorrelationData(autocorrelation.sublist(1));
    print(
        'autocorrelation after setting controller data: ${stopwatch.elapsed}');
  }

  static void calculateAutocorrelationStack(List<double> samples) {
    //TODO Either fully implement this or delete it... this was really way
    //TODO to difficult to calculate and also dont know where it leads
    // MicInitializationValuesController micInitializationValuesController =
    //     Get.find();
    // int fs = micInitializationValuesController.sampleRate.value;
    // int K = 3;
    // int L = 2048;
    // int M = 4096;
    // int N = 8192;
    // double maxValue = samples.reduce(max);
    // List<double> normalizedSamples = samples.map((e) => e / maxValue).toList();
    // int mi = samples.length ~/ 4;
    // var x = samples.sublist(mi, mi + K * M - (K - 1) * L);
    // var w = Window.hamming(M);
    // var welchResults = welch(x, w, L, N);
    // var Xsq = welchResults['Xsq'];
    // var bias = welchResults['bias'];
    // var p = welchResults['p'];
    // FFT xsqFft = FFT(Xsq.length);
    // List<double> Rxx = xsqFft.realFft(Xsq).discardConjugates().magnitudes();
    // Rxx = Rxx.map((e) => e / bias).toList();
    // var RxxMax = Rxx.reduce(max);
    // var mp = Rxx.firstWhere((element) => element == RxxMax) + 28;
    // N = L - (L % mp);
  }

  static void calculateAutocorrelationAlan() {
    WaveDataController waveDataController = Get.find();
    List<double> waveData = waveDataController.waveData;
    double mean =
        waveData.reduce((value, element) => value + element) / waveData.length;
    List<double> autocorrelation = List.filled(waveData.length ~/ 2, 0);
    for (var t = 0; t < autocorrelation.length; t++) {
      double n = 0;
      double d = 0;
      for (var i = 0; i < waveData.length; i++) {
        double xim = waveData[i] - mean;
        n += xim * (waveData[(i + t).remainder(waveData.length)] - mean);
        d += xim * xim;
      }
      autocorrelation[t] = n / d;
    }
    print('autocorrelation: ${autocorrelation}');
    waveDataController.setAutocorrelationData(autocorrelation.sublist(1));
  }

  static Map<String, dynamic> welch(
      List<double> x, Float64List w, int L, int N) {
    int M = w.length;
    int K = (x.length - L) ~/ (M - L);
    List<double> Xsq = List.filled(N ~/ 2 + 1, 0); // len(N-point rfft) = N/2+1
    for (var k = 0; k < K; k++) {
      int m = k * (M - L);
      List<double> xt = [];
      x.sublist(m, m + M).asMap().forEach((key, value) {
        xt.add(value * w[key]);
      }); // w * x.sublist(m, m+M);
      FFT fft = FFT(xt.length); //Should be N??
      var tmp = fft.realFft(xt).discardConjugates().magnitudes();
      tmp.asMap().forEach(
        (key, value) {
          Xsq[key] += value;
        },
      );
    }
    Xsq = Xsq.map((e) => e / K).toList();
    FFT wfft = FFT(w.length); //should be N??
    var Wsq = wfft.realFft(w).discardConjugates();
    var WsqMags = Wsq.magnitudes();
    var bias = wfft.realInverseFft(Wsq); //for unbiasing Rxx and Sxx
    var p = x.reduce((value, element) => value + element * element) /
        x.length; // avg power, used as a check
    return {'Xsq': Xsq, 'bias': bias, 'p': p};
  }

  static List<double> calculateWaveData(Uint8List samples) {
    Stopwatch stopwatch = Stopwatch()..start();
    print('start: ${stopwatch.elapsed}');
    MicInitializationValuesController micInitializationValuesController =
        Get.find();
    print('found mic init controller: ${stopwatch.elapsed}');

    List<double> waveData = [];
    if (micInitializationValuesController.audioFormat.value ==
        AudioFormat.ENCODING_PCM_8BIT) {
      print('before calculate 8bit: ${stopwatch.elapsed}');
      waveData = eightBitWaveDataCalculation(samples);
      // print('waveData: $waveData');
      print('after calculate 8bit: ${stopwatch.elapsed}');
    } else if (micInitializationValuesController.audioFormat.value ==
        AudioFormat.ENCODING_PCM_16BIT) {
      print('before calculate 16bit: ${stopwatch.elapsed}');
      waveData = sixteenBitWaveDataCalculation(samples);
      print('after calculate 16bit: ${stopwatch.elapsed}');
    } else {
      if (kDebugMode) {
        print(
            'Major error in wave data calculation. The defined audio format ${micInitializationValuesController.audioFormat.value} is not implemented!!');
      }
    }
    return waveData;
  }

  static void calculateHPSManually() {
    WaveDataController waveDataController = Get.find();
    MicInitializationValuesController micInitializationValuesController =
        Get.find();
    MicTechnicalDataController micTechnicalDataController = Get.find();
    // List<double> audio = waveDataController.waveData;
    List<double> fft = waveDataController.fftData;
    int N = 3;
    List<double> hps = List.from(fft);
    // print('orig hps: ${hps.sublist(0, 10)}');
    for (var downSampling = 2; downSampling <= N; downSampling++) {
      // List<double> downsampledFft = [];
      for (var i = 0; i < fft.length; i++) {
        hps[i] = hps[i] * fft[(i * downSampling).remainder(fft.length)];
      }
      // print('downsampled $downSampling times hps: ${hps.sublist(0, 10)}');
    }
    waveDataController.setHPSData(hps);
    var maxValue = hps.reduce(max);
    // var maxIdx = hps.firstWhere((element) => element == maxValue);
    var maxIdx = hps.indexOf(maxValue);
    var freq = maxIdx *
        micInitializationValuesController.sampleRate.value /
        micTechnicalDataController.bufferSize;

    waveDataController.addHPSVisibleSamples([freq]);
  }

  static void calculateHPS() {
    WaveDataController waveDataController = Get.find();
    List<double> audio = waveDataController.waveData;
    const chunkSize = 1024;
    final stft = STFT(chunkSize, Window.hamming(chunkSize));
    Float64List hps = Float64List(0);
    List<double> hpsMaxes = [];
    List<dynamic> ax = [];
    stft.run(audio, (Float64x2List freq) {
      List<double> tmp = freq.discardConjugates().magnitudes();
      // tmp.setRange(tmp., end, iterable)

      hps = Float64List.fromList(tmp);
      int N = 2;
      List<double> newTmp = [];
      for (var element in tmp) {
        newTmp.add(element);
      }

      newTmp.addAll(List.filled(tmp.length * N, 0.0));
      // tmp.addAll(List.filled(tmp.length * N, 0.0));
      for (int downsamplingFactor = 2;
          downsamplingFactor <= N;
          downsamplingFactor++) {
        // print('downsamplingfactor: $downsamplingFactor');
        // for (var i = 0; i < tmp.length~/downsamplingFactor; i++) {
        // for (var i = 0; i < downsamplingFactor; i++) {

        // }

        hps.asMap().forEach((key, value) {
          hps[key] = value * newTmp[key * downsamplingFactor];
        });
        // hps[i] *= tmp[i];
        // }
      }
      // hps = hps.sublist();

      hps = hps.sublist(31, 435);

      ax = findPeaks(Array(hps), threshold: 100);

      var hpsMax = hps.reduce(max);
      var hpsMaxBin = hps.indexWhere((element) => element == hpsMax);
      hpsMaxes.add(hpsMaxBin.toDouble() + 31);
    }, chunkSize ~/ 2);
    var meanHpsMax =
        hpsMaxes.reduce((value, element) => value + element) / hpsMaxes.length;
    MicInitializationValuesController micInitializationValuesController =
        Get.find();
    var maxFreqHPS = (meanHpsMax) *
        micInitializationValuesController.sampleRate.value /
        chunkSize;

    waveDataController.setHPSData(hps.sublist(0, 100));
    // waveDataController.addVisibleSample(maxFreqHPS);
    // print('hps length: ${hps.length}');
    // print('val: $ax');
    // print('hps: $hps');
    // print('hpsMaxList: $hpsMaxes');
    // print('hpsMax: $meanHpsMax');
    // print('maxFreqHPS: $maxFreqHPS');
  }

  static void calculateFrequency() {
    Stopwatch stopwatch = Stopwatch()..start();
    WaveDataController waveDataController = Get.find();
    FftController fftController = Get.find();
    final frequenciesList =
        fftController.applyRealFft(waveDataController.doubleWaveData);
    print('realFft: ${stopwatch.elapsed}');
    waveDataController.setFrequencyData(
        frequenciesList.sublist(2, frequenciesList.length ~/ 2));
    // waveDataController.setFrequencyData(frequenciesList);
    print('set frequency data: ${stopwatch.elapsed}');
    var freqValue = fftController.getMaxFrequency(waveDataController.fftData);
    // var freqValue = 0.0;
    print('get max frequency: ${stopwatch.elapsed}');
    waveDataController.addVisibleSample(freqValue);
    print('add visible sample: ${stopwatch.elapsed}');
  }

  static void calculateDisplayData(dynamic samples) {
    WaveDataController waveDataController = Get.find();

    Stopwatch stopwatch = Stopwatch()..start();

    waveDataController.addWaveData(calculateWaveData(samples));
    print('calculate Wavedata executed: ${stopwatch.elapsed}');
    // calculateHPS();
    calculateFrequency();
    print('frequency calculated: ${stopwatch.elapsed}');
    calculateHPSManually();
    print('hps calculated: ${stopwatch.elapsed}');
    // calculateAutocorrelationAlan();
    // print('autocorrelation calculated: ${stopwatch.elapsed}');

    // stopMicrophone();
  }

  static void stopMicrophone() {
    MicrophoneController microphoneController = Get.find();
    microphoneController.controlMicStream(command: Command.stop);
  }
}
