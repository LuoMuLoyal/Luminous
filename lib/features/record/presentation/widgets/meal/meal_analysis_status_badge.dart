import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:luminous/core/design/app_colors.dart';
import 'package:luminous/core/widgets/common/app_status_pill.dart';
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

    return AppStatusPill(label: text, color: color, icon: icon, large: large);
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
