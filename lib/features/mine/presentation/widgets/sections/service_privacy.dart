import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/copy.dart';

import 'package:luminous/l10n/app_localizations.dart';

class MinePrivacyNoticeSection extends StatelessWidget {
  const MinePrivacyNoticeSection({super.key, required this.notice});

  final MinePrivacyNotice notice;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    return FTappable(
      onPress: () => pushAuthRequiredRoute(context, '/account'),
      child: FCard.raw(
        style: .delta(
          decoration: .shapeDelta(
            color: Color.alphaBlend(
              colors.primary.withValues(alpha: 0.05),
              colors.background,
            ),
            shape: RoundedSuperellipseBorder(
              side: BorderSide(color: colors.primary.withValues(alpha: 0.14)),
              borderRadius: context.theme.style.borderRadius.lg,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacingTokens.level4),
          child: Row(
            children: [
              Icon(
                notice.icon,
                color: context.theme.colors.primary,
                size: AppSpacingTokens.level5,
              ),
              const SizedBox(width: AppSpacingTokens.level3),
              Expanded(
                child: Text(
                  mineCopy(l10n, notice.titleKey),
                  style: AppTypographyToken.level3
                      .body(context)
                      .copyWith(color: colors.mutedForeground),
                ),
              ),
              const SizedBox(width: AppSpacingTokens.level3),
              Text(
                mineCopy(l10n, notice.actionKey),
                style: AppTypographyToken.level4
                    .body(context)
                    .copyWith(
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
    );
  }
}
