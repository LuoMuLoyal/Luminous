import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

class MedicineRiskMetricChip extends StatelessWidget {
  const MedicineRiskMetricChip({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    final card = FCard(
      style: .delta(
        decoration: .shapeDelta(
          color: SemanticColor.neutral.muted(context),
          shape: RoundedSuperellipseBorder(
            side: BorderSide(color: colors.border),
            borderRadius: context.theme.style.borderRadius.lg,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level4,
          vertical: Spacing.level3,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: typography.body.sm.copyWith(color: colors.mutedForeground),
            ),
            const SizedBox(height: Spacing.level1),
            Text(
              value,
              style: typography.body.xl.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
    if (onTap == null) return card;
    return FTappable(onPress: onTap, child: card);
  }
}
