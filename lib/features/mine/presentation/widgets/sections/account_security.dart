import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/copy.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/shared.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MineAccountSecuritySection extends ConsumerWidget {
  const MineAccountSecuritySection({super.key, required this.account});

  final MineAccount account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final session = ref.watch(authSessionProvider);
    final signedIn = session.canAccessProtectedData;
    final accountSubtitle = account.isAuthenticated
        ? (account.email.isNotEmpty
              ? account.email
              : mineCopy(l10n, account.statusKey))
        : l10n.mineAccountSignedOutMeta;

    return Column(
      key: const Key('mine-account-security-section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MineSectionTitle(title: l10n.settingsAccountSecuritySectionTitle),
        const SizedBox(height: Spacing.level3),
        FTileGroup(
          divider: FItemDivider.full,
          children: [
            FTile(
              key: const Key('mine-account-settings-tile'),
              prefix: Icon(
                SemanticIcons.profileUser,
                color: SemanticColor.primary.solid(context),
                size: Spacing.level5,
              ),
              title: Text(l10n.mineSettingsAccountTitle),
              subtitle: Text(
                accountSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              suffix: const Icon(SemanticIcons.actionNext),
              onPress: () => pushAuthRequiredRoute(context, Routes.account),
            ),
            if (Platform.isIOS || Platform.isAndroid)
              FTile(
                key: const Key('mine-health-sync-tile'),
                prefix: Icon(
                  SemanticIcons.recordActivity,
                  color: SemanticColor.primary.solid(context),
                  size: Spacing.level5,
                ),
                title: Text(l10n.mineHealthSyncTitle),
                subtitle: Text(
                  l10n.mineHealthSyncSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                suffix: const Icon(SemanticIcons.actionNext),
                onPress: () =>
                    pushAuthRequiredRoute(context, Routes.healthSync),
              ),
            FTile(
              key: const Key('mine-sign-out-tile'),
              prefix: Icon(
                SemanticIcons.actionClose,
                color: signedIn
                    ? colors.error
                    : SemanticColor.primary.solid(context),
                size: Spacing.level5,
              ),
              title: Text(
                signedIn ? l10n.authSignOut : l10n.authGoLogin,
                style: context.theme.typography.body.md.copyWith(
                  color: signedIn
                      ? colors.error
                      : SemanticColor.primary.solid(context),
                ),
              ),
              enabled: !session.isLoading,
              onPress: session.isLoading
                  ? null
                  : () async {
                      if (!signedIn) {
                        context.go(loginRouteForCurrentLocation(context));
                        return;
                      }
                      final confirmed = await showDangerConfirmationDialog(
                        context: context,
                        title: l10n.authSignOutConfirmTitle,
                        message: l10n.authSignOutConfirmMessage,
                        confirmLabel: l10n.authSignOutConfirmAction,
                      );
                      if (!confirmed || !context.mounted) return;
                      await ref.read(authSessionProvider.notifier).logout();
                      if (!context.mounted) return;
                      context.go(Routes.login);
                    },
            ),
          ],
        ),
      ],
    );
  }
}
