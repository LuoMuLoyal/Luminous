import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
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
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface.canvas,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(color: surface.hairline),
        boxShadow: AppShadowTokens.level2,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
    final background = emphasized ? surface.success : surface.canvas;
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
              color: emphasized ? surface.success : surface.hairline,
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

class MedicinePlanPill extends StatelessWidget {
  const MedicinePlanPill({
    super.key,
    required this.label,
    required this.color,
    required this.typography,
  });

  final String label;
  final Color color;
  final AppTypographyScale typography;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.sm,
        vertical: AppSpacingTokens.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
      ),
      child: Text(label, style: typography.caption.copyWith(color: color)),
    );
  }
}

double medicineQuickActionWidth(double width) {
  if (width >= AppBreakpoints.desktop) {
    return 218;
  }
  if (width >= AppBreakpoints.tablet) {
    return math.max((width - 240) / 2, 220).toDouble();
  }
  return double.infinity;
}
