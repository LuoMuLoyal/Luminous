import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/copy.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/shared.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MineAccountPrivacySection extends StatelessWidget {
  const MineAccountPrivacySection({
    super.key,
    required this.account,
    required this.notice,
  });

  final MineAccount account;
  final MinePrivacyNotice notice;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final accountSubtitle = account.isAuthenticated
        ? (account.email.isNotEmpty
              ? account.email
              : mineCopy(l10n, account.statusKey))
        : l10n.mineAccountSignedOutMeta;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MineSectionTitle(title: l10n.mineAccountPrivacySectionTitle),
        const SizedBox(height: AppSpacingTokens.level3),
        FTileGroup(
          key: const Key('mine-account-privacy-section'),
          divider: FItemDivider.full,
          children: [
            FTile(
              prefix: Icon(
                FLucideIcons.userCheck,
                color: colors.primary,
                size: AppSpacingTokens.level5,
              ),
              title: Text(mineCopy(l10n, MineCopyKey.alertPrivacyTitle)),
              subtitle: Text(mineCopy(l10n, MineCopyKey.alertPrivacySubtitle)),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => pushAuthRequiredRoute(context, AppRoutes.account),
            ),
            FTile(
              prefix: Icon(
                notice.icon,
                color: colors.primary,
                size: AppSpacingTokens.level5,
              ),
              title: Text(mineCopy(l10n, notice.actionKey)),
              subtitle: Text(
                mineCopy(l10n, notice.titleKey),
                style: AppTypographyToken.level3
                    .body(context)
                    .copyWith(color: colors.mutedForeground),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => pushAuthRequiredRoute(context, AppRoutes.account),
            ),
            FTile(
              prefix: Icon(
                FLucideIcons.shieldCheck,
                color: colors.primary,
                size: AppSpacingTokens.level5,
              ),
              title: Text(l10n.mineSettingsAccountTitle),
              subtitle: Text(
                accountSubtitle,
                style: AppTypographyToken.level3
                    .body(context)
                    .copyWith(color: colors.mutedForeground),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () => pushAuthRequiredRoute(context, AppRoutes.settings),
            ),
          ],
        ),
      ],
    );
  }
}
