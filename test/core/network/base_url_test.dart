import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/config/env_keys.dart';
import 'package:luminous/core/config/env_reader.dart';
import 'package:luminous/core/network/client/base_url.dart';

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
  });
}
