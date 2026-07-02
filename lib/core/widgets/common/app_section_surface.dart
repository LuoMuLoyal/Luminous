import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';

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
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    final effectivePadding =
        padding ?? const EdgeInsets.all(AppSpacingTokens.md);
    final hasHeader = (title != null && title!.isNotEmpty) || trailing != null;

    final content = Padding(
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
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (subtitle != null && subtitle!.isNotEmpty) ...[
                            const SizedBox(height: AppSpacingTokens.xs),
                            Text(
                              subtitle!,
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.mutedForeground,
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
    );

    return FCard.raw(child: content);
  }
}
