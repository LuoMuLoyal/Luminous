import 'package:luminous/core/network/api.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/features/auth/data/providers/data_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wechat_oauth_service.g.dart';

/// A code+state pair returned from a completed OAuth callback.
typedef OAuthCodeState = ({String code, String state});

/// Platform-aware WeChat OAuth service.
///
/// Handles the 3-path WeChat auth flow:
/// 1. **Mobile SDK** — `WechatMobileAuthClient.authorize()` → returns code
/// 2. **Desktop loopback** — starts a local HTTP server, creates authorize URL,
///    opens browser, waits for callback → returns code+state
/// 3. **Web fallback** — creates authorize URL, UI opens browser, user pastes
///    callback manually
///
/// Both login (via [OAuthLoginController]) and identity linking (via
/// [AuthAccountNotifier]) use this service to avoid duplicating the platform
/// detection logic.
class WechatOAuthService {
  WechatOAuthService(this._ref);

  final Ref _ref;

  // ---- Mobile ----

  /// Tries mobile SDK auth. Returns the auth code, or `null` if the mobile
  /// SDK is not supported on this platform.
  ///
  /// Throws if `authorize()` fails (user cancelled, network error, etc.).
  Future<String?> tryMobileAuth() async {
    final client = _ref.read(wechatMobileAuthClientProvider);
    if (!client.isSupported) return null;
    return client.authorize();
  }

  // ---- Desktop ----

  /// Tries desktop loopback auth. Returns `(code, state)` on success, or
  /// `null` if desktop is not supported, the browser failed to open, or the
  /// callback state didn't match.
  ///
  /// When [forIdentityLink] is `true`, uses the identity-link authorize URL
  /// endpoint instead of the login endpoint.
  ///
  /// Throws on network errors or server failures.
  Future<OAuthCodeState?> tryDesktopAuth({bool forIdentityLink = false}) async {
    final listener = _ref.read(wechatDesktopOAuthCallbackListenerProvider);
    if (!listener.isSupported) return null;

    final remote = _ref.read(authRemoteDataSourceProvider);
    final server = await listener.start();
    try {
      final authorize = forIdentityLink
          ? await remote.createWechatWebIdentityLinkAuthorizeUrl(
              callbackUri: server.callbackUri.toString(),
            )
          : await remote.createWechatWebAuthorizeUrl(
              callbackUri: server.callbackUri.toString(),
            );

      final opened = await _ref
          .read(externalUrlLauncherProvider)
          .open(Uri.parse(authorize.authorizeUrl));
      if (!opened) return null;

      final callback = await server.callback.timeout(
        Duration(seconds: authorize.expiresIn.toInt()),
      );
      if (callback.state != authorize.state) return null;

      return (code: callback.code, state: callback.state);
    } finally {
      await server.close();
    }
  }

  // ---- Web fallback ----

  /// Creates a web authorize URL for the manual callback flow.
  ///
  /// When [forIdentityLink] is `true`, uses the identity-link endpoint.
  Future<OAuthAuthorizeDataDto> createWebAuthorizeUrl({
    String? callbackUri,
    bool forIdentityLink = false,
  }) async {
    final remote = _ref.read(authRemoteDataSourceProvider);
    return forIdentityLink
        ? remote.createWechatWebIdentityLinkAuthorizeUrl(
            callbackUri: callbackUri,
          )
        : remote.createWechatWebAuthorizeUrl(callbackUri: callbackUri);
  }
}

/// Provider for [WechatOAuthService].
@riverpod
WechatOAuthService wechatOAuthService(Ref ref) {
  return WechatOAuthService(ref);
}
