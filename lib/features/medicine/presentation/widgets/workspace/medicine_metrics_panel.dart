import 'package:flutter/material.dart';
import 'package:luminous/core/widgets/app_section_surface.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_workspace.dart';
import 'package:luminous/features/medicine/presentation/widgets/workspace/medicine_workspace_helpers.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MedicineMetricsPanel extends StatelessWidget {
  const MedicineMetricsPanel({
    super.key,
    required this.workspace,
    required this.typography,
    required this.surface,
    required this.l10n,
  });

  final MedicineWorkspace workspace;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return AppSectionSurface(
      title: '',
      typography: typography,
      surface: surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.lg,
        vertical: AppSpacingTokens.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: _MetricBlock(
              label: l10n.medicineHeroMetricTodayCountLabel,
              value: workspace.hero.metricDosesToday,
              typography: typography,
              surface: surface,
              suffix: l10n.medicineHeroMetricTodayCountUnit,
            ),
          ),
          Container(width: 1, height: 70, color: surface.hairline),
          Expanded(
            child: _MetricBlock(
              label: l10n.medicineHeroMetricAdherenceLabel,
              value: workspace.hero.metricAdherence.replaceAll('%', ''),
              typography: typography,
              surface: surface,
              suffix: l10n.medicineHeroMetricAdherenceUnit,
              showInfo: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({
    required this.label,
    required this.value,
    required this.typography,
    required this.surface,
    required this.suffix,
    this.showInfo = false,
  });

  final String label;
  final String value;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final String suffix;
  final bool showInfo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  label,
                  style: typography.bodySm.copyWith(color: surface.body),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showInfo) ...[
                const SizedBox(width: AppSpacingTokens.xxs),
                Icon(Icons.info_outline_rounded, size: 14, color: surface.mute),
              ],
            ],
          ),
          const SizedBox(height: AppSpacingTokens.xs),
          RichText(
            text: TextSpan(
              style: typography.displayXl.copyWith(
                color: MedicineWorkspacePalette.green,
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(text: value),
                TextSpan(
                  text: suffix,
                  style: typography.bodySmStrong.copyWith(
                    color: MedicineWorkspacePalette.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
