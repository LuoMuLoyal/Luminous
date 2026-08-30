import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

/// A label-value row with a fixed-width label, used in clinic summary
/// and suggestion history detail layouts.
///
/// The label column is 80px wide with muted foreground color; the value
/// expands to fill the remaining space.
class MetaRow extends StatelessWidget {
  const MetaRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.level1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
          ),
          const SizedBox(width: Spacing.level3),
          Expanded(child: Text(value, style: typography.body.xs)),
        ],
      ),
    );
  }
}

class ReviewMetricTrack extends StatelessWidget {
  const ReviewMetricTrack({
    super.key,
    required this.values,
    required this.color,
    this.height = Spacing.level7,
  });

  final List<double> values;
  final SemanticColor color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final visibleValues = values.isEmpty ? const <double>[0, 0] : values;
    final minValue = visibleValues.reduce((a, b) => a < b ? a : b);
    final maxValue = visibleValues.reduce((a, b) => a > b ? a : b);
    final span = (maxValue - minValue).abs() < 1 ? 1 : maxValue - minValue;

    return RepaintBoundary(
      child: SizedBox(
        height: height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var index = 0; index < visibleValues.length; index += 1) ...[
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor:
                        0.28 +
                        ((visibleValues[index] - minValue) / span * 0.62),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: color.border(context),
                        borderRadius: context.theme.style.borderRadius.pill,
                        border: Border.all(
                          color: SemanticColor.neutral.border(context),
                        ),
                      ),
                      child: const SizedBox(width: Spacing.level1),
                    ),
                  ),
                ),
              ),
              if (index != visibleValues.length - 1)
                const SizedBox(width: Spacing.level1),
            ],
          ],
        ),
      ),
    );
  }
}
