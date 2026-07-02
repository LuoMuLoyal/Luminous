import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';

class RecordHeaderActionChip extends StatelessWidget {
  const RecordHeaderActionChip({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.emphasized = false,
    this.iconOnly = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool emphasized;
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    const accent = AppColorTokens.cyanDeep;
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    final foreground = emphasized
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.onSurface;

    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: emphasized ? accent : colors.background,
              borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
              border: Border.all(color: emphasized ? accent : colors.border),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: iconOnly
                    ? AppSpacingTokens.sm
                    : AppSpacingTokens.md,
                vertical: AppSpacingTokens.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18, color: foreground),
                  if (!iconOnly) ...[
                    const SizedBox(width: AppSpacingTokens.xs),
                    Text(
                      label,
                      style: textTheme.labelLarge?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RecordLineChart extends StatelessWidget {
  const RecordLineChart({
    super.key,
    required this.points,
    required this.color,
    required this.gridColor,
    this.secondaryPoints = const <double>[],
    this.secondaryColor,
    this.height = 104,
  });

  final List<double> points;
  final Color color;
  final Color gridColor;
  final List<double> secondaryPoints;
  final Color? secondaryColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final allValues = [...points, ...secondaryPoints];
    final minY = allValues.isEmpty
        ? 0.0
        : allValues.reduce((a, b) => a < b ? a : b);
    final maxY = allValues.isEmpty
        ? 1.0
        : allValues.reduce((a, b) => a > b ? a : b);
    final span = (maxY - minY).abs() < 1 ? 1.0 : (maxY - minY);

    List<LineChartBarData> bars() {
      final primary = points
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), e.value))
          .toList();
      final result = <LineChartBarData>[
        LineChartBarData(
          spots: primary,
          color: color,
          barWidth: 2,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) =>
                FlDotCirclePainter(radius: 3, color: color),
          ),
          belowBarData: BarAreaData(show: false),
        ),
      ];
      if (secondaryColor != null && secondaryPoints.isNotEmpty) {
        final secondary = secondaryPoints
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value))
            .toList();
        result.add(
          LineChartBarData(
            spots: secondary,
            color: secondaryColor!,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) =>
                  FlDotCirclePainter(radius: 3, color: secondaryColor!),
            ),
            belowBarData: BarAreaData(show: false),
          ),
        );
      }
      return result;
    }

    return RepaintBoundary(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: LineChart(
          LineChartData(
            minY: minY - span * 0.1,
            maxY: maxY + span * 0.1,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) =>
                  FlLine(color: gridColor, strokeWidth: 1),
              horizontalInterval: (maxY - minY + span * 0.2) / 4,
            ),
            borderData: FlBorderData(show: false),
            titlesData: const FlTitlesData(show: false),
            lineTouchData: const LineTouchData(enabled: false),
            lineBarsData: bars(),
          ),
        ),
      ),
    );
  }
}

class RecordBarChart extends StatelessWidget {
  const RecordBarChart({
    super.key,
    required this.values,
    required this.color,
    required this.gridColor,
    this.height = 104,
  });

  final List<double> values;
  final Color color;
  final Color gridColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: 1.0,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: gridColor, strokeWidth: 1),
            horizontalInterval: 1.0 / 3,
          ),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(show: false),
          barTouchData: const BarTouchData(enabled: false),
          barGroups: values.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.clamp(0.0, 1.0),
                  color: color.withValues(alpha: 0.7),
                  width: 12,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadiusTokens.xs),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
