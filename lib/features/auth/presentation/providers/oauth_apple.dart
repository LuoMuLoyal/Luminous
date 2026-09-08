part of 'oauth_login.dart';

mixin OAuthAppleMixin on OAuthLoginControllerBase {
  /// Completes an Apple Sign In flow.
  Future<AuthSession?> loginWithApple({
    required String identityToken,
    String? authorizationCode,
    String? givenName,
    String? familyName,
  }) async {
    state = state.copyWith(isStartingApple: true, errorMessage: null);
    try {
      final s = await _resolve(
        _remote.loginWithApple(
          identityToken: identityToken,
          authorizationCode: authorizationCode,
          givenName: givenName,
          familyName: familyName,
        ),
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
}
