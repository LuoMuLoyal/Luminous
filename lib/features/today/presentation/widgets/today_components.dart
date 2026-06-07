import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

abstract final class TodayPalette {
  static const Color ink = Color(0xFF111827);
  static const Color body = Color(0xFF5B667A);
  static const Color mute = Color(0xFF8A94A8);
  static const Color panel = Color(0xFFFFFFFF);
  static const Color panelSoft = Color(0xFFF8FBFF);
  static const Color line = Color(0xFFE7EDF4);
  static const Color lineStrong = Color(0xFFD8E5F2);
  static const Color teal = Color(0xFF12B8A6);
  static const Color tealDeep = Color(0xFF0BA88E);
  static const Color tealSoft = Color(0xFFE8F8F5);
  static const Color blue = Color(0xFF1677FF);
  static const Color blueDeep = Color(0xFF0D63F3);
  static const Color blueSoft = Color(0xFFEAF3FF);
  static const Color violet = Color(0xFF7C55E7);
  static const Color violetSoft = Color(0xFFF2ECFF);
  static const Color pink = Color(0xFFFF4B82);
  static const Color pinkSoft = Color(0xFFFFEDF3);
  static const Color amber = Color(0xFFFF8C2A);
  static const Color amberSoft = Color(0xFFFFF3E6);
  static const Color green = Color(0xFF18B26B);
  static const Color greenSoft = Color(0xFFEAF8EF);
}

const List<BoxShadow> _todaySoftShadow = <BoxShadow>[
  BoxShadow(
    color: Color(0x0D1A3554),
    offset: Offset(0, 6),
    blurRadius: 18,
    spreadRadius: -8,
  ),
  BoxShadow(color: Color(0x08000000), blurRadius: 1),
];

class TodayPanel extends StatelessWidget {
  const TodayPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacingTokens.md),
    this.color,
    this.radius = AppRadiusTokens.xl,
    this.borderColor,
    this.shadow = _todaySoftShadow,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double radius;
  final Color? borderColor;
  final List<BoxShadow> shadow;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? (dark ? surface.canvasSoft : TodayPalette.panel),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? (dark ? surface.hairline : TodayPalette.line),
        ),
        boxShadow: dark ? AppShadowTokens.level1 : shadow,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class TodaySectionHeader extends StatelessWidget {
  const TodaySectionHeader({
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
    final width = MediaQuery.sizeOf(context).width;
    final typography = width < 600
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: AppSpacingTokens.xs),
        ],
        Expanded(
          child: Text(
            title,
            style: (compact ? typography.bodyMdStrong : typography.displaySm)
                .copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class TodayTextAction extends StatelessWidget {
  const TodayTextAction({
    super.key,
    required this.label,
    required this.onTap,
    this.icon = Icons.chevron_right_rounded,
    this.emphasized = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);
    final foreground = emphasized ? TodayPalette.tealDeep : surface.body;

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
              ),
              if (icon != null) ...[
                const SizedBox(width: 2),
                Icon(icon, size: 18, color: foreground),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class TodayGlyphTile extends StatelessWidget {
  const TodayGlyphTile({
    super.key,
    required this.icon,
    required this.color,
    this.size = 58,
    this.radius = AppRadiusTokens.md,
    this.gradient = true,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double radius;
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    final decoration = gradient
        ? BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withValues(alpha: 0.92), color],
            ),
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.18),
                offset: const Offset(0, 8),
                blurRadius: 18,
                spreadRadius: -10,
              ),
            ],
          )
        : BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(radius),
          );

    return DecoratedBox(
      decoration: decoration,
      child: SizedBox.square(
        dimension: size,
        child: Icon(
          icon,
          color: gradient ? Colors.white : color,
          size: size * 0.5,
        ),
      ),
    );
  }
}

class TodayStatusPill extends StatelessWidget {
  const TodayStatusPill({super.key, required this.label, required this.color});

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
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Text(
          label,
          style: typography.caption.copyWith(
            color: color,
            fontSize: 10,
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

class TodayLinearProgress extends StatelessWidget {
  const TodayLinearProgress({
    super.key,
    required this.progress,
    required this.color,
    this.height = 8,
  });

  final double progress;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final value = progress.clamp(0, 1).toDouble();

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
      child: Stack(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(color: const Color(0xFFE8EEF2)),
            child: SizedBox(height: height, width: double.infinity),
          ),
          FractionallySizedBox(
            widthFactor: value,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.82), color],
                ),
              ),
              child: SizedBox(height: height, width: double.infinity),
            ),
          ),
        ],
      ),
    );
  }
}

class TodayMiniTrendChart extends StatelessWidget {
  const TodayMiniTrendChart({
    super.key,
    required this.points,
    required this.color,
    this.height = 68,
  });

  final List<double> points;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final tickCount = points.isEmpty ? 7 : points.length;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadiusTokens.md),
      ),
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacingTokens.xs,
            vertical: AppSpacingTokens.xs,
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Icon(
                    Icons.show_chart_rounded,
                    color: color.withValues(alpha: 0.74),
                    size: 28,
                  ),
                ),
              ),
              Row(
                children: [
                  for (var index = 0; index < tickCount; index += 1) ...[
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: index == 3 ? color : TodayPalette.lineStrong,
                          borderRadius: BorderRadius.circular(
                            AppRadiusTokens.pill,
                          ),
                        ),
                        child: const SizedBox(height: 3),
                      ),
                    ),
                    if (index < tickCount - 1) const SizedBox(width: 3),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
