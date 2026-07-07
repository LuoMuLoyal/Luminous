import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/config/env_keys.dart';
import 'package:luminous/core/config/env_reader.dart';
import 'package:luminous/core/network/base_url.dart';

void main() {
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
