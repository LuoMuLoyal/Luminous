import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/network/client/session_store.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

/// Registers fallback values for mocktail's `any()` matcher on the
/// optional platform-specific parameters of [FlutterSecureStorage].
void _registerFallbacks() {
  registerFallbackValue(IOSOptions.defaultOptions);
}

/// Stubs [FlutterSecureStorage.read] to return [returnValue] for any key.
void _stubRead(_MockFlutterSecureStorage mock, {String? returnValue}) {
  when(
    () => mock.read(
      key: any(named: 'key'),
      iOptions: any(named: 'iOptions'),
      aOptions: any(named: 'aOptions'),
      lOptions: any(named: 'lOptions'),
      webOptions: any(named: 'webOptions'),
      mOptions: any(named: 'mOptions'),
      wOptions: any(named: 'wOptions'),
    ),
  ).thenAnswer((_) async => returnValue);
}

/// Stubs [FlutterSecureStorage.write] to succeed.
void _stubWrite(_MockFlutterSecureStorage mock) {
  when(
    () => mock.write(
      key: any(named: 'key'),
      value: any(named: 'value'),
      iOptions: any(named: 'iOptions'),
      aOptions: any(named: 'aOptions'),
      lOptions: any(named: 'lOptions'),
      webOptions: any(named: 'webOptions'),
      mOptions: any(named: 'mOptions'),
      wOptions: any(named: 'wOptions'),
    ),
  ).thenAnswer((_) async {});
}

/// Stubs [FlutterSecureStorage.delete] to succeed.
void _stubDelete(_MockFlutterSecureStorage mock) {
  when(
    () => mock.delete(
      key: any(named: 'key'),
      iOptions: any(named: 'iOptions'),
      aOptions: any(named: 'aOptions'),
      lOptions: any(named: 'lOptions'),
      webOptions: any(named: 'webOptions'),
      mOptions: any(named: 'mOptions'),
      wOptions: any(named: 'wOptions'),
    ),
  ).thenAnswer((_) async {});
}

void main() {
  setUpAll(_registerFallbacks);

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

  group('LucentSessionTokens', () {
    test('hasAccessToken is true for non-empty token', () {
      const tokens = LucentSessionTokens(
        accessToken: 'access',
        refreshToken: 'refresh',
      );
      expect(tokens.hasAccessToken, isTrue);
    });

    test('hasAccessToken is false for empty token', () {
      const tokens = LucentSessionTokens(
        accessToken: '',
        refreshToken: 'refresh',
      );
      expect(tokens.hasAccessToken, isFalse);
    });

    test('hasAccessToken is false for whitespace-only token', () {
      const tokens = LucentSessionTokens(
        accessToken: '   ',
        refreshToken: 'refresh',
      );
      expect(tokens.hasAccessToken, isFalse);
    });

    test('hasRefreshToken is true for non-empty token', () {
      const tokens = LucentSessionTokens(
        accessToken: 'access',
        refreshToken: 'refresh',
      );
      expect(tokens.hasRefreshToken, isTrue);
    });

    test('hasRefreshToken is false for empty token', () {
      const tokens = LucentSessionTokens(
        accessToken: 'access',
        refreshToken: '',
      );
      expect(tokens.hasRefreshToken, isFalse);
    });

    test('hasRefreshToken is false for whitespace-only token', () {
      const tokens = LucentSessionTokens(
        accessToken: 'access',
        refreshToken: '  ',
      );
      expect(tokens.hasRefreshToken, isFalse);
    });
  });

  group('SecureLucentSessionStore', () {
    late _MockFlutterSecureStorage mockStorage;
    late SecureLucentSessionStore store;

    setUp(() {
      mockStorage = _MockFlutterSecureStorage();
      store = SecureLucentSessionStore(storage: mockStorage);
      _stubRead(mockStorage);
      _stubWrite(mockStorage);
      _stubDelete(mockStorage);
    });

    test('read returns null when no tokens stored', () async {
      _stubRead(mockStorage, returnValue: null);

      final tokens = await store.read();
      expect(tokens, isNull);
    });

    test('write then read returns the same tokens', () async {
      // Simulate write by capturing values and returning them on read.
      final writtenValues = <String, String>{};
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
          lOptions: any(named: 'lOptions'),
          webOptions: any(named: 'webOptions'),
          mOptions: any(named: 'mOptions'),
          wOptions: any(named: 'wOptions'),
        ),
      ).thenAnswer((inv) async {
        final key = inv.namedArguments[const Symbol('key')] as String;
        final value = inv.namedArguments[const Symbol('value')] as String?;
        if (value != null) writtenValues[key] = value;
      });

      when(
        () => mockStorage.read(
          key: any(named: 'key'),
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
          lOptions: any(named: 'lOptions'),
          webOptions: any(named: 'webOptions'),
          mOptions: any(named: 'mOptions'),
          wOptions: any(named: 'wOptions'),
        ),
      ).thenAnswer((inv) async {
        final key = inv.namedArguments[const Symbol('key')] as String;
        return writtenValues[key];
      });

      await store.write(
        const LucentSessionTokens(
          accessToken: 'secure-access',
          refreshToken: 'secure-refresh',
        ),
      );

      final tokens = await store.read();
      expect(tokens, isNotNull);
      expect(tokens!.accessToken, 'secure-access');
      expect(tokens.refreshToken, 'secure-refresh');
    });

    test('clear calls storage.delete for both keys', () async {
      await store.clear();

      verify(
        () => mockStorage.delete(
          key: SharedPrefsLucentSessionStore.accessTokenKey,
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
          lOptions: any(named: 'lOptions'),
          webOptions: any(named: 'webOptions'),
          mOptions: any(named: 'mOptions'),
          wOptions: any(named: 'wOptions'),
        ),
      ).called(1);

      verify(
        () => mockStorage.delete(
          key: SharedPrefsLucentSessionStore.refreshTokenKey,
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
          lOptions: any(named: 'lOptions'),
          webOptions: any(named: 'webOptions'),
          mOptions: any(named: 'mOptions'),
          wOptions: any(named: 'wOptions'),
        ),
      ).called(1);
    });

    test('write calls storage.write for both keys', () async {
      await store.write(
        const LucentSessionTokens(accessToken: 'acc', refreshToken: 'ref'),
      );

      verify(
        () => mockStorage.write(
          key: SharedPrefsLucentSessionStore.accessTokenKey,
          value: 'acc',
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
          lOptions: any(named: 'lOptions'),
          webOptions: any(named: 'webOptions'),
          mOptions: any(named: 'mOptions'),
          wOptions: any(named: 'wOptions'),
        ),
      ).called(1);

      verify(
        () => mockStorage.write(
          key: SharedPrefsLucentSessionStore.refreshTokenKey,
          value: 'ref',
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
          lOptions: any(named: 'lOptions'),
          webOptions: any(named: 'webOptions'),
          mOptions: any(named: 'mOptions'),
          wOptions: any(named: 'wOptions'),
        ),
      ).called(1);
    });

    test('write trims whitespace from tokens', () async {
      await store.write(
        const LucentSessionTokens(
          accessToken: '  padded-access  ',
          refreshToken: '  padded-refresh  ',
        ),
      );

      verify(
        () => mockStorage.write(
          key: SharedPrefsLucentSessionStore.accessTokenKey,
          value: 'padded-access',
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
          lOptions: any(named: 'lOptions'),
          webOptions: any(named: 'webOptions'),
          mOptions: any(named: 'mOptions'),
          wOptions: any(named: 'wOptions'),
        ),
      ).called(1);

      verify(
        () => mockStorage.write(
          key: SharedPrefsLucentSessionStore.refreshTokenKey,
          value: 'padded-refresh',
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
          lOptions: any(named: 'lOptions'),
          webOptions: any(named: 'webOptions'),
          mOptions: any(named: 'mOptions'),
          wOptions: any(named: 'wOptions'),
        ),
      ).called(1);
    });

    test('read returns null when only whitespace tokens stored', () async {
      when(
        () => mockStorage.read(
          key: any(named: 'key'),
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
          lOptions: any(named: 'lOptions'),
          webOptions: any(named: 'webOptions'),
          mOptions: any(named: 'mOptions'),
          wOptions: any(named: 'wOptions'),
        ),
      ).thenAnswer((_) async => '   ');

      final tokens = await store.read();
      expect(tokens, isNull);
    });

    test('read returns tokens when only access token is set', () async {
      when(
        () => mockStorage.read(
          key: any(named: 'key'),
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
          lOptions: any(named: 'lOptions'),
          webOptions: any(named: 'webOptions'),
          mOptions: any(named: 'mOptions'),
          wOptions: any(named: 'wOptions'),
        ),
      ).thenAnswer((inv) async {
        final key = inv.namedArguments[const Symbol('key')] as String;
        if (key == SharedPrefsLucentSessionStore.accessTokenKey) {
          return 'access-only';
        }
        return null;
      });

      final tokens = await store.read();
      expect(tokens, isNotNull);
      expect(tokens!.accessToken, 'access-only');
      expect(tokens.refreshToken, '');
    });

    test('read returns tokens when only refresh token is set', () async {
      when(
        () => mockStorage.read(
          key: any(named: 'key'),
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
          lOptions: any(named: 'lOptions'),
          webOptions: any(named: 'webOptions'),
          mOptions: any(named: 'mOptions'),
          wOptions: any(named: 'wOptions'),
        ),
      ).thenAnswer((inv) async {
        final key = inv.namedArguments[const Symbol('key')] as String;
        if (key == SharedPrefsLucentSessionStore.refreshTokenKey) {
          return 'refresh-only';
        }
        return null;
      });

      final tokens = await store.read();
      expect(tokens, isNotNull);
      expect(tokens!.accessToken, '');
      expect(tokens.refreshToken, 'refresh-only');
    });

    test('readAccessToken returns null when not stored', () async {
      _stubRead(mockStorage, returnValue: null);

      final token = await store.readAccessToken();
      expect(token, isNull);
    });

    test('readAccessToken returns trimmed token', () async {
      when(
        () => mockStorage.read(
          key: any(named: 'key'),
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
          lOptions: any(named: 'lOptions'),
          webOptions: any(named: 'webOptions'),
          mOptions: any(named: 'mOptions'),
          wOptions: any(named: 'wOptions'),
        ),
      ).thenAnswer((_) async => '  access-token  ');

      final token = await store.readAccessToken();
      expect(token, 'access-token');
    });

    test('readRefreshToken returns null when not stored', () async {
      _stubRead(mockStorage, returnValue: null);

      final token = await store.readRefreshToken();
      expect(token, isNull);
    });

    test('readRefreshToken returns trimmed token', () async {
      when(
        () => mockStorage.read(
          key: any(named: 'key'),
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
          lOptions: any(named: 'lOptions'),
          webOptions: any(named: 'webOptions'),
          mOptions: any(named: 'mOptions'),
          wOptions: any(named: 'wOptions'),
        ),
      ).thenAnswer((_) async => '  refresh-token  ');

      final token = await store.readRefreshToken();
      expect(token, 'refresh-token');
    });

    test('readAccessToken returns null for whitespace-only token', () async {
      when(
        () => mockStorage.read(
          key: any(named: 'key'),
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
          lOptions: any(named: 'lOptions'),
          webOptions: any(named: 'webOptions'),
          mOptions: any(named: 'mOptions'),
          wOptions: any(named: 'wOptions'),
        ),
      ).thenAnswer((_) async => '   ');

      final token = await store.readAccessToken();
      expect(token, isNull);
    });

    test('readRefreshToken returns null for whitespace-only token', () async {
      when(
        () => mockStorage.read(
          key: any(named: 'key'),
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
          lOptions: any(named: 'lOptions'),
          webOptions: any(named: 'webOptions'),
          mOptions: any(named: 'mOptions'),
          wOptions: any(named: 'wOptions'),
        ),
      ).thenAnswer((_) async => '   ');

      final token = await store.readRefreshToken();
      expect(token, isNull);
    });

    test('read calls storage.read for both keys', () async {
      when(
        () => mockStorage.read(
          key: SharedPrefsLucentSessionStore.accessTokenKey,
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
          lOptions: any(named: 'lOptions'),
          webOptions: any(named: 'webOptions'),
          mOptions: any(named: 'mOptions'),
          wOptions: any(named: 'wOptions'),
        ),
      ).thenAnswer((_) async => 'acc-val');

      when(
        () => mockStorage.read(
          key: SharedPrefsLucentSessionStore.refreshTokenKey,
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
          lOptions: any(named: 'lOptions'),
          webOptions: any(named: 'webOptions'),
          mOptions: any(named: 'mOptions'),
          wOptions: any(named: 'wOptions'),
        ),
      ).thenAnswer((_) async => 'ref-val');

      final tokens = await store.read();

      expect(tokens, isNotNull);
      expect(tokens!.accessToken, 'acc-val');
      expect(tokens.refreshToken, 'ref-val');
    });
  });
}
