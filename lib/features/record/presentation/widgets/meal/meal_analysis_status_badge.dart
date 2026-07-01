import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/common/app_status_pill.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MealAnalysisStatusBadge extends StatelessWidget {
  const MealAnalysisStatusBadge({
    super.key,
    required this.status,
    this.coverage,
    this.typography,
    this.large = false,
  });

  final String? status;
  final String? coverage;
  final AppTypographyScale? typography;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (label, color, icon) = _statusSpec(context, l10n, status);
    final coverageLabel = _coverageLabel(l10n, coverage);
    final text = coverageLabel == null ? label : '$label · $coverageLabel';

    return AppStatusPill(
      label: text,
      color: color,
      icon: icon,
      typography: typography,
      large: large,
    );
  }

  (String, Color, IconData) _statusSpec(
    BuildContext context,
    AppLocalizations l10n,
    String? currentStatus,
  ) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    return switch (currentStatus) {
      'analyzing' => (
        l10n.recordMealAnalysisStatusAnalyzing,
        surface.link,
        Icons.hourglass_top_rounded,
      ),
      'confirmed' => (
        l10n.recordMealAnalysisStatusConfirmed,
        surface.accent,
        Icons.check_circle_outline_rounded,
      ),
      'analysis_failed' => (
        l10n.recordMealAnalysisStatusFailed,
        surface.error,
        Icons.error_outline_rounded,
      ),
      _ => (
        l10n.recordMealAnalysisStatusUnconfirmed,
        surface.warningDeep,
        Icons.help_outline_rounded,
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
