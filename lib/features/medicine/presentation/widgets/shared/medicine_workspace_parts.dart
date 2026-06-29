import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

enum MedicineDoseAction { taken, skipped }

class MedicineHeaderActionChip extends StatelessWidget {
  const MedicineHeaderActionChip({
    super.key,
    required this.label,
    required this.icon,
    required this.typography,
    required this.surface,
    this.onTap,
    this.emphasized = false,
  });

  final String label;
  final IconData icon;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final VoidCallback? onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    const emphasisColor = AppColorTokens.cyanDeep;
    final background = emphasized ? emphasisColor : surface.canvas;
    final foreground = emphasized
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
            border: Border.all(
              color: emphasized ? emphasisColor : surface.hairline,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.md,
              vertical: AppSpacingTokens.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: foreground),
                const SizedBox(width: AppSpacingTokens.xs),
                Text(
                  label,
                  style: typography.buttonMd.copyWith(color: foreground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
