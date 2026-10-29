import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/features/auth/presentation/pages/oauth/oauth_navigation.dart';
import 'package:luminous/features/auth/presentation/pages/oauth/oauth_uris.dart';
import 'package:luminous/features/auth/presentation/providers/oauth_login.dart';
import 'package:luminous/features/auth/presentation/services/oauth_webview.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/oauth_callback_parser.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/oauth_deep_link.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

// =========================
//  WeChat
// =========================

Future<void> startWechatLogin(
  BuildContext context,
  WidgetRef ref,
  OAuthLoginController oauthController,
  AppLocalizations l10n, {
  String? returnTo,
}) async {
  final attempt = await oauthController.startWechatLogin(
    webCallbackUri: webWechatCallbackUri(returnTo: returnTo),
  );
  if (!context.mounted) return;

  switch (attempt) {
    case WechatLoginCompleted():
      goAfterLogin(context, returnTo: returnTo, fallbackHome: true);
    case WechatLoginWebFallback(:final authorizeUrl):
      final opened = await ref
          .read(externalUrlLauncherProvider)
          .open(Uri.parse(authorizeUrl));
      if (!context.mounted) return;
      if (!opened) {
        await Toast.show(context, l10n.authWechatBrowserOpenFailed);
        return;
      }
      await Toast.show(context, l10n.authWechatAuthorizeOpened);
    case WechatLoginFailed():
      // Error is in oauthState.error — toast is shown via state
      break;
  }
}

Future<void> completeWechatLoginFromInput(
  BuildContext context,
  OAuthLoginController oauthController,
  AppLocalizations l10n, {
  required TextEditingController callbackController,
  required String? fallbackState,
  String? returnTo,
}) async {
  final callback = OAuthCallbackParser.parse(
    callbackController.text,
    fallbackState,
  );
  if (callback == null) {
    final message = callbackController.text.trim().isEmpty
        ? l10n.authWechatCallbackRequiredToast
        : l10n.authWechatCallbackInvalidToast;
    await Toast.show(context, message);
    return;
  }
  final session = await oauthController.completeWechatLogin(
    code: callback.code,
    state: callback.state,
  );
  if (session == null || !context.mounted) return;
  goAfterLogin(context, returnTo: returnTo, fallbackHome: true);
}

// =========================
//  QQ
// =========================

Future<void> startQqLogin(
  BuildContext context,
  WidgetRef ref,
  OAuthLoginController oauthController,
  AppLocalizations l10n, {
  String? returnTo,
}) async {
  final callbackUri = nativeOAuthCallbackUri(
    Routes.loginOauthQq,
    returnTo: returnTo,
  );

  // Native path: authorize inside the app so the user never has to copy a URL.
  // Falls back to the external browser when no deep-link host is configured or
  // the platform has no WebView implementation.
  if (callbackUri != null && isOAuthWebViewSupported) {
    final authorizeUrl = await oauthController.startQqLogin(
      webCallbackUri: callbackUri,
    );
    if (authorizeUrl == null || !context.mounted) return;

    final result = await openOAuthWebView(
      context: context,
      authorizeUrl: authorizeUrl,
      callbackUri: Uri.parse(callbackUri),
      title: l10n.authOAuthWebViewTitle,
    );
    if (!context.mounted) return;

    switch (result) {
      case OAuthWebViewCallback(:final uri):
        final link = parseOAuthDeepLink(uri);
        if (link == null) return;
        final session = await oauthController.completeQqLogin(
          code: link.code,
          state: link.state,
        );
        if (session == null || !context.mounted) return;
        goAfterLogin(
          context,
          returnTo: link.returnTo ?? returnTo,
          fallbackHome: true,
        );
      case OAuthWebViewDismissed(:final loadFailed):
        await Toast.show(
          context,
          loadFailed
              ? l10n.authOAuthWebViewLoadFailed
              : l10n.authOAuthWebViewCancelled,
        );
    }
    return;
  }

  final authorizeUrl = await oauthController.startQqLogin(
    webCallbackUri: webQqCallbackUri(returnTo: returnTo),
  );
  if (authorizeUrl == null || !context.mounted) return;

  final opened = await ref
      .read(externalUrlLauncherProvider)
      .open(Uri.parse(authorizeUrl));
  if (!context.mounted) return;
  if (!opened) {
    await Toast.show(context, l10n.authQqBrowserOpenFailed);
    return;
  }
  await Toast.show(context, l10n.authQqAuthorizeOpened);
}

Future<void> completeQqLoginFromInput(
  BuildContext context,
  OAuthLoginController oauthController,
  AppLocalizations l10n, {
  required TextEditingController callbackController,
  required String? fallbackState,
  String? returnTo,
}) async {
  final callback = OAuthCallbackParser.parse(
    callbackController.text,
    fallbackState,
  );
  if (callback == null) {
    final message = callbackController.text.trim().isEmpty
        ? l10n.authQqCallbackRequiredToast
        : l10n.authQqCallbackInvalidToast;
    await Toast.show(context, message);
    return;
  }
  final session = await oauthController.completeQqLogin(
    code: callback.code,
    state: callback.state,
  );
  if (session == null || !context.mounted) return;
  goAfterLogin(context, returnTo: returnTo, fallbackHome: true);
}

// =========================
//  Google
// =========================

Future<void> startGoogleLogin(
  BuildContext context,
  WidgetRef ref,
  OAuthLoginController oauthController,
  AppLocalizations l10n, {
  String? returnTo,
}) async {
  final callbackUri = nativeOAuthCallbackUri(
    Routes.loginOauthGoogle,
    returnTo: returnTo,
  );

  if (callbackUri != null && isOAuthWebViewSupported) {
    final authorizeUrl = await oauthController.startGoogleLogin(
      webCallbackUri: callbackUri,
    );
    if (authorizeUrl == null || !context.mounted) return;

    final result = await openOAuthWebView(
      context: context,
      authorizeUrl: authorizeUrl,
      callbackUri: Uri.parse(callbackUri),
      title: l10n.authOAuthWebViewTitle,
    );
    if (!context.mounted) return;

    switch (result) {
      case OAuthWebViewCallback(:final uri):
        final link = parseOAuthDeepLink(uri);
        if (link == null) return;
        final session = await oauthController.completeGoogleLogin(
          code: link.code,
          state: link.state,
        );
        if (session == null || !context.mounted) return;
        goAfterLogin(
          context,
          returnTo: link.returnTo ?? returnTo,
          fallbackHome: true,
        );
      case OAuthWebViewDismissed(:final loadFailed):
        await Toast.show(
          context,
          loadFailed
              ? l10n.authOAuthWebViewLoadFailed
              : l10n.authOAuthWebViewCancelled,
        );
    }
    return;
  }

  final authorizeUrl = await oauthController.startGoogleLogin(
    webCallbackUri: webGoogleCallbackUri(returnTo: returnTo),
  );
  if (authorizeUrl == null || !context.mounted) return;

  final opened = await ref
      .read(externalUrlLauncherProvider)
      .open(Uri.parse(authorizeUrl));
  if (!context.mounted) return;
  if (!opened) {
    await Toast.show(context, l10n.authGoogleBrowserOpenFailed);
    return;
  }
  await Toast.show(context, l10n.authGoogleAuthorizeOpened);
}

Future<void> completeGoogleLoginFromInput(
  BuildContext context,
  OAuthLoginController oauthController,
  AppLocalizations l10n, {
  required TextEditingController callbackController,
  required String? fallbackState,
  String? returnTo,
}) async {
  final callback = OAuthCallbackParser.parse(
    callbackController.text,
    fallbackState,
  );
  if (callback == null) {
    final message = callbackController.text.trim().isEmpty
        ? l10n.authGoogleCallbackRequiredToast
        : l10n.authGoogleCallbackInvalidToast;
    await Toast.show(context, message);
    return;
  }
  final session = await oauthController.completeGoogleLogin(
    code: callback.code,
    state: callback.state,
  );
  if (session == null || !context.mounted) return;
  goAfterLogin(context, returnTo: returnTo, fallbackHome: true);
}

// =========================
//  Apple
// =========================

Future<void> startAppleLogin(
  BuildContext context,
  WidgetRef ref,
  OAuthLoginController oauthController,
  AppLocalizations l10n, {
  String? returnTo,
}) async {
  if (!context.mounted) return;
  final failMessage = l10n.authAppleSignInFailed;
  try {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    if (!context.mounted) return;
    final session = await oauthController.loginWithApple(
      identityToken: credential.identityToken ?? '',
      authorizationCode: credential.authorizationCode,
      givenName: credential.givenName,
      familyName: credential.familyName,
    );
    if (session == null || !context.mounted) return;
    goAfterLogin(context, returnTo: returnTo, fallbackHome: true);
  } catch (e, st) {
    ref.read(talkerProvider).warning('startAppleLogin: failed: $e', st);
    if (context.mounted) await Toast.show(context, failMessage);
  }
}
