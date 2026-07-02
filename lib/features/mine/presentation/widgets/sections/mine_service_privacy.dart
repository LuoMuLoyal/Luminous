import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/mine/domain/entities/mine_dashboard.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/mine_copy.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/mine_shared.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MinePrivacyNoticeSection extends StatelessWidget {
  const MinePrivacyNoticeSection({super.key, required this.notice});

  final MinePrivacyNotice notice;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => pushAuthRequiredRoute(context, '/account'),
        borderRadius: BorderRadius.circular(AppRadiusTokens.level4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              mineGreen.withValues(alpha: 0.05),
              colors.background,
            ),
            borderRadius: BorderRadius.circular(AppRadiusTokens.level4),
            border: Border.all(color: mineGreen.withValues(alpha: 0.14)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.level4),
            child: Row(
              children: [
                Icon(notice.icon, color: mineGreen, size: AppSpacingTokens.level5),
                const SizedBox(width: AppSpacingTokens.level3),
                Expanded(
                  child: Text(
                    mineCopy(l10n, notice.titleKey),
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.level3),
                Text(
                  mineCopy(l10n, notice.actionKey),
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(
                  FLucideIcons.chevronRight,
                  color: colors.mutedForeground,
                  size: AppSpacingTokens.level5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
