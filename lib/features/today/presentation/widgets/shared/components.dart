import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

class TodayGlyphTile extends StatelessWidget {
  const TodayGlyphTile({
    super.key,
    required this.icon,
    required this.color,
    this.size = Spacing.level8 + Spacing.level2,
    this.radius = RadiusTokens.level3,
    this.gradient = true,
  });

  final IconData icon;
  final SemanticColor color;
  final double size;
  final double radius;
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    final palette = color.palette(context);
    final decoration = gradient
        ? BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [palette.solid.withValues(alpha: 0.92), palette.solid],
            ),
            borderRadius: BorderRadius.circular(radius),
          )
        : BoxDecoration(
            color: palette.muted,
            borderRadius: BorderRadius.circular(radius),
          );

    return DecoratedBox(
      decoration: decoration,
      child: SizedBox.square(
        dimension: size,
        child: Icon(
          icon,
          color: gradient ? context.theme.colors.primary : palette.solid,
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
    this.height = Spacing.level9,
  });

  final List<double> points;
  final SemanticColor color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = color.palette(context);
    final tickCount = points.isEmpty ? 7 : points.length;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.subtle,
        borderRadius: BorderRadius.circular(RadiusTokens.level3),
      ),
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.level2,
            vertical: Spacing.level2,
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Icon(
                    FLucideIcons.chartLine,
                    color: palette.solid.withValues(alpha: 0.74),
                    size: Spacing.level5,
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
                              ? palette.solid
                              : context.theme.colors.primary,
                          borderRadius: BorderRadius.circular(
                            RadiusTokens.levelFull,
                          ),
                        ),
                        child: const SizedBox(height: Spacing.level1),
                      ),
                    ),
                    if (index < tickCount - 1)
                      const SizedBox(width: Spacing.level1),
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
