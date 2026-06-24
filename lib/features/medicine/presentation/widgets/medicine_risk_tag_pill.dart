import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';

class MedicineRiskTagPill extends StatelessWidget {
  const MedicineRiskTagPill({
    super.key,
    required this.label,
    required this.color,
  });
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final typography = AppTypographyTokens.mobile(
      Theme.of(context).colorScheme.onSurface,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.sm,
          vertical: AppSpacingTokens.xxs,
        ),
        child: Text(
          label,
          style: typography.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
