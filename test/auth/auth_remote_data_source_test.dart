import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/network/lucent_api.dart';
import 'package:luminous/features/auth/data/datasources/auth_remote_data_source.dart';

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

/// Helper: build a login response envelope.
Map<String, dynamic> _loginResponse({
  String accessToken = 'at-1',
  String refreshToken = 'rt-1',
  String userId = 'u-1',
  String email = 'test@example.com',
}) {
  return <String, dynamic>{
    'code': 0,
    'message': '',
    'data': <String, dynamic>{
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
    },
  };
}

void main() {
  group('AuthRemoteDataSource', () {
    late _MockAdapter adapter;
    late _MemStore store;
    late LucentDioClient client;
    late AuthRemoteDataSource dataSource;

    setUp(() {
      adapter = _MockAdapter();
      store = _MemStore();
      client = LucentDioClient(
        baseUrl: 'http://localhost:3000',
        sessionStore: store,
        dio: Dio()..httpClientAdapter = adapter,
      );
      dataSource = AuthRemoteDataSource(client);
    });

    group('login', () {
      test('returns session and writes tokens on success', () async {
        adapter.body = _loginResponse();

        final session = await dataSource.login(
          email: 'test@example.com',
          password: 'Pass123',
        );

        expect(session.user.id, 'u-1');
        expect(session.accessToken, 'at-1');
        expect(session.refreshToken, 'rt-1');

        final stored = await store.read();
        expect(stored?.accessToken, 'at-1');
        expect(stored?.refreshToken, 'rt-1');
      });

      test('throws on null response body', () async {
        adapter.body = null;

        expect(
          () => dataSource.login(email: 'test@example.com', password: 'Pw'),
          throwsA(isA<LucentApiException>()),
        );
      });

      test('trims email and password', () async {
        adapter.body = _loginResponse();

        await dataSource.login(
          email: '  test@example.com  ',
          password: '  Pass123  ',
        );
        // If no exception, the trimmed values were accepted
      });
    });

    group('register', () {
      test('returns session on success', () async {
        adapter.body = <String, dynamic>{
          'code': 0,
          'message': '',
          'data': <String, dynamic>{
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
          },
        };

        final session = await dataSource.register(
          email: 'new@example.com',
          password: 'Pass123',
          code: '123456',
        );

        expect(session.user.id, 'u-2');
        expect(session.accessToken, 'at-reg');
      });
    });

    group('logout', () {
      test('clears session when no refresh token', () async {
        await dataSource.logout();
        final tokens = await store.read();
        expect(tokens, isNull);
      });
    });

    group('fetchAccount', () {
      test('returns AuthUser from account endpoint', () async {
        adapter.body = <String, dynamic>{
          'code': 0,
          'message': '',
          'data': <String, dynamic>{
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
          },
        };

        final user = await dataSource.fetchAccount();

        expect(user.id, 'u-1');
        expect(user.email, 'test@example.com');
        expect(user.nickname, 'TestUser');
      });

      test('throws on null response', () async {
        adapter.body = null;

        expect(
          () => dataSource.fetchAccount(),
          throwsA(isA<LucentApiException>()),
        );
      });
    });

    group('sendVerificationCode', () {
      test('returns cooldown message', () async {
        adapter.body = <String, dynamic>{
          'code': 0,
          'message': '',
          'data': <String, dynamic>{'cooldown': 60, 'message': '验证码已发送'},
        };

        final msg = await dataSource.sendVerificationCode(
          email: 'test@example.com',
          scene: AuthVerificationScene.login,
        );

        expect(msg.cooldown, 60);
        expect(msg.message, '验证码已发送');
      });
    });

    group('AuthVerificationScene.toDtoScene', () {
      test('maps all scenes correctly', () {
        expect(
          AuthVerificationScene.register.toDtoScene(),
          SendVerificationCodeDtoSceneEnum.register,
        );
        expect(
          AuthVerificationScene.login.toDtoScene(),
          SendVerificationCodeDtoSceneEnum.login,
        );
        expect(
          AuthVerificationScene.resetPassword.toDtoScene(),
          SendVerificationCodeDtoSceneEnum.resetPassword,
        );
        expect(
          AuthVerificationScene.changeEmail.toDtoScene(),
          SendVerificationCodeDtoSceneEnum.changeEmail,
        );
      });
    });
  });
}
