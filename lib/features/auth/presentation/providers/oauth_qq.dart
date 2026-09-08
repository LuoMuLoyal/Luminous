part of 'oauth_login.dart';

mixin OAuthQqMixin on OAuthLoginControllerBase {
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
      final authorize = await _resolve(
        _remote.createQqAuthorizeUrl(callbackUri: webCallbackUri),
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
      final s = await _resolve(_remote.loginWithQq(code: code, state: state));
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
}
