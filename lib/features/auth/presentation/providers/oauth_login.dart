import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/logger/app_logger.dart';
import 'package:luminous/core/network/api.dart';
import 'package:luminous/features/auth/data/datasources/remote_data_source.dart';
import 'package:luminous/features/auth/data/providers/auth.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/presentation/providers/session/session_provider.dart';
import 'package:luminous/features/auth/presentation/services/wechat_oauth_service.dart';

/// State for OAuth login flows (WeChat, QQ, Apple).
///
/// Managed by [OAuthLoginController]. This is intentionally a plain Dart class
/// (not freezed) to avoid build_runner dependencies and keep the OAuth state
/// decoupled from the email/password form state.
class OAuthLoginState {
  const OAuthLoginState({
    this.isStartingWechat = false,
    this.isCompletingWechat = false,
    this.wechatAuthorizeUrl,
    this.wechatState,
    this.isStartingQq = false,
    this.isCompletingQq = false,
    this.qqAuthorizeUrl,
    this.qqState,
    this.isStartingApple = false,
    this.errorMessage,
  });

  final bool isStartingWechat;
  final bool isCompletingWechat;
  final String? wechatAuthorizeUrl;
  final String? wechatState;

  final bool isStartingQq;
  final bool isCompletingQq;
  final String? qqAuthorizeUrl;
  final String? qqState;

  final bool isStartingApple;
  final String? errorMessage;

  /// Sentinel-based copyWith so nullable fields can be explicitly set to null.
  static const _sentinel = Object();

  OAuthLoginState copyWith({
    bool? isStartingWechat,
    bool? isCompletingWechat,
    Object? wechatAuthorizeUrl = _sentinel,
    Object? wechatState = _sentinel,
    bool? isStartingQq,
    bool? isCompletingQq,
    Object? qqAuthorizeUrl = _sentinel,
    Object? qqState = _sentinel,
    bool? isStartingApple,
    Object? errorMessage = _sentinel,
  }) {
    return OAuthLoginState(
      isStartingWechat: isStartingWechat ?? this.isStartingWechat,
      isCompletingWechat: isCompletingWechat ?? this.isCompletingWechat,
      wechatAuthorizeUrl: wechatAuthorizeUrl == _sentinel
          ? this.wechatAuthorizeUrl
          : wechatAuthorizeUrl as String?,
      wechatState: wechatState == _sentinel
          ? this.wechatState
          : wechatState as String?,
      isStartingQq: isStartingQq ?? this.isStartingQq,
      isCompletingQq: isCompletingQq ?? this.isCompletingQq,
      qqAuthorizeUrl: qqAuthorizeUrl == _sentinel
          ? this.qqAuthorizeUrl
          : qqAuthorizeUrl as String?,
      qqState: qqState == _sentinel ? this.qqState : qqState as String?,
      isStartingApple: isStartingApple ?? this.isStartingApple,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

/// Result of a WeChat login attempt via [OAuthLoginController.startWechatLogin].
sealed class WechatLoginAttempt {
  const WechatLoginAttempt();
}

/// Login completed successfully.
class WechatLoginCompleted extends WechatLoginAttempt {
  const WechatLoginCompleted(this.session);
  final AuthSession session;
}

/// Web fallback is active — authorize URL created. The UI should open the
/// browser and then the user pastes the callback manually.
class WechatLoginWebFallback extends WechatLoginAttempt {
  const WechatLoginWebFallback(this.authorizeUrl);
  final String authorizeUrl;
}

/// Attempt failed or no platform supported. Check
/// [OAuthLoginState.errorMessage] for details.
class WechatLoginFailed extends WechatLoginAttempt {
  const WechatLoginFailed();
}

/// Manages all OAuth login flows (WeChat, QQ, Apple).
///
/// Replaces the 7 OAuth methods that were previously on [LoginFormNotifier].
/// The email/password form notifier is now slim and focused.
class OAuthLoginController extends Notifier<OAuthLoginState> {
  @override
  OAuthLoginState build() => const OAuthLoginState();

  WechatOAuthService get _wechat => ref.read(wechatOAuthServiceProvider);
  AuthRemoteDataSource get _remote => ref.read(authRemoteDataSourceProvider);

  /// Maps an error to a user-facing message and logs it.
  String _mapError(Object error, String tag) {
    ref.read(talkerProvider).error('$tag: failed: $error');
    return LucentErrorMapper.fromObject(error).message;
  }

  // =========================
  //  WeChat
  // =========================

  /// Tries all WeChat login paths in order: mobile → desktop → web fallback.
  ///
  /// Returns:
  /// - [WechatLoginCompleted] on successful login
  /// - [WechatLoginWebFallback] when web fallback is needed (UI opens browser)
  /// - [WechatLoginFailed] on error or unsupported platform
  Future<WechatLoginAttempt> startWechatLogin({String? webCallbackUri}) async {
    state = state.copyWith(
      isStartingWechat: true,
      errorMessage: null,
      wechatAuthorizeUrl: null,
      wechatState: null,
    );

    // 1. Try mobile SDK
    final mobileSession = await startWechatMobileLogin();
    if (mobileSession != null) {
      return WechatLoginCompleted(mobileSession);
    }
    // Bail if mobile auth threw an error (not just "unsupported")
    if (state.errorMessage?.isNotEmpty == true) {
      return const WechatLoginFailed();
    }

    // 2. Try desktop loopback
    final desktopSession = await startWechatDesktopLogin();
    if (desktopSession != null) {
      return WechatLoginCompleted(desktopSession);
    }
    if (state.errorMessage?.isNotEmpty == true) {
      return const WechatLoginFailed();
    }

    // 3. Web fallback — create authorize URL, let UI open browser
    try {
      final authorize = await _wechat.createWebAuthorizeUrl(
        callbackUri: webCallbackUri,
      );
      state = state.copyWith(
        isStartingWechat: false,
        wechatAuthorizeUrl: authorize.authorizeUrl,
        wechatState: authorize.state,
      );
      return WechatLoginWebFallback(authorize.authorizeUrl);
    } catch (e) {
      final errorMessage = _mapError(
        e,
        'OAuthLoginController.startWechatLogin.webFallback',
      );
      state = state.copyWith(
        isStartingWechat: false,
        errorMessage: errorMessage,
      );
      return const WechatLoginFailed();
    }
  }

  /// Tries mobile SDK login only. Returns the session on success, `null` if
  /// mobile is not supported or login failed.
  Future<AuthSession?> startWechatMobileLogin() async {
    try {
      final code = await _wechat.tryMobileAuth();
      if (code == null) return null;

      state = state.copyWith(
        isStartingWechat: true,
        isCompletingWechat: true,
        errorMessage: null,
      );
      final s = await _remote.loginWithWechatMobile(code: code);
      await ref.read(authSessionProvider.notifier).applySession(s);
      state = state.copyWith(
        isStartingWechat: false,
        isCompletingWechat: false,
      );
      return s;
    } catch (e) {
      final errorMessage = _mapError(
        e,
        'OAuthLoginController.startWechatMobileLogin',
      );
      state = state.copyWith(
        isStartingWechat: false,
        isCompletingWechat: false,
        errorMessage: errorMessage,
      );
      return null;
    }
  }

  /// Tries desktop loopback login only. Returns the session on success, `null`
  /// if desktop is not supported, browser failed, or state mismatch.
  Future<AuthSession?> startWechatDesktopLogin() async {
    try {
      final result = await _wechat.tryDesktopAuth(forIdentityLink: false);
      if (result == null) return null;

      state = state.copyWith(
        isStartingWechat: false,
        isCompletingWechat: true,
        errorMessage: null,
      );
      final s = await _remote.loginWithWechatWeb(
        code: result.code,
        state: result.state,
      );
      await ref.read(authSessionProvider.notifier).applySession(s);
      state = state.copyWith(isCompletingWechat: false);
      return s;
    } catch (e) {
      final errorMessage = _mapError(
        e,
        'OAuthLoginController.startWechatDesktopLogin',
      );
      state = state.copyWith(
        isStartingWechat: false,
        isCompletingWechat: false,
        errorMessage: errorMessage,
      );
      return null;
    }
  }

  /// Completes a WeChat web login with a manually-pasted callback.
  Future<AuthSession?> completeWechatLogin({
    required String code,
    required String state,
  }) async {
    this.state = this.state.copyWith(
      isCompletingWechat: true,
      errorMessage: null,
    );
    try {
      final s = await _remote.loginWithWechatWeb(code: code, state: state);
      await ref.read(authSessionProvider.notifier).applySession(s);
      this.state = this.state.copyWith(isCompletingWechat: false);
      return s;
    } catch (e) {
      final errorMessage = _mapError(
        e,
        'OAuthLoginController.completeWechatLogin',
      );
      this.state = this.state.copyWith(
        isCompletingWechat: false,
        errorMessage: errorMessage,
      );
      return null;
    }
  }

  // =========================
  //  QQ
  // =========================

  /// Creates a QQ authorize URL.
  ///
  /// Returns the authorize URL on success, `null` on failure.
  Future<String?> startQqLogin({String? webCallbackUri}) async {
    state = state.copyWith(
      isStartingQq: true,
      errorMessage: null,
      qqAuthorizeUrl: null,
      qqState: null,
    );
    try {
      final authorize = await _remote.createQqAuthorizeUrl(
        callbackUri: webCallbackUri,
      );
      state = state.copyWith(
        isStartingQq: false,
        qqAuthorizeUrl: authorize.authorizeUrl,
        qqState: authorize.state,
      );
      return authorize.authorizeUrl;
    } catch (e) {
      final errorMessage = _mapError(e, 'OAuthLoginController.startQqLogin');
      state = state.copyWith(isStartingQq: false, errorMessage: errorMessage);
      return null;
    }
  }

  /// Completes a QQ login with a manually-pasted callback.
  Future<AuthSession?> completeQqLogin({
    required String code,
    required String state,
  }) async {
    this.state = this.state.copyWith(isCompletingQq: true, errorMessage: null);
    try {
      final s = await _remote.loginWithQq(code: code, state: state);
      await ref.read(authSessionProvider.notifier).applySession(s);
      this.state = this.state.copyWith(isCompletingQq: false);
      return s;
    } catch (e) {
      final errorMessage = _mapError(e, 'OAuthLoginController.completeQqLogin');
      this.state = this.state.copyWith(
        isCompletingQq: false,
        errorMessage: errorMessage,
      );
      return null;
    }
  }

  // =========================
  //  Apple
  // =========================

  /// Completes an Apple Sign In flow.
  Future<AuthSession?> loginWithApple({
    required String identityToken,
    String? authorizationCode,
    String? givenName,
    String? familyName,
  }) async {
    state = state.copyWith(isStartingApple: true, errorMessage: null);
    try {
      final s = await _remote.loginWithApple(
        identityToken: identityToken,
        authorizationCode: authorizationCode,
        givenName: givenName,
        familyName: familyName,
      );
      await ref.read(authSessionProvider.notifier).applySession(s);
      state = state.copyWith(isStartingApple: false);
      return s;
    } catch (e) {
      final errorMessage = _mapError(e, 'OAuthLoginController.loginWithApple');
      state = state.copyWith(
        isStartingApple: false,
        errorMessage: errorMessage,
      );
      return null;
    }
  }

  // =========================
  //  Shared
  // =========================

  /// Clears the error message.
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final oauthLoginProvider =
    NotifierProvider<OAuthLoginController, OAuthLoginState>(
      OAuthLoginController.new,
    );
