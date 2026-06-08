import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
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
    return const SizedBox.shrink(key: Key('auth-required-dialog-gate'));
  }
}

Future<void> pushAuthRequiredRoute(BuildContext context, String route) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final session = container.read(authSessionProvider);
  if (session.canAccessProtectedData) {
    context.push(route);
    return;
  }

  if (session.isLoading) {
    return;
  }

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
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        key: const Key('auth-required-dialog'),
        title: Text(l10n.authNotSignedIn),
        content: Text(l10n.authLoginRequiredPrompt),
        actions: [
          TextButton(
            key: const Key('auth-required-cancel-action'),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.authCancelAction),
          ),
          FilledButton(
            key: const Key('auth-required-login-action'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onLogin();
            },
            child: Text(l10n.authGoLogin),
          ),
        ],
      );
    },
  );
}

String loginRouteForReturnTo(String returnTo) {
  return Uri(
    path: '/login',
    queryParameters: {'returnTo': returnTo},
  ).toString();
}

String loginRouteForCurrentLocation(BuildContext context) {
  final location = GoRouterState.of(context).uri.toString();
  if (location.isEmpty || !location.startsWith('/')) {
    return loginRouteForReturnTo('/');
  }
  return loginRouteForReturnTo(location);
}
