import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';

class AppStatusPill extends StatelessWidget {
  const AppStatusPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.backgroundAlpha = 0.12,
    this.radius = AppRadiusTokens.sm,
    this.typography,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacingTokens.xs,
      vertical: AppSpacingTokens.xxs,
    ),
    this.large = false,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final double backgroundAlpha;
  final double radius;
  final AppTypographyScale? typography;
  final EdgeInsetsGeometry padding;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final effectiveTypography =
        typography ??
        AppTypographyTokens.mobile(Theme.of(context).colorScheme.onSurface);
    final foreground = backgroundAlpha > 0.5 ? Colors.white : color;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: backgroundAlpha),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: foreground, size: AppSpacingTokens.sm),
              const SizedBox(width: AppSpacingTokens.xxs),
            ],
            Text(
              label,
              style: large
                  ? effectiveTypography.bodySmStrong.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w600,
                    )
                  : effectiveTypography.caption.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
