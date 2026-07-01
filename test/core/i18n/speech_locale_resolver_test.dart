import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/i18n/speech_locale_resolver.dart';

void main() {
  group('speechLocaleIdForAppLocale', () {
    test('maps Chinese locales to zh_CN', () {
      expect(speechLocaleIdForAppLocale(const Locale('zh')), equals('zh_CN'));
      expect(
        speechLocaleIdForAppLocale(const Locale('zh', 'TW')),
        equals('zh_CN'),
      );
    });

    test('maps non-Chinese locales to en_US', () {
      expect(speechLocaleIdForAppLocale(const Locale('en')), equals('en_US'));
      expect(speechLocaleIdForAppLocale(const Locale('fr')), equals('en_US'));
    });
  });

  group('resolveSpeechLocaleId', () {
    test('prefers exact locale when available', () {
      expect(
        resolveSpeechLocaleId(const Locale('zh'), const ['en_US', 'zh_CN']),
        equals('zh_CN'),
      );
    });

    test('falls back to a matching language variant', () {
      expect(
        resolveSpeechLocaleId(const Locale('en'), const ['en_GB', 'zh_CN']),
        equals('en_GB'),
      );
    });

    test('normalizes hyphenated locale ids', () {
      expect(
        resolveSpeechLocaleId(const Locale('zh'), const ['zh-CN']),
        equals('zh-CN'),
      );
    });

    test('returns null when no matching language exists', () {
      expect(
        resolveSpeechLocaleId(const Locale('zh'), const ['en_US']),
        isNull,
      );
    });
  });
}
