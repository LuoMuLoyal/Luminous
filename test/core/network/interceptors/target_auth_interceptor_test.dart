import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/network/interceptors/auth_interceptor.dart';
import 'package:luminous/core/network/session_store.dart';

const _tokenExpiredProblem = <String, dynamic>{
  'type': 'https://api.lumos.example/problems/auth/token-expired',
  'title': 'Authentication token expired',
  'detail': 'The access token has expired.',
  'code': 'AUTH_TOKEN_EXPIRED',
  'retryable': false,
};

const _wrongPasswordProblem = <String, dynamic>{
  'type': 'https://api.lumos.example/problems/auth/wrong-password',
  'title': 'Wrong password',
  'detail': 'The password is incorrect.',
  'code': 'AUTH_WRONG_PASSWORD',
  'retryable': false,
};

final class _SessionStore implements LucentSessionStore {
  LucentSessionTokens? tokens;

  @override
  Future<LucentSessionTokens?> read() async => tokens;

  @override
  Future<String?> readAccessToken() async => tokens?.accessToken;

  @override
  Future<String?> readRefreshToken() async => tokens?.refreshToken;

  @override
  Future<void> write(LucentSessionTokens value) async => tokens = value;

  @override
  Future<void> clear() async => tokens = null;
}

final class _QueueAdapter implements HttpClientAdapter {
  _QueueAdapter(this.responses);

  final List<_Response> responses;
  int callCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    callCount++;
    final response = responses.removeAt(0);
    final body = Uint8List.fromList(utf8.encode(jsonEncode(response.body)));
    return ResponseBody(
      Stream.value(body),
      response.statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: [response.contentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

final class _Response {
  const _Response(this.statusCode, this.body, this.contentType);

  final int statusCode;
  final Map<String, dynamic> body;
  final String contentType;
}

void main() {
  test(
    'refreshes from a target Problem Details 401 into direct token data',
    () async {
      final store = _SessionStore()
        ..tokens = const LucentSessionTokens(
          accessToken: 'expired-access-token',
          refreshToken: 'valid-refresh-token',
        );
      final mainAdapter = _QueueAdapter([
        const _Response(401, _tokenExpiredProblem, 'application/problem+json'),
        const _Response(200, {'id': 'retried-resource'}, 'application/json'),
      ]);
      final refreshAdapter = _QueueAdapter([
        const _Response(200, {
          'accessToken': 'new-access-token',
          'refreshToken': 'new-refresh-token',
          'expiresIn': 3600,
        }, 'application/json'),
      ]);

      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
        ..httpClientAdapter = mainAdapter;
      dio.interceptors.add(
        AuthInterceptor(
          dio: dio,
          sessionStore: store,
          refreshDio: Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
            ..httpClientAdapter = refreshAdapter,
        ),
      );

      await dio.get('/api/v1/test');

      expect(refreshAdapter.callCount, 1);
      expect(mainAdapter.callCount, 2);
      expect((await store.read())?.accessToken, 'new-access-token');
      expect((await store.read())?.refreshToken, 'new-refresh-token');
    },
  );

  test('does not refresh a non-refreshable Problem Details 401', () async {
    final store = _SessionStore()
      ..tokens = const LucentSessionTokens(
        accessToken: 'bad-access-token',
        refreshToken: 'valid-refresh-token',
      );
    final mainAdapter = _QueueAdapter([
      const _Response(401, _wrongPasswordProblem, 'application/problem+json'),
    ]);
    final refreshAdapter = _QueueAdapter([]);
    var sessionExpired = false;

    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
      ..httpClientAdapter = mainAdapter;
    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        sessionStore: store,
        refreshDio: Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
          ..httpClientAdapter = refreshAdapter,
        onSessionExpired: () async => sessionExpired = true,
      ),
    );

    try {
      await dio.get('/api/v1/test');
    } on DioException {
      // Expected.
    }

    expect(refreshAdapter.callCount, 0);
    expect(sessionExpired, isTrue);
    expect(await store.read(), isNull);
  });
}
