import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';

enum MedicineDoseAction { taken, skipped }

class MedicineHeaderActionChip extends StatelessWidget {
  const MedicineHeaderActionChip({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
    this.emphasized = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return FButton(
      onPress: onTap,
      variant: emphasized ? FButtonVariant.primary : FButtonVariant.outline,
      mainAxisSize: MainAxisSize.min,
      style: const .delta(
        contentStyle: .delta(
          padding: .value(
            EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.level4,
              vertical: AppSpacingTokens.level3,
            ),
          ),
        ),
      ),
      prefix: Icon(icon, size: 18),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
