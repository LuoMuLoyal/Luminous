import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';

class MedicineRiskMetricChip extends StatelessWidget {
  const MedicineRiskMetricChip({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return FCard.raw(
      style: .delta(
        decoration: .shapeDelta(
          color: colors.secondary.withValues(alpha: 0.08),
          shape: RoundedSuperellipseBorder(
            side: BorderSide(color: colors.border),
            borderRadius: context.theme.style.borderRadius.lg,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.level4,
          vertical: AppSpacingTokens.level3,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: typography.body.sm.copyWith(color: colors.mutedForeground),
            ),
            const SizedBox(height: AppSpacingTokens.level1),
            Text(
              value,
              style: typography.body.xl.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
