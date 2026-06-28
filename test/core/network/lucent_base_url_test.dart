import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/network/lucent_base_url.dart';

void main() {
  group('LucentBaseUrl', () {
    test('defineKey is LUCENT_BASE_URL', () {
      expect(LucentBaseUrl.defineKey, equals('LUCENT_BASE_URL'));
    });

    test('returns dev fallback when LUCENT_BASE_URL is not set', () {
      dotenv.testLoad(mergeWith: <String, String>{});
      final url = LucentBaseUrl.value;
      expect(url, equals('http://127.0.0.1:3000'));
    });

    test('returns env value when LUCENT_BASE_URL is set', () {
      dotenv.testLoad(
        mergeWith: <String, String>{'LUCENT_BASE_URL': 'https://api.lumos.app'},
      );
      final url = LucentBaseUrl.value;
      expect(url, equals('https://api.lumos.app'));
    });

    test('trims whitespace from env value', () {
      dotenv.testLoad(
        mergeWith: <String, String>{
          'LUCENT_BASE_URL': '  https://api.test.com  ',
        },
      );
      final url = LucentBaseUrl.value;
      expect(url, equals('https://api.test.com'));
    });
  });
}
