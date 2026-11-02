import 'package:flutter/foundation.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/router/deep_link.dart';
import 'package:luminous/features/auth/presentation/pages/oauth/oauth_navigation.dart';

/// Builds the OAuth callback URI for the native in-app WebView flow.
///
/// The backend validates `callbackUri` as either a loopback `http` address or an
/// `https` URL whose origin is in `CORS_ORIGIN` and whose path matches the
/// provider's callback path (`AuthOAuthStateService.normalizeCallbackUri`).
/// Reusing the site origin that the web client already uses satisfies both
/// checks without new backend surface.
///
/// Returns `null` when no host is configured (`LUMINOUS_DEEP_LINK_HOST` unset),
/// in which case callers fall back to the external-browser + manual-paste flow.
String? nativeOAuthCallbackUri(String path, {String? returnTo}) {
  final host = deepLinkHostValue;
  if (host.isEmpty) return null;
  final rt = safeReturnTo(returnTo);
  return Uri(
    scheme: 'https',
    host: host,
    path: path,
    queryParameters: rt == null ? null : {'returnTo': rt},
  ).toString();
}

/// Builds the WeChat OAuth callback URI for web platforms.
///
/// Returns `null` on non-web platforms.
String? webWechatCallbackUri({String? returnTo}) {
  if (!kIsWeb) return null;
  final base = Uri.base;
  final rt = safeReturnTo(returnTo);
  return Uri(
    scheme: base.scheme,
    host: base.host,
    port: base.hasPort ? base.port : null,
    path: Routes.loginOauthWechat,
    queryParameters: rt == null ? null : {'returnTo': rt},
  ).toString();
}

/// Builds the QQ OAuth callback URI for web platforms.
///
/// Returns `null` on non-web platforms.
String? webQqCallbackUri({String? returnTo}) {
  if (!kIsWeb) return null;
  final base = Uri.base;
  final rt = safeReturnTo(returnTo);
  return Uri(
    scheme: base.scheme,
    host: base.host,
    port: base.hasPort ? base.port : null,
    path: Routes.loginOauthQq,
    queryParameters: rt == null ? null : {'returnTo': rt},
  ).toString();
}

/// Builds the Google OAuth callback URI for web platforms.
///
/// Returns `null` on non-web platforms.
String? webGoogleCallbackUri({String? returnTo}) {
  if (!kIsWeb) return null;
  final base = Uri.base;
  final rt = safeReturnTo(returnTo);
  return Uri(
    scheme: base.scheme,
    host: base.host,
    port: base.hasPort ? base.port : null,
    path: Routes.loginOauthGoogle,
    queryParameters: rt == null ? null : {'returnTo': rt},
  ).toString();
}
