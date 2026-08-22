import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/network/dio_client.dart';
import 'package:luminous/core/network/session_store.dart';
import 'package:luminous/core/utils/date_format_utils.dart';
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

  /// Extracts the response body, throwing a descriptive error if null.
  ///
  /// Replaces `response.data!` to avoid `NullPointerException` when
  /// the server returns an empty body (500 error, network timeout, CDN
  /// interception). [operation] names the API call so production errors
  /// carry request context.
  T _requireBody<T>(T? body, String operation) {
    if (body == null) {
      throw StateError('API 返回空响应体（$operation）');
    }
    return body;
  }

  /// Trims [value]; returns null when the result is empty.
  ///
  /// Consolidates the repeated `x?.trim()` + `== null || isEmpty` pattern
  /// across OAuth/account methods so trim policy lives in one place.
  static String? _trimOrNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
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
    final response = await _client.auth.localControllerLoginV1(
      loginDto: LoginDto(
        email: email.trim(),
        password: _trimOrNull(password),
        code: _trimOrNull(code),
      ),
    );
    final session = AuthMapper.toSessionFromLogin(
      _requireBody(response.data, 'login'),
    );
    await _persistSession(session);
    return session;
  }

  @override
  Future<OAuthAuthorizeData> createWechatWebAuthorizeUrl({
    String? callbackUri,
  }) async {
    final trimmedCallbackUri = _trimOrNull(callbackUri);
    final response = await _client.auth
        .oAuthControllerCreateWechatWebAuthorizeUrlV1(
          oAuthAuthorizeDto: trimmedCallbackUri != null
              ? OAuthAuthorizeDto(callbackUri: trimmedCallbackUri)
              : null,
        );
    return _mapAuthorizeData(
      _requireBody(response.data, 'createWechatWebAuthorizeUrl'),
    );
  }

  @override
  Future<OAuthAuthorizeData> createWechatWebIdentityLinkAuthorizeUrl({
    String? callbackUri,
  }) async {
    final trimmedIdentityCallbackUri = _trimOrNull(callbackUri);
    final response = await _client.account
        .accountControllerCreateWechatWebIdentityLinkAuthorizeUrlV1(
          oAuthAuthorizeDto: trimmedIdentityCallbackUri != null
              ? OAuthAuthorizeDto(callbackUri: trimmedIdentityCallbackUri)
              : null,
        );
    return _mapAuthorizeData(
      _requireBody(response.data, 'createWechatWebIdentityLinkAuthorizeUrl'),
    );
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
    final session = AuthMapper.toSessionFromLogin(
      _requireBody(response.data, 'loginWithWechatWeb'),
    );
    await _persistSession(session);
    return session;
  }

  @override
  Future<AuthSession> loginWithWechatMobile({required String code}) async {
    final response = await _client.auth.oAuthControllerLoginWithWechatMobileV1(
      oAuthCodeCallbackDto: OAuthCodeCallbackDto(code: code.trim()),
    );
    final session = AuthMapper.toSessionFromLogin(
      _requireBody(response.data, 'loginWithWechatMobile'),
    );
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
    final session = AuthMapper.toSessionFromLogin(
      _requireBody(response.data, 'loginWithApple'),
    );
    await _persistSession(session);
    return session;
  }

  @override
  Future<OAuthAuthorizeData> createQqAuthorizeUrl({String? callbackUri}) async {
    final trimmedQqCallbackUri = _trimOrNull(callbackUri);
    final response = await _client.auth.oAuthControllerCreateQqAuthorizeUrlV1(
      qqOAuthAuthorizeDto: trimmedQqCallbackUri != null
          ? QqOAuthAuthorizeDto(callbackUri: trimmedQqCallbackUri)
          : null,
    );
    return _mapAuthorizeData(
      _requireBody(response.data, 'createQqAuthorizeUrl'),
    );
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
    final session = AuthMapper.toSessionFromLogin(
      _requireBody(response.data, 'loginWithQq'),
    );
    await _persistSession(session);
    return session;
  }

  @override
  Future<OAuthAuthorizeData> createWeiboAuthorizeUrl({
    String? callbackUri,
  }) async {
    final trimmedWeiboCallbackUri = _trimOrNull(callbackUri);
    final response = await _client.auth
        .oAuthControllerCreateWeiboAuthorizeUrlV1(
          weiboOAuthAuthorizeDto: trimmedWeiboCallbackUri != null
              ? WeiboOAuthAuthorizeDto(callbackUri: trimmedWeiboCallbackUri)
              : null,
        );
    return _mapAuthorizeData(
      _requireBody(response.data, 'createWeiboAuthorizeUrl'),
    );
  }

  @override
  Future<AuthSession> loginWithWeibo({
    required String code,
    required String state,
  }) async {
    final response = await _client.auth.oAuthControllerLoginWithWeiboV1(
      weiboOAuthCallbackDto: WeiboOAuthCallbackDto(
        code: code.trim(),
        state: state.trim(),
      ),
    );
    final session = AuthMapper.toSessionFromLogin(
      _requireBody(response.data, 'loginWithWeibo'),
    );
    await _persistSession(session);
    return session;
  }

  @override
  Future<OAuthAuthorizeData> createGoogleAuthorizeUrl({
    String? callbackUri,
  }) async {
    final trimmedGoogleCallbackUri = _trimOrNull(callbackUri);
    final response = await _client.auth
        .oAuthControllerCreateGoogleAuthorizeUrlV1(
          googleOAuthAuthorizeDto: trimmedGoogleCallbackUri != null
              ? GoogleOAuthAuthorizeDto(callbackUri: trimmedGoogleCallbackUri)
              : null,
        );
    return _mapAuthorizeData(
      _requireBody(response.data, 'createGoogleAuthorizeUrl'),
    );
  }

  @override
  Future<AuthSession> loginWithGoogle({
    required String code,
    required String state,
  }) async {
    final response = await _client.auth.oAuthControllerLoginWithGoogleV1(
      googleOAuthCallbackDto: GoogleOAuthCallbackDto(
        code: code.trim(),
        state: state.trim(),
      ),
    );
    final session = AuthMapper.toSessionFromLogin(
      _requireBody(response.data, 'loginWithGoogle'),
    );
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
    return _authUserFromAccount(
      _requireBody(response.data, 'linkWechatWebIdentity'),
    );
  }

  @override
  Future<AuthUser> linkWechatMobileIdentity({required String code}) async {
    final response = await _client.account
        .accountControllerLinkWechatMobileIdentityV1(
          oAuthCodeCallbackDto: OAuthCodeCallbackDto(code: code.trim()),
        );
    return _authUserFromAccount(
      _requireBody(response.data, 'linkWechatMobileIdentity'),
    );
  }

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String code,
    String? nickname,
  }) async {
    final response = await _client.auth.localControllerRegisterV1(
      registerDto: RegisterDto(
        email: email.trim(),
        password: password.trim(),
        code: code.trim(),
        nickname: _trimOrNull(nickname),
      ),
    );
    return AuthMapper.toSessionFromRegister(
      _requireBody(response.data, 'register'),
    );
  }

  @override
  Future<void> logout() async {
    final refreshToken = await _sessionStore.readRefreshToken();
    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _client.auth.sessionControllerLogoutV1(
          logoutDto: LogoutDto(refreshToken: refreshToken),
        );
      }
    } finally {
      // 无论登出请求成功与否，本地 session 都必须清除，避免 token 残留
      //（例如 500/超时导致用户已"登出"但本地仍持有凭证）。
      await _sessionStore.clear();
    }
  }

  @override
  Future<AuthUser> fetchAccount() async {
    final response = await _client.account.accountControllerGetAccountV1();
    return _authUserFromAccount(_requireBody(response.data, 'fetchAccount'));
  }

  @override
  Future<AuthSession> refreshSession({required String refreshToken}) async {
    final response = await _client.auth.sessionControllerRefreshV1(
      refreshDto: RefreshDto(refreshToken: refreshToken.trim()),
    );
    final tokens = _requireBody(response.data, 'refreshSession');
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
    final dto = _requireBody(response.data, 'sendVerificationCode');
    return _mapCooldown(dto.message, dto.cooldown);
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
    final dto = _requireBody(response.data, 'forgotPassword');
    return _mapCooldown(dto.message, dto.cooldown);
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
        nickname: _trimOrNull(nickname),
        avatar: _trimOrNull(avatar),
      ),
    );
    return _authUserFromAccount(
      _requireBody(response.data, 'updateAccountProfile'),
    );
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
    final body = _requireBody(response.data, 'changeEmail');
    return currentUser.copyWith(
      email: body.email,
      emailVerifiedAt: parseDateTimeOrNull(body.emailVerifiedAt),
    );
  }

  @override
  Future<void> deleteAccount({String? password, String? code}) async {
    await _client.account.accountControllerDeleteAccountV1(
      deleteAccountDto: DeleteAccountDto(
        password: _trimOrNull(password),
        code: _trimOrNull(code),
      ),
    );
    await _sessionStore.clear();
  }

  @override
  Future<AuthUser> unlinkIdentity({required String identityId}) async {
    final response = await _client.account.accountControllerUnlinkIdentityV1(
      identityId: identityId,
    );
    return _authUserFromAccount(_requireBody(response.data, 'unlinkIdentity'));
  }

  AuthUser _authUserFromAccount(AccountResponseDto user) {
    return AuthUser(
      id: user.id,
      email: user.email?.toString(),
      nickname: user.nickname?.toString(),
      avatar: user.avatar?.toString(),
      emailVerifiedAt: parseDateTimeOrNull(user.emailVerifiedAt),
      hasPassword: user.hasPassword,
      lastLoginAt: parseDateTimeOrNull(user.lastLoginAt),
      linkedIdentities: user.linkedIdentities
          .map(
            (identity) => AuthLinkedIdentity(
              id: identity.id,
              provider: identity.provider,
              email: identity.email?.toString(),
              emailVerifiedAt: parseDateTimeOrNull(identity.emailVerifiedAt),
              linkedAt: parseDateTimeOrEpoch(identity.linkedAt),
            ),
          )
          .toList(),
      createdAt: parseDateTimeOrEpoch(user.createdAt),
      updatedAt: parseDateTimeOrEpoch(user.updatedAt),
    );
  }

  OAuthAuthorizeData _mapAuthorizeData(OAuthAuthorizeResponseDto dto) {
    return OAuthAuthorizeData(
      authorizeUrl: dto.authorizeUrl,
      state: dto.state,
      expiresInSeconds: dto.expiresIn.toInt(),
    );
  }

  VerificationCooldown _mapCooldown(String message, num cooldown) {
    return VerificationCooldown(
      message: message,
      cooldownSeconds: cooldown.toInt(),
    );
  }
}
