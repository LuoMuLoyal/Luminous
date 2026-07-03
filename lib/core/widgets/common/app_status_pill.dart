import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_colors.dart';
import 'package:luminous/core/design/app_design.dart';

/// A thin wrapper around Forui's [FBadge.raw] that resolves a semantic
/// [AppColors] token against the current theme.
class AppStatusPill extends StatelessWidget {
  const AppStatusPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.backgroundAlpha = 0.12,
    this.radius = AppRadiusTokens.level2,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacingTokens.level2,
      vertical: AppSpacingTokens.level1,
    ),
    this.large = false,
  });

  final String label;
  final AppColors color;
  final IconData? icon;
  final double backgroundAlpha;
  final double radius;
  final EdgeInsetsGeometry padding;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.theme.colors;
    final resolvedColor = color.resolve(colors);
    final foreground = backgroundAlpha > 0.5
        ? colors.primaryForeground
        : resolvedColor;

    return FBadge.raw(
      builder: (context, style) => DecoratedBox(
        decoration: ShapeDecoration(
          color: resolvedColor.withValues(alpha: backgroundAlpha),
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: Padding(
          padding: padding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: foreground, size: AppSpacingTokens.level3),
                const SizedBox(width: AppSpacingTokens.level1),
              ],
              Text(
                label,
                style: large
                    ? textTheme.labelMedium?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w600,
                      )
                    : textTheme.labelSmall?.copyWith(
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
      ),
    );
  }
}
