import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/network/lucent_api.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';

class TestAuthApp extends StatelessWidget {
  const TestAuthApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: const Locale('zh'),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}

class FakeAuthRemoteDataSource extends AuthRemoteDataSource {
  FakeAuthRemoteDataSource()
    : super(
        LucentDioClient(
          baseUrl: 'http://localhost',
          sessionStore: _MemorySessionStore(),
        ),
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
  Future<OAuthAuthorizeDataDto> createWechatWebAuthorizeUrl({
    String? callbackUri,
  }) async {
    createWechatAuthorizeCalled = true;
    wechatAuthorizeCallbackUri = callbackUri;
    return OAuthAuthorizeDataDto(
      authorizeUrl:
          'https://open.weixin.qq.com/connect/qrconnect?state=state-1',
      state: 'state-1',
      expiresIn: 600,
      callbackUri: callbackUri,
    );
  }

  @override
  Future<OAuthAuthorizeDataDto> createWechatWebIdentityLinkAuthorizeUrl({
    String? callbackUri,
  }) async {
    createWechatIdentityLinkAuthorizeCalled = true;
    wechatIdentityLinkAuthorizeCallbackUri = callbackUri;
    return OAuthAuthorizeDataDto(
      authorizeUrl:
          'https://open.weixin.qq.com/connect/qrconnect?state=link-state-1',
      state: 'link-state-1',
      expiresIn: 600,
      callbackUri: callbackUri,
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
  Future<CooldownMessageDto> sendVerificationCode({
    required String email,
    required AuthVerificationScene scene,
  }) async {
    sentCodeEmail = email;
    sentCodeScene = scene;
    return CooldownMessageDto(message: 'sent', cooldown: 60);
  }

  @override
  Future<CooldownMessageDto> forgotPassword({required String email}) async {
    forgotPasswordEmail = email;
    return CooldownMessageDto(message: 'sent', cooldown: 60);
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
  Future<void> deleteAccount({required String password}) async {
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
