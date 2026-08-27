import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/presentation/widgets/shared/section_models.dart';
import 'package:luminous/features/review/presentation/widgets/shared/top_bar.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReviewTrendSection extends StatelessWidget {
  const ReviewTrendSection({
    super.key,
    required this.trends,
    required this.selectedQuery,
    required this.onQueryChanged,
    required this.l10n,
    required this.startDate,
    this.showRangePill = true,
  });

  final List<ReviewTrendSeries> trends;
  final ReviewDashboardQuery selectedQuery;
  final ValueChanged<ReviewDashboardQuery> onQueryChanged;
  final AppLocalizations l10n;
  final String startDate;
  final bool showRangePill;

  @override
  Widget build(BuildContext context) {
    final allEmpty = trends.isEmpty || _allSeriesEmpty(trends);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                l10n.reviewTrendSectionTitle,
                style: TypographyToken.level5
                    .body(context)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (showRangePill)
              ReviewRangeMenu(
                selectedQuery: selectedQuery,
                onQueryChanged: onQueryChanged,
              ),
          ],
        ),
        const SizedBox(height: Spacing.level4),
        Semantics(
          label: _buildSemanticsLabel(l10n),
          child: allEmpty
              ? _TrendEmptyState(l10n: l10n)
              : _TrendTabs(trends: trends, startDate: startDate, l10n: l10n),
        ),
      ],
    );
  }

  String _buildSemanticsLabel(AppLocalizations l10n) {
    final parts = <String>[l10n.reviewTrendSectionTitle];
    for (final series in trends) {
      parts.add(
        '${reportMetricTitle(l10n, series.kind)}: ${series.currentValue}${series.unit}',
      );
    }
    return parts.join(', ');
  }
}

// ---------------------------------------------------------------------------
// Tabs-based metric selector + single-line chart

class _TrendTabs extends StatelessWidget {
  const _TrendTabs({
    required this.trends,
    required this.startDate,
    required this.l10n,
  });

  final List<ReviewTrendSeries> trends;
  final String startDate;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return FTabs(
      children: [
        for (final series in trends)
          FTabEntry(
            label: Text(reportMetricTitle(l10n, series.kind)),
            child: _SingleTrendChart(
              series: series,
              startDate: startDate,
              l10n: l10n,
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Single-line chart for one metric — shows actual Y-axis values

class _SingleTrendChart extends StatelessWidget {
  const _SingleTrendChart({
    required this.series,
    required this.startDate,
    required this.l10n,
  });

  final ReviewTrendSeries series;
  final String startDate;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final values = series.values;

    // Empty state for this specific metric.
    if (values.isEmpty || values.every((v) => v == 0)) {
      return _TrendEmptyState(l10n: l10n);
    }

    final resolvedColor = series.color.solid(context);
    final dayCount = values.length;

    final spots = values
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    // Use actual data range for Y axis with a small padding.
    final dataMin = values.reduce((a, b) => a < b ? a : b);
    final dataMax = values.reduce((a, b) => a > b ? a : b);
    final dataSpan = (dataMax - dataMin).abs() < 0.001
        ? dataMax.abs() < 0.001
              ? 1.0
              : dataMax
        : (dataMax - dataMin);
    final yPadding = dataSpan * 0.15;
    final minY = (dataMin - yPadding).clamp(0.0, double.infinity);
    final maxY = dataMax + yPadding;

    final labels = _generateDateLabels(dayCount, context);
    final labelInterval = dayCount <= 7 ? 1.0 : (dayCount / 6).ceilToDouble();

    return FCard(
      child: Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(RadiusTokens.level4),
          border: Border.all(color: colors.border),
        ),
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current value summary row
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${series.currentValue}${series.unit}',
                  style: TypographyToken.level7
                      .display(context)
                      .copyWith(
                        color: resolvedColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.level3),
            SizedBox(
              height: ResponsiveSizing.scaleByHeight(
                context,
                fraction: 0.22,
                minValue: 144,
                maxValue: 200,
              ),
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (dayCount - 1).toDouble(),
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) =>
                        FlLine(color: colors.border, strokeWidth: 0.5),
                    horizontalInterval: dataSpan < 0.001 ? 1.0 : dataSpan / 4,
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
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
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
                          final index = spot.spotIndex;
                          final value = index >= 0 && index < values.length
                              ? values[index]
                              : null;
                          final dateLabel = _dateLabelForIndex(index, context);
                          final valueText = value != null
                              ? '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)}${series.unit}'
                              : series.currentValue;
                          return LineTooltipItem(
                            '$valueText\n$dateLabel',
                            TypographyToken.level3
                                .body(context)
                                .copyWith(
                                  color: resolvedColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      color: resolvedColor,
                      barWidth: 2,
                      dotData: FlDotData(
                        show: dayCount <= 10,
                        getDotPainter: (spot, percent, bar, index) =>
                            FlDotCirclePainter(radius: 3, color: resolvedColor),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: resolvedColor.withValues(alpha: 0.08),
                      ),
                      isCurved: dayCount > 10,
                      curveSmoothness: 0.3,
                    ),
                  ],
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
      return List.generate(count, (i) => '${i + 1}');
    }
    final formatter = DateFormat.Md(locale);
    return List.generate(count, (i) {
      final date = parsed.add(Duration(days: i));
      return formatter.format(date);
    });
  }

  /// Returns a locale-aware date label for a specific chart index.
  String _dateLabelForIndex(int index, BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final parsed = DateTime.tryParse(startDate);
    if (parsed == null || index < 0) return '';
    final date = parsed.add(Duration(days: index));
    return DateFormat.MMMEd(locale).format(date);
  }
}

// ---------------------------------------------------------------------------
// Shared empty-state card

class _TrendEmptyState extends StatelessWidget {
  const _TrendEmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FCard(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.level4,
            vertical: Spacing.level8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                SemanticIcons.reportChart,
                size: Spacing.level8,
                color: colors.mutedForeground,
              ),
              const SizedBox(height: Spacing.level3),
              Text(
                l10n.reviewTrendEmptyTitle,
                style: TypographyToken.level5
                    .body(context)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: Spacing.level1),
              Text(
                l10n.reviewTrendEmptyBody,
                style: TypographyToken.level3
                    .body(context)
                    .copyWith(color: colors.mutedForeground),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers

/// Checks whether all trend series have no meaningful data (empty values).
bool _allSeriesEmpty(List<ReviewTrendSeries> trends) {
  if (trends.isEmpty) return true;
  return trends.every(
    (series) => series.values.isEmpty || series.values.every((v) => v == 0),
  );
}
