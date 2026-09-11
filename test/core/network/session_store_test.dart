import 'dart:convert';

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

/// Stubs the secure storage with a map-backed store, so writes and deletes take
/// effect for later reads (the plain `_stub*` helpers are fixed per-test fakes).
void _stubMapBackedStorage(
  _MockFlutterSecureStorage mock,
  Map<String, String> values,
) {
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
  ).thenAnswer((inv) async {
    values[inv.namedArguments[const Symbol('key')] as String] =
        inv.namedArguments[const Symbol('value')] as String;
  });

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
  ).thenAnswer(
    (inv) async => values[inv.namedArguments[const Symbol('key')] as String],
  );

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
  ).thenAnswer((inv) async {
    values.remove(inv.namedArguments[const Symbol('key')] as String);
  });
}

void main() {
  setUpAll(_registerFallbacks);

  group('SharedPrefsLucentSessionStore', () {
    late SharedPrefsLucentSessionStore store;

    setUp(() {
      store = const SharedPrefsLucentSessionStore();
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('read returns null when no tokens stored', () async {
      final tokens = await store.read();
      expect(tokens, isNull);
    });

    test('write then read returns the same tokens', () async {
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

    test(
      'write persists the pair in one store operation under a single key',
      () async {
        await store.write(
          const LucentSessionTokens(
            accessToken: 'access-123',
            refreshToken: 'refresh-456',
          ),
        );

        // One key carries the whole pair — a reader can never observe a torn
        // "new access token + old refresh token" state.
        final prefs = await SharedPreferences.getInstance();
        final payload = prefs.getString(
          SharedPrefsLucentSessionStore.payloadKey,
        );
        expect(payload, isNotNull);

        final decoded = jsonDecode(payload!) as Map<String, dynamic>;
        expect(decoded['accessToken'], 'access-123');
        expect(decoded['refreshToken'], 'refresh-456');
        expect(
          prefs.containsKey(SharedPrefsLucentSessionStore.refreshTokenKey),
          isFalse,
        );
      },
    );

    test('clear removes stored tokens', () async {
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
      final token = await store.readAccessToken();
      expect(token, isNull);
    });

    test('readAccessToken returns stored access token', () async {
      await store.write(
        const LucentSessionTokens(
          accessToken: 'my-access-token',
          refreshToken: 'my-refresh-token',
        ),
      );

      final token = await store.readAccessToken();
      expect(token, equals('my-access-token'));
    });

    test('readRefreshToken returns stored refresh token', () async {
      await store.write(
        const LucentSessionTokens(
          accessToken: 'my-access-token',
          refreshToken: 'my-refresh-token',
        ),
      );

      final token = await store.readRefreshToken();
      expect(token, equals('my-refresh-token'));
    });

    test('write trims whitespace from tokens', () async {
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

    test(
      'read migrates the legacy two-key layout and drops the legacy key',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          SharedPrefsLucentSessionStore.accessTokenKey: 'legacy-access',
          SharedPrefsLucentSessionStore.refreshTokenKey: 'legacy-refresh',
        });

        final tokens = await store.read();
        expect(tokens!.accessToken, 'legacy-access');
        expect(tokens.refreshToken, 'legacy-refresh');

        // The legacy key is gone; the next read still works.
        final prefs = await SharedPreferences.getInstance();
        expect(
          prefs.containsKey(SharedPrefsLucentSessionStore.refreshTokenKey),
          isFalse,
        );
        final reread = await store.read();
        expect(reread!.accessToken, 'legacy-access');
        expect(reread.refreshToken, 'legacy-refresh');
      },
    );

    test('legacy layout with only a refresh token stays readable', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        SharedPrefsLucentSessionStore.refreshTokenKey: 'legacy-refresh-only',
      });

      final tokens = await store.read();
      expect(tokens!.accessToken, '');
      expect(tokens.refreshToken, 'legacy-refresh-only');
    });

    test(
      'a write over the legacy layout replaces it with the payload',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          SharedPrefsLucentSessionStore.accessTokenKey: 'legacy-access',
          SharedPrefsLucentSessionStore.refreshTokenKey: 'legacy-refresh',
        });

        await store.write(
          const LucentSessionTokens(
            accessToken: 'fresh-access',
            refreshToken: 'fresh-refresh',
          ),
        );

        final prefs = await SharedPreferences.getInstance();
        expect(
          prefs.containsKey(SharedPrefsLucentSessionStore.refreshTokenKey),
          isFalse,
        );
        final tokens = await store.read();
        expect(tokens!.accessToken, 'fresh-access');
        expect(tokens.refreshToken, 'fresh-refresh');
      },
    );
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
      _stubMapBackedStorage(mockStorage, <String, String>{});

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

    test('write persists the pair in one storage.write call', () async {
      await store.write(
        const LucentSessionTokens(accessToken: 'acc', refreshToken: 'ref'),
      );

      // A single write of the payload key is what makes the rotation atomic;
      // two calls would expose the half-updated pair to a concurrent reader.
      verify(
        () => mockStorage.write(
          key: SecureLucentSessionStore.payloadKey,
          value: any(named: 'value'),
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
          lOptions: any(named: 'lOptions'),
          webOptions: any(named: 'webOptions'),
          mOptions: any(named: 'mOptions'),
          wOptions: any(named: 'wOptions'),
        ),
      ).called(1);
    });

    test('clear deletes both the payload and legacy refresh keys', () async {
      await store.clear();

      verify(
        () => mockStorage.delete(
          key: SecureLucentSessionStore.payloadKey,
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
          key: SecureLucentSessionStore.refreshTokenKey,
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
          lOptions: any(named: 'lOptions'),
          webOptions: any(named: 'webOptions'),
          mOptions: any(named: 'mOptions'),
          wOptions: any(named: 'wOptions'),
        ),
      ).called(1);
    });

    test('write trims whitespace from the payload', () async {
      await store.write(
        const LucentSessionTokens(
          accessToken: '  padded-access  ',
          refreshToken: '  padded-refresh  ',
        ),
      );

      final captured =
          verify(
                () => mockStorage.write(
                  key: SecureLucentSessionStore.payloadKey,
                  value: captureAny(named: 'value'),
                  iOptions: any(named: 'iOptions'),
                  aOptions: any(named: 'aOptions'),
                  lOptions: any(named: 'lOptions'),
                  webOptions: any(named: 'webOptions'),
                  mOptions: any(named: 'mOptions'),
                  wOptions: any(named: 'wOptions'),
                ),
              ).captured.single
              as String;

      final decoded = jsonDecode(captured) as Map<String, dynamic>;
      expect(decoded['accessToken'], 'padded-access');
      expect(decoded['refreshToken'], 'padded-refresh');
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
          key: SecureLucentSessionStore.payloadKey,
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
          lOptions: any(named: 'lOptions'),
          webOptions: any(named: 'webOptions'),
          mOptions: any(named: 'mOptions'),
          wOptions: any(named: 'wOptions'),
        ),
      ).thenAnswer((_) async => 'access-only');

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
        if (key == SecureLucentSessionStore.refreshTokenKey) {
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

    test('read migrates the legacy two-key layout', () async {
      final values = <String, String>{
        SecureLucentSessionStore.payloadKey: 'legacy-access',
        SecureLucentSessionStore.refreshTokenKey: 'legacy-refresh',
      };
      _stubMapBackedStorage(mockStorage, values);

      final tokens = await store.read();
      expect(tokens!.accessToken, 'legacy-access');
      expect(tokens.refreshToken, 'legacy-refresh');

      // The pair is re-encoded into the payload and the legacy refresh key is
      // dropped.
      expect(values[SecureLucentSessionStore.payloadKey], startsWith('{'));
      expect(
        values.containsKey(SecureLucentSessionStore.refreshTokenKey),
        isFalse,
      );
    });

    test(
      'a migrated legacy pair survives later reads after the legacy key is gone',
      () async {
        final values = <String, String>{
          SecureLucentSessionStore.payloadKey: 'legacy-access',
          SecureLucentSessionStore.refreshTokenKey: 'legacy-refresh',
        };
        _stubMapBackedStorage(mockStorage, values);

        final first = await store.read();
        expect(first!.accessToken, 'legacy-access');
        expect(first.refreshToken, 'legacy-refresh');

        // The legacy key is gone; only the re-encoded payload can serve this.
        final second = await store.read();
        expect(second!.accessToken, 'legacy-access');
        expect(second.refreshToken, 'legacy-refresh');
      },
    );
  });
}
