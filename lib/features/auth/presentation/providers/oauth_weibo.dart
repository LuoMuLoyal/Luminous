part of 'oauth_login.dart';

mixin OAuthWeiboMixin on OAuthLoginControllerBase {
  /// Creates a Weibo authorize URL.
  ///
  /// Returns the authorize URL on success, `null` on failure.
  Future<String?> startWeiboLogin({String? webCallbackUri}) async {
    state = state.copyWith(
      isStartingWeibo: true,
      errorMessage: null,
      weiboAuthorizeUrl: null,
      weiboState: null,
    );
    try {
      final authorize = await _resolve(
        _remote.createWeiboAuthorizeUrl(callbackUri: webCallbackUri),
      );
      state = state.copyWith(
        isStartingWeibo: false,
        weiboAuthorizeUrl: authorize.authorizeUrl,
        weiboState: authorize.state,
      );
      return authorize.authorizeUrl;
    } catch (e) {
      final errorMessage = _mapError(e, 'OAuthLoginController.startWeiboLogin');
      state = state.copyWith(
        isStartingWeibo: false,
        errorMessage: errorMessage,
      );
      return null;
    }
  }

  /// Completes a Weibo login with a manually-pasted callback.
  Future<AuthSession?> completeWeiboLogin({
    required String code,
    required String state,
  }) async {
    this.state = this.state.copyWith(
      isCompletingWeibo: true,
      errorMessage: null,
    );
    try {
      final s = await _resolve(
        _remote.loginWithWeibo(code: code, state: state),
      );
      await ref.read(authSessionProvider.notifier).applySession(s);
      this.state = this.state.copyWith(isCompletingWeibo: false);
      return s;
    } catch (e) {
      final errorMessage = _mapError(
        e,
        'OAuthLoginController.completeWeiboLogin',
      );
      this.state = this.state.copyWith(
        isCompletingWeibo: false,
        errorMessage: errorMessage,
      );
      return null;
    }
  }
}
