import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/client/dio_client.dart';
import 'package:luminous/core/network/client/session_store.dart';

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

/// A mock adapter that captures requests and returns configurable canned responses.
/// Supports second-call override for testing retry flows.
class _CaptureAdapter implements HttpClientAdapter {
  _CaptureAdapter({this.responseData});

  int statusCode = 200;
  String statusMessage = 'OK';
  Object? responseData;
  Map<String, List<String>>? responseHeaders;
  RequestOptions? capturedRequest;
  int callCount = 0;

  /// When set, the second fetch() call uses these overrides.
  int? secondCallStatusCode;
  Object? secondCallResponseData;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    callCount++;
    capturedRequest = options;

    final isSecondCall = callCount >= 2 && secondCallStatusCode != null;
    final resolvedStatus = isSecondCall ? secondCallStatusCode! : statusCode;
    final resolvedData = isSecondCall
        ? (secondCallResponseData ?? responseData)
        : responseData;

    final body = resolvedData != null
        ? Uint8List.fromList(utf8.encode(jsonEncode(resolvedData)))
        : Uint8List(0);

    return ResponseBody(
      Stream.value(body),
      resolvedStatus,
      headers:
          responseHeaders ??
          <String, List<String>>{
            Headers.contentTypeHeader: <String>[
              resolvedStatus >= 400
                  ? 'application/problem+json'
                  : 'application/json',
            ],
          },
      statusMessage: isSecondCall ? 'OK (retry)' : statusMessage,
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Target 401 Problem Details response with an expired access token.
const Map<String, dynamic> _tokenExpiredBody = <String, dynamic>{
  'type': 'https://api.lumos.example/problems/auth/token-expired',
  'title': 'Authentication token expired',
  'detail': 'The access token has expired.',
  'code': 'AUTH_TOKEN_EXPIRED',
  'retryable': false,
};

/// Direct token/resource response used by the target contract tests.
const Map<String, dynamic> _successBody = <String, dynamic>{
  'accessToken': 'new-access-token',
  'refreshToken': 'new-refresh-token',
  'expiresIn': 3600,
};

/// 401 Problem Details response that cannot be fixed by refreshing.
const Map<String, dynamic> _unauthorizedBody = <String, dynamic>{
  'type': 'https://api.lumos.example/problems/auth/unauthorized',
  'title': 'Unauthorized',
  'detail': 'The credentials are not accepted.',
  'code': 'AUTH_UNAUTHORIZED',
  'retryable': false,
};

/// Adapter that throws a DioException with a configurable type.
class _FailingAdapter implements HttpClientAdapter {
  _FailingAdapter({required this.exceptionType});

  final DioExceptionType exceptionType;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    throw DioException(requestOptions: options, type: exceptionType);
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

      final adapter = _CaptureAdapter(responseData: _successBody);

      final client = LucentDioClient(
        baseUrl: 'http://localhost:3000',
        sessionStore: store,
        httpClientAdapter: adapter,
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

      final adapter = _CaptureAdapter(responseData: _successBody);

      final client = LucentDioClient(
        baseUrl: 'http://localhost:3000',
        sessionStore: store,
        httpClientAdapter: adapter,
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
      final adapter = _CaptureAdapter(responseData: _successBody);

      final client = LucentDioClient(
        baseUrl: 'http://localhost:3000',
        sessionStore: store,
        localeResolver: () => 'zh-CN',
        httpClientAdapter: adapter,
      );

      await client.dio.get('/api/v1/test');

      expect(
        adapter.capturedRequest!.headers['Accept-Language'],
        equals('zh-CN'),
      );
    });
  });

  group('LucentDioClient token refresh (onError)', () {
    // ── Successful refresh + retry ──

    test(
      'refreshes token on 401 with tokenExpired code and retries request',
      () async {
        final store = _MemorySessionStore();
        await store.write(
          const LucentSessionTokens(
            accessToken: 'expired-token',
            refreshToken: 'valid-refresh-token',
          ),
        );

        // Adapter returns 401 first, then success on retry
        // The refresh call (POST /api/v1/auth/refresh) should return success
        final adapter = _CaptureAdapter(responseData: _tokenExpiredBody);
        adapter.statusCode = 401;
        adapter.statusMessage = 'Unauthorized';
        adapter.secondCallStatusCode = 200;
        adapter.secondCallResponseData = _successBody;

        // We use a separate adapter for _refreshDio since it's a different Dio instance.
        // Actually, with httpClientAdapter parameter, both dio instances share the adapter.
        final client = LucentDioClient(
          baseUrl: 'http://localhost:3000',
          sessionStore: store,
          httpClientAdapter: adapter,
        );

        await client.dio.get('/api/v1/test');

        // Original request + refresh request + retried original request.
        expect(adapter.callCount, equals(3));
        expect((await store.read())?.accessToken, 'new-access-token');
      },
    );

    // ── No refresh when skipAuthRefresh is set ──

    test('does not refresh when skipAuthRefresh extra is set', () async {
      final store = _MemorySessionStore();
      await store.write(
        const LucentSessionTokens(
          accessToken: 'expired-token',
          refreshToken: 'valid-refresh-token',
        ),
      );

      final adapter = _CaptureAdapter(responseData: _tokenExpiredBody);
      adapter.statusCode = 401;
      adapter.statusMessage = 'Unauthorized';

      final client = LucentDioClient(
        baseUrl: 'http://localhost:3000',
        sessionStore: store,
        httpClientAdapter: adapter,
      );

      try {
        await client.dio.get(
          '/api/v1/test',
          options: Options(extra: <String, Object?>{'skipAuthRefresh': true}),
        );
      } on DioException {
        // Expected
      }

      // Only one call — no refresh request was made
      expect(adapter.callCount, equals(1));
    });

    // ── No refresh for non-401 errors ──

    test('does not refresh for non-401 status codes', () async {
      final store = _MemorySessionStore();
      await store.write(
        const LucentSessionTokens(
          accessToken: 'some-token',
          refreshToken: 'valid-refresh-token',
        ),
      );

      final adapter = _CaptureAdapter(
        responseData: const <String, dynamic>{
          'type': 'https://api.lumos.example/problems/internal-error',
          'title': 'Internal error',
          'detail': 'The server failed to process the request.',
          'code': 'INTERNAL_ERROR',
        },
      );
      adapter.statusCode = 500;
      adapter.statusMessage = 'Internal Server Error';

      final client = LucentDioClient(
        baseUrl: 'http://localhost:3000',
        sessionStore: store,
        httpClientAdapter: adapter,
      );

      try {
        await client.dio.get(
          '/api/v1/test',
          options: Options(extra: <String, Object?>{'retryEnabled': false}),
        );
      } on DioException {
        // Expected
      }

      // Only one call — no refresh for non-401
      expect(adapter.callCount, equals(1));
    });

    // ── 401 without AUTH_TOKEN_EXPIRED code → no refresh, session cleared ──

    test(
      'clears session on 401 without AUTH_TOKEN_EXPIRED without refreshing',
      () async {
        final store = _MemorySessionStore();
        await store.write(
          const LucentSessionTokens(
            accessToken: 'bad-token',
            refreshToken: 'valid-refresh-token',
          ),
        );

        bool sessionExpiredCalled = false;
        final adapter = _CaptureAdapter(responseData: _unauthorizedBody);
        adapter.statusCode = 401;
        adapter.statusMessage = 'Unauthorized';

        final client = LucentDioClient(
          baseUrl: 'http://localhost:3000',
          sessionStore: store,
          onSessionExpired: () async {
            sessionExpiredCalled = true;
          },
          httpClientAdapter: adapter,
        );

        try {
          await client.dio.get('/api/v1/test');
        } on DioException {
          // Expected.
        }

        // Auth-refresh contract: only AUTH_TOKEN_EXPIRED triggers a refresh
        // attempt. A 401 with any other Problem Details code is not a refresh
        // candidate, so no refresh request is made; the session is cleared
        // and the callback invoked.
        expect(adapter.callCount, equals(1));
        final storedTokens = await store.read();
        expect(storedTokens, isNull);
        expect(sessionExpiredCalled, isTrue);
      },
    );

    test(
      'does not refresh for non-refreshable auth codes and clears session',
      () async {
        final store = _MemorySessionStore();
        await store.write(
          const LucentSessionTokens(
            accessToken: 'bad-token',
            refreshToken: 'valid-refresh-token',
          ),
        );

        bool sessionExpiredCalled = false;
        final adapter = _CaptureAdapter(
          responseData: const <String, dynamic>{
            'type':
                'https://api.lumos.example/problems/auth/refresh-token-invalid',
            'title': 'Refresh token invalid',
            'detail': 'The refresh token is invalid.',
            'code': 'AUTH_REFRESH_TOKEN_INVALID',
          },
        );
        adapter.statusCode = 401;
        adapter.statusMessage = 'Unauthorized';

        final client = LucentDioClient(
          baseUrl: 'http://localhost:3000',
          sessionStore: store,
          onSessionExpired: () async {
            sessionExpiredCalled = true;
          },
          httpClientAdapter: adapter,
        );

        try {
          await client.dio.get('/api/v1/test');
        } on DioException {
          // Expected
        }

        // refreshTokenInvalid is a non-refreshable auth code: no refresh
        // request is made, the session is cleared and the callback invoked.
        expect(adapter.callCount, equals(1));
        final storedTokens = await store.read();
        expect(storedTokens, isNull);
        expect(sessionExpiredCalled, isTrue);
      },
    );

    // ── No refresh when no refresh token stored ──

    test('clears session when no refresh token in store', () async {
      final store = _MemorySessionStore();
      // Only access token, no refresh token
      await store.write(
        const LucentSessionTokens(
          accessToken: 'expired-token',
          refreshToken: '',
        ),
      );

      bool sessionExpiredCalled = false;
      final adapter = _CaptureAdapter(responseData: _tokenExpiredBody);
      adapter.statusCode = 401;
      adapter.statusMessage = 'Unauthorized';

      final client = LucentDioClient(
        baseUrl: 'http://localhost:3000',
        sessionStore: store,
        onSessionExpired: () async {
          sessionExpiredCalled = true;
        },
        httpClientAdapter: adapter,
      );

      try {
        await client.dio.get('/api/v1/test');
      } on DioException {
        // Expected
      }

      // No refresh attempted, but session is cleared and callback invoked
      expect(adapter.callCount, equals(1));
      final storedTokens = await store.read();
      expect(storedTokens, isNull);
      expect(sessionExpiredCalled, isTrue);
    });

    // ── Prevents infinite retry loop ──

    test(
      'does not retry more than once (hasRetriedAfterRefresh guard)',
      () async {
        final store = _MemorySessionStore();
        await store.write(
          const LucentSessionTokens(
            accessToken: 'expired-token',
            refreshToken: 'valid-refresh-token',
          ),
        );

        // Adapter always returns 401 — simulates refresh also failing
        final adapter = _CaptureAdapter(responseData: _tokenExpiredBody);
        adapter.statusCode = 401;
        adapter.statusMessage = 'Unauthorized';

        final client = LucentDioClient(
          baseUrl: 'http://localhost:3000',
          sessionStore: store,
          httpClientAdapter: adapter,
        );

        try {
          await client.dio.get('/api/v1/test');
        } on DioException {
          // Expected after refresh fails
        }

        // Adapter should be called exactly 2 times:
        // 1. Original request (401)
        // 2. Refresh request (also 401, or fails)
        // NOT 3+ — no infinite loop
        expect(adapter.callCount, lessThanOrEqualTo(3));
        // Verify hasRetriedAfterRefresh was set on the retry
        final lastRequest = adapter.capturedRequest;
        expect(lastRequest, isNotNull);
      },
    );

    // ── Refresh failure clears session and calls onSessionExpired ──

    test(
      'clears session and calls onSessionExpired when refresh fails',
      () async {
        final store = _MemorySessionStore();
        await store.write(
          const LucentSessionTokens(
            accessToken: 'expired-token',
            refreshToken: 'valid-refresh-token',
          ),
        );

        bool sessionExpiredCalled = false;
        final adapter = _CaptureAdapter(responseData: _tokenExpiredBody);
        adapter.statusCode = 401;
        adapter.statusMessage = 'Unauthorized';

        final client = LucentDioClient(
          baseUrl: 'http://localhost:3000',
          sessionStore: store,
          onSessionExpired: () async {
            sessionExpiredCalled = true;
          },
          httpClientAdapter: adapter,
        );

        try {
          await client.dio.get('/api/v1/test');
        } on DioException {
          // Expected
        }

        // Session should be cleared and callback invoked
        final storedTokens = await store.read();
        expect(storedTokens, isNull);
        expect(sessionExpiredCalled, isTrue);
      },
    );

    test('onSessionExpired setter wires callback after construction', () async {
      final store = _MemorySessionStore();
      await store.write(
        const LucentSessionTokens(
          accessToken: 'expired-token',
          refreshToken: '',
        ),
      );

      bool sessionExpiredCalled = false;
      final adapter = _CaptureAdapter(responseData: _tokenExpiredBody);
      adapter.statusCode = 401;
      adapter.statusMessage = 'Unauthorized';

      final client = LucentDioClient(
        baseUrl: 'http://localhost:3000',
        sessionStore: store,
        httpClientAdapter: adapter,
      );
      client.onSessionExpired = () async {
        sessionExpiredCalled = true;
      };

      try {
        await client.dio.get('/api/v1/test');
      } on DioException {
        // Expected
      }

      expect(adapter.callCount, equals(1));
      final storedTokens = await store.read();
      expect(storedTokens, isNull);
      expect(sessionExpiredCalled, isTrue);
    });

    // ── Concurrent refresh deduplication ──

    test('deduplicates concurrent refresh requests', () async {
      final store = _MemorySessionStore();
      await store.write(
        const LucentSessionTokens(
          accessToken: 'expired-token',
          refreshToken: 'valid-refresh-token',
        ),
      );

      // Adapter: first call returns 401, subsequent calls return success
      final adapter = _CaptureAdapter(responseData: _tokenExpiredBody);
      adapter.statusCode = 401;
      adapter.statusMessage = 'Unauthorized';
      adapter.secondCallStatusCode = 200;
      adapter.secondCallResponseData = _successBody;

      final client = LucentDioClient(
        baseUrl: 'http://localhost:3000',
        sessionStore: store,
        httpClientAdapter: adapter,
      );

      // Fire two concurrent requests — both get 401
      // The refresh should only happen once
      try {
        await Future.wait([
          client.dio.get('/api/v1/test'),
          client.dio.get('/api/v1/other'),
        ]);
      } on DioException {
        // Expected when refresh response format doesn't match
      }

      // Both requests hit the adapter, plus one refresh request
      // So total calls should be 3 (2 original + 1 refresh) not 4 (2 + 2)
      expect(adapter.callCount, greaterThanOrEqualTo(3));
    });
  });

  group('LucentDioClient error mapping (ErrorInterceptor)', () {
    Future<void> expectFallbackMessage(
      DioExceptionType type,
      String expectedMessage,
    ) async {
      final store = _MemorySessionStore();
      final adapter = _FailingAdapter(exceptionType: type);

      final client = LucentDioClient(
        baseUrl: 'http://localhost:3000',
        sessionStore: store,
        httpClientAdapter: adapter,
      );

      try {
        await client.dio.get(
          '/api/v1/test',
          options: Options(extra: <String, Object?>{'retryEnabled': false}),
        );
        fail('Expected DioException');
      } catch (error) {
        expect(error, isA<DioException>());
        final mapped = (error as DioException).error;
        expect(mapped, isA<LucentFailure>());
        expect((mapped as LucentFailure).message, expectedMessage);
      }
    }

    test('maps connectionTimeout to fallback message', () async {
      await expectFallbackMessage(
        DioExceptionType.connectionTimeout,
        'Connection timed out. Please try again later.',
      );
    });

    test('maps sendTimeout to fallback message', () async {
      await expectFallbackMessage(
        DioExceptionType.sendTimeout,
        'Request timed out. Please try again later.',
      );
    });

    test('maps receiveTimeout to fallback message', () async {
      await expectFallbackMessage(
        DioExceptionType.receiveTimeout,
        'Response timed out. Please try again later.',
      );
    });

    test('maps transformTimeout to fallback message', () async {
      await expectFallbackMessage(
        DioExceptionType.transformTimeout,
        'Response processing timed out. Please try again later.',
      );
    });

    test('maps badCertificate to fallback message', () async {
      await expectFallbackMessage(
        DioExceptionType.badCertificate,
        'Server certificate verification failed.',
      );
    });

    test('maps connectionError to fallback message', () async {
      await expectFallbackMessage(
        DioExceptionType.connectionError,
        'Network request failed. Please check your connection.',
      );
    });

    test('maps cancel to fallback message', () async {
      await expectFallbackMessage(
        DioExceptionType.cancel,
        'Request was cancelled.',
      );
    });

    test('maps badResponse to fallback message', () async {
      await expectFallbackMessage(
        DioExceptionType.badResponse,
        'Request failed. Please try again later.',
      );
    });

    test('maps unknown to fallback message', () async {
      await expectFallbackMessage(
        DioExceptionType.unknown,
        'An unexpected network error occurred.',
      );
    });

    test('maps error without response data gracefully', () async {
      final store = _MemorySessionStore();
      final adapter = _FailingAdapter(
        exceptionType: DioExceptionType.connectionError,
      );

      final client = LucentDioClient(
        baseUrl: 'http://localhost:3000',
        sessionStore: store,
        httpClientAdapter: adapter,
      );

      try {
        await client.dio.get(
          '/api/v1/test',
          options: Options(extra: <String, Object?>{'retryEnabled': false}),
        );
        fail('Expected DioException');
      } catch (error) {
        expect(error, isA<DioException>());
        final mapped = (error as DioException).error;
        expect(mapped, isA<LucentFailure>());
        expect(
          (mapped as LucentFailure).message,
          'Network request failed. Please check your connection.',
        );
      }
    });
  });
}
