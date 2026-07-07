import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:luminous/core/design/colors.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MealAnalysisStatusBadge extends StatelessWidget {
  const MealAnalysisStatusBadge({
    super.key,
    required this.status,
    this.coverage,
    this.large = false,
  });

  final String? status;
  final String? coverage;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    final (label, color, icon) = _statusSpec(context, l10n, status);
    final coverageLabel = _coverageLabel(l10n, coverage);
    final text = coverageLabel == null ? label : '$label · $coverageLabel';
    final resolvedColor = color.resolve(colors);
    final foreground = 0.12 > 0.5 ? colors.primaryForeground : resolvedColor;

    return FBadge.raw(
      builder: (context, style) => DecoratedBox(
        decoration: ShapeDecoration(
          color: resolvedColor.withValues(alpha: 0.12),
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(AppRadiusTokens.level2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacingTokens.level2,
            vertical: AppSpacingTokens.level1,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: foreground, size: AppSpacingTokens.level3),
              const SizedBox(width: AppSpacingTokens.level1),
              Text(
                text,
                style: large
                    ? AppTypographyToken.level4
                          .body(context)
                          .copyWith(
                            color: foreground,
                            fontWeight: FontWeight.w600,
                          )
                    : AppTypographyToken.level3
                          .body(context)
                          .copyWith(
                            color: foreground,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                          ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  (String, AppColors, IconData) _statusSpec(
    BuildContext context,
    AppLocalizations l10n,
    String? currentStatus,
  ) {
    return switch (currentStatus) {
      'analyzing' => (
        l10n.recordMealAnalysisStatusAnalyzing,
        AppColors.primary,
        FLucideIcons.clock3,
      ),
      'confirmed' => (
        l10n.recordMealAnalysisStatusConfirmed,
        AppColors.primary,
        FLucideIcons.badgeCheck,
      ),
      'analysis_failed' => (
        l10n.recordMealAnalysisStatusFailed,
        AppColors.destructive,
        FLucideIcons.circleAlert,
      ),
      _ => (
        l10n.recordMealAnalysisStatusUnconfirmed,
        AppColors.primary,
        FLucideIcons.badgeHelp,
      ),
    };
  }

  String? _coverageLabel(AppLocalizations l10n, String? currentCoverage) {
    return switch (currentCoverage) {
      'complete' => l10n.recordMealAnalysisCoverageComplete,
      'none' => l10n.recordMealAnalysisCoverageNone,
      'partial' => l10n.recordMealAnalysisCoveragePartial,
      _ => null,
    };
  }
}
