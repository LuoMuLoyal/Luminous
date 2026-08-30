import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

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

    final (label, color, icon) = _statusSpec(context, l10n, status);
    final coverageLabel = _coverageLabel(l10n, coverage);
    final text = coverageLabel == null ? label : '$label · $coverageLabel';
    final palette = color.palette(context);
    final foreground = palette.solid;

    return FBadge.raw(
      builder: (context, style) => DecoratedBox(
        decoration: ShapeDecoration(
          color: palette.muted,
          shape: RoundedSuperellipseBorder(
            borderRadius: context.theme.style.borderRadius.xs,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.level2,
            vertical: Spacing.level1,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: foreground, size: Spacing.level3),
              const SizedBox(width: Spacing.level1),
              Text(
                text,
                style: large
                    ? context.theme.typography.body.sm.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w600,
                      )
                    : context.theme.typography.body.xs.copyWith(
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

  (String, SemanticColor, IconData) _statusSpec(
    BuildContext context,
    AppLocalizations l10n,
    String? currentStatus,
  ) {
    return switch (currentStatus) {
      'analyzing' => (
        l10n.recordMealAnalysisStatusAnalyzing,
        SemanticColor.primary,
        SemanticIcons.statusPending,
      ),
      'confirmed' => (
        l10n.recordMealAnalysisStatusConfirmed,
        SemanticColor.primary,
        SemanticIcons.reportAdherence,
      ),
      'analysis_failed' => (
        l10n.recordMealAnalysisStatusFailed,
        SemanticColor.destructive,
        SemanticIcons.statusError,
      ),
      _ => (
        l10n.recordMealAnalysisStatusUnconfirmed,
        SemanticColor.primary,
        SemanticIcons.actionHelp,
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
