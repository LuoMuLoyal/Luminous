import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:luminous/features/scan/domain/services/ocr_service.dart';

void main() {
  group('ocrScriptForLocale', () {
    test('uses Chinese recognition for Chinese locales', () {
      expect(
        ocrScriptForLocale(const Locale('zh')),
        equals(TextRecognitionScript.chinese),
      );
    });

    test('uses Latin recognition for non-Chinese locales', () {
      expect(
        ocrScriptForLocale(const Locale('en')),
        equals(TextRecognitionScript.latin),
      );
      expect(
        ocrScriptForLocale(const Locale('fr')),
        equals(TextRecognitionScript.latin),
      );
    });
  });
}
