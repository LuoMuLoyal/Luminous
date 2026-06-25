import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';

abstract final class TodayPalette {
  static const Color ink = AppColorTokens.ink;
  static const Color body = AppColorTokens.body;
  static const Color mute = AppColorTokens.mute;
  static const Color panel = AppColorTokens.canvas;
  static const Color panelSoft = AppColorTokens.canvasSoft;
  static const Color line = AppColorTokens.hairline;
  static const Color lineStrong = AppColorTokens.hairlineStrong;
  static const Color healthGreen = AppColorTokens.health;
  static const Color teal = AppColorTokens.cyanDeep;
  static const Color tealDeep = AppColorTokens.cyanDeep;
  static const Color tealSoft = AppColorTokens.cyanSoft;
  static const Color blue = AppColorTokens.link;
  static const Color blueDeep = AppColorTokens.linkDeep;
  static const Color blueSoft = AppColorTokens.linkSoft;
  static const Color violet = AppColorTokens.violet;
  static const Color violetSoft = AppColorTokens.violetSoft;
  static const Color pink = AppColorTokens.highlightMagenta;
  static const Color pinkSoft = AppColorTokens.errorSoft;
  static const Color amber = AppColorTokens.warning;
  static const Color amberSoft = AppColorTokens.warningSoft;
  static const Color green = AppColorTokens.cyanDeep;
  static const Color greenSoft = AppColorTokens.cyanSoft;
}

class TodayGlyphTile extends StatelessWidget {
  const TodayGlyphTile({
    super.key,
    required this.icon,
    required this.color,
    this.size = AppSpacingTokens.x3l + AppSpacingTokens.xs,
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
            boxShadow: AppShadowTokens.level1,
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
          color: gradient ? AppColorTokens.onPrimary : color,
          size: size * 0.5,
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
    this.height = AppSpacingTokens.xs,
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
            decoration: const BoxDecoration(color: TodayPalette.line),
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
    this.height = AppSpacingTokens.x4l,
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
                    size: AppSpacingTokens.lg,
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
                        child: const SizedBox(height: AppSpacingTokens.xxs),
                      ),
                    ),
                    if (index < tickCount - 1)
                      const SizedBox(width: AppSpacingTokens.xxs),
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
