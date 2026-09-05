import 'package:fpdart/fpdart.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/client/dio_client.dart';
import 'package:luminous/core/network/client/session_store.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/core/network/contract/error_mapper.dart';
import 'package:luminous/core/utils/date_format.dart';
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

  /// Extracts the response body, throwing a network failure if null.
  ///
  /// Replaces `response.data!` to avoid `NullPointerException` when
  /// the server returns an empty body (500 error, network timeout, CDN
  /// interception). [operation] names the API call so production errors
  /// carry request context. Follows the `TodayAiRemoteDataSource` precedent:
  /// an empty body is a transport-level failure, not a protocol invariant.
  T _requireBody<T>(T? body, String operation) {
    if (body == null) {
      throw LucentFailure.network(
        message: 'Empty response body ($operation)',
        networkErrorCode: NetworkErrorCode.emptyResponse,
      );
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

  SendVerificationCodeRequestSceneEnum _toDtoScene(
    AuthVerificationScene scene,
  ) {
    return switch (scene) {
      AuthVerificationScene.register =>
        SendVerificationCodeRequestSceneEnum.register,
      AuthVerificationScene.login => SendVerificationCodeRequestSceneEnum.login,
      AuthVerificationScene.setPassword =>
        SendVerificationCodeRequestSceneEnum.setPassword,
      AuthVerificationScene.changeEmail =>
        SendVerificationCodeRequestSceneEnum.changeEmail,
      AuthVerificationScene.deleteAccount =>
        SendVerificationCodeRequestSceneEnum.deleteAccount,
    };
  }

  @override
  TaskEither<LucentFailure, AuthSession> login({
    required String email,
    String? password,
    String? code,
  }) {
    return TaskEither.tryCatch(() async {
      final response = await _client.auth.login(
        loginRequest: LoginRequest(
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
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, OAuthAuthorizeData> createWechatWebAuthorizeUrl({
    String? callbackUri,
  }) {
    return TaskEither.tryCatch(() async {
      final trimmedCallbackUri = _trimOrNull(callbackUri);
      final response = await _client.auth.createWechatWebAuthorizeUrl(
        createWechatWebAuthorizeUrlRequest: CreateWechatWebAuthorizeUrlRequest(
          callbackUri: trimmedCallbackUri,
        ),
      );
      return _mapAuthorizeData(
        _requireBody(response.data, 'createWechatWebAuthorizeUrl'),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, OAuthAuthorizeData>
  createWechatWebIdentityLinkAuthorizeUrl({String? callbackUri}) {
    return TaskEither.tryCatch(() async {
      final trimmedIdentityCallbackUri = _trimOrNull(callbackUri);
      final response = await _client.account
          .createWechatWebIdentityLinkAuthorizeUrl(
            createWechatWebIdentityLinkAuthorizeUrlRequest:
                CreateWechatWebIdentityLinkAuthorizeUrlRequest(
                  callbackUri: trimmedIdentityCallbackUri,
                ),
          );
      return _mapAuthorizeData(
        _requireBody(response.data, 'createWechatWebIdentityLinkAuthorizeUrl'),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, AuthSession> loginWithWechatWeb({
    required String code,
    required String state,
  }) {
    return TaskEither.tryCatch(() async {
      final response = await _client.auth.loginWithWechatWeb(
        loginWithWechatWebRequest: LoginWithWechatWebRequest(
          code: code.trim(),
          state: state.trim(),
        ),
      );
      final session = AuthMapper.toSessionFromLogin(
        _requireBody(response.data, 'loginWithWechatWeb'),
      );
      await _persistSession(session);
      return session;
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, AuthSession> loginWithWechatMobile({
    required String code,
  }) {
    return TaskEither.tryCatch(() async {
      final response = await _client.auth.loginWithWechatMobile(
        loginWithWechatMobileRequest: LoginWithWechatMobileRequest(
          code: code.trim(),
        ),
      );
      final session = AuthMapper.toSessionFromLogin(
        _requireBody(response.data, 'loginWithWechatMobile'),
      );
      await _persistSession(session);
      return session;
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, AuthSession> loginWithApple({
    required String identityToken,
    String? authorizationCode,
    String? givenName,
    String? familyName,
  }) {
    return TaskEither.tryCatch(() async {
      final response = await _client.auth.loginWithApple(
        loginWithAppleRequest: LoginWithAppleRequest(
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
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, OAuthAuthorizeData> createQqAuthorizeUrl({
    String? callbackUri,
  }) {
    return TaskEither.tryCatch(() async {
      final trimmedQqCallbackUri = _trimOrNull(callbackUri);
      final response = await _client.auth.createQqAuthorizeUrl(
        createQqAuthorizeUrlRequest: CreateQqAuthorizeUrlRequest(
          callbackUri: trimmedQqCallbackUri,
        ),
      );
      return _mapAuthorizeData(
        _requireBody(response.data, 'createQqAuthorizeUrl'),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, AuthSession> loginWithQq({
    required String code,
    required String state,
  }) {
    return TaskEither.tryCatch(() async {
      final response = await _client.auth.loginWithQq(
        loginWithQqRequest: LoginWithQqRequest(
          code: code.trim(),
          state: state.trim(),
        ),
      );
      final session = AuthMapper.toSessionFromLogin(
        _requireBody(response.data, 'loginWithQq'),
      );
      await _persistSession(session);
      return session;
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, OAuthAuthorizeData> createWeiboAuthorizeUrl({
    String? callbackUri,
  }) {
    return TaskEither.tryCatch(() async {
      final trimmedWeiboCallbackUri = _trimOrNull(callbackUri);
      final response = await _client.auth.createWeiboAuthorizeUrl(
        createWeiboAuthorizeUrlRequest: CreateWeiboAuthorizeUrlRequest(
          callbackUri: trimmedWeiboCallbackUri,
        ),
      );
      return _mapAuthorizeData(
        _requireBody(response.data, 'createWeiboAuthorizeUrl'),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, AuthSession> loginWithWeibo({
    required String code,
    required String state,
  }) {
    return TaskEither.tryCatch(() async {
      final response = await _client.auth.loginWithWeibo(
        loginWithWeiboRequest: LoginWithWeiboRequest(
          code: code.trim(),
          state: state.trim(),
        ),
      );
      final session = AuthMapper.toSessionFromLogin(
        _requireBody(response.data, 'loginWithWeibo'),
      );
      await _persistSession(session);
      return session;
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, OAuthAuthorizeData> createGoogleAuthorizeUrl({
    String? callbackUri,
  }) {
    return TaskEither.tryCatch(() async {
      final trimmedGoogleCallbackUri = _trimOrNull(callbackUri);
      final response = await _client.auth.createGoogleAuthorizeUrl(
        createGoogleAuthorizeUrlRequest: CreateGoogleAuthorizeUrlRequest(
          callbackUri: trimmedGoogleCallbackUri,
        ),
      );
      return _mapAuthorizeData(
        _requireBody(response.data, 'createGoogleAuthorizeUrl'),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, AuthSession> loginWithGoogle({
    required String code,
    required String state,
  }) {
    return TaskEither.tryCatch(() async {
      final response = await _client.auth.loginWithGoogle(
        loginWithGoogleRequest: LoginWithGoogleRequest(
          code: code.trim(),
          state: state.trim(),
        ),
      );
      final session = AuthMapper.toSessionFromLogin(
        _requireBody(response.data, 'loginWithGoogle'),
      );
      await _persistSession(session);
      return session;
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, AuthUser> linkWechatWebIdentity({
    required String code,
    required String state,
  }) {
    return TaskEither.tryCatch(() async {
      final response = await _client.account.linkWechatWebIdentity(
        linkWechatWebIdentityRequest: LinkWechatWebIdentityRequest(
          code: code.trim(),
          state: state.trim(),
        ),
      );
      return _authUserFromAccount(
        _requireBody(response.data, 'linkWechatWebIdentity'),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, AuthUser> linkWechatMobileIdentity({
    required String code,
  }) {
    return TaskEither.tryCatch(() async {
      final response = await _client.account.linkWechatMobileIdentity(
        linkWechatMobileIdentityRequest: LinkWechatMobileIdentityRequest(
          code: code.trim(),
        ),
      );
      return _authUserFromAccount(
        _requireBody(response.data, 'linkWechatMobileIdentity'),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, AuthSession> register({
    required String email,
    required String password,
    required String code,
    String? nickname,
  }) {
    return TaskEither.tryCatch(() async {
      final response = await _client.auth.register(
        registerRequest: RegisterRequest(
          email: email.trim(),
          password: password.trim(),
          code: code.trim(),
          nickname: _trimOrNull(nickname),
        ),
      );
      return AuthMapper.toSessionFromRegister(
        _requireBody(response.data, 'register'),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, void> logout() {
    return TaskEither.tryCatch(() async {
      final refreshToken = await _sessionStore.readRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _client.auth.logout(
          logoutRequest: LogoutRequest(refreshToken: refreshToken),
        );
      }
      // 远程注销成功（或无 refresh token 可注销）才清本地 session；
      // 远程注销失败时 tryCatch 已把失败转为 Left，此处不会执行，
      // 本地尚未确认的 session 被保留，也不写 token holder。
      await _sessionStore.clear();
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, AuthUser> fetchAccount() {
    return TaskEither.tryCatch(() async {
      final response = await _client.account.getAccount();
      return _authUserFromAccount(_requireBody(response.data, 'fetchAccount'));
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, AuthSession> refreshSession({
    required String refreshToken,
  }) {
    // Step 1: refresh tokens (with side-effect: persist to session store).
    final refreshTokens = TaskEither<LucentFailure, RefreshResponse>.tryCatch(
      () async {
        final response = await _client.auth.refreshSession(
          refreshSessionRequest: RefreshSessionRequest(
            refreshToken: refreshToken.trim(),
          ),
        );
        final tokens = _requireBody(response.data, 'refreshSession');
        await _sessionStore.write(
          LucentSessionTokens(
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken,
          ),
        );
        return tokens;
      },
      (error, stackTrace) => LucentErrorMapper.fromObject(error),
    );

    // Step 2: fetch account and compose the session — no throw inside.
    return refreshTokens.flatMap(
      (tokens) => fetchAccount().map(
        (user) => AuthSession(
          user: user,
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
          expiresInSeconds: tokens.expiresIn.toInt(),
        ),
      ),
    );
  }

  @override
  TaskEither<LucentFailure, VerificationCooldown> sendVerificationCode({
    required String email,
    required AuthVerificationScene scene,
  }) {
    return TaskEither.tryCatch(() async {
      final response = await _client.auth.sendVerificationCode(
        sendVerificationCodeRequest: SendVerificationCodeRequest(
          email: email.trim(),
          scene: _toDtoScene(scene),
        ),
      );
      final dto = _requireBody(response.data, 'sendVerificationCode');
      return _mapCooldown(dto.message, dto.cooldown);
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, void> resetPassword({
    required String token,
    required String password,
  }) {
    return TaskEither.tryCatch(() async {
      await _client.auth.resetPassword(
        resetPasswordRequest: ResetPasswordRequest(
          token: token.trim(),
          password: password.trim(),
        ),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, VerificationCooldown> forgotPassword({
    required String email,
  }) {
    return TaskEither.tryCatch(() async {
      final response = await _client.auth.forgotPassword(
        forgotPasswordRequest: ForgotPasswordRequest(email: email.trim()),
      );
      final dto = _requireBody(response.data, 'forgotPassword');
      return _mapCooldown(dto.message, dto.cooldown);
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, void> verifyEmail({required String token}) {
    return TaskEither.tryCatch(() async {
      await _client.auth.verifyEmail(
        verifyEmailRequest: VerifyEmailRequest(token: token.trim()),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, AuthUser> updateAccountProfile({
    String? nickname,
    String? avatar,
  }) {
    return TaskEither.tryCatch(() async {
      final response = await _client.account.updateAccount(
        updateAccountRequest: UpdateAccountRequest(
          nickname: _trimOrNull(nickname),
          avatar: _trimOrNull(avatar),
        ),
      );
      return _authUserFromAccount(
        _requireBody(response.data, 'updateAccountProfile'),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, void> changePassword({
    required String password,
    required String newPassword,
  }) {
    return TaskEither.tryCatch(() async {
      await _client.account.changePassword(
        changePasswordRequest: ChangePasswordRequest(
          password: password.trim(),
          newPassword: newPassword.trim(),
        ),
      );
      await _sessionStore.clear();
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, AuthUser> changeEmail({
    required String newEmail,
    required String code,
    required String password,
    required AuthUser currentUser,
  }) {
    return TaskEither.tryCatch(() async {
      final response = await _client.account.changeEmail(
        changeEmailRequest: ChangeEmailRequest(
          newEmail: newEmail.trim(),
          code: code.trim(),
          password: password.trim(),
        ),
      );
      final body = _requireBody(response.data, 'changeEmail');
      return currentUser.copyWith(
        email: body.email,
        emailVerifiedAt: parseDateTimeOrNull(body.emailVerifiedAt),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, void> deleteAccount({
    String? password,
    String? code,
  }) {
    return TaskEither.tryCatch(() async {
      await _client.account.deleteAccount(
        deleteAccountRequest: DeleteAccountRequest(
          password: _trimOrNull(password),
          code: _trimOrNull(code),
        ),
      );
      await _sessionStore.clear();
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, AuthUser> unlinkIdentity({
    required String identityId,
    required String password,
  }) {
    return TaskEither.tryCatch(() async {
      final response = await _client.account.unlinkIdentity(
        identityId: identityId,
        unlinkIdentityRequest: UnlinkIdentityRequest(password: password.trim()),
      );
      return _authUserFromAccount(
        _requireBody(response.data, 'unlinkIdentity'),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, DataExportRequestData> requestDataExport({
    required CreateRequestRequestKindEnum kind,
    required CreateRequestRequestFormatEnum format,
    required CreateRequestRequestRangeEnum range,
    required String password,
  }) {
    return TaskEither.tryCatch(() async {
      final response = await _client.dataExport.createRequest(
        createRequestRequest: CreateRequestRequest(
          kind: kind,
          format: format,
          range: range,
          password: password.trim(),
        ),
      );
      final body = _requireBody(response.data, 'requestDataExport');
      return DataExportRequestData.fromJson(body.toJson());
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  AuthUser _authUserFromAccount(AccountResponse user) {
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

  OAuthAuthorizeData _mapAuthorizeData(OAuthAuthorizeResponse dto) {
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
