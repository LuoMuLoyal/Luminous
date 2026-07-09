import 'package:luminous/core/network/api.dart';
import 'package:luminous/features/auth/data/mappers/mapper.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';

enum AuthVerificationScene {
  register,
  login,
  resetPassword,
  changeEmail;

  SendVerificationCodeDtoSceneScene toDtoScene() {
    return switch (this) {
      AuthVerificationScene.register =>
        SendVerificationCodeDtoSceneScene.register,
      AuthVerificationScene.login => SendVerificationCodeDtoSceneScene.login,
      AuthVerificationScene.resetPassword =>
        SendVerificationCodeDtoSceneScene.resetPassword,
      AuthVerificationScene.changeEmail =>
        SendVerificationCodeDtoSceneScene.changeEmail,
    };
  }
}

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._client);

  final LucentDioClient _client;

  Future<AuthSession> login({
    required String email,
    String? password,
    String? code,
  }) async {
    final trimmedPassword = password?.trim();
    final trimmedCode = code?.trim();
    final response = await _client.authApi.localControllerLoginV1(
      body: LoginDto(
        email: email.trim(),
        password: trimmedPassword == null || trimmedPassword.isEmpty
            ? null
            : trimmedPassword,
        code: trimmedCode == null || trimmedCode.isEmpty ? null : trimmedCode,
      ),
    );
    final session = AuthMapper.toSessionFromLogin(response);
    await _client.writeSession(
      LucentSessionTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      ),
    );
    return session;
  }

  Future<OAuthAuthorizeDataDto> createWechatWebAuthorizeUrl({
    String? callbackUri,
  }) async {
    final trimmedCallbackUri = callbackUri?.trim();
    final response = await _client.authApi
        .oAuthControllerCreateWechatWebAuthorizeUrlV1(
          body: trimmedCallbackUri != null && trimmedCallbackUri.isNotEmpty
              ? OAuthAuthorizeDto(callbackUri: trimmedCallbackUri)
              : null,
        );
    return response.data;
  }

  Future<OAuthAuthorizeDataDto> createWechatWebIdentityLinkAuthorizeUrl({
    String? callbackUri,
  }) async {
    final trimmedIdentityCallbackUri = callbackUri?.trim();
    final response = await _client.accountApi
        .accountControllerCreateWechatWebIdentityLinkAuthorizeUrlV1(
          body:
              trimmedIdentityCallbackUri != null &&
                  trimmedIdentityCallbackUri.isNotEmpty
              ? OAuthAuthorizeDto(callbackUri: trimmedIdentityCallbackUri)
              : null,
        );
    return response.data;
  }

  Future<AuthSession> loginWithWechatWeb({
    required String code,
    required String state,
  }) async {
    final response = await _client.authApi.oAuthControllerLoginWithWechatWebV1(
      body: OAuthCallbackDto(code: code.trim(), state: state.trim()),
    );
    final session = AuthMapper.toSessionFromLogin(response);
    await _client.writeSession(
      LucentSessionTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      ),
    );
    return session;
  }

  Future<AuthSession> loginWithWechatMobile({required String code}) async {
    final response = await _client.authApi
        .oAuthControllerLoginWithWechatMobileV1(
          body: OAuthCodeCallbackDto(code: code.trim()),
        );
    final session = AuthMapper.toSessionFromLogin(response);
    await _client.writeSession(
      LucentSessionTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      ),
    );
    return session;
  }

  Future<AuthSession> loginWithApple({
    required String identityToken,
    String? authorizationCode,
    String? givenName,
    String? familyName,
  }) async {
    final response = await _client.authApi.oAuthControllerLoginWithAppleV1(
      body: AppleOAuthCallbackDto(
        identityToken: identityToken,
        authorizationCode: authorizationCode,
        givenName: givenName,
        familyName: familyName,
      ),
    );
    final session = AuthMapper.toSessionFromLogin(response);
    await _client.writeSession(
      LucentSessionTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      ),
    );
    return session;
  }

  Future<OAuthAuthorizeDataDto> createQqAuthorizeUrl({
    String? callbackUri,
  }) async {
    final trimmedQqCallbackUri = callbackUri?.trim();
    final response = await _client.authApi
        .oAuthControllerCreateQqAuthorizeUrlV1(
          body: trimmedQqCallbackUri != null && trimmedQqCallbackUri.isNotEmpty
              ? QqOAuthAuthorizeDto(callbackUri: trimmedQqCallbackUri)
              : null,
        );
    return response.data;
  }

  Future<AuthSession> loginWithQq({
    required String code,
    required String state,
  }) async {
    final response = await _client.authApi.oAuthControllerLoginWithQqV1(
      body: QqOAuthCallbackDto(code: code.trim(), state: state.trim()),
    );
    final session = AuthMapper.toSessionFromLogin(response);
    await _client.writeSession(
      LucentSessionTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      ),
    );
    return session;
  }

  Future<AuthUser> linkWechatWebIdentity({
    required String code,
    required String state,
  }) async {
    final response = await _client.accountApi
        .accountControllerLinkWechatWebIdentityV1(
          body: OAuthCallbackDto(code: code.trim(), state: state.trim()),
        );
    return _authUserFromAccount(response.data);
  }

  Future<AuthUser> linkWechatMobileIdentity({required String code}) async {
    final response = await _client.accountApi
        .accountControllerLinkWechatMobileIdentityV1(
          body: OAuthCodeCallbackDto(code: code.trim()),
        );
    return _authUserFromAccount(response.data);
  }

  Future<AuthSession> register({
    required String email,
    required String password,
    required String code,
    String? nickname,
  }) async {
    final trimmedNickname = nickname?.trim();
    final response = await _client.authApi.localControllerRegisterV1(
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

  Future<void> logout() async {
    final refreshToken = await _client.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _client.clearSession();
      return;
    }

    await _client.authApi.sessionControllerLogoutV1(
      body: LogoutDto(refreshToken: refreshToken),
    );
    await _client.clearSession();
  }

  Future<AuthUser> fetchAccount() async {
    final response = await _client.accountApi.accountControllerGetAccountV1();
    return _authUserFromAccount(response.data);
  }

  Future<CooldownMessageDto> sendVerificationCode({
    required String email,
    required AuthVerificationScene scene,
  }) async {
    final response = await _client.authApi
        .localControllerSendVerificationCodeV1(
          body: SendVerificationCodeDto(
            email: email.trim(),
            scene: scene.toDtoScene(),
          ),
        );
    return response.data;
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    await _client.authApi.localControllerResetPasswordV1(
      body: ResetPasswordDto(
        email: email.trim(),
        code: code.trim(),
        password: password.trim(),
      ),
    );
  }

  Future<CooldownMessageDto> forgotPassword({required String email}) async {
    final response = await _client.authApi.localControllerForgotPasswordV1(
      body: ForgotPasswordDto(email: email.trim()),
    );
    return response.data;
  }

  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    await _client.authApi.localControllerVerifyEmailV1(
      body: VerifyEmailDto(email: email.trim(), code: code.trim()),
    );
  }

  Future<AuthUser> updateAccountProfile({
    String? nickname,
    String? avatar,
  }) async {
    final response = await _client.accountApi.accountControllerUpdateAccountV1(
      body: UpdateAccountDto(
        nickname: nickname?.trim(),
        avatar: avatar?.trim(),
      ),
    );
    return _authUserFromAccount(response.data);
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _client.accountApi.accountControllerChangePasswordV1(
      body: ChangePasswordDto(
        oldPassword: oldPassword.trim(),
        newPassword: newPassword.trim(),
      ),
    );
    await _client.clearSession();
  }

  Future<AuthUser> changeEmail({
    required String newEmail,
    required String code,
    required AuthUser currentUser,
  }) async {
    final response = await _client.accountApi.accountControllerChangeEmailV1(
      body: ChangeEmailDto(newEmail: newEmail.trim(), code: code.trim()),
    );
    return currentUser.copyWith(
      email: response.data.email,
      emailVerifiedAt: DateTime.parse(response.data.emailVerifiedAt),
    );
  }

  Future<void> deleteAccount({required String password}) async {
    await _client.accountApi.accountControllerDeleteAccountV1(
      body: DeleteAccountDto(password: password.trim()),
    );
    await _client.clearSession();
  }

  Future<AuthUser> unlinkIdentity({required String identityId}) async {
    final response = await _client.accountApi.accountControllerUnlinkIdentityV1(
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

  DateTime? _parseOptionalDateTime(Object? value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.parse(raw);
  }
}
