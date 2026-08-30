import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

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
    return FTooltip(
      tipBuilder: (context, controller) => Text(label),
      child: FButton(
        onPress: onTap,
        variant: emphasized ? FButtonVariant.primary : FButtonVariant.outline,
        mainAxisSize: MainAxisSize.min,
        style: FButtonStyleDelta.delta(
          decoration: iconOnly && emphasized
              ? .delta([
                  .all(
                    .shapeDelta(
                      shape: RoundedRectangleBorder(
                        borderRadius: context.theme.style.borderRadius.md,
                      ),
                    ),
                  ),
                ])
              : null,
          contentStyle: FButtonContentStyleDelta.delta(
            padding: .value(
              EdgeInsets.symmetric(
                horizontal: iconOnly ? Spacing.level3 : Spacing.level4,
                vertical: Spacing.level3,
              ),
            ),
            spacing: iconOnly ? 0 : null,
          ),
        ),
        prefix: Icon(icon, size: IconSizeTokens.level3),
        child: iconOnly
            ? const SizedBox.shrink()
            : Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
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
  final SemanticColor color;
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
                  color: color.fillStrong(context),
                  width: 12,
                  borderRadius: BorderRadius.vertical(
                    top: context.theme.style.borderRadius.xs2.topLeft,
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
