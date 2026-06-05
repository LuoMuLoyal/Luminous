import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

class MedicineSectionSurface extends StatelessWidget {
  const MedicineSectionSurface({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    required this.typography,
    required this.surface,
    this.trailing,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final hasHeader = title.isNotEmpty || trailing != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface.canvas,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(color: surface.hairline),
        boxShadow: AppShadowTokens.level1,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacingTokens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasHeader) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title.isNotEmpty)
                          Text(title, style: typography.displaySm),
                        if (subtitle != null && subtitle!.isNotEmpty) ...[
                          const SizedBox(height: AppSpacingTokens.xs),
                          Text(
                            subtitle!,
                            style: typography.bodySm.copyWith(
                              color: surface.body,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: AppSpacingTokens.md),
                    trailing!,
                  ],
                ],
              ),
              const SizedBox(height: AppSpacingTokens.lg),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

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
    final emphasisColor = const Color(0xFF159B55);
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
