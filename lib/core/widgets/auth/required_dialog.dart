import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/auth_session_adapter.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/router/routes.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// A lightweight widget that shows the auth-required dialog in a post-frame
/// callback. Used by pages that need to gate access behind authentication.
class AuthRequiredDialogGate extends StatefulWidget {
  const AuthRequiredDialogGate({super.key, required this.onLogin});

  final VoidCallback onLogin;

  @override
  State<AuthRequiredDialogGate> createState() => _AuthRequiredDialogGateState();
}

class _AuthRequiredDialogGateState extends State<AuthRequiredDialogGate> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showDialog());
  }

  Future<void> _showDialog() async {
    if (!mounted || _shown) {
      return;
    }
    _shown = true;

    await showAuthRequiredDialog(context, onLogin: widget.onLogin);
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// Shows a dialog prompting the user to sign in.
///
/// This is a cross-cutting UI concern — it does not depend on any auth
/// feature routes. The [onLogin] callback is provided by the caller, which
/// can build the appropriate login route.
Future<void> showAuthRequiredDialog(
  BuildContext context, {
  required VoidCallback onLogin,
}) async {
  final l10n = AppLocalizations.of(context)!;
  await showAppDialog<void>(
    context: context,
    // 按 Apple HIG 的 alert 规格：宽度固定 270pt，居中，不随屏幕变大。
    // 之前用 showAppDialog 的自适应宽度（360/420 起，桌面可到 640），在
    // 浏览器窗口里弹窗被拉成一条横亘整屏的长条，按钮挤在左边，完全不像 alert。
    maxWidth: _higAlertWidth,
    minWidth: _higAlertWidth,
    // HIG 的 alert 内容本身左右各留 16pt。
    padding: const EdgeInsets.fromLTRB(
      Spacing.xl,
      Spacing.xl2,
      Spacing.xl,
      Spacing.xl,
    ),
    builder: (dialogContext) => Column(
      key: const Key('auth-required-dialog'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // HIG：标题与正文居中、等宽，标题加粗。
        Text(
          l10n.authNotSignedIn,
          textAlign: TextAlign.center,
          style: dialogContext.theme.dialogStyle.titleTextStyle.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          l10n.authLoginRequiredPrompt,
          textAlign: TextAlign.center,
          style: dialogContext.theme.dialogStyle.bodyTextStyle,
        ),
        const SizedBox(height: Spacing.xl),
        // HIG：两个按钮并排、等宽，取消在左。
        Row(
          children: [
            Expanded(
              child: DialogActionButton(
                key: const Key('auth-required-cancel-action'),
                label: l10n.authCancelAction,
                variant: FButtonVariant.ghost,
                onPress: () => Navigator.of(dialogContext).pop(),
              ),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: DialogActionButton(
                key: const Key('auth-required-login-action'),
                label: l10n.authGoLogin,
                onPress: () {
                  Navigator.of(dialogContext).pop();
                  onLogin();
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

/// Apple HIG 的 alert 固定宽度（270pt）。
const double _higAlertWidth = 270;

/// Checks the auth session and either pushes [route] directly (if
/// authenticated) or shows the auth-required dialog (if not).
///
/// This is a cross-cutting concern, so it lives in core rather than in the
/// auth feature. The login route is built via [loginRouteLocation], which
/// mirrors the auth feature's typed `LoginRoute` — keep the two in sync
/// (drift is guarded by test/core/router/routes_test.dart).
Future<void> pushAuthRequiredRoute(BuildContext context, String route) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final session = container.read(authSessionProvider);
  if (session.canAccessProtectedData) {
    unawaited(context.push(route));
    return;
  }

  if (session.isLoading) {
    return;
  }

  // When not signed in, show login dialog and return to current location
  // after login. The user can then retry navigating to the target route.
  await requestSignIn(context);
}

/// The single sign-in gate for the whole app: shows the auth-required dialog
/// and navigates to the login screen only when the user accepts it.
///
/// Every "you need an account for this" path must go through this function —
/// jumping straight to `/login` on a tap is the one behaviour it replaces:
/// a silent redirect leaves the user wondering why the screen changed, while
/// the dialog names the requirement and offers a way out.
Future<void> requestSignIn(
  BuildContext context, {
  String? returnTo,
}) async {
  if (returnTo == null) {
    return _showSignInDialog(context);
  }

  // A caller that knows the destination the user was heading for (a deep link,
  // a feature entry point) returns there instead of wherever the dialog
  // happens to be opened from.
  await showAuthRequiredDialog(
    context,
    onLogin: () => _pushLogin(context, loginRouteForReturnTo(returnTo)),
  );
}

Future<void> _showSignInDialog(BuildContext context) async {
  await showAuthRequiredDialog(
    context,
    // The login action fires on a later user tap; guard the push in case the
    // calling surface was closed in between (a deactivated context pushed
    // through trips the `_dependents.isEmpty` assertion).
    onLogin: () => _pushLogin(context, _currentLocationLoginRoute(context)),
  );
}

/// Pushes [location], skipping the push when the context is gone or the login
/// route is already on top (a second dialog confirmation must not stack two
/// copies of the sign-in screen).
///
/// Reads the current location from the [GoRouter] handle rather than
/// `GoRouterState.of(context)`: the dialog's context is a navigation-dialog
/// subtree and reading route state through it registers an InheritedWidget
/// dependency on a widget that is being torn down.
void _pushLogin(BuildContext context, String location) {
  if (!context.mounted) return;
  final router = GoRouter.maybeOf(context);
  if (router?.state.matchedLocation == location) return;
  unawaited(context.push(location));
}

String _currentLocationLoginRoute(BuildContext context) {
  final location = GoRouterState.of(context).uri.toString();
  if (location.isEmpty || !location.startsWith('/')) {
    return loginRouteForReturnTo(CoreRoutes.home);
  }
  return loginRouteForReturnTo(location);
}

/// Builds the login route location carrying [returnTo] as a `return-to`
/// query hint.
String loginRouteForReturnTo(String returnTo) {
  return loginRouteLocation(returnTo);
}

/// Builds the login route location that returns to the current location after
/// login, falling back to the home shell for empty/relative locations.
///
/// Only for surfaces that navigate to sign-in directly by design — the sign-out
/// button pressed while signed out, and the preview-state account actions.
/// **Do not use this for an auth gate**: a gate must confirm with
/// [requestSignIn] so the user knows why the screen changes.
String loginRouteForCurrentLocation(BuildContext context) {
  return _currentLocationLoginRoute(context);
}
