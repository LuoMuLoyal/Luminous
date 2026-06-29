import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_responsive_sizing.dart';
import 'package:luminous/core/widgets/app_section_surface.dart';
import 'package:luminous/core/widgets/app_text_action.dart';
import 'package:luminous/core/widgets/app_status_pill.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/shared/report_section_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReportScoreHero extends StatelessWidget {
  const ReportScoreHero({
    super.key,
    required this.dashboard,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final ReportDashboard dashboard;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final score = dashboard.score;

    return AppSectionSurface(
      padding: const EdgeInsets.all(AppSpacingTokens.lg),
      borderColor: AppColorTokens.health.withValues(alpha: 0.22),
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
                        style: typography.displaySm.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.info_outline_rounded,
                      color: surface.mute,
                      size: AppSpacingTokens.lg,
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
                        style: typography.displayXl.copyWith(
                          color: AppColorTokens.health,
                          fontSize: AppResponsiveSizing.scaleByWidth(
                            context,
                            fraction: 0.128,
                            minValue: 40,
                            maxValue: 54,
                          ),
                          height: 1,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    Text(
                      l10n.reportScoreOutOf(score.maxValue),
                      style: typography.bodyLg.copyWith(
                        color: surface.body,
                        letterSpacing: 0,
                      ),
                    ),
                    AppSkeletonSlot(
                      skeleton: const AppInlineSkeletonBlock(
                        height: 22,
                        width: 64,
                        radius: AppRadiusTokens.sm,
                      ),
                      child: AppStatusPill(
                        label: reportStatusLabel(l10n, score.status),
                        color: reportStatusColor(score.status),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacingTokens.lg),
                AppSkeletonSlot(
                  skeleton: const AppInlineSkeletonBlock(
                    height: 20,
                    widthFactor: 0.86,
                    radius: AppRadiusTokens.sm,
                  ),
                  child: AppTextAction(
                    label: score.summary,
                    flexible: true,
                    onTap: null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacingTokens.md),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColorTokens.healthSoft,
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
                Icons.fact_check_rounded,
                color: AppColorTokens.health,
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
    );
  }
}
