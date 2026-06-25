import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

class AppHeaderActionChip extends StatelessWidget {
  const AppHeaderActionChip({
    super.key,
    required this.label,
    required this.icon,
    required this.typography,
    required this.surface,
    required this.onTap,
    this.emphasized = false,
    this.iconOnly = false,
  });
  final String label;
  final IconData icon;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final VoidCallback onTap;
  final bool emphasized;
  final bool iconOnly;
  @override
  Widget build(BuildContext context) {
    const accent = AppColorTokens.cyanDeep;
    final background = emphasized ? accent : surface.canvas;
    final foreground = emphasized
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.onSurface;
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
              border: Border.all(color: emphasized ? accent : surface.hairline),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: iconOnly
                    ? AppSpacingTokens.sm
                    : AppSpacingTokens.md,
                vertical: AppSpacingTokens.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18, color: foreground),
                  if (!iconOnly) ...[
                    const SizedBox(width: AppSpacingTokens.xs),
                    Text(
                      label,
                      style: typography.buttonMd.copyWith(color: foreground),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
