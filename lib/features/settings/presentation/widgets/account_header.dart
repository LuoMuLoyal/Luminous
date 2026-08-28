import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Account header card shown at the top of the settings page.
class AccountHeader extends StatelessWidget {
  const AccountHeader({
    super.key,
    required this.session,
    required this.signedIn,
    required this.onTap,
  });

  final AuthSessionState session;
  final bool signedIn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final displayName =
        session.user?.nickname ??
        (signedIn ? l10n.mineAccountSignedIn : l10n.mineAccountSignedOut);
    final subtitle =
        session.user?.email ?? (signedIn ? '' : l10n.mineAccountSignedOutMeta);

    return FCard(
      child: FTile(
        title: Text(displayName),
        subtitle: subtitle.isEmpty ? null : Text(subtitle),
        prefix: FAvatar.raw(
          size: IconSizeTokens.level8,
          child: const Icon(
            SemanticIcons.profileUser,
            size: IconSizeTokens.level6,
          ),
        ),
        suffix: const Icon(SemanticIcons.actionNext),
        onPress: onTap,
      ),
    );
  }
}
