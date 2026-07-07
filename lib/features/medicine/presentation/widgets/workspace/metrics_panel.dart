import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';
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

    return FCard.raw(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.level5,
          vertical: AppSpacingTokens.level4,
        ),
        child: Row(
          children: [
            Expanded(
              child: _MetricBlock(
                label: l10n.medicineHeroMetricTodayCountLabel,
                value: workspace.hero.metricDosesToday,
                suffix: l10n.medicineHeroMetricTodayCountUnit,
                accent: context.theme.colors.primary,
                muted: colors.mutedForeground,
              ),
            ),
            Container(width: 1, height: 70, color: colors.border),
            Expanded(
              child: _MetricBlock(
                label: l10n.medicineHeroMetricAdherenceLabel,
                value: workspace.hero.metricAdherence.replaceAll('%', ''),
                suffix: l10n.medicineHeroMetricAdherenceUnit,
                accent: context.theme.colors.primary,
                muted: colors.mutedForeground,
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
  });

  final String label;
  final String value;
  final String suffix;
  final Color accent;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.level3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypographyToken.level3
                .body(context)
                .copyWith(color: muted),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacingTokens.level2),
          RichText(
            text: TextSpan(
              style: AppTypographyToken.level8
                  .display(context)
                  .copyWith(color: accent, fontWeight: FontWeight.w700),
              children: [
                TextSpan(text: value),
                TextSpan(
                  text: suffix,
                  style: AppTypographyToken.level5
                      .body(context)
                      .copyWith(color: accent, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
