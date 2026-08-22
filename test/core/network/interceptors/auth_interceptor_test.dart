import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/network/interceptors/auth_interceptor.dart';
import 'package:luminous/core/network/session_store.dart';

// ── In-memory session store ────────────────────────────────────

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

// ── Configurable HTTP adapter ──────────────────────────────────

class _MockAdapter implements HttpClientAdapter {
  _MockAdapter();

  /// A queue of responses to return. Each fetch() call pops the first entry.
  /// If empty, returns a default 200 success.
  final List<_MockResponse> _queue = [];

  /// Captured requests for assertions.
  final List<RequestOptions> capturedRequests = [];

  int callCount = 0;

  void enqueue(_MockResponse response) {
    _queue.add(response);
  }

  void enqueueSuccess({int statusCode = 200, Map<String, dynamic>? data}) {
    enqueue(
      _MockResponse(statusCode: statusCode, data: data ?? <String, dynamic>{}),
    );
  }

  void enqueueError({
    required int statusCode,
    Map<String, dynamic>? data,
    String statusMessage = '',
  }) {
    enqueue(
      _MockResponse(
        statusCode: statusCode,
        data: data,
        statusMessage: statusMessage,
      ),
    );
  }

  void enqueueRefreshSuccess({
    String accessToken = 'new-access-token',
    String refreshToken = 'new-refresh-token',
  }) {
    enqueue(
      _MockResponse(
        statusCode: 200,
        data: {
          'accessToken': accessToken,
          'refreshToken': refreshToken,
          'expiresIn': 3600,
        },
      ),
    );
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    callCount++;
    capturedRequests.add(options);

    final response = _queue.isNotEmpty ? _queue.removeAt(0) : _MockResponse();

    final body = response.data != null
        ? Uint8List.fromList(utf8.encode(jsonEncode(response.data)))
        : Uint8List(0);

    return ResponseBody(
      body.isNotEmpty ? Stream.value(body) : const Stream.empty(),
      response.statusCode,
      headers: {
        Headers.contentTypeHeader: [
          response.statusCode >= 400
              ? 'application/problem+json'
              : 'application/json',
        ],
      },
      statusMessage: response.statusMessage,
    );
  }

  @override
  void close({bool force = false}) {}
}

class _MockResponse {
  _MockResponse({this.statusCode = 200, this.data, this.statusMessage = 'OK'});

  final int statusCode;
  final Map<String, dynamic>? data;
  final String statusMessage;
}

/// Adapter that always throws [error] — simulates network-level failures
/// (connection refused, timeout, DNS failure) on the refresh endpoint.
class _ThrowingRefreshAdapter implements HttpClientAdapter {
  _ThrowingRefreshAdapter(this.error);

  final DioException error;
  int callCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    callCount++;
    throw error;
  }

  @override
  void close({bool force = false}) {}
}

// ── Helpers ────────────────────────────────────────────────────

const _tokenExpiredBody = {
  'type': 'https://api.lumos.example/problems/auth/token-expired',
  'title': 'Authentication token expired',
  'detail': 'The access token has expired.',
  'code': 'AUTH_TOKEN_EXPIRED',
  'retryable': false,
};

const _unauthorizedBody = {
  'type': 'https://api.lumos.example/problems/auth/unauthorized',
  'title': 'Unauthorized',
  'detail': 'The credentials are not accepted.',
  'code': 'AUTH_UNAUTHORIZED',
  'retryable': false,
};

void main() {
  group('AuthInterceptor.onRequest', () {
    test('injects Bearer token from session store', () async {
      final store = _MemorySessionStore();
      await store.write(
        const LucentSessionTokens(
          accessToken: 'my-access-token',
          refreshToken: 'my-refresh-token',
        ),
      );

      final adapter = _MockAdapter()..enqueueSuccess();
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(
        AuthInterceptor(
          dio: dio,
          sessionStore: store,
          refreshDio: Dio(BaseOptions(baseUrl: 'http://localhost:3000')),
        ),
      );

      await dio.get('/api/v1/test');

      expect(adapter.callCount, 1);
      expect(
        adapter.capturedRequests.first.headers['Authorization'],
        'Bearer my-access-token',
      );
    });

    test('sets Accept header to application/json', () async {
      final store = _MemorySessionStore();
      final adapter = _MockAdapter()..enqueueSuccess();
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(
        AuthInterceptor(
          dio: dio,
          sessionStore: store,
          refreshDio: Dio(BaseOptions(baseUrl: 'http://localhost:3000')),
        ),
      );

      await dio.get('/api/v1/test');

      expect(
        adapter.capturedRequests.first.headers['Accept'],
        'application/json',
      );
    });

    test('injects Accept-Language from localeResolver', () async {
      final store = _MemorySessionStore();
      final adapter = _MockAdapter()..enqueueSuccess();
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(
        AuthInterceptor(
          dio: dio,
          sessionStore: store,
          refreshDio: Dio(BaseOptions(baseUrl: 'http://localhost:3000')),
          localeResolver: () => 'zh-CN',
        ),
      );

      await dio.get('/api/v1/test');

      expect(
        adapter.capturedRequests.first.headers['Accept-Language'],
        'zh-CN',
      );
    });

    test('skips Authorization when skipAuthorization extra is set', () async {
      final store = _MemorySessionStore();
      await store.write(
        const LucentSessionTokens(
          accessToken: 'should-not-be-sent',
          refreshToken: 'ref',
        ),
      );

      final adapter = _MockAdapter()..enqueueSuccess();
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(
        AuthInterceptor(
          dio: dio,
          sessionStore: store,
          refreshDio: Dio(BaseOptions(baseUrl: 'http://localhost:3000')),
        ),
      );

      await dio.get(
        '/api/v1/public',
        options: Options(extra: {'skipAuthorization': true}),
      );

      expect(
        adapter.capturedRequests.first.headers.containsKey('Authorization'),
        isFalse,
      );
    });

    test('does not inject Authorization when token is null', () async {
      final store = _MemorySessionStore();
      final adapter = _MockAdapter()..enqueueSuccess();
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(
        AuthInterceptor(
          dio: dio,
          sessionStore: store,
          refreshDio: Dio(BaseOptions(baseUrl: 'http://localhost:3000')),
        ),
      );

      await dio.get('/api/v1/test');

      expect(
        adapter.capturedRequests.first.headers.containsKey('Authorization'),
        isFalse,
      );
    });

    test('does not overwrite existing Authorization header', () async {
      final store = _MemorySessionStore();
      await store.write(
        const LucentSessionTokens(
          accessToken: 'store-token',
          refreshToken: 'ref',
        ),
      );

      final adapter = _MockAdapter()..enqueueSuccess();
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(
        AuthInterceptor(
          dio: dio,
          sessionStore: store,
          refreshDio: Dio(BaseOptions(baseUrl: 'http://localhost:3000')),
        ),
      );

      await dio.get(
        '/api/v1/test',
        options: Options(headers: {'Authorization': 'Bearer custom-token'}),
      );

      expect(
        adapter.capturedRequests.first.headers['Authorization'],
        'Bearer custom-token',
      );
    });
  });

  group('AuthInterceptor.onError — token refresh', () {
    test(
      'refreshes token on 401 with tokenExpired and retries successfully',
      () async {
        final store = _MemorySessionStore();
        await store.write(
          const LucentSessionTokens(
            accessToken: 'expired-token',
            refreshToken: 'valid-refresh-token',
          ),
        );

        final mainAdapter = _MockAdapter()
          ..enqueueError(
            statusCode: 401,
            data: _tokenExpiredBody,
            statusMessage: 'Unauthorized',
          )
          ..enqueueSuccess(data: {});

        final refreshAdapter = _MockAdapter()..enqueueRefreshSuccess();

        final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
        dio.httpClientAdapter = mainAdapter;
        dio.interceptors.add(
          AuthInterceptor(
            dio: dio,
            sessionStore: store,
            refreshDio: Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
              ..httpClientAdapter = refreshAdapter,
          ),
        );

        final response = await dio.get('/api/v1/test');

        // Original request + retry after refresh
        expect(mainAdapter.callCount, 2);
        expect(refreshAdapter.callCount, 1);
        expect(response.statusCode, 200);

        // New tokens should be stored
        final tokens = await store.read();
        expect(tokens!.accessToken, 'new-access-token');
        expect(tokens.refreshToken, 'new-refresh-token');

        // Retry request should use new token
        final retryRequest = mainAdapter.capturedRequests[1];
        expect(
          retryRequest.headers['Authorization'],
          'Bearer new-access-token',
        );
        expect(retryRequest.extra['hasRetriedAfterRefresh'], true);
      },
    );

    test('does not refresh when skipAuthRefresh is set', () async {
      final store = _MemorySessionStore();
      await store.write(
        const LucentSessionTokens(
          accessToken: 'expired-token',
          refreshToken: 'valid-refresh-token',
        ),
      );

      final mainAdapter = _MockAdapter()
        ..enqueueError(
          statusCode: 401,
          data: _tokenExpiredBody,
          statusMessage: 'Unauthorized',
        );

      final refreshAdapter = _MockAdapter();

      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
      dio.httpClientAdapter = mainAdapter;
      dio.interceptors.add(
        AuthInterceptor(
          dio: dio,
          sessionStore: store,
          refreshDio: Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
            ..httpClientAdapter = refreshAdapter,
        ),
      );

      try {
        await dio.get(
          '/api/v1/test',
          options: Options(extra: {'skipAuthRefresh': true}),
        );
      } on DioException {
        // Expected
      }

      expect(mainAdapter.callCount, 1);
      expect(refreshAdapter.callCount, 0);
    });

    test('does not refresh for non-401 status codes', () async {
      final store = _MemorySessionStore();
      await store.write(
        const LucentSessionTokens(
          accessToken: 'some-token',
          refreshToken: 'valid-refresh-token',
        ),
      );

      final mainAdapter = _MockAdapter()
        ..enqueueError(
          statusCode: 500,
          data: {
            'type': 'https://api.lumos.example/problems/internal-error',
            'title': 'Internal error',
            'detail': 'The server failed to process the request.',
            'code': 'INTERNAL_ERROR',
          },
          statusMessage: 'Internal Server Error',
        );

      final refreshAdapter = _MockAdapter();

      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
      dio.httpClientAdapter = mainAdapter;
      dio.interceptors.add(
        AuthInterceptor(
          dio: dio,
          sessionStore: store,
          refreshDio: Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
            ..httpClientAdapter = refreshAdapter,
        ),
      );

      try {
        await dio.get('/api/v1/test');
      } on DioException {
        // Expected
      }

      expect(mainAdapter.callCount, 1);
      expect(refreshAdapter.callCount, 0);
    });

    test('attempts refresh for 401 without tokenExpired code and keeps session '
        'on transient refresh failure', () async {
      final store = _MemorySessionStore();
      await store.write(
        const LucentSessionTokens(
          accessToken: 'bad-token',
          refreshToken: 'valid-refresh-token',
        ),
      );

      bool sessionExpiredCalled = false;
      final mainAdapter = _MockAdapter()
        ..enqueueError(
          statusCode: 401,
          data: _unauthorizedBody,
          statusMessage: 'Unauthorized',
        );

      // Refresh endpoint returns 200 with an empty body (malformed —
      // transient failure): the session must be kept.
      final refreshAdapter = _MockAdapter();

      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
      dio.httpClientAdapter = mainAdapter;
      dio.interceptors.add(
        AuthInterceptor(
          dio: dio,
          sessionStore: store,
          refreshDio: Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
            ..httpClientAdapter = refreshAdapter,
          onSessionExpired: () async {
            sessionExpiredCalled = true;
          },
        ),
      );

      try {
        await dio.get('/api/v1/test');
      } on DioException {
        // Expected
      }

      // A non-tokenExpired 401 still triggers a refresh attempt...
      expect(mainAdapter.callCount, 1);
      expect(refreshAdapter.callCount, 1);
      // ...but a transient refresh failure keeps the session.
      expect(sessionExpiredCalled, isFalse);
      expect(await store.read(), isNotNull);
    });

    test('keeps session when refresh fails with network error', () async {
      final store = _MemorySessionStore();
      await store.write(
        const LucentSessionTokens(
          accessToken: 'expired-token',
          refreshToken: 'valid-refresh-token',
        ),
      );

      bool sessionExpiredCalled = false;
      final mainAdapter = _MockAdapter()
        ..enqueueError(
          statusCode: 401,
          data: _tokenExpiredBody,
          statusMessage: 'Unauthorized',
        );

      final refreshAdapter = _ThrowingRefreshAdapter(
        DioException(
          requestOptions: RequestOptions(path: '/api/v1/auth/refresh'),
          type: DioExceptionType.connectionError,
          message: 'Connection refused',
        ),
      );

      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
      dio.httpClientAdapter = mainAdapter;
      dio.interceptors.add(
        AuthInterceptor(
          dio: dio,
          sessionStore: store,
          refreshDio: Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
            ..httpClientAdapter = refreshAdapter,
          onSessionExpired: () async {
            sessionExpiredCalled = true;
          },
        ),
      );

      try {
        await dio.get('/api/v1/test');
      } on DioException {
        // Expected
      }

      expect(refreshAdapter.callCount, 1);
      expect(sessionExpiredCalled, isFalse);
      // Network blip must not force-log-out the user.
      expect(await store.read(), isNotNull);
    });

    test('keeps session when refresh endpoint returns 5xx', () async {
      final store = _MemorySessionStore();
      await store.write(
        const LucentSessionTokens(
          accessToken: 'expired-token',
          refreshToken: 'valid-refresh-token',
        ),
      );

      bool sessionExpiredCalled = false;
      final mainAdapter = _MockAdapter()
        ..enqueueError(
          statusCode: 401,
          data: _tokenExpiredBody,
          statusMessage: 'Unauthorized',
        );

      final refreshAdapter = _MockAdapter()
        ..enqueueError(
          statusCode: 500,
          data: {
            'type': 'https://api.lumos.example/problems/internal-error',
            'title': 'Internal error',
            'detail': 'The server failed to process the request.',
            'code': 'INTERNAL_ERROR',
          },
          statusMessage: 'Internal Server Error',
        );

      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
      dio.httpClientAdapter = mainAdapter;
      dio.interceptors.add(
        AuthInterceptor(
          dio: dio,
          sessionStore: store,
          refreshDio: Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
            ..httpClientAdapter = refreshAdapter,
          onSessionExpired: () async {
            sessionExpiredCalled = true;
          },
        ),
      );

      try {
        await dio.get('/api/v1/test');
      } on DioException {
        // Expected
      }

      expect(refreshAdapter.callCount, 1);
      expect(sessionExpiredCalled, isFalse);
      expect(await store.read(), isNotNull);
    });

    test(
      'does not refresh for 401 with explicitly non-refreshable code',
      () async {
        final store = _MemorySessionStore();
        await store.write(
          const LucentSessionTokens(
            accessToken: 'bad-token',
            refreshToken: 'valid-refresh-token',
          ),
        );

        bool sessionExpiredCalled = false;
        final mainAdapter = _MockAdapter()
          ..enqueueError(
            statusCode: 401,
            data: {
              'type': 'https://api.lumos.example/problems/auth/wrong-password',
              'title': 'Wrong password',
              'detail': 'The password is incorrect.',
              'code': 'AUTH_WRONG_PASSWORD',
            },
            statusMessage: 'Unauthorized',
          );

        final refreshAdapter = _MockAdapter();

        final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
        dio.httpClientAdapter = mainAdapter;
        dio.interceptors.add(
          AuthInterceptor(
            dio: dio,
            sessionStore: store,
            refreshDio: Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
              ..httpClientAdapter = refreshAdapter,
            onSessionExpired: () async {
              sessionExpiredCalled = true;
            },
          ),
        );

        try {
          await dio.get('/api/v1/test');
        } on DioException {
          // Expected
        }

        expect(refreshAdapter.callCount, 0);
        expect(sessionExpiredCalled, isTrue);
        expect(await store.read(), isNull);
      },
    );

    test('clears session when no refresh token in store', () async {
      final store = _MemorySessionStore();
      await store.write(
        const LucentSessionTokens(
          accessToken: 'expired-token',
          refreshToken: '',
        ),
      );

      bool sessionExpiredCalled = false;
      final mainAdapter = _MockAdapter()
        ..enqueueError(
          statusCode: 401,
          data: _tokenExpiredBody,
          statusMessage: 'Unauthorized',
        );

      final refreshAdapter = _MockAdapter();

      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
      dio.httpClientAdapter = mainAdapter;
      dio.interceptors.add(
        AuthInterceptor(
          dio: dio,
          sessionStore: store,
          refreshDio: Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
            ..httpClientAdapter = refreshAdapter,
          onSessionExpired: () async {
            sessionExpiredCalled = true;
          },
        ),
      );

      try {
        await dio.get('/api/v1/test');
      } on DioException {
        // Expected
      }

      expect(mainAdapter.callCount, 1);
      expect(refreshAdapter.callCount, 0);
      expect(sessionExpiredCalled, isTrue);
      expect(await store.read(), isNull);
    });

    test(
      'prevents infinite retry loop with hasRetriedAfterRefresh guard',
      () async {
        final store = _MemorySessionStore();
        await store.write(
          const LucentSessionTokens(
            accessToken: 'expired-token',
            refreshToken: 'valid-refresh-token',
          ),
        );

        // Every response returns 401 with tokenExpired
        final mainAdapter = _MockAdapter();
        for (var i = 0; i < 10; i++) {
          mainAdapter.enqueueError(
            statusCode: 401,
            data: _tokenExpiredBody,
            statusMessage: 'Unauthorized',
          );
        }

        final refreshAdapter = _MockAdapter()..enqueueRefreshSuccess();

        final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
        dio.httpClientAdapter = mainAdapter;
        dio.interceptors.add(
          AuthInterceptor(
            dio: dio,
            sessionStore: store,
            refreshDio: Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
              ..httpClientAdapter = refreshAdapter,
          ),
        );

        try {
          await dio.get('/api/v1/test');
        } on DioException {
          // Expected
        }

        // Should be: 1 original + 1 retry = 2 calls to mainAdapter
        // (plus 1 refresh call)
        expect(mainAdapter.callCount, lessThanOrEqualTo(2));
        expect(refreshAdapter.callCount, 1);
      },
    );

    test(
      'clears session and calls onSessionExpired when refresh response is not success',
      () async {
        final store = _MemorySessionStore();
        await store.write(
          const LucentSessionTokens(
            accessToken: 'expired-token',
            refreshToken: 'valid-refresh-token',
          ),
        );

        bool sessionExpiredCalled = false;
        final mainAdapter = _MockAdapter()
          ..enqueueError(
            statusCode: 401,
            data: _tokenExpiredBody,
            statusMessage: 'Unauthorized',
          );

        // Refresh endpoint returns error
        final refreshAdapter = _MockAdapter()
          ..enqueueError(
            statusCode: 401,
            data: {
              'type':
                  'https://api.lumos.example/problems/auth/refresh-token-invalid',
              'title': 'Refresh token invalid',
              'detail': 'The refresh token is invalid.',
              'code': 'AUTH_REFRESH_TOKEN_INVALID',
            },
            statusMessage: 'Unauthorized',
          );

        final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
        dio.httpClientAdapter = mainAdapter;
        dio.interceptors.add(
          AuthInterceptor(
            dio: dio,
            sessionStore: store,
            refreshDio: Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
              ..httpClientAdapter = refreshAdapter,
            onSessionExpired: () async {
              sessionExpiredCalled = true;
            },
          ),
        );

        try {
          await dio.get('/api/v1/test');
        } on DioException {
          // Expected
        }

        expect(sessionExpiredCalled, isTrue);
        expect(await store.read(), isNull);
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
      final mainAdapter = _MockAdapter()
        ..enqueueError(
          statusCode: 401,
          data: _tokenExpiredBody,
          statusMessage: 'Unauthorized',
        );

      final interceptor = AuthInterceptor(
        dio: Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
          ..httpClientAdapter = mainAdapter,
        sessionStore: store,
        refreshDio: Dio(BaseOptions(baseUrl: 'http://localhost:3000')),
      );
      interceptor.onSessionExpired = () async {
        sessionExpiredCalled = true;
      };

      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
      dio.httpClientAdapter = mainAdapter;
      dio.interceptors.add(interceptor);

      try {
        await dio.get('/api/v1/test');
      } on DioException {
        // Expected
      }

      expect(sessionExpiredCalled, isTrue);
      expect(await store.read(), isNull);
    });

    test('deduplicates concurrent refresh requests', () async {
      final store = _MemorySessionStore();
      await store.write(
        const LucentSessionTokens(
          accessToken: 'expired-token',
          refreshToken: 'valid-refresh-token',
        ),
      );

      final mainAdapter = _MockAdapter()
        ..enqueueError(
          statusCode: 401,
          data: _tokenExpiredBody,
          statusMessage: 'Unauthorized',
        )
        ..enqueueError(
          statusCode: 401,
          data: _tokenExpiredBody,
          statusMessage: 'Unauthorized',
        )
        ..enqueueSuccess()
        ..enqueueSuccess();

      final refreshAdapter = _MockAdapter()..enqueueRefreshSuccess();

      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
      dio.httpClientAdapter = mainAdapter;
      dio.interceptors.add(
        AuthInterceptor(
          dio: dio,
          sessionStore: store,
          refreshDio: Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
            ..httpClientAdapter = refreshAdapter,
        ),
      );

      // Fire two concurrent requests — both get 401
      // The refresh should only happen once
      try {
        await Future.wait([dio.get('/api/v1/test'), dio.get('/api/v1/other')]);
      } on DioException {
        // Expected when refresh/retry fails
      }

      // Only one refresh call should have been made
      expect(refreshAdapter.callCount, 1);
    });
  });
}
