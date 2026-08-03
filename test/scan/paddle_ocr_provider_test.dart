import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/scan/domain/services/paddle_ocr_provider.dart';
import 'package:paddle_ocr_native/paddle_ocr_native.dart';
import 'package:paddle_ocr_native/src/paddle_ocr_platform.dart'
    show PaddleOcrNativePlatform;

import '../helpers/mocks/scan.dart';

void main() {
  late FakePaddleOcrNativePlatform fakePlatform;

  setUpAll(() {
    // The PaddleOcr singleton captures PaddleOcrNativePlatform.instance at
    // construction, so the fake must be installed before any PaddleOcrEngine
    // is created.
    fakePlatform = FakePaddleOcrNativePlatform();
    PaddleOcrNativePlatform.instance = fakePlatform;
  });

  setUp(() async {
    // Every engine wraps the same process-wide PaddleOcr singleton. Reset its
    // internal initialized flag (by disposing a throwaway engine) and the
    // fake's counters so tests are independent.
    await PaddleOcrEngine().dispose();
    fakePlatform.initCalls = 0;
    fakePlatform.releaseCalls = 0;
    fakePlatform.initError = null;
    fakePlatform.recognizeResult = OcrRunResult.empty;
    fakePlatform.lastRecognizedPath = null;
  });

  OcrRunResult runWith(String text, double confidence) {
    return OcrRunResult(
      results: [
        OcrResult(
          text: text,
          confidence: confidence,
          points: const [OcrPoint(x: 10, y: 20), OcrPoint(x: 30, y: 40)],
        ),
      ],
      detectionTimeMs: 5,
      recognitionTimeMs: 10,
    );
  }

  group('PaddleOcrEngine', () {
    test('ensureInitialized initialises once and is idempotent', () async {
      final engine = PaddleOcrEngine();
      addTearDown(engine.dispose);

      await engine.ensureInitialized();
      await engine.ensureInitialized();

      expect(fakePlatform.initCalls, 1);
    });

    test('ensureInitialized propagates failure and allows retry', () async {
      fakePlatform.initError = StateError('ABI incompatible');
      final engine = PaddleOcrEngine();

      await expectLater(engine.ensureInitialized(), throwsA(isA<StateError>()));
      expect(fakePlatform.initCalls, 1);

      // Failure resets the flag, so a later successful call retries.
      fakePlatform.initError = null;
      await engine.ensureInitialized();
      expect(fakePlatform.initCalls, 2);
      addTearDown(engine.dispose);
    });

    test(
      'recognize lazily initialises and maps plugin results to domain',
      () async {
        fakePlatform.recognizeResult = runWith('阿莫西林胶囊', 0.98);
        final engine = PaddleOcrEngine();
        addTearDown(engine.dispose);

        final blocks = await engine.recognize('/tmp/box.jpg');

        expect(fakePlatform.initCalls, 1);
        expect(fakePlatform.lastRecognizedPath, '/tmp/box.jpg');
        expect(blocks, hasLength(1));
        expect(blocks.first.text, '阿莫西林胶囊');
        expect(blocks.first.confidence, 0.98);
        expect(blocks.first.points, const [Offset(10, 20), Offset(30, 40)]);
        expect(blocks.first.boundingBox, const Rect.fromLTRB(10, 20, 30, 40));
      },
    );

    test('recognize returns empty list for empty run', () async {
      fakePlatform.recognizeResult = OcrRunResult.empty;
      final engine = PaddleOcrEngine();
      addTearDown(engine.dispose);

      final blocks = await engine.recognize('/tmp/empty.jpg');

      expect(blocks, isEmpty);
    });

    test('dispose releases native sessions only when initialized', () async {
      final engine = PaddleOcrEngine();

      await engine.dispose();
      expect(fakePlatform.releaseCalls, 0);

      await engine.ensureInitialized();
      await engine.dispose();
      expect(fakePlatform.releaseCalls, 1);

      // Disposing again is a no-op.
      await engine.dispose();
      expect(fakePlatform.releaseCalls, 1);
    });
  });

  group('paddleOcrProvider', () {
    test('provides a shared engine instance and disposes it', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final engine = container.read(paddleOcrProvider);
      expect(engine, isA<PaddleOcrEngine>());

      await engine.ensureInitialized();
      expect(fakePlatform.initCalls, greaterThan(0));

      // On container dispose the native sessions are released.
      container.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(fakePlatform.releaseCalls, greaterThan(0));
    });
  });
}
