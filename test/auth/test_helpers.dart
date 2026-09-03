import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/client/dio_client.dart';
import 'package:luminous/core/network/client/session_store.dart';
import 'package:luminous/features/auth/data/datasources/auth.dart';
import 'package:luminous/features/auth/domain/entities/auth_verification_scene.dart';
import 'package:luminous/features/auth/domain/entities/oauth_authorize.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/domain/entities/verification_code.dart';

import '../helpers/test_forui_app.dart';

Response<dynamic> problemResponse({
  required String path,
  required int statusCode,
  required String code,
  required String detail,
}) {
  return Response<dynamic>(
    requestOptions: RequestOptions(path: path),
    statusCode: statusCode,
    data: <String, dynamic>{
      'type': 'https://api.lumos.example/problems/$code',
      'title': 'Request failed',
      'detail': detail,
      'code': code,
    },
    headers: Headers.fromMap(const {
      Headers.contentTypeHeader: ['application/problem+json'],
    }),
  );
}

class TestAuthApp extends StatelessWidget {
  const TestAuthApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return TestForuiRouterApp(routerConfig: router);
  }
}

class FakeLucentAuthRepository extends LucentAuthRepository {
  FakeLucentAuthRepository()
    : super(
        LucentClient(
          LucentApi(dio: Dio(BaseOptions(baseUrl: 'http://localhost'))),
        ),
        _MemorySessionStore(),
      );

  String? loginEmail;
  String? loginPassword;
  String? loginCode;
  String? registerEmail;
  String? registerPassword;
  String? registerCode;
  String? registerNickname;
  String? sentCodeEmail;
  AuthVerificationScene? sentCodeScene;
  String? forgotPasswordEmail;
  String? resetPasswordToken;
  String? resetPasswordValue;
  String? verifyEmailToken;
  String? changeEmailNewEmail;
  String? changeEmailCode;
  String? changeEmailPassword;
  String? updateProfileNickname;
  String? updateProfileAvatar;
  String? changePasswordPassword;
  String? changePasswordNewPassword;
  String? deleteAccountPassword;
  String? unlinkIdentityId;
  String? unlinkIdentityPassword;
  DataExportControllerCreateRequestV1Request? lastDataExportRequest;
  bool createWechatAuthorizeCalled = false;
  bool createWechatIdentityLinkAuthorizeCalled = false;
  String? wechatAuthorizeCallbackUri;
  String? wechatIdentityLinkAuthorizeCallbackUri;
  String? wechatCallbackCode;
  String? wechatCallbackState;
  String? wechatMobileCallbackCode;
  String? wechatIdentityLinkCallbackCode;
  String? wechatIdentityLinkCallbackState;
  String? wechatMobileIdentityLinkCallbackCode;

  @override
  TaskEither<LucentFailure, AuthSession> login({
    required String email,
    String? password,
    String? code,
  }) {
    loginEmail = email;
    loginPassword = password;
    loginCode = code;
    return TaskEither.right(testSession(email: email));
  }

  @override
  TaskEither<LucentFailure, OAuthAuthorizeData> createWechatWebAuthorizeUrl({
    String? callbackUri,
  }) {
    createWechatAuthorizeCalled = true;
    wechatAuthorizeCallbackUri = callbackUri;
    return TaskEither.right(
      const OAuthAuthorizeData(
        authorizeUrl:
            'https://open.weixin.qq.com/connect/qrconnect?state=state-1',
        state: 'state-1',
        expiresInSeconds: 600,
      ),
    );
  }

  @override
  TaskEither<LucentFailure, OAuthAuthorizeData>
  createWechatWebIdentityLinkAuthorizeUrl({String? callbackUri}) {
    createWechatIdentityLinkAuthorizeCalled = true;
    wechatIdentityLinkAuthorizeCallbackUri = callbackUri;
    return TaskEither.right(
      const OAuthAuthorizeData(
        authorizeUrl:
            'https://open.weixin.qq.com/connect/qrconnect?state=link-state-1',
        state: 'link-state-1',
        expiresInSeconds: 600,
      ),
    );
  }

  @override
  TaskEither<LucentFailure, AuthSession> loginWithWechatWeb({
    required String code,
    required String state,
  }) {
    wechatCallbackCode = code;
    wechatCallbackState = state;
    return TaskEither.right(
      testSession(email: 'wechat@example.com', nickname: 'WechatUser'),
    );
  }

  @override
  TaskEither<LucentFailure, AuthSession> loginWithWechatMobile({
    required String code,
  }) {
    wechatMobileCallbackCode = code;
    return TaskEither.right(
      testSession(email: 'wechat-mobile@example.com', nickname: 'WxMobile'),
    );
  }

  @override
  TaskEither<LucentFailure, AuthUser> linkWechatWebIdentity({
    required String code,
    required String state,
  }) {
    wechatIdentityLinkCallbackCode = code;
    wechatIdentityLinkCallbackState = state;
    return TaskEither.right(_linkedWechatUser(provider: 'wechat_web'));
  }

  @override
  TaskEither<LucentFailure, AuthUser> linkWechatMobileIdentity({
    required String code,
  }) {
    wechatMobileIdentityLinkCallbackCode = code;
    return TaskEither.right(_linkedWechatUser(provider: 'wechat_mobile'));
  }

  @override
  TaskEither<LucentFailure, AuthSession> refreshSession({
    required String refreshToken,
  }) {
    return TaskEither.right(
      testSession(email: 'refresh@example.com', nickname: 'Refreshed'),
    );
  }

  @override
  TaskEither<LucentFailure, AuthSession> register({
    required String email,
    required String password,
    required String code,
    String? nickname,
  }) {
    registerEmail = email;
    registerPassword = password;
    registerCode = code;
    registerNickname = nickname;
    return TaskEither.right(testSession(email: email, nickname: nickname));
  }

  @override
  TaskEither<LucentFailure, VerificationCooldown> sendVerificationCode({
    required String email,
    required AuthVerificationScene scene,
  }) {
    sentCodeEmail = email;
    sentCodeScene = scene;
    return TaskEither.right(
      const VerificationCooldown(message: 'sent', cooldownSeconds: 60),
    );
  }

  @override
  TaskEither<LucentFailure, VerificationCooldown> forgotPassword({
    required String email,
  }) {
    forgotPasswordEmail = email;
    return TaskEither.right(
      const VerificationCooldown(message: 'sent', cooldownSeconds: 60),
    );
  }

  @override
  TaskEither<LucentFailure, void> resetPassword({
    required String token,
    required String password,
  }) {
    resetPasswordToken = token;
    resetPasswordValue = password;
    return TaskEither.right(null);
  }

  @override
  TaskEither<LucentFailure, void> verifyEmail({required String token}) {
    verifyEmailToken = token;
    return TaskEither.right(null);
  }

  @override
  TaskEither<LucentFailure, AuthUser> changeEmail({
    required String newEmail,
    required String code,
    required String password,
    required AuthUser currentUser,
  }) {
    changeEmailNewEmail = newEmail;
    changeEmailCode = code;
    changeEmailPassword = password;
    return TaskEither.right(
      currentUser.copyWith(email: newEmail, emailVerifiedAt: null),
    );
  }

  @override
  TaskEither<LucentFailure, AuthUser> updateAccountProfile({
    String? nickname,
    String? avatar,
  }) {
    updateProfileNickname = nickname;
    updateProfileAvatar = avatar;
    return TaskEither.right(
      AuthUser(
        id: 'user-1',
        email: 'user@example.com',
        nickname: nickname,
        avatar: avatar,
        emailVerifiedAt: DateTime.parse('2026-01-01T00:00:00Z'),
        createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
      ),
    );
  }

  @override
  TaskEither<LucentFailure, void> changePassword({
    required String password,
    required String newPassword,
  }) {
    changePasswordPassword = password;
    changePasswordNewPassword = newPassword;
    return TaskEither.right(null);
  }

  @override
  TaskEither<LucentFailure, void> deleteAccount({
    String? password,
    String? code,
  }) {
    deleteAccountPassword = password;
    return TaskEither.right(null);
  }

  @override
  TaskEither<LucentFailure, AuthUser> unlinkIdentity({
    required String identityId,
    required String password,
  }) {
    unlinkIdentityId = identityId;
    unlinkIdentityPassword = password;
    return TaskEither.right(
      AuthUser(
        id: 'user-1',
        email: 'user@example.com',
        nickname: 'Lumi',
        avatar: null,
        emailVerifiedAt: DateTime.parse('2026-01-01T00:00:00Z'),
        hasPassword: true,
        createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
      ),
    );
  }

  @override
  TaskEither<LucentFailure, DataExportRequestDataDto> requestDataExport({
    required DataExportControllerCreateRequestV1RequestKindEnum kind,
    required DataExportControllerCreateRequestV1RequestFormatEnum format,
    required DataExportControllerCreateRequestV1RequestRangeEnum range,
    required String password,
  }) {
    lastDataExportRequest = DataExportControllerCreateRequestV1Request(
      kind: kind,
      format: format,
      range: range,
      password: password,
    );
    return TaskEither.right(
      DataExportRequestDataDto(
        id: 'export-1',
        kind: DataExportRequestDataDtoKindEnum.hospital,
        format: DataExportRequestDataDtoFormatEnum.pdf,
        range: DataExportRequestDataDtoRangeEnum.last7Days,
        status: DataExportRequestDataDtoStatusEnum.requested,
        requestedAt: DateTime.now().toUtc().toIso8601String(),
        completedAt: null,
        downloadUrl: null,
        fileName: null,
        fileSizeBytes: null,
        errorMessage: null,
      ),
    );
  }

  AuthUser _linkedWechatUser({required String provider}) {
    return AuthUser(
      id: 'user-1',
      email: 'user@example.com',
      nickname: 'Lumi',
      avatar: null,
      emailVerifiedAt: DateTime.parse('2026-01-01T00:00:00Z'),
      hasPassword: true,
      linkedIdentities: [
        AuthLinkedIdentity(
          id: 'identity-linked',
          provider: provider,
          email: null,
          emailVerifiedAt: null,
          linkedAt: DateTime.parse('2026-01-03T00:00:00Z'),
        ),
      ],
      createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
      updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
    );
  }
}

class _MemorySessionStore implements LucentSessionStore {
  LucentSessionTokens? tokens;

  @override
  Future<void> clear() async {
    tokens = null;
  }

  @override
  Future<LucentSessionTokens?> read() async => tokens;

  @override
  Future<String?> readAccessToken() async => tokens?.accessToken;

  @override
  Future<String?> readRefreshToken() async => tokens?.refreshToken;

  @override
  Future<void> write(LucentSessionTokens tokens) async {
    this.tokens = tokens;
  }
}

AuthSession testSession({required String email, String? nickname}) {
  return AuthSession(
    user: AuthUser(
      id: 'user-1',
      email: email,
      nickname: nickname,
      avatar: null,
      emailVerifiedAt: DateTime.parse('2026-01-01T00:00:00Z'),
      createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
      updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
    ),
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    expiresInSeconds: 3600,
  );
}

class SignedInAuthSessionNotifier extends AuthSessionNotifier {
  SignedInAuthSessionNotifier({this.email = 'user@example.com'});

  final String email;

  @override
  AuthSessionState build() {
    return AuthSessionState(
      isAuthenticated: true,
      isLoading: false,
      user: AuthUser(
        id: 'user-1',
        email: email,
        nickname: 'Lumi',
        avatar: null,
        emailVerifiedAt: DateTime.parse('2026-01-01T00:00:00Z'),
        createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
      ),
    );
  }
}
