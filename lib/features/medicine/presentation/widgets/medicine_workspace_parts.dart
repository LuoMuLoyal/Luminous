import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

enum MedicineDoseAction { taken, skipped }

class MedicinePanel extends StatelessWidget {
  const MedicinePanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacingTokens.md),
    this.color,
    this.borderColor,
    this.radius = AppRadiusTokens.lg,
    this.shadow = AppShadowTokens.level1,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final double radius;
  final List<BoxShadow> shadow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? surface.canvas,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? surface.hairline),
        boxShadow: theme.brightness == Brightness.dark
            ? AppShadowTokens.level1
            : shadow,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class MedicineSectionHeader extends StatelessWidget {
  const MedicineSectionHeader({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.compact = false,
  });

  final String title;
  final Widget? leading;
  final Widget? trailing;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return Row(
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: AppSpacingTokens.xs),
        ],
        Expanded(
          child: Text(
            title,
            style: (compact ? typography.bodyMdStrong : typography.displaySm)
                .copyWith(fontWeight: FontWeight.w600, letterSpacing: 0),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacingTokens.sm),
          trailing!,
        ],
      ],
    );
  }
}

class MedicineTextAction extends StatelessWidget {
  const MedicineTextAction({
    super.key,
    required this.label,
    required this.onTap,
    this.icon = Icons.chevron_right_rounded,
    this.color,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);
    final foreground = color ?? surface.body;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.xxs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: typography.bodySmStrong.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (icon != null) ...[
                const SizedBox(width: AppSpacingTokens.xxs),
                Icon(icon, size: AppSpacingTokens.md, color: foreground),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class MedicineIconBadge extends StatelessWidget {
  const MedicineIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.backgroundColor,
    this.size = AppSpacingTokens.x3l,
    this.iconSize = AppSpacingTokens.lg,
    this.shape = BoxShape.rectangle,
  });

  final IconData icon;
  final Color color;
  final Color? backgroundColor;
  final double size;
  final double iconSize;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.1),
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(AppRadiusTokens.lg)
            : null,
        shape: shape,
      ),
      child: SizedBox.square(
        dimension: size,
        child: Icon(icon, color: color, size: iconSize),
      ),
    );
  }
}

class MedicineStatusPill extends StatelessWidget {
  const MedicineStatusPill({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypographyTokens.mobile(
      Theme.of(context).colorScheme.onSurface,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.xs,
          vertical: AppSpacingTokens.xxs,
        ),
        child: Text(
          label,
          style: typography.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

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
