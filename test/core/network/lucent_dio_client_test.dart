import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/network/lucent_dio_client.dart';
import 'package:luminous/core/network/lucent_session_store.dart';

/// A session store that stores tokens in memory.
class _MemorySessionStore implements LucentSessionStore {
  LucentSessionTokens? _tokens;

  @override
  Future<LucentSessionTokens?> read() async => _tokens;

  @override
  Future<String?> readAccessToken() async => _tokens?.accessToken;

  @override
  Future<String?> readRefreshToken() async => _tokens?.refreshToken;

  @override
  Future<void> write(LucentSessionTokens tokens) async {
    _tokens = tokens;
  }

  @override
  Future<void> clear() async {
    _tokens = null;
  }
}

/// A mock adapter that captures the request and returns a canned response.
class _CaptureAdapter implements HttpClientAdapter {
  _CaptureAdapter({this.responseData});

  int statusCode = 200;
  Object? responseData;
  RequestOptions? capturedRequest;
  int callCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    callCount++;
    capturedRequest = options;

    final body = responseData != null
        ? Uint8List.fromList(utf8.encode(jsonEncode(responseData)))
        : Uint8List(0);

    return ResponseBody(
      Stream.value(body),
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('LucentDioClient request interceptor', () {
    test('injects Bearer token from session store', () async {
      final store = _MemorySessionStore();
      await store.write(
        const LucentSessionTokens(
          accessToken: 'my-access-token',
          refreshToken: 'my-refresh-token',
        ),
      );

      final adapter = _CaptureAdapter(
        responseData: <String, dynamic>{'code': 0, 'message': '', 'data': null},
      );

      final client = LucentDioClient(
        baseUrl: 'http://localhost:3000',
        sessionStore: store,
        dio: Dio()..httpClientAdapter = adapter,
      );

      await client.dio.get('/api/v1/test');

      expect(adapter.callCount, equals(1));
      expect(
        adapter.capturedRequest!.headers['Authorization'],
        equals('Bearer my-access-token'),
      );
    });

    test('skips authorization when skipAuthorization extra is set', () async {
      final store = _MemorySessionStore();
      await store.write(
        const LucentSessionTokens(
          accessToken: 'should-not-be-sent',
          refreshToken: 'ref',
        ),
      );

      final adapter = _CaptureAdapter(
        responseData: <String, dynamic>{'code': 0, 'message': '', 'data': null},
      );

      final client = LucentDioClient(
        baseUrl: 'http://localhost:3000',
        sessionStore: store,
        dio: Dio()..httpClientAdapter = adapter,
      );

      await client.dio.get(
        '/api/v1/public',
        options: Options(extra: <String, Object?>{'skipAuthorization': true}),
      );

      expect(
        adapter.capturedRequest!.headers.containsKey('Authorization'),
        isFalse,
      );
    });

    test('injects Accept-Language from localeResolver', () async {
      final store = _MemorySessionStore();
      final adapter = _CaptureAdapter(
        responseData: <String, dynamic>{'code': 0, 'message': '', 'data': null},
      );

      final client = LucentDioClient(
        baseUrl: 'http://localhost:3000',
        sessionStore: store,
        localeResolver: () => 'zh-CN',
        dio: Dio()..httpClientAdapter = adapter,
      );

      await client.dio.get('/api/v1/test');

      expect(
        adapter.capturedRequest!.headers['Accept-Language'],
        equals('zh-CN'),
      );
    });
  });

  group('LucentDioClient session operations', () {
    test('writeSession delegates to session store', () async {
      final store = _MemorySessionStore();
      final adapter = _CaptureAdapter(
        responseData: <String, dynamic>{'code': 0, 'message': '', 'data': null},
      );

      final client = LucentDioClient(
        baseUrl: 'http://localhost:3000',
        sessionStore: store,
        dio: Dio()..httpClientAdapter = adapter,
      );

      await client.writeSession(
        const LucentSessionTokens(
          accessToken: 'new-token',
          refreshToken: 'new-refresh',
        ),
      );

      final tokens = await store.read();
      expect(tokens?.accessToken, equals('new-token'));
      expect(tokens?.refreshToken, equals('new-refresh'));
    });

    test('readAccessToken returns from store', () async {
      final store = _MemorySessionStore();
      await store.write(
        const LucentSessionTokens(
          accessToken: 'existing-token',
          refreshToken: 'existing-refresh',
        ),
      );

      final adapter = _CaptureAdapter(
        responseData: <String, dynamic>{'code': 0, 'message': '', 'data': null},
      );

      final client = LucentDioClient(
        baseUrl: 'http://localhost:3000',
        sessionStore: store,
        dio: Dio()..httpClientAdapter = adapter,
      );

      final token = await client.readAccessToken();
      expect(token, equals('existing-token'));
    });

    test('clearSession delegates to store', () async {
      final store = _MemorySessionStore();
      await store.write(
        const LucentSessionTokens(
          accessToken: 'temp',
          refreshToken: 'temp-ref',
        ),
      );

      final adapter = _CaptureAdapter(
        responseData: <String, dynamic>{'code': 0, 'message': '', 'data': null},
      );

      final client = LucentDioClient(
        baseUrl: 'http://localhost:3000',
        sessionStore: store,
        dio: Dio()..httpClientAdapter = adapter,
      );

      await client.clearSession();
      final tokens = await store.read();
      expect(tokens, isNull);
    });
  });

  group('LucentDioClient API getters', () {
    test('provides access to all API instances', () async {
      final store = _MemorySessionStore();
      final adapter = _CaptureAdapter(
        responseData: <String, dynamic>{'code': 0, 'message': '', 'data': null},
      );

      final client = LucentDioClient(
        baseUrl: 'http://localhost:3000',
        sessionStore: store,
        dio: Dio()..httpClientAdapter = adapter,
      );

      // Verify each API getter returns a non-null instance
      expect(client.appApi, isNotNull);
      expect(client.authApi, isNotNull);
      expect(client.medicinesApi, isNotNull);
      expect(client.environmentApi, isNotNull);
      expect(client.notificationsApi, isNotNull);
      expect(client.userSettingsApi, isNotNull);
      expect(client.reportsApi, isNotNull);
      expect(client.assistantApi, isNotNull);
    });
  });
}
