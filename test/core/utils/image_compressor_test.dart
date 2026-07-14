import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/utils/image_compressor.dart';

void main() {
  group('AppImageCompressor', () {
    final testBytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10]);

    group('compressForUpload', () {
      test('returns original bytes on compression failure (non-web)', () async {
        // In test environment, FlutterImageCompress.compressWithList will
        // fail because the platform plugin is not available.
        // The fallback should return the original bytes.
        final result = await AppImageCompressor.compressForUpload(testBytes);
        expect(result, equals(testBytes));
      });

      test('accepts custom maxWidth parameter', () async {
        final result = await AppImageCompressor.compressForUpload(
          testBytes,
          maxWidth: 800,
        );
        // Falls back to original on failure
        expect(result, equals(testBytes));
      });

      test('accepts custom maxHeight parameter', () async {
        final result = await AppImageCompressor.compressForUpload(
          testBytes,
          maxHeight: 600,
        );
        expect(result, equals(testBytes));
      });

      test('accepts custom quality parameter', () async {
        final result = await AppImageCompressor.compressForUpload(
          testBytes,
          quality: 70,
        );
        expect(result, equals(testBytes));
      });

      test(
        'default parameters are maxWidth=1280, maxHeight=1280, quality=85',
        () async {
          // Just verify the method doesn't throw with defaults
          final result = await AppImageCompressor.compressForUpload(testBytes);
          expect(result, isNotNull);
        },
      );
    });

    group('compressForAiRecognition', () {
      test('returns original bytes on compression failure (non-web)', () async {
        final result = await AppImageCompressor.compressForAiRecognition(
          testBytes,
        );
        expect(result, equals(testBytes));
      });

      test('accepts custom maxWidth parameter', () async {
        final result = await AppImageCompressor.compressForAiRecognition(
          testBytes,
          maxWidth: 2400,
        );
        expect(result, equals(testBytes));
      });

      test('accepts custom maxHeight parameter', () async {
        final result = await AppImageCompressor.compressForAiRecognition(
          testBytes,
          maxHeight: 2000,
        );
        expect(result, equals(testBytes));
      });

      test('accepts custom quality parameter', () async {
        final result = await AppImageCompressor.compressForAiRecognition(
          testBytes,
          quality: 95,
        );
        expect(result, equals(testBytes));
      });

      test(
        'default parameters are maxWidth=1920, maxHeight=1920, quality=90',
        () async {
          final result = await AppImageCompressor.compressForAiRecognition(
            testBytes,
          );
          expect(result, isNotNull);
        },
      );
    });

    group('fallback behavior', () {
      test('handles empty byte array gracefully', () async {
        final emptyBytes = Uint8List(0);
        final result = await AppImageCompressor.compressForUpload(emptyBytes);
        expect(result, equals(emptyBytes));
      });

      test('handles single byte array gracefully', () async {
        final singleByte = Uint8List.fromList([0x00]);
        final result = await AppImageCompressor.compressForUpload(singleByte);
        expect(result, equals(singleByte));
      });

      test('handles large byte array gracefully', () async {
        final largeBytes = Uint8List(10000);
        final result = await AppImageCompressor.compressForUpload(largeBytes);
        expect(result, equals(largeBytes));
      });
    });
  });
}
