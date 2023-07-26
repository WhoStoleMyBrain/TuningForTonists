import 'package:tuning_for_tonists/models/note.dart';
import 'package:tuning_for_tonists/models/tuning_configuration.dart';

class Constants {
  // static List<TuningConfiguration> defaultTuningConfigurations =
  //     defaultGuitarTuningConfigurations
  //       ..addAll(defaultUkuleleTuningConfigurations);
  static List<TuningConfiguration> defaultGuitarTuningConfigurations = [
    TuningConfiguration([
      Note(frequency: 82.41, name: 'E2'),
      Note(frequency: 110.0, name: 'A2'),
      Note(frequency: 146.8, name: 'D3'),
      Note(frequency: 196.0, name: 'G3'),
      Note(frequency: 246.9, name: 'B3'),
      Note(frequency: 329.6, name: 'E4'),
    ], 'Standard Guitar (E-A-D-G-B-E)'),
    TuningConfiguration([
      Note(frequency: 82.41, name: 'E2'),
      Note(frequency: 110.0, name: 'A2'),
      Note(frequency: 138.6, name: 'C3#'),
      Note(frequency: 164.8, name: 'E3'),
      Note(frequency: 220.0, name: 'A3'),
      Note(frequency: 329.6, name: 'E4'),
    ], 'Open A (E-A-C#-E-A-E)'),
    TuningConfiguration([
      Note(frequency: 61.74, name: 'B1'),
      Note(frequency: 92.50, name: 'F2#'),
      Note(frequency: 123.5, name: 'B2'),
      Note(frequency: 185.0, name: 'F3#'),
      Note(frequency: 246.9, name: 'B3'),
      Note(frequency: 293.7, name: 'D4'),
    ], 'Open B (B-F#-B-F#-B-D)'),
    TuningConfiguration([
      Note(frequency: 130.8, name: 'C3'),
      Note(frequency: 164.8, name: 'E3'),
      Note(frequency: 196.0, name: 'G3'),
      Note(frequency: 261.6, name: 'C4'),
      Note(frequency: 329.6, name: 'E4'),
      Note(frequency: 392.0, name: 'G4'),
    ], 'Open C (C-E-G-C-E-G)'),
    TuningConfiguration([
      Note(frequency: 65.41, name: 'C2'),
      Note(frequency: 98.00, name: 'G2'),
      Note(frequency: 130.8, name: 'C3'),
      Note(frequency: 196.0, name: 'G3'),
      Note(frequency: 261.6, name: 'C4'),
      Note(frequency: 329.6, name: 'E4'),
    ], 'Open C (C-G-C-G-C-E)'),
    TuningConfiguration([
      Note(frequency: 65.41, name: 'C2'),
      Note(frequency: 130.8, name: 'C3'),
      Note(frequency: 196.0, name: 'G3'),
      Note(frequency: 261.6, name: 'C4'),
      Note(frequency: 329.6, name: 'E4'),
      Note(frequency: 392.0, name: 'G4'),
    ], 'Open C (C-C-G-C-E-G)'),
    TuningConfiguration([
      Note(frequency: 73.42, name: 'D2'),
      Note(frequency: 110.0, name: 'A2'),
      Note(frequency: 146.8, name: 'D3'),
      Note(frequency: 185.0, name: 'F3#'),
      Note(frequency: 220.0, name: 'A3'),
      Note(frequency: 293.7, name: 'D4'),
    ], 'Open D (D-A-D-F#-A-D)'),
  ];
  static List<TuningConfiguration> defaultUkuleleTuningConfigurations = [
    TuningConfiguration([
      Note(frequency: 330, name: 'A1'),
    ], 'My Ukulele Tuning'),
  ];
}
