import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

class TodayGlyphTile extends StatelessWidget {
  const TodayGlyphTile({
    super.key,
    required this.icon,
    required this.color,
    this.size = Spacing.level8 + Spacing.level2,
    this.radius,
    this.filled = false,
  });

  final IconData icon;
  final SemanticColor color;
  final double size;
  final double? radius;

  /// When `true`, uses [GradientTokens.semanticFill] for a rich, visually
  /// weighted fill (primary suggestion cards). When `false`, uses
  /// [SemanticColorPalette.muted] for a light tint (secondary suggestions).
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final radius = this.radius ?? context.theme.style.borderRadius.sm.topLeft.x;
    final palette = color.palette(context);
    final decoration = BoxDecoration(
      gradient: filled ? GradientTokens.semanticFill(palette) : null,
      color: filled ? null : palette.muted,
      borderRadius: BorderRadius.circular(radius),
    );

    return DecoratedBox(
      decoration: decoration,
      child: SizedBox.square(
        dimension: size,
        child: Center(
          child: Icon(
            icon,
            color: filled ? palette.foreground : palette.solid,
            size: IconSizeTokens.level3,
          ),
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
    final borderRadius = context.theme.style.borderRadius;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.subtle,
        borderRadius: borderRadius.sm,
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
                    SemanticIcons.reportChart,
                    color: palette.fillStrong,
                    size: IconSizeTokens.level3,
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
                              : SemanticColor.primary.solid(context),
                          borderRadius: borderRadius.pill,
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
