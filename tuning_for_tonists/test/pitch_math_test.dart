import 'package:flutter_test/flutter_test.dart';
import 'package:tuning_for_tonists/tuning/pitch_math.dart';

void main() {
  group('centsBetween', () {
    test('returns zero for matching frequencies', () {
      expect(PitchMath.centsBetween(440, 440), closeTo(0, 1e-10));
    });

    test('uses the correct sign and interval', () {
      expect(PitchMath.centsBetween(880, 440), closeTo(1200, 1e-10));
      expect(PitchMath.centsBetween(220, 440), closeTo(-1200, 1e-10));
      expect(
        PitchMath.centsBetween(440 * pow2OneCent, 440),
        closeTo(1, 1e-10),
      );
    });

    test('rejects invalid frequencies', () {
      expect(() => PitchMath.centsBetween(0, 440), throwsArgumentError);
      expect(
        () => PitchMath.centsBetween(440, double.infinity),
        throwsArgumentError,
      );
    });
  });

  group('nearestNote', () {
    test('maps standard reference pitches and octaves', () {
      final a4 = PitchMath.nearestNote(440);
      final middleC = PitchMath.nearestNote(261.625565);

      expect(a4.name, 'A4');
      expect(a4.midiNote, 69);
      expect(a4.frequency, closeTo(440, 1e-10));
      expect(a4.cents, closeTo(0, 1e-10));
      expect(middleC.name, 'C4');
      expect(middleC.midiNote, 60);
      expect(middleC.cents, closeTo(0, 0.001));
    });

    test('reports signed cents from the nearest note', () {
      expect(PitchMath.nearestNote(445).cents, closeTo(19.56, 0.01));
      expect(PitchMath.nearestNote(435).cents, closeTo(-19.79, 0.01));
    });

    test('supports a custom reference pitch', () {
      final match = PitchMath.nearestNote(442, referenceFrequency: 442);

      expect(match.name, 'A4');
      expect(match.frequency, 442);
      expect(match.cents, closeTo(0, 1e-10));
    });

    test('handles notes below MIDI note zero without invalid indexing', () {
      expect(PitchMath.nearestNote(4).name, 'C-2');
    });
  });
}

const double pow2OneCent = 1.0005777895065548;
