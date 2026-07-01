import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/record/domain/services/voice_recording_service.dart';

void main() {
  group('normalizeSpeechSoundLevel', () {
    test('clamps levels below the lower bound to zero', () {
      expect(normalizeSpeechSoundLevel(-20), equals(0));
    });

    test('maps the midpoint into the middle of the pulse range', () {
      expect(normalizeSpeechSoundLevel(4), equals(0.5));
    });

    test('clamps levels above the upper bound to one', () {
      expect(normalizeSpeechSoundLevel(42), equals(1));
    });
  });
}
