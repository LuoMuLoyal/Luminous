import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/dialogs/range_picker_dialog.dart';
import 'package:luminous/features/report/presentation/widgets/shared/section_models.dart';
import 'package:luminous/features/report/presentation/widgets/shared/top_bar.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/core/widgets/common/divider.dart';

class ReportTrendSection extends StatelessWidget {
  const ReportTrendSection({
    super.key,
    required this.trends,
    required this.selectedQuery,
    required this.onQueryChanged,
    required this.l10n,
    required this.startDate,
    this.showRangePill = true,
  });

  final List<ReportTrendSeries> trends;
  final ReportDashboardQuery selectedQuery;
  final ValueChanged<ReportDashboardQuery> onQueryChanged;
  final AppLocalizations l10n;
  final String startDate;
  final bool showRangePill;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                l10n.reportTrendSectionTitle,
                style: TypographyToken.level5
                    .body(context)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (showRangePill)
              ReportPeriodPill(
                range: selectedQuery.range,
                onTap: () => _showRangePicker(context),
              ),
          ],
        ),
        const SizedBox(height: Spacing.level3),
        const AppDivider(),
        const SizedBox(height: Spacing.level4),
        Wrap(
          spacing: Spacing.level4,
          runSpacing: Spacing.level2,
          children: [
            for (final series in trends)
              _LegendDot(
                color: series.color,
                label: reportMetricTitle(l10n, series.kind),
                currentValue: series.currentValue,
                unit: series.unit,
              ),
          ],
        ),
        const SizedBox(height: Spacing.level4),
        Semantics(
          label: l10n.reportTrendSectionTitle,
          child: _TrendChart(trends: trends, startDate: startDate),
        ),
      ],
    );
  }

  Future<void> _showRangePicker(BuildContext context) async {
    final selected = await showReportRangePickerDialog(
      context,
      selectedQuery: selectedQuery,
    );
    if (selected != null && selected != selectedQuery) {
      onQueryChanged(selected);
    }
  }
}

// ---------------------------------------------------------------------------

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.trends, required this.startDate});

  final List<ReportTrendSeries> trends;
  final String startDate;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    // All series share the same x-axis length.
    final dayCount = trends.isEmpty || trends.first.values.isEmpty
        ? 7
        : trends.first.values.length;

    // Compute global Y bounds across all series for a shared scale.
    final allValues = trends.expand((s) => s.values).toList();
    final minY = allValues.isEmpty
        ? 0.0
        : allValues.reduce((a, b) => a < b ? a : b);
    final maxY = allValues.isEmpty
        ? 1.0
        : allValues.reduce((a, b) => a > b ? a : b);
    final span = (maxY - minY).abs() < 1 ? 1.0 : (maxY - minY);

    // Build one LineChartBarData per trend series.
    final bars = <LineChartBarData>[];
    for (final series in trends) {
      final resolvedColor = series.color.solid(context);
      final spots = series.values.isEmpty
          ? const <FlSpot>[]
          : series.values
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value))
                .toList();
      bars.add(
        LineChartBarData(
          spots: spots,
          color: resolvedColor,
          barWidth: 2,
          dotData: FlDotData(
            show: dayCount <= 10,
            getDotPainter: (spot, percent, bar, index) =>
                FlDotCirclePainter(radius: 3, color: resolvedColor),
          ),
          belowBarData: BarAreaData(show: false),
          isCurved: dayCount > 10,
          curveSmoothness: 0.3,
        ),
      );
    }

    // Generate x-axis labels from startDate.
    final labels = _generateDateLabels(dayCount, context);

    // For 30-day range, only show every Nth label to avoid crowding.
    final labelInterval = dayCount <= 7 ? 1.0 : (dayCount / 6).ceilToDouble();

    return FCard.raw(
      child: Container(
        decoration: BoxDecoration(
          color: SemanticColor.neutral.subtle(context),
          borderRadius: BorderRadius.circular(RadiusTokens.level4),
          border: Border.all(color: colors.border),
        ),
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          children: [
            SizedBox(
              height: ResponsiveSizing.scaleByHeight(
                context,
                fraction: 0.22,
                minValue: 144,
                maxValue: 200,
              ),
              child: LineChart(
                LineChartData(
                  minY: minY - span * 0.1,
                  maxY: maxY + span * 0.1,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) =>
                        FlLine(color: colors.border, strokeWidth: 0.5),
                    horizontalInterval: span / 4,
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: span / 4,
                        getTitlesWidget: (value, meta) {
                          // Skip labels that are too close to the edges.
                          if (value == meta.min || value == meta.max) {
                            return const SizedBox.shrink();
                          }
                          // Format: integer if whole, otherwise 1 decimal.
                          final label = value == value.roundToDouble()
                              ? value.round().toString()
                              : value.toStringAsFixed(1);
                          return Padding(
                            padding: const EdgeInsets.only(
                              right: Spacing.level2,
                            ),
                            child: Text(
                              label,
                              style: TypographyToken.level2
                                  .body(context)
                                  .copyWith(color: colors.mutedForeground),
                              maxLines: 1,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: labelInterval,
                        getTitlesWidget: (value, meta) {
                          final index = value.round();
                          if (index < 0 || index >= labels.length) {
                            return const SizedBox.shrink();
                          }
                          // Skip labels that don't fall on the interval.
                          if (labelInterval > 1 &&
                              index % labelInterval.round() != 0 &&
                              index != labels.length - 1) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: Spacing.level2),
                            child: Text(
                              labels[index],
                              style: TypographyToken.level3
                                  .body(context)
                                  .copyWith(color: colors.mutedForeground),
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => colors.card,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final series = trends[spot.barIndex];
                          return LineTooltipItem(
                            '${series.currentValue}${series.unit}',
                            TypographyToken.level3
                                .body(context)
                                .copyWith(
                                  color: series.color.solid(context),
                                  fontWeight: FontWeight.w600,
                                ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: bars,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Generates locale-aware date labels starting from [startDate].
  List<String> _generateDateLabels(int count, BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final parsed = DateTime.tryParse(startDate);
    if (parsed == null) {
      // Fallback: use day offsets (1, 2, 3, ...).
      return List.generate(count, (i) => '${i + 1}');
    }
    final formatter = DateFormat.Md(locale);
    return List.generate(count, (i) {
      final date = parsed.add(Duration(days: i));
      return formatter.format(date);
    });
  }
}

// ---------------------------------------------------------------------------

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
    required this.currentValue,
    required this.unit,
  });

  final SemanticColor color;
  final String label;
  final String currentValue;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: color.solid(context),
            shape: BoxShape.circle,
          ),
          child: const SizedBox.square(dimension: 8),
        ),
        const SizedBox(width: Spacing.level2),
        Text(
          label,
          style: TypographyToken.level3
              .body(context)
              .copyWith(color: colors.mutedForeground),
        ),
        const SizedBox(width: Spacing.level1),
        Text(
          '$currentValue$unit',
          style: TypographyToken.level3
              .body(context)
              .copyWith(
                color: color.solid(context),
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
