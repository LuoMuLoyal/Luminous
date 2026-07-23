import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucent_api/api/export.dart';
import 'package:luminous/core/network/session_store.dart';
import 'package:luminous/features/auth/data/datasources/auth.dart';
import 'package:luminous/features/auth/domain/entities/auth_verification_scene.dart';
import 'package:luminous/features/auth/domain/entities/oauth_authorize.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/domain/entities/verification_code.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';

import '../helpers/test_forui_app.dart';

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
        LucentClient(Dio(BaseOptions(baseUrl: 'http://localhost'))),
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
  String? resetPasswordEmail;
  String? resetPasswordCode;
  String? resetPasswordValue;
  String? changeEmailNewEmail;
  String? changeEmailCode;
  String? updateProfileNickname;
  String? updateProfileAvatar;
  String? changePasswordOldPassword;
  String? changePasswordNewPassword;
  String? deleteAccountPassword;
  String? unlinkIdentityId;
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
  Future<AuthSession> login({
    required String email,
    String? password,
    String? code,
  }) async {
    loginEmail = email;
    loginPassword = password;
    loginCode = code;
    return testSession(email: email);
  }

  @override
  Future<OAuthAuthorizeData> createWechatWebAuthorizeUrl({
    String? callbackUri,
  }) async {
    createWechatAuthorizeCalled = true;
    wechatAuthorizeCallbackUri = callbackUri;
    return const OAuthAuthorizeData(
      authorizeUrl:
          'https://open.weixin.qq.com/connect/qrconnect?state=state-1',
      state: 'state-1',
      expiresInSeconds: 600,
    );
  }

  @override
  Future<OAuthAuthorizeData> createWechatWebIdentityLinkAuthorizeUrl({
    String? callbackUri,
  }) async {
    createWechatIdentityLinkAuthorizeCalled = true;
    wechatIdentityLinkAuthorizeCallbackUri = callbackUri;
    return const OAuthAuthorizeData(
      authorizeUrl:
          'https://open.weixin.qq.com/connect/qrconnect?state=link-state-1',
      state: 'link-state-1',
      expiresInSeconds: 600,
    );
  }

  @override
  Future<AuthSession> loginWithWechatWeb({
    required String code,
    required String state,
  }) async {
    wechatCallbackCode = code;
    wechatCallbackState = state;
    return testSession(email: 'wechat@example.com', nickname: 'WechatUser');
  }

  @override
  Future<AuthSession> loginWithWechatMobile({required String code}) async {
    wechatMobileCallbackCode = code;
    return testSession(
      email: 'wechat-mobile@example.com',
      nickname: 'WxMobile',
    );
  }

  @override
  Future<AuthUser> linkWechatWebIdentity({
    required String code,
    required String state,
  }) async {
    wechatIdentityLinkCallbackCode = code;
    wechatIdentityLinkCallbackState = state;
    return _linkedWechatUser(provider: 'wechat_web');
  }

  @override
  Future<AuthUser> linkWechatMobileIdentity({required String code}) async {
    wechatMobileIdentityLinkCallbackCode = code;
    return _linkedWechatUser(provider: 'wechat_mobile');
  }

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String code,
    String? nickname,
  }) async {
    registerEmail = email;
    registerPassword = password;
    registerCode = code;
    registerNickname = nickname;
    return testSession(email: email, nickname: nickname);
  }

  @override
  Future<VerificationCooldown> sendVerificationCode({
    required String email,
    required AuthVerificationScene scene,
  }) async {
    sentCodeEmail = email;
    sentCodeScene = scene;
    return const VerificationCooldown(message: 'sent', cooldownSeconds: 60);
  }

  @override
  Future<VerificationCooldown> forgotPassword({required String email}) async {
    forgotPasswordEmail = email;
    return const VerificationCooldown(message: 'sent', cooldownSeconds: 60);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    resetPasswordEmail = email;
    resetPasswordCode = code;
    resetPasswordValue = password;
  }

  @override
  Future<AuthUser> changeEmail({
    required String newEmail,
    required String code,
    required AuthUser currentUser,
  }) async {
    changeEmailNewEmail = newEmail;
    changeEmailCode = code;
    return currentUser.copyWith(email: newEmail, emailVerifiedAt: null);
  }

  @override
  Future<AuthUser> updateAccountProfile({
    String? nickname,
    String? avatar,
  }) async {
    updateProfileNickname = nickname;
    updateProfileAvatar = avatar;
    return AuthUser(
      id: 'user-1',
      email: 'user@example.com',
      nickname: nickname,
      avatar: avatar,
      emailVerifiedAt: DateTime.parse('2026-01-01T00:00:00Z'),
      createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
      updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
    );
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    changePasswordOldPassword = oldPassword;
    changePasswordNewPassword = newPassword;
  }

  @override
  Future<void> deleteAccount({String? password, String? code}) async {
    deleteAccountPassword = password;
  }

  @override
  Future<AuthUser> unlinkIdentity({required String identityId}) async {
    unlinkIdentityId = identityId;
    return AuthUser(
      id: 'user-1',
      email: 'user@example.com',
      nickname: 'Lumi',
      avatar: null,
      emailVerifiedAt: DateTime.parse('2026-01-01T00:00:00Z'),
      hasPassword: true,
      createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
      updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
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
