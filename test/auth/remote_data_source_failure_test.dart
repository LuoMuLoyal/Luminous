import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/dio_client.dart';
import 'package:luminous/core/network/error_code.dart';
import 'package:luminous/core/network/session_store.dart';
import 'package:luminous/features/auth/data/datasources/auth.dart';
import 'package:luminous/features/auth/domain/entities/auth_verification_scene.dart';

/// Configurable adapter for repository failure branches.
class _Adapter implements HttpClientAdapter {
  int statusCode = 200;
  Object? body;
  String contentType = 'application/json';

  /// When set, [fetch] throws this object instead of returning a response.
  Object? error;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    if (error != null) {
      throw error!;
    }
    final json = body != null ? utf8.encode(jsonEncode(body)) : <int>[];
    return ResponseBody(
      Stream.value(Uint8List.fromList(json)),
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[contentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _MemStore implements LucentSessionStore {
  LucentSessionTokens? _tokens;
  @override
  Future<LucentSessionTokens?> read() async => _tokens;
  @override
  Future<String?> readAccessToken() async => _tokens?.accessToken;
  @override
  Future<String?> readRefreshToken() async => _tokens?.refreshToken;
  @override
  Future<void> write(LucentSessionTokens t) async => _tokens = t;
  @override
  Future<void> clear() async => _tokens = null;
}

/// Runs a repository task and returns the [LucentFailure] from Left,
/// failing the test when the task reports a Right.
Future<LucentFailure> _left<T>(TaskEither<LucentFailure, T> task) async {
  final result = await task.run();
  return result.fold(
    (failure) => failure,
    (value) => fail('expected Left, got a Right'),
  );
}

/// A valid Problem Details error body served with `application/problem+json`.
Map<String, dynamic> _problemBody(String code, String detail) {
  return <String, dynamic>{
    'type': 'https://api.lumos.example/problems/$code',
    'title': 'Request failed',
    'detail': detail,
    'code': code,
  };
}

/// A non-Problem Details error body served with `application/json`.
Map<String, dynamic> _plainErrorBody() => <String, dynamic>{'error': 'oops'};

void main() {
  group('LucentAuthRepository — failure branches', () {
    late _Adapter adapter;
    late _MemStore store;
    late LucentAuthRepository dataSource;

    setUp(() {
      adapter = _Adapter();
      store = _MemStore();
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
        ..httpClientAdapter = adapter;
      dataSource = LucentAuthRepository(
        LucentClient(LucentApi(dio: dio)),
        store,
      );
    });

    group('login', () {
      test('AUTH_WRONG_PASSWORD stays a Problem Details failure', () async {
        adapter.statusCode = 401;
        adapter.contentType = 'application/problem+json';
        adapter.body = _problemBody('AUTH_WRONG_PASSWORD', '密码错误');

        final failure = await _left(
          dataSource.login(email: 'test@example.com', password: 'wrong'),
        );

        expect(failure.code, 'AUTH_WRONG_PASSWORD');
        expect(failure.statusCode, 401);
        expect(failure.kind, LucentFailureKind.authentication);
      });

      test(
        'AUTH_TOKEN_EXPIRED is preserved as a token-expired failure',
        () async {
          adapter.statusCode = 401;
          adapter.contentType = 'application/problem+json';
          adapter.body = _problemBody('AUTH_TOKEN_EXPIRED', 'token 已过期');

          final failure = await _left(
            dataSource.login(email: 'test@example.com', password: 'Pass123'),
          );

          expect(failure.isTokenExpired, isTrue);
          expect(failure.statusCode, 401);
        },
      );

      test(
        'Problem Details 4xx (rate limited) keeps code and status',
        () async {
          adapter.statusCode = 429;
          adapter.contentType = 'application/problem+json';
          adapter.body = _problemBody('AUTH_LOGIN_RATE_LIMITED', '发送过于频繁');

          final failure = await _left(
            dataSource.login(email: 'test@example.com', password: 'Pass123'),
          );

          expect(failure.code, 'AUTH_LOGIN_RATE_LIMITED');
          expect(failure.statusCode, 429);
          expect(failure.kind, LucentFailureKind.business);
        },
      );

      test('network timeout maps to a network connectivity failure', () async {
        adapter.error = DioException(
          requestOptions: RequestOptions(path: '/auth/login'),
          type: DioExceptionType.connectionTimeout,
        );

        final failure = await _left(
          dataSource.login(email: 'test@example.com', password: 'Pass123'),
        );

        expect(failure.isNetworkConnectivityError, isTrue);
        expect(failure.kind, LucentFailureKind.network);
      });

      test(
        'non-Problem Details error body propagates FormatException from run()',
        () async {
          adapter.statusCode = 400;
          adapter.contentType = 'application/json';
          adapter.body = _plainErrorBody();

          await expectLater(
            dataSource
                .login(email: 'test@example.com', password: 'Pass123')
                .run(),
            throwsA(isA<FormatException>()),
          );
        },
      );

      test(
        'empty body becomes Left(emptyResponse) and does not persist',
        () async {
          adapter.statusCode = 200;
          adapter.body = null;

          final failure = await _left(
            dataSource.login(email: 'test@example.com', password: 'Pass123'),
          );

          expect(failure.networkErrorCode, NetworkErrorCode.emptyResponse);
          expect(await store.read(), isNull);
        },
      );
    });

    group('register', () {
      test(
        'AUTH_EMAIL_ALREADY_REGISTERED stays a Problem Details failure',
        () async {
          adapter.statusCode = 409;
          adapter.contentType = 'application/problem+json';
          adapter.body = _problemBody('AUTH_EMAIL_ALREADY_REGISTERED', '邮箱已注册');

          final failure = await _left(
            dataSource.register(
              email: 'new@example.com',
              password: 'Pass123',
              code: '123456',
            ),
          );

          expect(failure.code, 'AUTH_EMAIL_ALREADY_REGISTERED');
          expect(failure.statusCode, 409);
        },
      );
    });

    group('sendVerificationCode', () {
      test('rate-limited send keeps the Problem Details failure', () async {
        adapter.statusCode = 429;
        adapter.contentType = 'application/problem+json';
        adapter.body = _problemBody('AUTH_LOGIN_RATE_LIMITED', '发送过于频繁');

        final failure = await _left(
          dataSource.sendVerificationCode(
            email: 'test@example.com',
            scene: AuthVerificationScene.login,
          ),
        );

        expect(failure.code, 'AUTH_LOGIN_RATE_LIMITED');
        expect(failure.statusCode, 429);
      });
    });

    group('resetPassword', () {
      test('invalid reset token keeps its code', () async {
        adapter.statusCode = 400;
        adapter.contentType = 'application/problem+json';
        adapter.body = _problemBody('AUTH_RESET_TOKEN_INVALID', '重置链接无效或已过期');

        final failure = await _left(
          dataSource.resetPassword(
            token: 'invalid-token',
            password: 'NewPass123',
          ),
        );

        expect(failure.code, 'AUTH_RESET_TOKEN_INVALID');
        expect(failure.statusCode, 400);
      });
    });

    group('forgotPassword', () {
      test('failure keeps the Problem Details failure', () async {
        adapter.statusCode = 429;
        adapter.contentType = 'application/problem+json';
        adapter.body = _problemBody('AUTH_LOGIN_RATE_LIMITED', '发送过于频繁');

        final failure = await _left(
          dataSource.forgotPassword(email: 'test@example.com'),
        );

        expect(failure.code, 'AUTH_LOGIN_RATE_LIMITED');
        expect(failure.statusCode, 429);
      });
    });

    group('verifyEmail', () {
      test('invalid verification token keeps its code', () async {
        adapter.statusCode = 400;
        adapter.contentType = 'application/problem+json';
        adapter.body = _problemBody('AUTH_VERIFY_TOKEN_INVALID', '验证链接无效或已过期');

        final failure = await _left(
          dataSource.verifyEmail(token: 'invalid-token'),
        );

        expect(failure.code, 'AUTH_VERIFY_TOKEN_INVALID');
        expect(failure.statusCode, 400);
      });
    });

    group('refreshSession', () {
      test(
        'AUTH_REFRESH_TOKEN_INVALID is preserved, not downgraded to a network error',
        () async {
          adapter.statusCode = 401;
          adapter.contentType = 'application/problem+json';
          adapter.body = _problemBody(
            'AUTH_REFRESH_TOKEN_INVALID',
            'refresh token 无效',
          );

          final failure = await _left(
            dataSource.refreshSession(refreshToken: 'expired-rt'),
          );

          expect(failure.isRefreshTokenInvalid, isTrue);
          expect(failure.code, 'AUTH_REFRESH_TOKEN_INVALID');
          expect(failure.statusCode, 401);
          expect(failure.isNetworkConnectivityError, isFalse);
        },
      );

      test('network timeout during refresh stays a network failure', () async {
        adapter.error = DioException(
          requestOptions: RequestOptions(path: '/auth/refresh'),
          type: DioExceptionType.receiveTimeout,
        );

        final failure = await _left(
          dataSource.refreshSession(refreshToken: 'rt'),
        );

        expect(failure.isNetworkConnectivityError, isTrue);
        expect(failure.code, isNull);
      });
    });

    group('logout', () {
      test('remote logout failure preserves the local session', () async {
        await store.write(
          const LucentSessionTokens(accessToken: 'at-1', refreshToken: 'rt-1'),
        );
        adapter.statusCode = 500;
        adapter.contentType = 'application/problem+json';
        adapter.body = _problemBody('INTERNAL_SERVER_ERROR', '服务器错误');

        final failure = await _left(dataSource.logout());

        expect(failure.statusCode, 500);
        expect(failure.kind, LucentFailureKind.server);
        // 注销失败不能清空尚未确认的本地 session
        expect(await store.read(), isNotNull);
      });
    });

    group('changePassword', () {
      test('failure does not clear the local session', () async {
        await store.write(
          const LucentSessionTokens(accessToken: 'at-1', refreshToken: 'rt-1'),
        );
        adapter.statusCode = 400;
        adapter.contentType = 'application/problem+json';
        adapter.body = _problemBody('AUTH_CURRENT_PASSWORD_INVALID', '原密码错误');

        final failure = await _left(
          dataSource.changePassword(
            oldPassword: 'wrong',
            newPassword: 'NewPass456',
          ),
        );

        expect(failure.code, 'AUTH_CURRENT_PASSWORD_INVALID');
        expect(await store.read(), isNotNull);
      });
    });

    group('deleteAccount', () {
      test('failure does not clear the local session', () async {
        await store.write(
          const LucentSessionTokens(accessToken: 'at-1', refreshToken: 'rt-1'),
        );
        adapter.statusCode = 400;
        adapter.contentType = 'application/problem+json';
        adapter.body = _problemBody('AUTH_PASSWORD_INVALID', '密码不正确');

        final failure = await _left(
          dataSource.deleteAccount(password: 'wrong'),
        );

        expect(failure.code, 'AUTH_PASSWORD_INVALID');
        expect(await store.read(), isNotNull);
      });
    });

    group('fetchAccount', () {
      test('server error keeps status and kind', () async {
        adapter.statusCode = 500;
        adapter.contentType = 'application/problem+json';
        adapter.body = _problemBody('INTERNAL_SERVER_ERROR', '服务器错误');

        final failure = await _left(dataSource.fetchAccount());

        expect(failure.statusCode, 500);
        expect(failure.kind, LucentFailureKind.server);
      });
    });
  });
}
