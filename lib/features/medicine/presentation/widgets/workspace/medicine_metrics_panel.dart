import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_workspace.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MedicineMetricsPanel extends StatelessWidget {
  const MedicineMetricsPanel({
    super.key,
    required this.workspace,
    required this.l10n,
  });

  final MedicineWorkspace workspace;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return FCard.raw(
      child: Padding(
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
                suffix: l10n.medicineHeroMetricTodayCountUnit,
                accent: Color(0xFF0F766E),
                muted: colors.mutedForeground,
                textTheme: textTheme,
              ),
            ),
            Container(width: 1, height: 70, color: colors.border),
            Expanded(
              child: _MetricBlock(
                label: l10n.medicineHeroMetricAdherenceLabel,
                value: workspace.hero.metricAdherence.replaceAll('%', ''),
                suffix: l10n.medicineHeroMetricAdherenceUnit,
                accent: Color(0xFF0F766E),
                muted: colors.mutedForeground,
                textTheme: textTheme,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({
    required this.label,
    required this.value,
    required this.suffix,
    required this.accent,
    required this.muted,
    required this.textTheme,
  });

  final String label;
  final String value;
  final String suffix;
  final Color accent;
  final Color muted;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(color: muted),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacingTokens.xs),
          RichText(
            text: TextSpan(
              style: textTheme.headlineMedium?.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
              ),
              children: [
                TextSpan(text: value),
                TextSpan(
                  text: suffix,
                  style: textTheme.labelLarge?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
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
