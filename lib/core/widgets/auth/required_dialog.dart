import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
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
