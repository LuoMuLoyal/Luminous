import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/network/lucent_session_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SharedPrefsLucentSessionStore', () {
    late SharedPrefsLucentSessionStore store;

    setUp(() {
      store = const SharedPrefsLucentSessionStore();
    });

    test('read returns null when no tokens stored', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final tokens = await store.read();
      expect(tokens, isNull);
    });

    test('write then read returns the same tokens', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await store.write(
        const LucentSessionTokens(
          accessToken: 'access-123',
          refreshToken: 'refresh-456',
        ),
      );

      final tokens = await store.read();
      expect(tokens, isNotNull);
      expect(tokens!.accessToken, equals('access-123'));
      expect(tokens.refreshToken, equals('refresh-456'));
    });

    test('clear removes stored tokens', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await store.write(
        const LucentSessionTokens(
          accessToken: 'temp-token',
          refreshToken: 'temp-refresh',
        ),
      );
      await store.clear();

      final tokens = await store.read();
      expect(tokens, isNull);
    });

    test('readAccessToken returns null when not stored', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final token = await store.readAccessToken();
      expect(token, isNull);
    });

    test('readAccessToken returns stored access token', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'lucent_access_token': 'my-access-token',
      });
      final token = await store.readAccessToken();
      expect(token, equals('my-access-token'));
    });

    test('readRefreshToken returns stored refresh token', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'lucent_refresh_token': 'my-refresh-token',
      });
      final token = await store.readRefreshToken();
      expect(token, equals('my-refresh-token'));
    });

    test('write trims whitespace from tokens', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await store.write(
        const LucentSessionTokens(
          accessToken: '  padded-token  ',
          refreshToken: '  padded-refresh  ',
        ),
      );

      final tokens = await store.read();
      expect(tokens!.accessToken, equals('padded-token'));
      expect(tokens.refreshToken, equals('padded-refresh'));
    });
  });
}
