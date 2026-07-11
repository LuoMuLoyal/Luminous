import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/api/export.dart';
import 'package:luminous/core/network/session_store.dart';
import 'package:luminous/features/auth/data/datasources/remote_data_source.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';

class _MockAdapter implements HttpClientAdapter {
  _MockAdapter();

  int statusCode = 200;
  Object? body;
  String? lastPath;
  Map<String, dynamic>? lastBody;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    lastPath = options.path;
    lastBody = options.data is Map
        ? Map<String, dynamic>.from(options.data as Map)
        : null;

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

Map<String, dynamic> _loginResponse({
  String accessToken = 'at-1',
  String refreshToken = 'rt-1',
  String userId = 'u-1',
  String email = 'test@example.com',
  String nickname = 'TestUser',
}) {
  return <String, dynamic>{
    'code': 0,
    'message': '',
    'data': <String, dynamic>{
      'user': <String, dynamic>{
        'id': userId,
        'email': email,
        'nickname': nickname,
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

Map<String, dynamic> _accountDto({
  String id = 'u-1',
  String email = 'test@example.com',
  String nickname = 'TestUser',
  String? avatar,
  String? emailVerifiedAt,
  bool hasPassword = true,
  String? lastLoginAt,
  List<Map<String, dynamic>> linkedIdentities = const [],
}) {
  return <String, dynamic>{
    'code': 0,
    'message': '',
    'data': <String, dynamic>{
      'id': id,
      'email': email,
      'nickname': nickname,
      'avatar': avatar,
      'emailVerifiedAt': emailVerifiedAt,
      'hasPassword': hasPassword,
      'lastLoginAt': lastLoginAt,
      'linkedIdentities': linkedIdentities,
      'createdAt': '2026-06-10T08:00:00.000Z',
      'updatedAt': '2026-06-10T08:00:00.000Z',
    },
  };
}

void main() {
  group('AuthRemoteDataSource — extended', () {
    late _MockAdapter adapter;
    late _MemStore store;
    late LucentClient client;
    late AuthRemoteDataSource dataSource;

    setUp(() {
      adapter = _MockAdapter();
      store = _MemStore();
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
        ..httpClientAdapter = adapter;
      client = LucentClient(dio, baseUrl: 'http://localhost:3000');
      dataSource = AuthRemoteDataSource(client, store);
    });

    // ─── OAuth: WeChat Web ───────────────────────────────────────────
    group('loginWithWechatWeb', () {
      test('returns session and persists tokens', () async {
        adapter.body = _loginResponse(
          accessToken: 'wx-at',
          refreshToken: 'wx-rt',
        );

        final session = await dataSource.loginWithWechatWeb(
          code: 'wx_code',
          state: 'wx_state',
        );

        expect(session.accessToken, 'wx-at');
        expect(session.refreshToken, 'wx-rt');

        final stored = await store.read();
        expect(stored?.accessToken, 'wx-at');
      });

      test('trims code and state', () async {
        adapter.body = _loginResponse();

        await dataSource.loginWithWechatWeb(
          code: '  wx_code  ',
          state: '  wx_state  ',
        );

        // Verify the request body was trimmed
        expect(adapter.lastBody?['code'], 'wx_code');
        expect(adapter.lastBody?['state'], 'wx_state');
      });
    });

    // ─── OAuth: WeChat Mobile ────────────────────────────────────────
    group('loginWithWechatMobile', () {
      test('returns session and persists tokens', () async {
        adapter.body = _loginResponse(
          accessToken: 'wxm-at',
          refreshToken: 'wxm-rt',
        );

        final session = await dataSource.loginWithWechatMobile(
          code: 'wx_mobile_code',
        );

        expect(session.accessToken, 'wxm-at');
        expect(session.refreshToken, 'wxm-rt');

        final stored = await store.read();
        expect(stored?.accessToken, 'wxm-at');
      });

      test('trims code', () async {
        adapter.body = _loginResponse();

        await dataSource.loginWithWechatMobile(code: '  wx_code  ');
        expect(adapter.lastBody?['code'], 'wx_code');
      });
    });

    // ─── OAuth: Apple ────────────────────────────────────────────────
    group('loginWithApple', () {
      test('returns session with identityToken only', () async {
        adapter.body = _loginResponse(
          accessToken: 'apple-at',
          refreshToken: 'apple-rt',
        );

        final session = await dataSource.loginWithApple(
          identityToken: 'apple_identity_token',
        );

        expect(session.accessToken, 'apple-at');
        expect(session.refreshToken, 'apple-rt');

        final stored = await store.read();
        expect(stored?.accessToken, 'apple-at');
      });

      test('passes all optional fields when provided', () async {
        adapter.body = _loginResponse();

        await dataSource.loginWithApple(
          identityToken: 'tok',
          authorizationCode: 'auth_code',
          givenName: 'John',
          familyName: 'Doe',
        );

        expect(adapter.lastBody?['identityToken'], 'tok');
        expect(adapter.lastBody?['authorizationCode'], 'auth_code');
        expect(adapter.lastBody?['givenName'], 'John');
        expect(adapter.lastBody?['familyName'], 'Doe');
      });
    });

    // ─── OAuth: QQ ───────────────────────────────────────────────────
    group('loginWithQq', () {
      test('returns session and persists tokens', () async {
        adapter.body = _loginResponse(
          accessToken: 'qq-at',
          refreshToken: 'qq-rt',
        );

        final session = await dataSource.loginWithQq(
          code: 'qq_code',
          state: 'qq_state',
        );

        expect(session.accessToken, 'qq-at');
        expect(session.refreshToken, 'qq-rt');

        final stored = await store.read();
        expect(stored?.accessToken, 'qq-at');
      });

      test('trims code and state', () async {
        adapter.body = _loginResponse();

        await dataSource.loginWithQq(
          code: '  qq_code  ',
          state: '  qq_state  ',
        );

        expect(adapter.lastBody?['code'], 'qq_code');
        expect(adapter.lastBody?['state'], 'qq_state');
      });
    });

    // ─── OAuth authorize URL creation ────────────────────────────────
    group('createWechatWebAuthorizeUrl', () {
      test('returns authorize data with callback URI', () async {
        adapter.body = <String, dynamic>{
          'code': 0,
          'message': '',
          'data': <String, dynamic>{
            'authorizeUrl':
                'https://open.weixin.qq.com/connect/oauth2/authorize?...',
            'state': 'random_state',
            'expiresIn': 300,
          },
        };

        final result = await dataSource.createWechatWebAuthorizeUrl(
          callbackUri: 'https://app.example.com/callback',
        );

        expect(result.authorizeUrl, isNotEmpty);
        expect(result.state, 'random_state');
      });

      test('sends null body when callbackUri is empty', () async {
        adapter.body = <String, dynamic>{
          'code': 0,
          'message': '',
          'data': <String, dynamic>{
            'authorizeUrl': 'https://open.weixin.qq.com/...',
            'state': 'st',
            'expiresIn': 300,
          },
        };

        await dataSource.createWechatWebAuthorizeUrl(callbackUri: null);
        // When body is null, the generated Retrofit client sends an empty map
        expect(adapter.lastBody ?? {}, isEmpty);
      });

      test('sends null body when callbackUri is whitespace', () async {
        adapter.body = <String, dynamic>{
          'code': 0,
          'message': '',
          'data': <String, dynamic>{
            'authorizeUrl': 'https://open.weixin.qq.com/...',
            'state': 'st',
            'expiresIn': 300,
          },
        };

        await dataSource.createWechatWebAuthorizeUrl(callbackUri: '   ');
        // When callbackUri is whitespace, it trims to empty and body becomes null
        expect(adapter.lastBody ?? {}, isEmpty);
      });
    });

    group('createQqAuthorizeUrl', () {
      test('returns authorize data', () async {
        adapter.body = <String, dynamic>{
          'code': 0,
          'message': '',
          'data': <String, dynamic>{
            'authorizeUrl': 'https://graph.qq.com/oauth2.0/authorize?...',
            'state': 'qq_state',
            'expiresIn': 300,
          },
        };

        final result = await dataSource.createQqAuthorizeUrl(
          callbackUri: 'https://app.example.com/qq/callback',
        );

        expect(result.authorizeUrl, isNotEmpty);
        expect(result.state, 'qq_state');
      });

      test('sends null body when callbackUri is null', () async {
        adapter.body = <String, dynamic>{
          'code': 0,
          'message': '',
          'data': <String, dynamic>{
            'authorizeUrl': 'https://graph.qq.com/...',
            'state': 'st',
            'expiresIn': 300,
          },
        };

        await dataSource.createQqAuthorizeUrl(callbackUri: null);
        // When body is null, the generated Retrofit client sends an empty map
        expect(adapter.lastBody ?? {}, isEmpty);
      });
    });

    // ─── Identity link ───────────────────────────────────────────────
    group('linkWechatWebIdentity', () {
      test('returns AuthUser from linked identity', () async {
        adapter.body = _accountDto(
          linkedIdentities: [
            <String, dynamic>{
              'id': 'id-1',
              'provider': 'wechat',
              'email': 'wx@example.com',
              'emailVerifiedAt': '2026-07-01T00:00:00.000Z',
              'linkedAt': '2026-07-01T00:00:00.000Z',
            },
          ],
        );

        final user = await dataSource.linkWechatWebIdentity(
          code: 'link_code',
          state: 'link_state',
        );

        expect(user.id, 'u-1');
        expect(user.linkedIdentities, hasLength(1));
        expect(user.linkedIdentities.first.provider, 'wechat');
        expect(user.linkedIdentities.first.email, 'wx@example.com');
      });

      test('trims code and state', () async {
        adapter.body = _accountDto();

        await dataSource.linkWechatWebIdentity(
          code: '  link_code  ',
          state: '  link_state  ',
        );

        expect(adapter.lastBody?['code'], 'link_code');
        expect(adapter.lastBody?['state'], 'link_state');
      });
    });

    group('linkWechatMobileIdentity', () {
      test('returns AuthUser from linked identity', () async {
        adapter.body = _accountDto();

        final user = await dataSource.linkWechatMobileIdentity(
          code: 'mobile_link_code',
        );

        expect(user.id, 'u-1');
      });

      test('trims code', () async {
        adapter.body = _accountDto();

        await dataSource.linkWechatMobileIdentity(code: '  link_code  ');
        expect(adapter.lastBody?['code'], 'link_code');
      });
    });

    // ─── logout ──────────────────────────────────────────────────────
    group('logout', () {
      test(
        'sends logout request with refresh token and clears store',
        () async {
          await store.write(
            const LucentSessionTokens(
              accessToken: 'at-1',
              refreshToken: 'rt-1',
            ),
          );
          adapter.body = <String, dynamic>{
            'code': 0,
            'message': '',
            'data': null,
          };

          await dataSource.logout();

          expect(await store.read(), isNull);
        },
      );

      test('clears store without API call when no refresh token', () async {
        // Store is already empty
        await dataSource.logout();

        expect(await store.read(), isNull);
      });

      test('clears store when refresh token is empty string', () async {
        await store.write(
          const LucentSessionTokens(accessToken: 'at-1', refreshToken: ''),
        );

        await dataSource.logout();

        expect(await store.read(), isNull);
      });
    });

    // ─── register ────────────────────────────────────────────────────
    group('register', () {
      test('returns session on success', () async {
        adapter.body = <String, dynamic>{
          'code': 0,
          'message': '',
          'data': <String, dynamic>{
            'user': <String, dynamic>{
              'id': 'u-reg',
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

        expect(session.user.id, 'u-reg');
        expect(session.accessToken, 'at-reg');
        expect(session.refreshToken, 'rt-reg');
        expect(session.expiresInSeconds, 3600);
      });

      test('includes nickname when provided', () async {
        adapter.body = <String, dynamic>{
          'code': 0,
          'message': '',
          'data': <String, dynamic>{
            'user': <String, dynamic>{
              'id': 'u-reg',
              'email': 'new@example.com',
              'nickname': 'CustomNick',
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
              'accessToken': 'at',
              'refreshToken': 'rt',
              'expiresIn': 3600,
            },
          },
        };

        await dataSource.register(
          email: 'new@example.com',
          password: 'Pass123',
          code: '123456',
          nickname: 'CustomNick',
        );

        expect(adapter.lastBody?['nickname'], 'CustomNick');
      });

      test('omits nickname when null', () async {
        adapter.body = <String, dynamic>{
          'code': 0,
          'message': '',
          'data': <String, dynamic>{
            'user': <String, dynamic>{
              'id': 'u-reg',
              'email': 'new@example.com',
              'nickname': null,
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
              'accessToken': 'at',
              'refreshToken': 'rt',
              'expiresIn': 3600,
            },
          },
        };

        await dataSource.register(
          email: 'new@example.com',
          password: 'Pass123',
          code: '123456',
        );

        expect(adapter.lastBody?['nickname'], isNull);
      });

      test('omits nickname when empty string after trim', () async {
        adapter.body = <String, dynamic>{
          'code': 0,
          'message': '',
          'data': <String, dynamic>{
            'user': <String, dynamic>{
              'id': 'u-reg',
              'email': 'new@example.com',
              'nickname': null,
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
              'accessToken': 'at',
              'refreshToken': 'rt',
              'expiresIn': 3600,
            },
          },
        };

        await dataSource.register(
          email: 'new@example.com',
          password: 'Pass123',
          code: '123456',
          nickname: '   ',
        );

        expect(adapter.lastBody?['nickname'], isNull);
      });

      test('trims email, password, and code', () async {
        adapter.body = <String, dynamic>{
          'code': 0,
          'message': '',
          'data': <String, dynamic>{
            'user': <String, dynamic>{
              'id': 'u-reg',
              'email': 'new@example.com',
              'nickname': null,
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
              'accessToken': 'at',
              'refreshToken': 'rt',
              'expiresIn': 3600,
            },
          },
        };

        await dataSource.register(
          email: '  new@example.com  ',
          password: '  Pass123  ',
          code: '  123456  ',
        );

        expect(adapter.lastBody?['email'], 'new@example.com');
        expect(adapter.lastBody?['password'], 'Pass123');
        expect(adapter.lastBody?['code'], '123456');
      });
    });

    // ─── fetchAccount ────────────────────────────────────────────────
    group('fetchAccount — extended', () {
      test('parses linked identities', () async {
        adapter.body = _accountDto(
          linkedIdentities: [
            <String, dynamic>{
              'id': 'id-1',
              'provider': 'wechat',
              'email': 'wx@example.com',
              'emailVerifiedAt': '2026-07-01T00:00:00.000Z',
              'linkedAt': '2026-07-01T00:00:00.000Z',
            },
            <String, dynamic>{
              'id': 'id-2',
              'provider': 'apple',
              'email': null,
              'emailVerifiedAt': null,
              'linkedAt': '2026-07-02T00:00:00.000Z',
            },
          ],
        );

        final user = await dataSource.fetchAccount();

        expect(user.linkedIdentities, hasLength(2));
        expect(user.linkedIdentities[0].provider, 'wechat');
        expect(user.linkedIdentities[0].email, 'wx@example.com');
        expect(user.linkedIdentities[0].emailVerifiedAt, isNotNull);
        expect(user.linkedIdentities[1].provider, 'apple');
        expect(user.linkedIdentities[1].email, isNull);
        expect(user.linkedIdentities[1].emailVerifiedAt, isNull);
      });

      test('parses emailVerifiedAt when present', () async {
        adapter.body = _accountDto(emailVerifiedAt: '2026-07-01T00:00:00.000Z');

        final user = await dataSource.fetchAccount();
        expect(user.emailVerifiedAt, isNotNull);
        expect(user.emailVerified, isTrue);
      });

      test('emailVerified is false when emailVerifiedAt is null', () async {
        adapter.body = _accountDto(emailVerifiedAt: null);

        final user = await dataSource.fetchAccount();
        expect(user.emailVerifiedAt, isNull);
        expect(user.emailVerified, isFalse);
      });

      test('parses lastLoginAt when present', () async {
        adapter.body = _accountDto(lastLoginAt: '2026-07-10T12:00:00.000Z');

        final user = await dataSource.fetchAccount();
        expect(user.lastLoginAt, isNotNull);
      });

      test('parses empty linked identities list', () async {
        adapter.body = _accountDto();

        final user = await dataSource.fetchAccount();
        expect(user.linkedIdentities, isEmpty);
      });
    });

    // ─── sendVerificationCode ────────────────────────────────────────
    group('sendVerificationCode — extended', () {
      test('trims email', () async {
        adapter.body = <String, dynamic>{
          'code': 0,
          'message': '',
          'data': <String, dynamic>{'cooldown': 60, 'message': '已发送'},
        };

        await dataSource.sendVerificationCode(
          email: '  test@example.com  ',
          scene: AuthVerificationScene.register,
        );

        expect(adapter.lastBody?['email'], 'test@example.com');
      });

      test('passes scene correctly for resetPassword', () async {
        adapter.body = <String, dynamic>{
          'code': 0,
          'message': '',
          'data': <String, dynamic>{'cooldown': 30, 'message': '已发送'},
        };

        await dataSource.sendVerificationCode(
          email: 'test@example.com',
          scene: AuthVerificationScene.resetPassword,
        );

        expect(
          adapter.lastBody?['scene'],
          SendVerificationCodeDtoSceneScene.resetPassword.json,
        );
      });

      test('passes scene correctly for changeEmail', () async {
        adapter.body = <String, dynamic>{
          'code': 0,
          'message': '',
          'data': <String, dynamic>{'cooldown': 30, 'message': '已发送'},
        };

        await dataSource.sendVerificationCode(
          email: 'test@example.com',
          scene: AuthVerificationScene.changeEmail,
        );

        expect(
          adapter.lastBody?['scene'],
          SendVerificationCodeDtoSceneScene.changeEmail.json,
        );
      });
    });

    // ─── resetPassword ───────────────────────────────────────────────
    group('resetPassword', () {
      test('completes without error on success', () async {
        adapter.body = <String, dynamic>{
          'code': 0,
          'message': '',
          'data': null,
        };

        await dataSource.resetPassword(
          email: 'test@example.com',
          code: '123456',
          password: 'NewPass123',
        );

        expect(adapter.lastBody?['email'], 'test@example.com');
        expect(adapter.lastBody?['code'], '123456');
        expect(adapter.lastBody?['password'], 'NewPass123');
      });

      test('trims all fields', () async {
        adapter.body = <String, dynamic>{
          'code': 0,
          'message': '',
          'data': null,
        };

        await dataSource.resetPassword(
          email: '  test@example.com  ',
          code: '  123456  ',
          password: '  NewPass123  ',
        );

        expect(adapter.lastBody?['email'], 'test@example.com');
        expect(adapter.lastBody?['code'], '123456');
        expect(adapter.lastBody?['password'], 'NewPass123');
      });
    });

    // ─── forgotPassword ──────────────────────────────────────────────
    group('forgotPassword', () {
      test('returns cooldown message', () async {
        adapter.body = <String, dynamic>{
          'code': 0,
          'message': '',
          'data': <String, dynamic>{'cooldown': 120, 'message': '重置链接已发送'},
        };

        final result = await dataSource.forgotPassword(
          email: 'test@example.com',
        );

        expect(result.cooldown, 120);
        expect(result.message, '重置链接已发送');
      });

      test('trims email', () async {
        adapter.body = <String, dynamic>{
          'code': 0,
          'message': '',
          'data': <String, dynamic>{'cooldown': 60, 'message': '已发送'},
        };

        await dataSource.forgotPassword(email: '  test@example.com  ');
        expect(adapter.lastBody?['email'], 'test@example.com');
      });
    });

    // ─── verifyEmail ─────────────────────────────────────────────────
    group('verifyEmail', () {
      test('completes without error on success', () async {
        adapter.body = <String, dynamic>{
          'code': 0,
          'message': '',
          'data': {'emailVerified': true},
        };

        await dataSource.verifyEmail(email: 'test@example.com', code: '123456');

        expect(adapter.lastBody?['email'], 'test@example.com');
        expect(adapter.lastBody?['code'], '123456');
      });

      test('trims email and code', () async {
        adapter.body = <String, dynamic>{
          'code': 0,
          'message': '',
          'data': {'emailVerified': true},
        };

        await dataSource.verifyEmail(
          email: '  test@example.com  ',
          code: '  123456  ',
        );

        expect(adapter.lastBody?['email'], 'test@example.com');
        expect(adapter.lastBody?['code'], '123456');
      });
    });

    // ─── updateAccountProfile ────────────────────────────────────────
    group('updateAccountProfile', () {
      test('returns updated AuthUser', () async {
        adapter.body = _accountDto(
          nickname: 'UpdatedNick',
          avatar: 'https://cdn.example.com/avatar.png',
        );

        final user = await dataSource.updateAccountProfile(
          nickname: 'UpdatedNick',
          avatar: 'https://cdn.example.com/avatar.png',
        );

        expect(user.nickname, 'UpdatedNick');
        expect(user.avatar, 'https://cdn.example.com/avatar.png');
      });

      test('trims nickname and avatar', () async {
        adapter.body = _accountDto();

        await dataSource.updateAccountProfile(
          nickname: '  NewNick  ',
          avatar: '  https://cdn.example.com/a.png  ',
        );

        expect(adapter.lastBody?['nickname'], 'NewNick');
        expect(adapter.lastBody?['avatar'], 'https://cdn.example.com/a.png');
      });

      test('passes null values', () async {
        adapter.body = _accountDto();

        await dataSource.updateAccountProfile();

        expect(adapter.lastBody?['nickname'], isNull);
        expect(adapter.lastBody?['avatar'], isNull);
      });
    });

    // ─── changePassword ──────────────────────────────────────────────
    group('changePassword', () {
      test('clears session store after password change', () async {
        await store.write(
          const LucentSessionTokens(accessToken: 'at-1', refreshToken: 'rt-1'),
        );

        adapter.body = <String, dynamic>{
          'code': 0,
          'message': '',
          'data': null,
        };

        await dataSource.changePassword(
          oldPassword: 'OldPass123',
          newPassword: 'NewPass456',
        );

        expect(await store.read(), isNull);
      });

      test('trims passwords', () async {
        adapter.body = <String, dynamic>{
          'code': 0,
          'message': '',
          'data': null,
        };

        await dataSource.changePassword(
          oldPassword: '  OldPass123  ',
          newPassword: '  NewPass456  ',
        );

        expect(adapter.lastBody?['oldPassword'], 'OldPass123');
        expect(adapter.lastBody?['newPassword'], 'NewPass456');
      });
    });

    // ─── changeEmail ─────────────────────────────────────────────────
    group('changeEmail', () {
      test('returns user with updated email and emailVerifiedAt', () async {
        adapter.body = <String, dynamic>{
          'code': 0,
          'message': '',
          'data': <String, dynamic>{
            'email': 'new@example.com',
            'emailVerifiedAt': '2026-07-11T00:00:00.000Z',
          },
        };

        final currentUser = AuthUser(
          id: 'u-1',
          email: 'old@example.com',
          nickname: 'TestUser',
          avatar: null,
          emailVerifiedAt: null,
          createdAt: DateTime.parse('2026-06-10T08:00:00.000Z'),
          updatedAt: DateTime.parse('2026-06-10T08:00:00.000Z'),
        );

        final result = await dataSource.changeEmail(
          newEmail: 'new@example.com',
          code: '123456',
          currentUser: currentUser,
        );

        expect(result.email, 'new@example.com');
        expect(result.emailVerifiedAt, isNotNull);
        // Other fields preserved from currentUser
        expect(result.id, 'u-1');
        expect(result.nickname, 'TestUser');
      });

      test('trims newEmail and code', () async {
        adapter.body = <String, dynamic>{
          'code': 0,
          'message': '',
          'data': <String, dynamic>{
            'email': 'new@example.com',
            'emailVerifiedAt': '2026-07-11T00:00:00.000Z',
          },
        };

        final currentUser = AuthUser(
          id: 'u-1',
          email: 'old@example.com',
          nickname: 'TestUser',
          avatar: null,
          emailVerifiedAt: null,
          createdAt: DateTime.parse('2026-06-10T08:00:00.000Z'),
          updatedAt: DateTime.parse('2026-06-10T08:00:00.000Z'),
        );

        await dataSource.changeEmail(
          newEmail: '  new@example.com  ',
          code: '  123456  ',
          currentUser: currentUser,
        );

        expect(adapter.lastBody?['newEmail'], 'new@example.com');
        expect(adapter.lastBody?['code'], '123456');
      });
    });

    // ─── deleteAccount ───────────────────────────────────────────────
    group('deleteAccount', () {
      test('clears session store after deletion', () async {
        await store.write(
          const LucentSessionTokens(accessToken: 'at-1', refreshToken: 'rt-1'),
        );

        adapter.body = <String, dynamic>{
          'code': 0,
          'message': '',
          'data': null,
        };

        await dataSource.deleteAccount(password: 'Pass123');

        expect(await store.read(), isNull);
      });

      test('trims password', () async {
        adapter.body = <String, dynamic>{
          'code': 0,
          'message': '',
          'data': null,
        };

        await dataSource.deleteAccount(password: '  Pass123  ');
        expect(adapter.lastBody?['password'], 'Pass123');
      });
    });

    // ─── unlinkIdentity ──────────────────────────────────────────────
    group('unlinkIdentity', () {
      test('returns AuthUser after unlinking', () async {
        adapter.body = _accountDto(linkedIdentities: []);

        final user = await dataSource.unlinkIdentity(identityId: 'id-1');

        expect(user.id, 'u-1');
        expect(user.linkedIdentities, isEmpty);
      });
    });

    // ─── _authUserFromAccount edge cases ─────────────────────────────
    group('_authUserFromAccount edge cases', () {
      test('handles null avatar and null emailVerifiedAt', () async {
        adapter.body = _accountDto(avatar: null, emailVerifiedAt: null);

        final user = await dataSource.fetchAccount();

        expect(user.avatar, isNull);
        expect(user.emailVerifiedAt, isNull);
      });

      test('handles hasPassword false', () async {
        adapter.body = _accountDto(hasPassword: false);

        final user = await dataSource.fetchAccount();
        expect(user.hasPassword, isFalse);
      });

      test('handles empty linkedIdentities', () async {
        adapter.body = _accountDto(linkedIdentities: []);

        final user = await dataSource.fetchAccount();
        expect(user.linkedIdentities, isEmpty);
      });

      test('parses emailVerifiedAt as DateTime', () async {
        adapter.body = _accountDto(emailVerifiedAt: '2026-07-01T12:30:00.000Z');

        final user = await dataSource.fetchAccount();
        expect(
          user.emailVerifiedAt,
          equals(DateTime.parse('2026-07-01T12:30:00.000Z')),
        );
      });
    });

    // ─── login with code instead of password ─────────────────────────
    group('login — code flow', () {
      test('passes null password when empty after trim', () async {
        adapter.body = _loginResponse();

        await dataSource.login(
          email: 'test@example.com',
          password: '   ',
          code: '123456',
        );

        expect(adapter.lastBody?['password'], isNull);
        expect(adapter.lastBody?['code'], '123456');
      });

      test('passes null code when empty after trim', () async {
        adapter.body = _loginResponse();

        await dataSource.login(
          email: 'test@example.com',
          password: 'Pass123',
          code: '   ',
        );

        expect(adapter.lastBody?['code'], isNull);
        expect(adapter.lastBody?['password'], 'Pass123');
      });

      test('passes null password and code when both null', () async {
        adapter.body = _loginResponse();

        await dataSource.login(
          email: 'test@example.com',
          password: null,
          code: null,
        );

        expect(adapter.lastBody?['password'], isNull);
        expect(adapter.lastBody?['code'], isNull);
      });
    });
  });
}
