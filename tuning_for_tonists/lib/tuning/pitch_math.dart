import 'dart:math';

/// The closest equal-tempered note to a measured frequency.
class PitchMatch {
  const PitchMatch({
    required this.midiNote,
    required this.name,
    required this.frequency,
    required this.cents,
  });

  final int midiNote;
  final String name;
  final double frequency;

  /// Signed distance from [frequency], positive when the input is sharp.
  final double cents;
}

/// Pure pitch calculations shared by detection and presentation code.
abstract final class PitchMath {
  static const double defaultReferenceFrequency = 440.0;
  static const int _referenceMidiNote = 69;
  static const List<String> _sharpNoteNames = <String>[
    'C',
    'C#',
    'D',
    'D#',
    'E',
    'F',
    'F#',
    'G',
    'G#',
    'A',
    'A#',
    'B',
  ];

  /// Returns the signed cents interval from [reference] to [frequency].
  static double centsBetween(double frequency, double reference) {
    _validateFrequency(frequency, 'frequency');
    _validateFrequency(reference, 'reference');
    return 1200 * log(frequency / reference) / ln2;
  }

  /// Maps [frequency] to its nearest 12-tone equal-tempered note.
  static PitchMatch nearestNote(
    double frequency, {
    double referenceFrequency = defaultReferenceFrequency,
  }) {
    _validateFrequency(frequency, 'frequency');
    _validateFrequency(referenceFrequency, 'referenceFrequency');

    final midiNote =
        (_referenceMidiNote + 12 * log(frequency / referenceFrequency) / ln2)
            .round();
    final noteFrequency = referenceFrequency *
        pow(2, (midiNote - _referenceMidiNote) / 12).toDouble();
    final pitchClass = ((midiNote % 12) + 12) % 12;
    final octave = midiNote ~/ 12 - 1;

    return PitchMatch(
      midiNote: midiNote,
      name: '${_sharpNoteNames[pitchClass]}$octave',
      frequency: noteFrequency,
      cents: centsBetween(frequency, noteFrequency),
    );
  }

  static void _validateFrequency(double frequency, String argumentName) {
    if (!frequency.isFinite || frequency <= 0) {
      throw ArgumentError.value(
        frequency,
        argumentName,
        'must be finite and greater than zero',
      );
    }
  }
}
