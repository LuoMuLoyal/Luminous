import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MetricRow extends StatelessWidget {
  const MetricRow({super.key, required this.l10n, required this.result});

  final AppLocalizations l10n;
  final MedicineRiskCheckResult result;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MetricItem(
          label: l10n.medicineRiskCheckCurrentMedicinesLabel,
          value: '${result.currentMedicineCount}',
          color: SemanticColor.neutral,
        ),
        const MetricDividerWidget(),
        MetricItem(
          label: l10n.medicineRiskCheckFindingsLabel,
          value: '${result.findingCount}',
          color: result.findingCount > 0
              ? SemanticColor.destructive
              : SemanticColor.success,
        ),
        const MetricDividerWidget(),
        MetricItem(
          label: l10n.medicineRiskCheckCoverageLabel,
          value: '${result.coverageCount}',
          color: result.coverageCount > 0
              ? SemanticColor.warning
              : SemanticColor.success,
        ),
      ],
    );
  }
}

class MetricItem extends StatelessWidget {
  const MetricItem({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final SemanticColor color;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: typography.display.xl.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            label,
            style: typography.body.xs.copyWith(
              color: SemanticColor.neutral.solid(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class MetricDividerWidget extends StatelessWidget {
  const MetricDividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: Spacing.xl2,
      color: SemanticColor.neutral.border(context),
    );
  }
}

class AlertChip extends StatelessWidget {
  const AlertChip({super.key, required this.alert, required this.l10n});

  final MedicineAlert alert;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return Row(
      children: [
        Icon(
          alert.icon,
          color: alert.color.solid(context),
          size: IconSizeTokens.md,
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: Text(
            medicineAlertTitle(l10n, alert),
            style: typography.body.xs.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm,
            vertical: Spacing.xs,
          ),
          decoration: ShapeDecoration(
            color: alert.color.muted(context),
            shape: RoundedSuperellipseBorder(
              borderRadius: context.theme.style.borderRadius.pill,
            ),
          ),
          child: Text(
            alert.color == SemanticColor.destructive
                ? l10n.medicineRiskCheckSeverityHigh
                : l10n.medicineRiskCheckSeverityMedium,
            style: typography.body.xs3.copyWith(
              color: alert.color.solid(context),
            ),
          ),
        ),
      ],
    );
  }
}
