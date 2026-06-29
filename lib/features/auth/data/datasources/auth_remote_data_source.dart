import 'package:luminous/core/network/lucent_api.dart';
import 'package:luminous/features/auth/data/mappers/auth_mapper.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';

enum AuthVerificationScene {
  register,
  login,
  resetPassword,
  changeEmail;

  SendVerificationCodeDtoSceneEnum toDtoScene() {
    return switch (this) {
      AuthVerificationScene.register =>
        SendVerificationCodeDtoSceneEnum.register,
      AuthVerificationScene.login => SendVerificationCodeDtoSceneEnum.login,
      AuthVerificationScene.resetPassword =>
        SendVerificationCodeDtoSceneEnum.resetPassword,
      AuthVerificationScene.changeEmail =>
        SendVerificationCodeDtoSceneEnum.changeEmail,
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
    final response = await _client.authApi.authControllerLoginV1(
      loginDto: LoginDto(
        email: email.trim(),
        password: password?.trim().isEmpty ?? true ? null : password!.trim(),
        code: code?.trim().isEmpty ?? true ? null : code!.trim(),
      ),
    );
    final body = response.data;
    if (body == null) {
      throw const LucentApiException(message: 'Login response is empty.');
    }
    final session = AuthMapper.toSessionFromLogin(body);
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
    final response = await _client.authApi
        .authControllerCreateWechatWebAuthorizeUrlV1(
          oAuthAuthorizeDto: callbackUri?.trim().isEmpty ?? true
              ? null
              : OAuthAuthorizeDto(callbackUri: callbackUri!.trim()),
        );
    final body = response.data;
    if (body == null) {
      throw const LucentApiException(
        message: 'WeChat authorize response is empty.',
      );
    }
    return body.data;
  }

  Future<OAuthAuthorizeDataDto> createWechatWebIdentityLinkAuthorizeUrl({
    String? callbackUri,
  }) async {
    final response = await _client.accountApi
        .accountControllerCreateWechatWebIdentityLinkAuthorizeUrlV1(
          oAuthAuthorizeDto: callbackUri?.trim().isEmpty ?? true
              ? null
              : OAuthAuthorizeDto(callbackUri: callbackUri!.trim()),
        );
    final body = response.data;
    if (body == null) {
      throw const LucentApiException(
        message: 'WeChat identity link authorize response is empty.',
      );
    }
    return body.data;
  }

  Future<AuthSession> loginWithWechatWeb({
    required String code,
    required String state,
  }) async {
    final response = await _client.authApi.authControllerLoginWithWechatWebV1(
      oAuthCallbackDto: OAuthCallbackDto(
        code: code.trim(),
        state: state.trim(),
      ),
    );
    final body = response.data;
    if (body == null) {
      throw const LucentApiException(
        message: 'WeChat login response is empty.',
      );
    }
    final session = AuthMapper.toSessionFromLogin(body);
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
        .authControllerLoginWithWechatMobileV1(
          oAuthCodeCallbackDto: OAuthCodeCallbackDto(code: code.trim()),
        );
    final body = response.data;
    if (body == null) {
      throw const LucentApiException(
        message: 'WeChat mobile login response is empty.',
      );
    }
    final session = AuthMapper.toSessionFromLogin(body);
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
    final response = await _client.authApi.authControllerLoginWithAppleV1(
      appleOAuthCallbackDto: AppleOAuthCallbackDto(
        identityToken: identityToken,
        authorizationCode: authorizationCode,
        givenName: givenName,
        familyName: familyName,
      ),
    );
    final body = response.data;
    if (body == null) {
      throw const LucentApiException(message: 'Apple login response is empty.');
    }
    final session = AuthMapper.toSessionFromLogin(body);
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
    final response = await _client.authApi.authControllerCreateQqAuthorizeUrlV1(
      qqOAuthAuthorizeDto: callbackUri?.trim().isEmpty ?? true
          ? null
          : QqOAuthAuthorizeDto(callbackUri: callbackUri!.trim()),
    );
    final body = response.data;
    if (body == null) {
      throw const LucentApiException(
        message: 'QQ authorize response is empty.',
      );
    }
    return body.data;
  }

  Future<AuthSession> loginWithQq({
    required String code,
    required String state,
  }) async {
    final response = await _client.authApi.authControllerLoginWithQqV1(
      qqOAuthCallbackDto: QqOAuthCallbackDto(
        code: code.trim(),
        state: state.trim(),
      ),
    );
    final body = response.data;
    if (body == null) {
      throw const LucentApiException(message: 'QQ login response is empty.');
    }
    final session = AuthMapper.toSessionFromLogin(body);
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
          oAuthCallbackDto: OAuthCallbackDto(
            code: code.trim(),
            state: state.trim(),
          ),
        );
    final body = response.data;
    if (body == null) {
      throw const LucentApiException(
        message: 'WeChat identity link response is empty.',
      );
    }
    return _authUserFromAccount(body.data);
  }

  Future<AuthUser> linkWechatMobileIdentity({required String code}) async {
    final response = await _client.accountApi
        .accountControllerLinkWechatMobileIdentityV1(
          oAuthCodeCallbackDto: OAuthCodeCallbackDto(code: code.trim()),
        );
    final body = response.data;
    if (body == null) {
      throw const LucentApiException(
        message: 'WeChat mobile identity link response is empty.',
      );
    }
    return _authUserFromAccount(body.data);
  }

  Future<AuthSession> register({
    required String email,
    required String password,
    required String code,
    String? nickname,
  }) async {
    final response = await _client.authApi.authControllerRegisterV1(
      registerDto: RegisterDto(
        email: email.trim(),
        password: password.trim(),
        code: code.trim(),
        nickname: nickname?.trim().isEmpty ?? true ? null : nickname!.trim(),
      ),
    );
    final body = response.data;
    if (body == null) {
      throw const LucentApiException(message: 'Register response is empty.');
    }
    return AuthMapper.toSessionFromRegister(body);
  }

  Future<void> logout() async {
    final refreshToken = await _client.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _client.clearSession();
      return;
    }

    await _client.authApi.authControllerLogoutV1(
      logoutDto: LogoutDto(refreshToken: refreshToken),
    );
    await _client.clearSession();
  }

  Future<AuthUser> fetchAccount() async {
    final response = await _client.accountApi.accountControllerGetAccountV1();
    final body = response.data;
    if (body == null) {
      throw const LucentApiException(message: 'Account response is empty.');
    }
    final user = body.data;
    return _authUserFromAccount(user);
  }

  Future<CooldownMessageDto> sendVerificationCode({
    required String email,
    required AuthVerificationScene scene,
  }) async {
    final response = await _client.authApi.authControllerSendVerificationCodeV1(
      sendVerificationCodeDto: SendVerificationCodeDto(
        email: email.trim(),
        scene: scene.toDtoScene(),
      ),
    );
    final body = response.data;
    if (body == null) {
      throw const LucentApiException(
        message: 'Send verification code response is empty.',
      );
    }
    return body.data;
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    await _client.authApi.authControllerResetPasswordV1(
      resetPasswordDto: ResetPasswordDto(
        email: email.trim(),
        code: code.trim(),
        password: password.trim(),
      ),
    );
  }

  Future<CooldownMessageDto> forgotPassword({required String email}) async {
    final response = await _client.authApi.authControllerForgotPasswordV1(
      forgotPasswordDto: ForgotPasswordDto(email: email.trim()),
    );
    final body = response.data;
    if (body == null) {
      throw const LucentApiException(
        message: 'Forgot password response is empty.',
      );
    }
    return body.data;
  }

  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    await _client.authApi.authControllerVerifyEmailV1(
      verifyEmailDto: VerifyEmailDto(email: email.trim(), code: code.trim()),
    );
  }

  Future<AuthUser> updateAccountProfile({
    String? nickname,
    String? avatar,
  }) async {
    final response = await _client.accountApi.accountControllerUpdateAccountV1(
      updateAccountDto: UpdateAccountDto(
        nickname: nickname?.trim(),
        avatar: avatar?.trim(),
      ),
    );
    final body = response.data;
    if (body == null) {
      throw const LucentApiException(
        message: 'Update profile response is empty.',
      );
    }
    return _authUserFromAccount(body.data);
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _client.accountApi.accountControllerChangePasswordV1(
      changePasswordDto: ChangePasswordDto(
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
      changeEmailDto: ChangeEmailDto(
        newEmail: newEmail.trim(),
        code: code.trim(),
      ),
    );
    final body = response.data;
    if (body == null) {
      throw const LucentApiException(
        message: 'Change email response is empty.',
      );
    }
    return currentUser.copyWith(
      email: body.data.email,
      emailVerifiedAt: DateTime.parse(body.data.emailVerifiedAt),
    );
  }

  Future<void> deleteAccount({required String password}) async {
    await _client.accountApi.accountControllerDeleteAccountV1(
      deleteAccountDto: DeleteAccountDto(password: password.trim()),
    );
    await _client.clearSession();
  }

  Future<AuthUser> unlinkIdentity({required String identityId}) async {
    final response = await _client.accountApi.accountControllerUnlinkIdentityV1(
      identityId: identityId,
    );
    final body = response.data;
    if (body == null) {
      throw const LucentApiException(
        message: 'Unlink identity response is empty.',
      );
    }
    return _authUserFromAccount(body.data);
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
