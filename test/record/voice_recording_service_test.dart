import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/record/domain/services/voice_recording_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class _MockSpeechToText extends Mock implements stt.SpeechToText {}

void main() {
  group('normalizeSpeechSoundLevel', () {
    test('clamps and normalizes -2.0 to 0.0', () {
      expect(normalizeSpeechSoundLevel(-2.0), 0.0);
    });

    test('clamps and normalizes 10.0 to 1.0', () {
      expect(normalizeSpeechSoundLevel(10.0), 1.0);
    });

    test('normalizes 4.0 to 0.5', () {
      expect(normalizeSpeechSoundLevel(4.0), 0.5);
    });

    test('clamps values below -2.0 to 0.0', () {
      expect(normalizeSpeechSoundLevel(-10.0), 0.0);
    });

    test('clamps values above 10.0 to 1.0', () {
      expect(normalizeSpeechSoundLevel(20.0), 1.0);
    });

    test('normalizes 0.0 to ~0.167', () {
      expect(normalizeSpeechSoundLevel(0.0), closeTo(0.167, 0.001));
    });
  });

  group('VoiceRecordingService', () {
    late _MockSpeechToText mockSpeech;
    late VoiceRecordingService service;

    setUp(() {
      mockSpeech = _MockSpeechToText();
      service = VoiceRecordingService(speech: mockSpeech);
    });

    tearDown(() {
      service.dispose();
    });

    test('isAvailable delegates to speech', () {
      when(() => mockSpeech.isAvailable).thenReturn(true);
      expect(service.isAvailable, isTrue);

      when(() => mockSpeech.isAvailable).thenReturn(false);
      expect(service.isAvailable, isFalse);
    });

    test('isListening delegates to speech', () {
      when(() => mockSpeech.isListening).thenReturn(true);
      expect(service.isListening, isTrue);
    });

    test('lastRecognizedWords delegates to speech', () {
      when(() => mockSpeech.lastRecognizedWords).thenReturn('hello world');
      expect(service.lastRecognizedWords, 'hello world');
    });

    test('hasPermission delegates to speech', () async {
      when(() => mockSpeech.hasPermission).thenAnswer((_) async => true);
      expect(await service.hasPermission, isTrue);
    });

    test('locales delegates to speech', () async {
      final localeNames = <stt.LocaleName>[
        stt.LocaleName('zh_CN', '中文（中国）'),
        stt.LocaleName('en_US', 'English (US)'),
      ];
      when(() => mockSpeech.locales())
          .thenAnswer((_) async => localeNames);
      final result = await service.locales();
      expect(result, hasLength(2));
      expect(result.first.localeId, 'zh_CN');
    });

    group('initialize', () {
      test('returns true when speech is already available', () async {
        when(() => mockSpeech.isAvailable).thenReturn(true);

        final result = await service.initialize(localeId: 'zh_CN');

        expect(result, isTrue);
        verifyNever(() => mockSpeech.initialize(
              onError: any(named: 'onError'),
              onStatus: any(named: 'onStatus'),
              debugLogging: any(named: 'debugLogging'),
            ));
      });

      test('returns true when speech.initialize succeeds', () async {
        when(() => mockSpeech.isAvailable).thenReturn(false);
        when(() => mockSpeech.initialize(
              onError: any(named: 'onError'),
              onStatus: any(named: 'onStatus'),
              debugLogging: any(named: 'debugLogging'),
            )).thenAnswer((_) async => true);

        final result = await service.initialize(localeId: 'zh_CN');

        expect(result, isTrue);
      });

      test('returns false when speech.initialize fails', () async {
        when(() => mockSpeech.isAvailable).thenReturn(false);
        when(() => mockSpeech.initialize(
              onError: any(named: 'onError'),
              onStatus: any(named: 'onStatus'),
              debugLogging: any(named: 'debugLogging'),
            )).thenAnswer((_) async => false);

        final result = await service.initialize(localeId: 'en_US');

        expect(result, isFalse);
      });
    });

    group('startListening', () {
      test('throws StateError when not available', () async {
        when(() => mockSpeech.isAvailable).thenReturn(false);

        expect(
          () => service.startListening(localeId: 'zh_CN'),
          throwsA(isA<StateError>()),
        );
      });

      test('calls speech.listen with correct options', () async {
        when(() => mockSpeech.isAvailable).thenReturn(true);
        when(() => mockSpeech.listen(
              onResult: any(named: 'onResult'),
              onSoundLevelChange: any(named: 'onSoundLevelChange'),
              listenOptions: any(named: 'listenOptions'),
            )).thenAnswer((_) async {});

        await service.startListening(localeId: 'zh_CN');

        verify(() => mockSpeech.listen(
              onResult: any(named: 'onResult'),
              onSoundLevelChange: any(named: 'onSoundLevelChange'),
              listenOptions: any(named: 'listenOptions'),
            )).called(1);
      });
    });

    group('stopListening', () {
      test('returns empty string when not available', () async {
        when(() => mockSpeech.isAvailable).thenReturn(false);

        final result = await service.stopListening();

        expect(result, isEmpty);
        verifyNever(() => mockSpeech.stop());
      });

      test('returns lastRecognizedWords after stop', () async {
        when(() => mockSpeech.isAvailable).thenReturn(true);
        when(() => mockSpeech.stop()).thenAnswer((_) async {});
        when(() => mockSpeech.lastRecognizedWords).thenReturn('final text');

        final result = await service.stopListening();

        expect(result, 'final text');
        verify(() => mockSpeech.stop()).called(1);
      });
    });

    group('cancelListening', () {
      test('does nothing when not available', () async {
        when(() => mockSpeech.isAvailable).thenReturn(false);

        await service.cancelListening();

        verifyNever(() => mockSpeech.cancel());
      });

      test('calls cancel when available', () async {
        when(() => mockSpeech.isAvailable).thenReturn(true);
        when(() => mockSpeech.cancel()).thenAnswer((_) async {});

        await service.cancelListening();

        verify(() => mockSpeech.cancel()).called(1);
      });
    });

    group('streams', () {
      test('soundLevelStream emits normalized values', () async {
        when(() => mockSpeech.isAvailable).thenReturn(true);
        when(() => mockSpeech.listen(
              onResult: any(named: 'onResult'),
              onSoundLevelChange: any(named: 'onSoundLevelChange'),
              listenOptions: any(named: 'listenOptions'),
            )).thenAnswer((invocation) async {
          final onSoundLevelChange = invocation.namedArguments[#onSoundLevelChange]
              as void Function(double);

          onSoundLevelChange(4.0); // Should normalize to 0.5
        });

        final emitted = <double>[];
        service.soundLevelStream.listen(emitted.add);

        await service.startListening(localeId: 'en_US');

        expect(emitted, [0.5]);
      });
    });

    test('dispose closes all stream controllers', () {
      when(() => mockSpeech.isAvailable).thenReturn(true);

      service.dispose();

      // After dispose, streams should not emit new values
      // This just verifies no exceptions are thrown
      service.recognizedTextStream.listen(null);
      service.listeningStatusStream.listen(null);
      service.soundLevelStream.listen(null);
      service.errorStream.listen(null);
    });
  });
}
