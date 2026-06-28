import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/i18n/app_locale.dart';

void main() {
  group('AppLocale enum values', () {
    test('system storageValue', () {
      expect(AppLocale.system.storageValue, equals('system'));
    });

    test('en storageValue', () {
      expect(AppLocale.en.storageValue, equals('en'));
    });

    test('zhCn storageValue', () {
      expect(AppLocale.zhCn.storageValue, equals('zh-CN'));
    });
  });

  group('flutterLocale', () {
    test('system returns null', () {
      expect(AppLocale.system.flutterLocale, isNull);
    });

    test('en returns Locale(en)', () {
      expect(AppLocale.en.flutterLocale, equals(const Locale('en')));
    });

    test('zhCn returns Locale(zh)', () {
      expect(AppLocale.zhCn.flutterLocale, equals(const Locale('zh')));
    });
  });

  group('acceptLanguage', () {
    test('en returns en', () {
      expect(AppLocale.en.acceptLanguage, equals('en'));
    });

    test('zhCn returns zh-CN', () {
      expect(AppLocale.zhCn.acceptLanguage, equals('zh-CN'));
    });
  });

  group('fromStorage', () {
    test('returns matching locale for known values', () {
      expect(AppLocale.fromStorage('system'), equals(AppLocale.system));
      expect(AppLocale.fromStorage('en'), equals(AppLocale.en));
      expect(AppLocale.fromStorage('zh-CN'), equals(AppLocale.zhCn));
    });

    test('defaults to system for unknown values', () {
      expect(AppLocale.fromStorage('fr'), equals(AppLocale.system));
    });

    test('defaults to system for null', () {
      expect(AppLocale.fromStorage(null), equals(AppLocale.system));
    });

    test('defaults to system for empty string', () {
      expect(AppLocale.fromStorage(''), equals(AppLocale.system));
    });
  });

  group('fromBackendPreference', () {
    test('returns zhCn for zh prefix', () {
      expect(AppLocale.fromBackendPreference('zh'), equals(AppLocale.zhCn));
      expect(AppLocale.fromBackendPreference('zh-CN'), equals(AppLocale.zhCn));
      expect(AppLocale.fromBackendPreference('ZH'), equals(AppLocale.zhCn));
    });

    test('returns en for en prefix', () {
      expect(AppLocale.fromBackendPreference('en'), equals(AppLocale.en));
      expect(AppLocale.fromBackendPreference('en-US'), equals(AppLocale.en));
    });

    test('returns system for null', () {
      expect(AppLocale.fromBackendPreference(null), equals(AppLocale.system));
    });

    test('returns system for empty string', () {
      expect(AppLocale.fromBackendPreference(''), equals(AppLocale.system));
    });

    test('trims whitespace', () {
      expect(
        AppLocale.fromBackendPreference('  zh-CN  '),
        equals(AppLocale.zhCn),
      );
    });

    test('returns null for unsupported languages', () {
      expect(AppLocale.fromBackendPreference('fr'), isNull);
      expect(AppLocale.fromBackendPreference('de'), isNull);
      expect(AppLocale.fromBackendPreference('ja'), isNull);
    });
  });

  group('fromFlutterLocale', () {
    test('returns zhCn for Chinese locales', () {
      expect(
        AppLocale.fromFlutterLocale(const Locale('zh')),
        equals(AppLocale.zhCn),
      );
      expect(
        AppLocale.fromFlutterLocale(const Locale('zh', 'CN')),
        equals(AppLocale.zhCn),
      );
      expect(
        AppLocale.fromFlutterLocale(const Locale('zh', 'TW')),
        equals(AppLocale.zhCn),
      );
    });

    test('returns en for English locales', () {
      expect(
        AppLocale.fromFlutterLocale(const Locale('en')),
        equals(AppLocale.en),
      );
      expect(
        AppLocale.fromFlutterLocale(const Locale('en', 'US')),
        equals(AppLocale.en),
      );
    });

    test('returns en for other languages', () {
      expect(
        AppLocale.fromFlutterLocale(const Locale('fr')),
        equals(AppLocale.en),
      );
      expect(
        AppLocale.fromFlutterLocale(const Locale('de')),
        equals(AppLocale.en),
      );
      expect(
        AppLocale.fromFlutterLocale(const Locale('ja')),
        equals(AppLocale.en),
      );
    });
  });
}
