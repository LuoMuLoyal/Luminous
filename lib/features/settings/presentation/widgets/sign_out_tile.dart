import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Sign-out / login tile shown at the bottom of the settings page.
class SignOutTile extends StatelessWidget {
  const SignOutTile({
    super.key,
    required this.signedIn,
    required this.isLoading,
    required this.onTap,
  });

  final bool signedIn;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    return FTileGroup(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        FTile(
          key: const Key('settings-footer-action'),
          title: Center(
            child: Text(
              signedIn ? l10n.authSignOut : l10n.authGoLogin,
              style: TypographyToken.level5
                  .body(context)
                  .copyWith(
                    color: signedIn
                        ? colors.error
                        : context.theme.colors.primary,
                  ),
            ),
          ),
          enabled: !isLoading,
          onPress: isLoading ? null : onTap,
        ),
      ],
    );
  }
}
