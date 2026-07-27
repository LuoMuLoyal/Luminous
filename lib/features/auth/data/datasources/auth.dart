import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/network/dio_client.dart';
import 'package:luminous/core/network/session_store.dart';
import 'package:luminous/features/auth/data/mappers/auth.dart';
import 'package:luminous/features/auth/domain/entities/auth_verification_scene.dart';
import 'package:luminous/features/auth/domain/entities/oauth_authorize.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/domain/entities/verification_code.dart';
import 'package:luminous/features/auth/domain/repositories/auth.dart';

class LucentAuthRepository implements AuthRepository {
  const LucentAuthRepository(this._client, this._sessionStore);

  final LucentClient _client;
  final LucentSessionStore _sessionStore;

  /// Persists [session] tokens to the local session store.
  ///
  /// Extracted to eliminate the 5× `writeSession` duplication across all
  /// login methods ([login], [loginWithWechatWeb], [loginWithWechatMobile],
  /// [loginWithApple], [loginWithQq]).
  Future<void> _persistSession(AuthSession session) async {
    await _sessionStore.write(
      LucentSessionTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      ),
    );
  }

  SendVerificationCodeDtoSceneEnum _toDtoScene(AuthVerificationScene scene) {
    return switch (scene) {
      AuthVerificationScene.register =>
        SendVerificationCodeDtoSceneEnum.register,
      AuthVerificationScene.login => SendVerificationCodeDtoSceneEnum.login,
      AuthVerificationScene.resetPassword =>
        SendVerificationCodeDtoSceneEnum.resetPassword,
      AuthVerificationScene.changeEmail =>
        SendVerificationCodeDtoSceneEnum.changeEmail,
      AuthVerificationScene.deleteAccount =>
        SendVerificationCodeDtoSceneEnum.deleteAccount,
    };
  }

  @override
  Future<AuthSession> login({
    required String email,
    String? password,
    String? code,
  }) async {
    final trimmedPassword = password?.trim();
    final trimmedCode = code?.trim();
    final response = await _client.auth.localControllerLoginV1(
      loginDto: LoginDto(
        email: email.trim(),
        password: trimmedPassword == null || trimmedPassword.isEmpty
            ? null
            : trimmedPassword,
        code: trimmedCode == null || trimmedCode.isEmpty ? null : trimmedCode,
      ),
    );
    final session = AuthMapper.toSessionFromLogin(response.data!.data);
    await _persistSession(session);
    return session;
  }

  @override
  Future<OAuthAuthorizeData> createWechatWebAuthorizeUrl({
    String? callbackUri,
  }) async {
    final trimmedCallbackUri = callbackUri?.trim();
    final response = await _client.auth
        .oAuthControllerCreateWechatWebAuthorizeUrlV1(
          oAuthAuthorizeDto:
              trimmedCallbackUri != null && trimmedCallbackUri.isNotEmpty
              ? OAuthAuthorizeDto(callbackUri: trimmedCallbackUri)
              : null,
        );
    return _mapAuthorizeData(response.data!.data);
  }

  @override
  Future<OAuthAuthorizeData> createWechatWebIdentityLinkAuthorizeUrl({
    String? callbackUri,
  }) async {
    final trimmedIdentityCallbackUri = callbackUri?.trim();
    final response = await _client.account
        .accountControllerCreateWechatWebIdentityLinkAuthorizeUrlV1(
          oAuthAuthorizeDto:
              trimmedIdentityCallbackUri != null &&
                  trimmedIdentityCallbackUri.isNotEmpty
              ? OAuthAuthorizeDto(callbackUri: trimmedIdentityCallbackUri)
              : null,
        );
    return _mapAuthorizeData(response.data!.data);
  }

  @override
  Future<AuthSession> loginWithWechatWeb({
    required String code,
    required String state,
  }) async {
    final response = await _client.auth.oAuthControllerLoginWithWechatWebV1(
      oAuthCallbackDto: OAuthCallbackDto(
        code: code.trim(),
        state: state.trim(),
      ),
    );
    final session = AuthMapper.toSessionFromLogin(response.data!.data);
    await _persistSession(session);
    return session;
  }

  @override
  Future<AuthSession> loginWithWechatMobile({required String code}) async {
    final response = await _client.auth.oAuthControllerLoginWithWechatMobileV1(
      oAuthCodeCallbackDto: OAuthCodeCallbackDto(code: code.trim()),
    );
    final session = AuthMapper.toSessionFromLogin(response.data!.data);
    await _persistSession(session);
    return session;
  }

  @override
  Future<AuthSession> loginWithApple({
    required String identityToken,
    String? authorizationCode,
    String? givenName,
    String? familyName,
  }) async {
    final response = await _client.auth.oAuthControllerLoginWithAppleV1(
      appleOAuthCallbackDto: AppleOAuthCallbackDto(
        identityToken: identityToken,
        authorizationCode: authorizationCode,
        givenName: givenName,
        familyName: familyName,
      ),
    );
    final session = AuthMapper.toSessionFromLogin(response.data!.data);
    await _persistSession(session);
    return session;
  }

  @override
  Future<OAuthAuthorizeData> createQqAuthorizeUrl({String? callbackUri}) async {
    final trimmedQqCallbackUri = callbackUri?.trim();
    final response = await _client.auth.oAuthControllerCreateQqAuthorizeUrlV1(
      qqOAuthAuthorizeDto:
          trimmedQqCallbackUri != null && trimmedQqCallbackUri.isNotEmpty
          ? QqOAuthAuthorizeDto(callbackUri: trimmedQqCallbackUri)
          : null,
    );
    return _mapAuthorizeData(response.data!.data);
  }

  @override
  Future<AuthSession> loginWithQq({
    required String code,
    required String state,
  }) async {
    final response = await _client.auth.oAuthControllerLoginWithQqV1(
      qqOAuthCallbackDto: QqOAuthCallbackDto(
        code: code.trim(),
        state: state.trim(),
      ),
    );
    final session = AuthMapper.toSessionFromLogin(response.data!.data);
    await _persistSession(session);
    return session;
  }

  @override
  Future<AuthUser> linkWechatWebIdentity({
    required String code,
    required String state,
  }) async {
    final response = await _client.account
        .accountControllerLinkWechatWebIdentityV1(
          oAuthCallbackDto: OAuthCallbackDto(
            code: code.trim(),
            state: state.trim(),
          ),
        );
    return _authUserFromAccount(response.data!.data);
  }

  @override
  Future<AuthUser> linkWechatMobileIdentity({required String code}) async {
    final response = await _client.account
        .accountControllerLinkWechatMobileIdentityV1(
          oAuthCodeCallbackDto: OAuthCodeCallbackDto(code: code.trim()),
        );
    return _authUserFromAccount(response.data!.data);
  }

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String code,
    String? nickname,
  }) async {
    final trimmedNickname = nickname?.trim();
    final response = await _client.auth.localControllerRegisterV1(
      registerDto: RegisterDto(
        email: email.trim(),
        password: password.trim(),
        code: code.trim(),
        nickname: trimmedNickname == null || trimmedNickname.isEmpty
            ? null
            : trimmedNickname,
      ),
    );
    return AuthMapper.toSessionFromRegister(response.data!.data);
  }

  @override
  Future<void> logout() async {
    final refreshToken = await _sessionStore.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _sessionStore.clear();
      return;
    }

    await _client.auth.sessionControllerLogoutV1(
      logoutDto: LogoutDto(refreshToken: refreshToken),
    );
    await _sessionStore.clear();
  }

  @override
  Future<AuthUser> fetchAccount() async {
    final response = await _client.account.accountControllerGetAccountV1();
    return _authUserFromAccount(response.data!.data);
  }

  @override
  Future<AuthSession> refreshSession({required String refreshToken}) async {
    final response = await _client.auth.sessionControllerRefreshV1(
      refreshDto: RefreshDto(refreshToken: refreshToken.trim()),
    );
    final tokens = response.data!.data;
    await _sessionStore.write(
      LucentSessionTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      ),
    );
    final user = await fetchAccount();
    return AuthSession(
      user: user,
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      expiresInSeconds: tokens.expiresIn.toInt(),
    );
  }

  @override
  Future<VerificationCooldown> sendVerificationCode({
    required String email,
    required AuthVerificationScene scene,
  }) async {
    final response = await _client.auth.localControllerSendVerificationCodeV1(
      sendVerificationCodeDto: SendVerificationCodeDto(
        email: email.trim(),
        scene: _toDtoScene(scene),
      ),
    );
    return _mapCooldown(response.data!.data);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    await _client.auth.localControllerResetPasswordV1(
      resetPasswordDto: ResetPasswordDto(
        email: email.trim(),
        code: code.trim(),
        password: password.trim(),
      ),
    );
  }

  @override
  Future<VerificationCooldown> forgotPassword({required String email}) async {
    final response = await _client.auth.localControllerForgotPasswordV1(
      forgotPasswordDto: ForgotPasswordDto(email: email.trim()),
    );
    return _mapCooldown(response.data!.data);
  }

  @override
  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    await _client.auth.localControllerVerifyEmailV1(
      verifyEmailDto: VerifyEmailDto(email: email.trim(), code: code.trim()),
    );
  }

  @override
  Future<AuthUser> updateAccountProfile({
    String? nickname,
    String? avatar,
  }) async {
    final response = await _client.account.accountControllerUpdateAccountV1(
      updateAccountDto: UpdateAccountDto(
        nickname: nickname?.trim(),
        avatar: avatar?.trim(),
      ),
    );
    return _authUserFromAccount(response.data!.data);
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _client.account.accountControllerChangePasswordV1(
      changePasswordDto: ChangePasswordDto(
        oldPassword: oldPassword.trim(),
        newPassword: newPassword.trim(),
      ),
    );
    await _sessionStore.clear();
  }

  @override
  Future<AuthUser> changeEmail({
    required String newEmail,
    required String code,
    required AuthUser currentUser,
  }) async {
    final response = await _client.account.accountControllerChangeEmailV1(
      changeEmailDto: ChangeEmailDto(
        newEmail: newEmail.trim(),
        code: code.trim(),
      ),
    );
    return currentUser.copyWith(
      email: response.data!.data.email,
      emailVerifiedAt: _parseOptionalDateTime(
        response.data!.data.emailVerifiedAt,
      ),
    );
  }

  @override
  Future<void> deleteAccount({String? password, String? code}) async {
    final trimmedPassword = password?.trim();
    final trimmedCode = code?.trim();
    await _client.account.accountControllerDeleteAccountV1(
      deleteAccountDto: DeleteAccountDto(
        password: trimmedPassword == null || trimmedPassword.isEmpty
            ? null
            : trimmedPassword,
        code: trimmedCode == null || trimmedCode.isEmpty ? null : trimmedCode,
      ),
    );
    await _sessionStore.clear();
  }

  @override
  Future<AuthUser> unlinkIdentity({required String identityId}) async {
    final response = await _client.account.accountControllerUnlinkIdentityV1(
      identityId: identityId,
    );
    return _authUserFromAccount(response.data!.data);
  }

  AuthUser _authUserFromAccount(AccountDto user) {
    return AuthUser(
      id: user.id,
      email: user.email?.toString(),
      nickname: user.nickname?.toString(),
      avatar: user.avatar?.toString(),
      emailVerifiedAt: _parseOptionalDateTime(user.emailVerifiedAt),
      hasPassword: user.hasPassword,
      lastLoginAt: _parseOptionalDateTime(user.lastLoginAt),
      linkedIdentities: user.linkedIdentities
          .map(
            (identity) => AuthLinkedIdentity(
              id: identity.id,
              provider: identity.provider,
              email: identity.email?.toString(),
              emailVerifiedAt: _parseOptionalDateTime(identity.emailVerifiedAt),
              linkedAt: DateTime.parse(identity.linkedAt),
            ),
          )
          .toList(),
      createdAt: DateTime.parse(user.createdAt),
      updatedAt: DateTime.parse(user.updatedAt),
    );
  }

  OAuthAuthorizeData _mapAuthorizeData(OAuthAuthorizeDataDto dto) {
    return OAuthAuthorizeData(
      authorizeUrl: dto.authorizeUrl,
      state: dto.state,
      expiresInSeconds: dto.expiresIn.toInt(),
    );
  }

  VerificationCooldown _mapCooldown(CooldownMessageDto dto) {
    return VerificationCooldown(
      message: dto.message,
      cooldownSeconds: dto.cooldown.toInt(),
    );
  }

  DateTime? _parseOptionalDateTime(Object? value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return DateTime.parse(raw);
    } on FormatException {
      return null;
    }
  }
}
