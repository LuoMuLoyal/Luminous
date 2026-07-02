import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';

class ReportMetricTrack extends StatelessWidget {
  const ReportMetricTrack({
    super.key,
    required this.values,
    required this.color,
    this.height = AppSpacingTokens.x2l,
  });

  final List<double> values;
  final Color color;
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
                        color: color.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(
                          AppRadiusTokens.pill,
                        ),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: const SizedBox(width: AppSpacingTokens.xxs),
                    ),
                  ),
                ),
              ),
              if (index != visibleValues.length - 1)
                const SizedBox(width: AppSpacingTokens.xxs),
            ],
          ],
        ),
      ),
    );
  }
}
