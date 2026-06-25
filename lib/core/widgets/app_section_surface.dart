import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

class AppSectionSurface extends StatelessWidget {
  const AppSectionSurface({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.trailing,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.radius = AppRadiusTokens.lg,
    this.shadow,
    // Legacy params — accepted but ignored (self-themed)
    this.typography,
    this.surface,
    this.color,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double radius;
  final List<BoxShadow>? shadow;
  final dynamic typography;
  final dynamic surface;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appSurface = theme.extension<AppThemeSurface>()!;
    final isDark = theme.brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;
    final effectiveTypography = width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);

    final effectivePadding =
        padding ?? const EdgeInsets.all(AppSpacingTokens.md);
    final effectiveBg = backgroundColor ?? color ?? appSurface.canvas;
    final effectiveBorder = borderColor ?? appSurface.hairline;
    final effectiveShadow = shadow ?? AppShadowTokens.level1;
    final hasHeader = (title != null && title!.isNotEmpty) || trailing != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: effectiveBorder),
        boxShadow: isDark ? AppShadowTokens.level1 : effectiveShadow,
      ),
      child: Padding(
        padding: effectivePadding,
        child: hasHeader
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (title != null && title!.isNotEmpty)
                              Text(
                                title!,
                                style: effectiveTypography.displaySm,
                              ),
                            if (subtitle != null && subtitle!.isNotEmpty) ...[
                              const SizedBox(height: AppSpacingTokens.xs),
                              Text(
                                subtitle!,
                                style: effectiveTypography.bodySm.copyWith(
                                  color: appSurface.body,
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
              )
            : child,
      ),
    );
  }
}
