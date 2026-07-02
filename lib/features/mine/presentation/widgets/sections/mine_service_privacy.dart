import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/mine/domain/entities/mine_dashboard.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/mine_copy.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/mine_shared.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MinePrivacyNoticeSection extends StatelessWidget {
  const MinePrivacyNoticeSection({
    super.key,
    required this.notice,
    required this.l10n,
    required this.typography,
    required this.surface,
  });
  final MinePrivacyNotice notice;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => pushAuthRequiredRoute(context, '/account'),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              mineGreen.withValues(alpha: 0.05),
              surface.canvas,
            ),
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
            border: Border.all(color: mineGreen.withValues(alpha: 0.14)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.md),
            child: Row(
              children: [
                Icon(notice.icon, color: mineGreen, size: AppSpacingTokens.lg),
                const SizedBox(width: AppSpacingTokens.sm),
                Expanded(
                  child: Text(
                    mineCopy(l10n, notice.titleKey),
                    style: typography.bodySm.copyWith(
                      color: surface.body,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.sm),
                Text(
                  mineCopy(l10n, notice.actionKey),
                  style: typography.bodySmStrong.copyWith(
                    color: surface.body,
                    letterSpacing: 0,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: surface.body,
                  size: AppSpacingTokens.lg,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
