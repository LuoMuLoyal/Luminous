import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/network/client/base_url.dart';
import 'package:luminous/core/network/config/env_keys.dart';
import 'package:luminous/core/network/config/env_reader.dart';

void main() {
  TargetPlatform? originalPlatform;

  setUp(() {
    originalPlatform = debugDefaultTargetPlatformOverride;
    // Force a non-Android platform so the dev fallback URL is 127.0.0.1,
    // not 10.0.2.2 (which is only correct for Android emulators).
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = originalPlatform;
    EnvReader.clearTestValues();
  });

  group('LucentBaseUrl', () {
    tearDown(EnvReader.clearTestValues);

    test('defineKey is LUCENT_BASE_URL', () {
      expect(LucentBaseUrl.defineKey, equals('LUCENT_BASE_URL'));
    });

    test('returns dev fallback when LUCENT_BASE_URL is not set', () {
      EnvReader.clearTestValues();
      expect(LucentBaseUrl.value, equals('http://127.0.0.1:3000'));
    });

    test('returns env value when LUCENT_BASE_URL is set', () {
      EnvReader.setTestValue(EnvKey.lucentBaseUrl, 'https://api.lumos.app');
      expect(LucentBaseUrl.value, equals('https://api.lumos.app'));
    });

    test('trims whitespace from env value', () {
      EnvReader.setTestValue(EnvKey.lucentBaseUrl, '  https://api.test.com  ');
      expect(LucentBaseUrl.value, equals('https://api.test.com'));
    });

    test('configured is null when LUCENT_BASE_URL is not set', () {
      EnvReader.clearTestValues();
      expect(LucentBaseUrl.configured, isNull);
    });

    test('configured returns the pinned URL, trimmed', () {
      EnvReader.setTestValue(EnvKey.lucentBaseUrl, '  https://api.test.com  ');
      expect(LucentBaseUrl.configured, equals('https://api.test.com'));
    });

    test('configured is null for a whitespace-only value', () {
      EnvReader.setTestValue(EnvKey.lucentBaseUrl, '   ');
      expect(LucentBaseUrl.configured, isNull);
      // value still yields the debug fallback rather than an empty URL.
      expect(LucentBaseUrl.value, equals('http://127.0.0.1:3000'));
    });

    group('normalize', () {
      test('prepends http:// when the scheme is missing', () {
        expect(
          LucentBaseUrl.normalize('122.9.102.50:3000'),
          equals('http://122.9.102.50:3000'),
        );
      });

      test('keeps an explicit https scheme and path', () {
        expect(
          LucentBaseUrl.normalize('https://api.example.com/v1'),
          equals('https://api.example.com/v1'),
        );
      });

      test('trims whitespace, quotes and trailing slashes', () {
        expect(
          LucentBaseUrl.normalize('  "https://api.example.com/"  '),
          equals('https://api.example.com'),
        );
      });

      test('returns null for blank input', () {
        expect(LucentBaseUrl.normalize(''), isNull);
        expect(LucentBaseUrl.normalize('   '), isNull);
      });

      test('rejects non-http(s) schemes and missing hosts', () {
        expect(LucentBaseUrl.normalize('ftp://files.example.com'), isNull);
        expect(LucentBaseUrl.normalize('http://'), isNull);
        expect(LucentBaseUrl.normalize('/relative/path'), isNull);
      });

      test('normalizes a scheme-less compile-time define', () {
        EnvReader.setTestValue(EnvKey.lucentBaseUrl, '122.9.102.50:3000');
        expect(LucentBaseUrl.configured, equals('http://122.9.102.50:3000'));
        expect(LucentBaseUrl.value, equals('http://122.9.102.50:3000'));
      });

      test('treats an unusable define as unset', () {
        EnvReader.setTestValue(EnvKey.lucentBaseUrl, 'ftp://files.example.com');
        expect(LucentBaseUrl.configured, isNull);
        expect(LucentBaseUrl.value, equals('http://127.0.0.1:3000'));
      });

      test('fallback is the platform-local development server', () {
        expect(LucentBaseUrl.fallback, equals('http://127.0.0.1:3000'));
      });
    });
  });
}
