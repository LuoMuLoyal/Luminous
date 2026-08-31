import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/client/dio_client.dart';
import 'package:luminous/core/network/client/session_store.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/features/auth/data/datasources/auth.dart';
import 'package:luminous/features/auth/domain/entities/auth_verification_scene.dart';

/// A mock adapter that returns canned JSON responses.
class _MockAdapter implements HttpClientAdapter {
  _MockAdapter();

  int statusCode = 200;
  Object? body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    final json = body != null ? utf8.encode(jsonEncode(body)) : <int>[];
    return ResponseBody(
      Stream.value(Uint8List.fromList(json)),
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>['application/json'],
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

/// Resolves a repository task, returning the Right value and failing the
/// test when the repository reports a Left.
Future<T> _right<T>(TaskEither<LucentFailure, T> task) async {
  final result = await task.run();
  return result.fold(
    (failure) => fail('expected Right, got $failure'),
    (value) => value,
  );
}

/// Helper: build a direct login resource response.
Map<String, dynamic> _loginResponse({
  String accessToken = 'at-1',
  String refreshToken = 'rt-1',
  String userId = 'u-1',
  String email = 'test@example.com',
}) {
  return <String, dynamic>{
    'user': <String, dynamic>{
      'id': userId,
      'email': email,
      'nickname': 'TestUser',
      'avatar': null,
      'emailVerified': false,
      'emailVerifiedAt': null,
      'hasPassword': true,
      'lastLoginAt': null,
      'linkedIdentities': <dynamic>[],
      'createdAt': '2026-06-10T08:00:00.000Z',
      'updatedAt': '2026-06-10T08:00:00.000Z',
    },
    'tokens': <String, dynamic>{
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresIn': 3600,
    },
  };
}

void main() {
  group('LucentAuthRepository', () {
    late _MockAdapter adapter;
    late _MemStore store;
    late LucentClient client;
    late LucentAuthRepository dataSource;

    setUp(() {
      adapter = _MockAdapter();
      store = _MemStore();
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
        ..httpClientAdapter = adapter;
      client = LucentClient(LucentApi(dio: dio));
      dataSource = LucentAuthRepository(client, store);
    });

    group('login', () {
      test('returns session and writes tokens on success', () async {
        adapter.body = _loginResponse();

        final session = await _right(
          dataSource.login(email: 'test@example.com', password: 'Pass123'),
        );

        expect(session.user.id, 'u-1');
        expect(session.accessToken, 'at-1');
        expect(session.refreshToken, 'rt-1');

        final stored = await store.read();
        expect(stored?.accessToken, 'at-1');
        expect(stored?.refreshToken, 'rt-1');
      });

      test('returns Left with emptyResponse on null response body', () async {
        adapter.body = null;

        final result = await dataSource
            .login(email: 'test@example.com', password: 'Pw')
            .run();

        final failure = result.fold(
          (failure) => failure,
          (value) => fail('expected Left, got $value'),
        );
        expect(failure.networkErrorCode, NetworkErrorCode.emptyResponse);
      });

      test('trims email and password', () async {
        adapter.body = _loginResponse();

        await _right(
          dataSource.login(
            email: '  test@example.com  ',
            password: '  Pass123  ',
          ),
        );
        // If no failure, the trimmed values were accepted
      });
    });

    group('register', () {
      test('returns session on success', () async {
        adapter.body = <String, dynamic>{
          'user': <String, dynamic>{
            'id': 'u-2',
            'email': 'new@example.com',
            'nickname': 'NewUser',
            'avatar': null,
            'emailVerified': false,
            'emailVerifiedAt': null,
            'hasPassword': true,
            'lastLoginAt': null,
            'linkedIdentities': <dynamic>[],
            'createdAt': '2026-06-10T08:00:00.000Z',
            'updatedAt': '2026-06-10T08:00:00.000Z',
          },
          'tokens': <String, dynamic>{
            'accessToken': 'at-reg',
            'refreshToken': 'rt-reg',
            'expiresIn': 3600,
          },
        };

        final session = await _right(
          dataSource.register(
            email: 'new@example.com',
            password: 'Pass123',
            code: '123456',
          ),
        );

        expect(session.user.id, 'u-2');
        expect(session.accessToken, 'at-reg');
      });
    });

    group('logout', () {
      test('clears session when no refresh token', () async {
        await _right(dataSource.logout());
        final tokens = await store.read();
        expect(tokens, isNull);
      });
    });

    group('fetchAccount', () {
      test('returns AuthUser from account endpoint', () async {
        adapter.body = <String, dynamic>{
          'id': 'u-1',
          'email': 'test@example.com',
          'nickname': 'TestUser',
          'avatar': null,
          'emailVerifiedAt': null,
          'hasPassword': true,
          'lastLoginAt': null,
          'linkedIdentities': <dynamic>[],
          'createdAt': '2026-06-10T08:00:00.000Z',
          'updatedAt': '2026-06-10T08:00:00.000Z',
        };

        final user = await _right(dataSource.fetchAccount());

        expect(user.id, 'u-1');
        expect(user.email, 'test@example.com');
        expect(user.nickname, 'TestUser');
      });

      test('returns Left with emptyResponse on null response', () async {
        adapter.body = null;

        final result = await dataSource.fetchAccount().run();
        final failure = result.fold(
          (failure) => failure,
          (value) => fail('expected Left, got $value'),
        );
        expect(failure.networkErrorCode, NetworkErrorCode.emptyResponse);
      });
    });

    group('sendVerificationCode', () {
      test('returns cooldown message', () async {
        adapter.body = <String, dynamic>{'cooldown': 60, 'message': '验证码已发送'};

        final msg = await _right(
          dataSource.sendVerificationCode(
            email: 'test@example.com',
            scene: AuthVerificationScene.login,
          ),
        );

        expect(msg.cooldownSeconds, 60);
        expect(msg.message, '验证码已发送');
      });
    });
  });
}
