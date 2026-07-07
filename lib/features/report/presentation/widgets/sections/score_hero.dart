import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/colors.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/design/responsive_sizing.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/shared/section_models.dart';
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

    return FCard.raw(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.level5),
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
                          style: AppTypographyToken.level7
                              .display(context)
                              .copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      Icon(
                        FLucideIcons.circleHelp,
                        color: colors.mutedForeground,
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacingTokens.level4),
                  Wrap(
                    spacing: AppSpacingTokens.level3,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      AppSkeletonSlot(
                        skeleton: const AppInlineSkeletonBlock(
                          height: 58,
                          width: 76,
                          radius: AppRadiusTokens.level3,
                        ),
                        child: Text(
                          score.value.toString(),
                          style: AppTypographyToken.level9
                              .display(context)
                              .copyWith(
                                color: context.theme.colors.primary,
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
                        style: AppTypographyToken.level5
                            .body(context)
                            .copyWith(color: colors.mutedForeground),
                      ),
                      AppSkeletonSlot(
                        skeleton: const AppInlineSkeletonBlock(
                          height: 22,
                          width: 64,
                          radius: AppRadiusTokens.level2,
                        ),
                        child: _StatusBadge(
                          label: reportStatusLabel(l10n, score.status),
                          color: reportStatusColor(score.status),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacingTokens.level5),
                  AppSkeletonText(
                    text: score.summary,
                    style: AppTypographyToken.level4
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w600),
                    widthFactor: 0.88,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacingTokens.level4),
            FAvatar.raw(
              size: AppResponsiveSizing.scaleByWidth(
                context,
                fraction: 0.26,
                minValue: 80,
                maxValue: 112,
              ),
              style: .delta(backgroundColor: colors.primary),
              child: Icon(
                FLucideIcons.badgeCheck,
                color: colors.primaryForeground,
                size: AppResponsiveSizing.scaleByWidth(
                  context,
                  fraction: 0.16,
                  minValue: 48,
                  maxValue: 68,
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
  final AppColors color;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    final resolvedColor = color.resolve(colors);

    return FBadge.raw(
      style: .delta(
        decoration: .shapeDelta(
          color: resolvedColor.withValues(alpha: 0.12),
          shape: RoundedSuperellipseBorder(
            borderRadius: context.theme.style.borderRadius.pill,
          ),
        ),
      ),
      builder: (context, style) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.level3,
          vertical: AppSpacingTokens.level1,
        ),
        child: Text(
          label,
          style: AppTypographyToken.level3
              .body(context)
              .copyWith(color: resolvedColor, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
