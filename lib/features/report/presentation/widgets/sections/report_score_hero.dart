import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/design/app_responsive_sizing.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/shared/report_section_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReportScoreHero extends StatelessWidget {
  const ReportScoreHero({
    super.key,
    required this.dashboard,
    required this.l10n,
  });

  final ReportDashboard dashboard;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final score = dashboard.score;
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return FCard.raw(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.reportScoreTitle,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Icon(
                        FLucideIcons.circleHelp,
                        color: colors.mutedForeground,
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacingTokens.md),
                  Wrap(
                    spacing: AppSpacingTokens.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      AppSkeletonSlot(
                        skeleton: const AppInlineSkeletonBlock(
                          height: 58,
                          width: 76,
                          radius: AppRadiusTokens.md,
                        ),
                        child: Text(
                          score.value.toString(),
                          style: textTheme.displayMedium?.copyWith(
                            color: Color(0xFF15803D),
                            fontSize: AppResponsiveSizing.scaleByWidth(
                              context,
                              fraction: 0.128,
                              minValue: 40,
                              maxValue: 54,
                            ),
                            height: 1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        l10n.reportScoreOutOf(score.maxValue),
                        style: textTheme.bodyLarge?.copyWith(
                          color: colors.mutedForeground,
                        ),
                      ),
                      AppSkeletonSlot(
                        skeleton: const AppInlineSkeletonBlock(
                          height: 22,
                          width: 64,
                          radius: AppRadiusTokens.sm,
                        ),
                        child: _StatusBadge(
                          label: reportStatusLabel(l10n, score.status),
                          color: reportStatusColor(score.status),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacingTokens.lg),
                  AppSkeletonText(
                    text: score.summary,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    widthFactor: 0.88,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacingTokens.md),
            DecoratedBox(
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(
                dimension: AppResponsiveSizing.scaleByWidth(
                  context,
                  fraction: 0.26,
                  minValue: 80,
                  maxValue: 112,
                ),
                child: Icon(
                  FLucideIcons.badgeCheck,
                  color: Color(0xFF15803D),
                  size: AppResponsiveSizing.scaleByWidth(
                    context,
                    fraction: 0.16,
                    minValue: 48,
                    maxValue: 68,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.sm,
          vertical: AppSpacingTokens.xxs,
        ),
        child: Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
