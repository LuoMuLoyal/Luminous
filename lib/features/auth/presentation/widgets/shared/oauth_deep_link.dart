import 'package:luminous/core/router/routes.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/oauth_callback_parser.dart';

/// OAuth provider identified by an incoming callback deep link.
enum OAuthDeepLinkProvider { wechat, qq, google }

/// A deep link resolved to a concrete provider callback.
class OAuthDeepLink {
  const OAuthDeepLink({
    required this.provider,
    required this.code,
    required this.state,
    this.returnTo,
  });

  final OAuthDeepLinkProvider provider;
  final String code;
  final String state;

  /// Optional post-login target carried by the callback link.
  final String? returnTo;
}

/// Resolves an incoming deep-link [uri] into an [OAuthDeepLink].
///
/// Accepts the same URI shapes the manual-paste path already handles, so the
/// native deep link and the pasted-URL fallback converge on one parse result:
/// - `https://<host>/login/oauth/qq?code=..&state=..`
/// - `luminous://login/oauth/qq?code=..&state=..`
/// - `https://<host>/login/oauth/qq?returnTo=..` with a bare code (see below)
///
/// Returns `null` when the path is not an OAuth callback, or when `code` is
/// missing — a link without a code cannot complete a login and must not be
/// surfaced as a failure.
///
/// [fallbackState] supplies the state when the link carries only a bare code
/// (WeChat returns the code as the whole payload in some flows).
OAuthDeepLink? parseOAuthDeepLink(Uri uri, {String? fallbackState}) {
  final provider = _providerForPath(_callbackPath(uri));
  if (provider == null) return null;

  final callback = OAuthCallbackParser.parse(uri.toString(), fallbackState);
  if (callback == null) return null;

  final returnTo = uri.queryParameters['returnTo']?.trim();

  return OAuthDeepLink(
    provider: provider,
    code: callback.code,
    state: callback.state,
    returnTo: (returnTo?.isEmpty ?? true) ? null : returnTo,
  );
}

/// The callback path carried by [uri], tolerant of how custom schemes parse.
///
/// `app://login/oauth/qq` parses as `host == 'login'` + `path == '/oauth/qq'`,
/// while `app:///login/oauth/qq` (three slashes) parses with the full path.
/// Both spellings are accepted by re-attaching a non-empty authority.
String _callbackPath(Uri uri) {
  final path = uri.path;
  if (uri.host.isEmpty) return path;
  // A custom-scheme authority that is not the deep-link host is really the
  // first path segment; http(s) links keep their real host.
  if (uri.scheme == 'http' || uri.scheme == 'https') return path;
  return '/${uri.host}$path';
}

OAuthDeepLinkProvider? _providerForPath(String path) {
  // Normalize a trailing slash so `/login/oauth/qq/` resolves too.
  final normalized = path.endsWith('/') && path.length > 1
      ? path.substring(0, path.length - 1)
      : path;

  return switch (normalized) {
    CoreRoutes.loginOauthWechat => OAuthDeepLinkProvider.wechat,
    CoreRoutes.loginOauthQq => OAuthDeepLinkProvider.qq,
    CoreRoutes.loginOauthGoogle => OAuthDeepLinkProvider.google,
    _ => null,
  };
}
