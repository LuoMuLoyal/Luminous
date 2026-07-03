import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';

class TodayGlyphTile extends StatelessWidget {
  const TodayGlyphTile({
    super.key,
    required this.icon,
    required this.color,
    this.size = AppSpacingTokens.level8 + AppSpacingTokens.level2,
    this.radius = AppRadiusTokens.level3,
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
          color: gradient ? context.theme.colors.primary : color,
          size: size * 0.5,
        ),
      ),
    );
  }
}

class TodayMiniTrendChart extends StatelessWidget {
  const TodayMiniTrendChart({
    super.key,
    required this.points,
    required this.color,
    this.height = AppSpacingTokens.level9,
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
        borderRadius: BorderRadius.circular(AppRadiusTokens.level3),
      ),
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacingTokens.level2,
            vertical: AppSpacingTokens.level2,
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Icon(
                    FLucideIcons.chartLine,
                    color: color.withValues(alpha: 0.74),
                    size: AppSpacingTokens.level5,
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
                              : context.theme.colors.primary,
                          borderRadius: BorderRadius.circular(
                            AppRadiusTokens.levelFull,
                          ),
                        ),
                        child: const SizedBox(height: AppSpacingTokens.level1),
                      ),
                    ),
                    if (index < tickCount - 1)
                      const SizedBox(width: AppSpacingTokens.level1),
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
