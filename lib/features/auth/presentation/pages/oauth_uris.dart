import 'package:flutter/foundation.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/features/auth/presentation/pages/oauth_navigation.dart';

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

/// Builds the Weibo OAuth callback URI for web platforms.
///
/// Returns `null` on non-web platforms.
String? webWeiboCallbackUri({String? returnTo}) {
  if (!kIsWeb) return null;
  final base = Uri.base;
  final rt = safeReturnTo(returnTo);
  return Uri(
    scheme: base.scheme,
    host: base.host,
    port: base.hasPort ? base.port : null,
    path: Routes.loginOauthWeibo,
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
