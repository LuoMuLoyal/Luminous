import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';

class AppHeaderActionChip extends StatelessWidget {
  const AppHeaderActionChip({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.emphasized = false,
    this.iconOnly = false,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool emphasized;
  final bool iconOnly;
  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    final foreground = emphasized
        ? colors.primaryForeground
        : colors.foreground;

    return Tooltip(
      message: label,
      child: FButton(
        variant: emphasized ? FButtonVariant.primary : FButtonVariant.outline,
        size: FButtonSizeVariant.sm,
        onPress: onTap,
        mainAxisSize: MainAxisSize.min,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: foreground),
            if (!iconOnly) ...[
              const SizedBox(width: AppSpacingTokens.xs),
              Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
