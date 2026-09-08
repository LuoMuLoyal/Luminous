part of 'oauth_login.dart';

mixin OAuthGoogleMixin on OAuthLoginControllerBase {
  /// Creates a Google authorize URL.
  ///
  /// Returns the authorize URL on success, `null` on failure.
  Future<String?> startGoogleLogin({String? webCallbackUri}) async {
    state = state.copyWith(
      isStartingGoogle: true,
      errorMessage: null,
      googleAuthorizeUrl: null,
      googleState: null,
    );
    try {
      final authorize = await _resolve(
        _remote.createGoogleAuthorizeUrl(callbackUri: webCallbackUri),
      );
      state = state.copyWith(
        isStartingGoogle: false,
        googleAuthorizeUrl: authorize.authorizeUrl,
        googleState: authorize.state,
      );
      return authorize.authorizeUrl;
    } catch (e) {
      final errorMessage = _mapError(
        e,
        'OAuthLoginController.startGoogleLogin',
      );
      state = state.copyWith(
        isStartingGoogle: false,
        errorMessage: errorMessage,
      );
      return null;
    }
  }

  /// Completes a Google login with a manually-pasted callback.
  Future<AuthSession?> completeGoogleLogin({
    required String code,
    required String state,
  }) async {
    this.state = this.state.copyWith(
      isCompletingGoogle: true,
      errorMessage: null,
    );
    try {
      final s = await _resolve(
        _remote.loginWithGoogle(code: code, state: state),
      );
      await ref.read(authSessionProvider.notifier).applySession(s);
      this.state = this.state.copyWith(isCompletingGoogle: false);
      return s;
    } catch (e) {
      final errorMessage = _mapError(
        e,
        'OAuthLoginController.completeGoogleLogin',
      );
      this.state = this.state.copyWith(
        isCompletingGoogle: false,
        errorMessage: errorMessage,
      );
      return null;
    }
  }
}
