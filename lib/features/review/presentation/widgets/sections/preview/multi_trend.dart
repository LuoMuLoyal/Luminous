import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/presentation/utils/review_formatters.dart';
import 'package:luminous/features/review/presentation/widgets/shared/section_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 多维度趋势：把多个 [ReviewTrendSeries] 叠在同一张折线图上。
///
/// 与 `ReviewTrendSection`（单维、卡片内 tab 切换）互补：
/// - 单维回答「这一个指标最近怎么走」；
/// - 多维回答「几个指标之间是不是同向变化」——这是需求原文第 5 条
///   「单维度、多维度组件都做」里的后者。
///
/// 各维度单位不同（饮水 ml、睡眠小时、用药百分比），所以**不做同一个 Y 轴**：
/// 每条线各自归一化到自己的 min–max，Y 轴不显示刻度，只保留网格。
/// 图例给出每个维度的当前值，用户据此读绝对值。
///
/// 归一化的代价是「线的绝对高度不代表跨维度的大小」，所以图例必须给出当前值，
/// 底部只用一句话指向图例（HIG：说明性长句不进 UI，能靠布局表达就不写）。
class ReviewMultiTrendSection extends StatelessWidget {
  const ReviewMultiTrendSection({
    super.key,
    required this.trends,
    required this.startDate,
    this.kinds,
  });

  /// 全部可用维度；[kinds] 为空时取有数据的全部维度。
  final List<ReviewTrendSeries> trends;

  /// 数据窗口起始日（ISO），用于 X 轴日期标签。
  final String startDate;

  /// 只展示这些维度；空表示全部。
  final List<ReviewDataKind>? kinds;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selected = _selectedSeries();

    if (selected.isEmpty) {
      return _EmptyMultiTrend(l10n: l10n);
    }

    final dayCount = selected
        .map((series) => series.values.length)
        .reduce((a, b) => a > b ? a : b);
    final labels = _axisLabels(context, dayCount);
    final typography = context.theme.typography;
    final colors = context.theme.colors;

    return Container(
      key: const Key('review-multi-trend-section'),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: context.theme.style.borderRadius.md,
        border: Border.all(color: SemanticColor.neutral.border(context)),
      ),
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.reviewMultiTrendTitle,
            style: typography.body.md.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            l10n.reviewMultiTrendSubtitle,
            style: typography.body.xs.copyWith(
              color: SemanticColor.neutral.solid(context),
            ),
          ),
          const SizedBox(height: Spacing.md),
          _Legend(series: selected, l10n: l10n),
          const SizedBox(height: Spacing.md),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (dayCount - 1).clamp(0, double.infinity).toDouble(),
                minY: 0,
                maxY: 1,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: SemanticColor.neutral.border(context),
                    strokeWidth: 0.5,
                  ),
                  horizontalInterval: 0.25,
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
                  // Y 轴是归一化的相对位置，刻度没有意义。
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: _labelInterval(dayCount),
                      getTitlesWidget: (value, meta) {
                        final index = value.round();
                        if (index < 0 || index >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: Spacing.sm),
                          child: Text(
                            labels[index],
                            style: typography.body.xs.copyWith(
                              color: SemanticColor.neutral.solid(context),
                            ),
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
                        final series = selected[spot.barIndex];
                        final index = spot.spotIndex;
                        final raw = index >= 0 && index < series.values.length
                            ? series.values[index]
                            : null;
                        final valueText = raw == null
                            ? series.currentValue
                            : '${reviewTrendValueLabel(raw)}${series.unit}';
                        return LineTooltipItem(
                          '${reviewMetricTitle(l10n, series.kind)} '
                          '$valueText\n${_dateLabelForIndex(context, index)}',
                          typography.body.xs.copyWith(
                            color: series.color.solid(context),
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  for (final series in selected)
                    LineChartBarData(
                      spots: _normalizedSpots(series.values),
                      color: series.color.solid(context),
                      barWidth: 2,
                      dotData: FlDotData(show: dayCount <= 7),
                      belowBarData: BarAreaData(show: false),
                      isCurved: dayCount > 10,
                      curveSmoothness: 0.3,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            l10n.reviewMultiTrendNormalizedNote,
            style: typography.body.xs.copyWith(
              color: SemanticColor.neutral.solid(context),
            ),
          ),
        ],
      ),
    );
  }

  List<ReviewTrendSeries> _selectedSeries() {
    final wanted = kinds;
    final withData = trends.where((series) => series.values.isNotEmpty);
    if (wanted == null || wanted.isEmpty) return withData.toList();
    return withData.where((series) => wanted.contains(series.kind)).toList();
  }

  /// 每条线各自归一化到 0–1，这样单位不同的维度可以同图比较「形状」。
  List<FlSpot> _normalizedSpots(List<double> values) {
    if (values.isEmpty) return const [];
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final span = max - min;
    return [
      for (var i = 0; i < values.length; i++)
        FlSpot(
          i.toDouble(),
          // 全平的一条线：画在中线，而不是贴底。
          span < 0.0001 ? 0.5 : (values[i] - min) / span,
        ),
    ];
  }

  List<String> _axisLabels(BuildContext context, int dayCount) {
    final start = DateTime.tryParse(startDate);
    if (start == null) {
      return List.generate(dayCount, (index) => '${index + 1}');
    }
    return List.generate(dayCount, (index) {
      final date = start.add(Duration(days: index));
      final iso = date.toIso8601String();
      return reviewShortDateLabel(context, iso);
    });
  }

  String _dateLabelForIndex(BuildContext context, int index) {
    final start = DateTime.tryParse(startDate);
    if (start == null) return '${index + 1}';
    return reviewShortDateLabel(
      context,
      start.add(Duration(days: index)).toIso8601String(),
    );
  }

  double _labelInterval(int dayCount) {
    if (dayCount <= 7) return 1;
    if (dayCount <= 14) return 2;
    return (dayCount / 6).ceilToDouble();
  }
}

/// 图例：色点 + 维度名 + 当前值。
///
/// 归一化之后线的绝对高度不可读，绝对值必须在这里给出。
class _Legend extends StatelessWidget {
  const _Legend({required this.series, required this.l10n});

  final List<ReviewTrendSeries> series;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return Wrap(
      spacing: Spacing.md,
      runSpacing: Spacing.sm,
      children: [
        for (final item in series)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: item.color.solid(context),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                '${reviewMetricTitle(l10n, item.kind)} '
                '${item.currentValue}${item.unit}',
                style: typography.body.xs,
              ),
            ],
          ),
      ],
    );
  }
}

class _EmptyMultiTrend extends StatelessWidget {
  const _EmptyMultiTrend({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return FCard(
      key: const Key('review-multi-trend-empty'),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.reviewTrendEmptyTitle,
              style: context.theme.typography.body.md,
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              l10n.reviewTrendEmptyBody,
              style: context.theme.typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
