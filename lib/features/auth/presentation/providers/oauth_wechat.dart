part of 'oauth_login.dart';

/// WeChat login attempt result types.
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

mixin OAuthWechatMixin on OAuthLoginControllerBase {
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
      final s = await _resolve(_remote.loginWithWechatMobile(code: code));
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
      final s = await _resolve(
        _remote.loginWithWechatWeb(code: result.code, state: result.state),
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
      final s = await _resolve(
        _remote.loginWithWechatWeb(code: code, state: state),
      );
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
}
