import 'dart:async';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Result of an in-app WebView authorization round trip.
sealed class OAuthWebViewResult {
  const OAuthWebViewResult();
}

/// The provider redirected to [callbackUri] and it carried a usable code/state.
final class OAuthWebViewCallback extends OAuthWebViewResult {
  const OAuthWebViewCallback(this.uri);

  final Uri uri;
}

/// The user dismissed the sheet, or the page failed to load.
final class OAuthWebViewDismissed extends OAuthWebViewResult {
  const OAuthWebViewDismissed({this.loadFailed = false});

  /// `true` when the failure was a load error rather than a user dismissal.
  final bool loadFailed;
}

/// Whether an in-app WebView is available on the current platform.
///
/// `webview_flutter` only ships Android and iOS implementations; web and
/// desktop builds must keep the external-browser flow.
bool get isOAuthWebViewSupported {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}

/// Whether [uri] is the OAuth callback target for [callback].
///
/// Compares scheme/host/path only: the provider appends `code`/`state` as query
/// parameters, and the backend clears any query the client sent at authorize
/// time.
bool isOAuthCallbackNavigation(Uri uri, Uri callback) {
  return uri.scheme == callback.scheme &&
      uri.host.toLowerCase() == callback.host.toLowerCase() &&
      uri.path == callback.path;
}

/// Opens [authorizeUrl] in an in-app WebView and resolves when the navigation
/// reaches [callbackUri].
///
/// Only loads and intercepts: the callback URI is never actually fetched, so no
/// local HTTP server is needed (unlike the desktop loopback flow). The backend
/// still validates the callback URI at authorize time.
Future<OAuthWebViewResult> openOAuthWebView({
  required BuildContext context,
  required String authorizeUrl,
  required Uri callbackUri,
  required String title,
}) async {
  final l10n = AppLocalizations.of(context)!;

  final controller = WebViewController();
  unawaited(controller.setJavaScriptMode(JavaScriptMode.unrestricted));

  final result = await showAppDialog<OAuthWebViewResult>(
    context: context,
    maxWidth: 520,
    maxHeight: MediaQuery.sizeOf(context).height * 0.8,
    padding: const EdgeInsets.all(Spacing.lg),
    barrierDismissible: true,
    // The body hosts a bounded WebView; letting DialogShell wrap it in a
    // SingleChildScrollView would hand the Column unbounded height and the
    // Flexible child would fail layout.
    scrollable: false,
    builder: (dialogContext) => _OAuthWebViewBody(
      controller: controller,
      authorizeUrl: authorizeUrl,
      callbackUri: callbackUri,
      title: title,
      loadFailedLabel: l10n.authOAuthWebViewLoadFailed,
      closeLabel: l10n.commonCancel,
    ),
  );

  return result ?? const OAuthWebViewDismissed();
}

class _OAuthWebViewBody extends StatefulWidget {
  const _OAuthWebViewBody({
    required this.controller,
    required this.authorizeUrl,
    required this.callbackUri,
    required this.title,
    required this.loadFailedLabel,
    required this.closeLabel,
  });

  final WebViewController controller;
  final String authorizeUrl;
  final Uri callbackUri;
  final String title;
  final String loadFailedLabel;
  final String closeLabel;

  @override
  State<_OAuthWebViewBody> createState() => _OAuthWebViewBodyState();
}

class _OAuthWebViewBodyState extends State<_OAuthWebViewBody> {
  var _loadFailed = false;

  @override
  void initState() {
    super.initState();

    final controller = widget.controller;
    unawaited(
      controller.setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.navigate;

            // Intercept before the request is issued: the callback URI carries
            // the code/state and has no client-side handler.
            if (isOAuthCallbackNavigation(uri, widget.callbackUri)) {
              Navigator.of(context).pop(OAuthWebViewCallback(uri));
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            // Sub-resource failures must not tear down the sheet; only a
            // main-frame failure means the authorization page is unusable.
            if (error.isForMainFrame != true) return;
            if (!mounted) return;
            setState(() => _loadFailed = true);
          },
        ),
      ),
    );
    unawaited(controller.loadRequest(Uri.parse(widget.authorizeUrl)));
  }

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;

    if (_loadFailed) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: typography.body.lg),
          const SizedBox(height: Spacing.md),
          Text(widget.loadFailedLabel, style: typography.body.sm),
          const SizedBox(height: Spacing.lg),
          DialogActionRow(
            actions: [
              DialogActionButton(
                label: widget.closeLabel,
                variant: FButtonVariant.ghost,
                onPress: () => Navigator.of(
                  context,
                ).pop(const OAuthWebViewDismissed(loadFailed: true)),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: typography.body.lg),
        const SizedBox(height: Spacing.md),
        Flexible(
          child: SizedBox(
            height: 420,
            child: WebViewWidget(controller: widget.controller),
          ),
        ),
        const SizedBox(height: Spacing.lg),
        DialogActionRow(
          actions: [
            DialogActionButton(
              label: widget.closeLabel,
              variant: FButtonVariant.ghost,
              onPress: () =>
                  Navigator.of(context).pop(const OAuthWebViewDismissed()),
            ),
          ],
        ),
      ],
    );
  }
}
