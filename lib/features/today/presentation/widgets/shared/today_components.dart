import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';

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
            decoration: const BoxDecoration(color: AppColorTokens.hairline),
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
                          color: index == 3
                              ? color
                              : AppColorTokens.hairlineStrong,
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
