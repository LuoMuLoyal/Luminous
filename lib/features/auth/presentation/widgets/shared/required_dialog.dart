import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/auth/presentation/routes.dart';
import 'package:luminous/l10n/app_localizations.dart';

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
  await showAuthRequiredDialog(
    context,
    onLogin: () => context.push(loginRouteForCurrentLocation(context)),
  );
}

Future<void> showAuthRequiredDialog(
  BuildContext context, {
  required VoidCallback onLogin,
}) async {
  final l10n = AppLocalizations.of(context)!;
  await showAppDialog<void>(
    context: context,
    scrollable: false,
    builder: (dialogContext) => Column(
      key: const Key('auth-required-dialog'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.authNotSignedIn,
          style: dialogContext.theme.dialogStyle.titleTextStyle,
        ),
        const SizedBox(height: Spacing.level2),
        Text(
          l10n.authLoginRequiredPrompt,
          style: dialogContext.theme.dialogStyle.bodyTextStyle,
        ),
        const SizedBox(height: Spacing.level5),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FButton(
              variant: FButtonVariant.ghost,
              key: const Key('auth-required-cancel-action'),
              onPress: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.authCancelAction),
            ),
            const SizedBox(width: Spacing.level3),
            FButton(
              key: const Key('auth-required-login-action'),
              onPress: () {
                Navigator.of(dialogContext).pop();
                onLogin();
              },
              child: Text(l10n.authGoLogin),
            ),
          ],
        ),
      ],
    ),
  );
}

String loginRouteForReturnTo(String returnTo) {
  return LoginRoute(returnTo: returnTo).location;
}

String loginRouteForCurrentLocation(BuildContext context) {
  final location = GoRouterState.of(context).uri.toString();
  if (location.isEmpty || !location.startsWith('/')) {
    return loginRouteForReturnTo(Routes.home);
  }
  return loginRouteForReturnTo(location);
}
