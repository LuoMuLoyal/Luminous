import 'package:lucent_api/api/export.dart';
import 'package:luminous/core/network/session_store.dart';
import 'package:luminous/features/auth/data/mappers/mapper.dart';
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

  SendVerificationCodeDtoSceneScene _toDtoScene(AuthVerificationScene scene) {
    return switch (scene) {
      AuthVerificationScene.register =>
        SendVerificationCodeDtoSceneScene.register,
      AuthVerificationScene.login => SendVerificationCodeDtoSceneScene.login,
      AuthVerificationScene.resetPassword =>
        SendVerificationCodeDtoSceneScene.resetPassword,
      AuthVerificationScene.changeEmail =>
        SendVerificationCodeDtoSceneScene.changeEmail,
      AuthVerificationScene.deleteAccount =>
        SendVerificationCodeDtoSceneScene.deleteAccount,
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
      body: LoginDto(
        email: email.trim(),
        password: trimmedPassword == null || trimmedPassword.isEmpty
            ? null
            : trimmedPassword,
        code: trimmedCode == null || trimmedCode.isEmpty ? null : trimmedCode,
      ),
    );
    final session = AuthMapper.toSessionFromLogin(response);
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
          body: trimmedCallbackUri != null && trimmedCallbackUri.isNotEmpty
              ? OAuthAuthorizeDto(callbackUri: trimmedCallbackUri)
              : null,
        );
    return _mapAuthorizeData(response.data);
  }

  @override
  Future<OAuthAuthorizeData> createWechatWebIdentityLinkAuthorizeUrl({
    String? callbackUri,
  }) async {
    final trimmedIdentityCallbackUri = callbackUri?.trim();
    final response = await _client.account
        .accountControllerCreateWechatWebIdentityLinkAuthorizeUrlV1(
          body:
              trimmedIdentityCallbackUri != null &&
                  trimmedIdentityCallbackUri.isNotEmpty
              ? OAuthAuthorizeDto(callbackUri: trimmedIdentityCallbackUri)
              : null,
        );
    return _mapAuthorizeData(response.data);
  }

  @override
  Future<AuthSession> loginWithWechatWeb({
    required String code,
    required String state,
  }) async {
    final response = await _client.auth.oAuthControllerLoginWithWechatWebV1(
      body: OAuthCallbackDto(code: code.trim(), state: state.trim()),
    );
    final session = AuthMapper.toSessionFromLogin(response);
    await _persistSession(session);
    return session;
  }

  @override
  Future<AuthSession> loginWithWechatMobile({required String code}) async {
    final response = await _client.auth.oAuthControllerLoginWithWechatMobileV1(
      body: OAuthCodeCallbackDto(code: code.trim()),
    );
    final session = AuthMapper.toSessionFromLogin(response);
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
      body: AppleOAuthCallbackDto(
        identityToken: identityToken,
        authorizationCode: authorizationCode,
        givenName: givenName,
        familyName: familyName,
      ),
    );
    final session = AuthMapper.toSessionFromLogin(response);
    await _persistSession(session);
    return session;
  }

  @override
  Future<OAuthAuthorizeData> createQqAuthorizeUrl({String? callbackUri}) async {
    final trimmedQqCallbackUri = callbackUri?.trim();
    final response = await _client.auth.oAuthControllerCreateQqAuthorizeUrlV1(
      body: trimmedQqCallbackUri != null && trimmedQqCallbackUri.isNotEmpty
          ? QqOAuthAuthorizeDto(callbackUri: trimmedQqCallbackUri)
          : null,
    );
    return _mapAuthorizeData(response.data);
  }

  @override
  Future<AuthSession> loginWithQq({
    required String code,
    required String state,
  }) async {
    final response = await _client.auth.oAuthControllerLoginWithQqV1(
      body: QqOAuthCallbackDto(code: code.trim(), state: state.trim()),
    );
    final session = AuthMapper.toSessionFromLogin(response);
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
          body: OAuthCallbackDto(code: code.trim(), state: state.trim()),
        );
    return _authUserFromAccount(response.data);
  }

  @override
  Future<AuthUser> linkWechatMobileIdentity({required String code}) async {
    final response = await _client.account
        .accountControllerLinkWechatMobileIdentityV1(
          body: OAuthCodeCallbackDto(code: code.trim()),
        );
    return _authUserFromAccount(response.data);
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
      body: RegisterDto(
        email: email.trim(),
        password: password.trim(),
        code: code.trim(),
        nickname: trimmedNickname == null || trimmedNickname.isEmpty
            ? null
            : trimmedNickname,
      ),
    );
    return AuthMapper.toSessionFromRegister(response);
  }

  @override
  Future<void> logout() async {
    final refreshToken = await _sessionStore.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _sessionStore.clear();
      return;
    }

    await _client.auth.sessionControllerLogoutV1(
      body: LogoutDto(refreshToken: refreshToken),
    );
    await _sessionStore.clear();
  }

  @override
  Future<AuthUser> fetchAccount() async {
    final response = await _client.account.accountControllerGetAccountV1();
    return _authUserFromAccount(response.data);
  }

  @override
  Future<VerificationCooldown> sendVerificationCode({
    required String email,
    required AuthVerificationScene scene,
  }) async {
    final response = await _client.auth.localControllerSendVerificationCodeV1(
      body: SendVerificationCodeDto(
        email: email.trim(),
        scene: _toDtoScene(scene),
      ),
    );
    return _mapCooldown(response.data);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    await _client.auth.localControllerResetPasswordV1(
      body: ResetPasswordDto(
        email: email.trim(),
        code: code.trim(),
        password: password.trim(),
      ),
    );
  }

  @override
  Future<VerificationCooldown> forgotPassword({required String email}) async {
    final response = await _client.auth.localControllerForgotPasswordV1(
      body: ForgotPasswordDto(email: email.trim()),
    );
    return _mapCooldown(response.data);
  }

  @override
  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    await _client.auth.localControllerVerifyEmailV1(
      body: VerifyEmailDto(email: email.trim(), code: code.trim()),
    );
  }

  @override
  Future<AuthUser> updateAccountProfile({
    String? nickname,
    String? avatar,
  }) async {
    final response = await _client.account.accountControllerUpdateAccountV1(
      body: UpdateAccountDto(
        nickname: nickname?.trim(),
        avatar: avatar?.trim(),
      ),
    );
    return _authUserFromAccount(response.data);
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _client.account.accountControllerChangePasswordV1(
      body: ChangePasswordDto(
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
      body: ChangeEmailDto(newEmail: newEmail.trim(), code: code.trim()),
    );
    return currentUser.copyWith(
      email: response.data.email,
      emailVerifiedAt: DateTime.parse(response.data.emailVerifiedAt),
    );
  }

  @override
  Future<void> deleteAccount({String? password, String? code}) async {
    final trimmedPassword = password?.trim();
    final trimmedCode = code?.trim();
    await _client.account.accountControllerDeleteAccountV1(
      body: DeleteAccountDto(
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
    return _authUserFromAccount(response.data);
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
    return DateTime.parse(raw);
  }
}
