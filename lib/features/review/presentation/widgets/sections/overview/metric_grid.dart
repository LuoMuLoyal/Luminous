import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/presentation/utils/icons.dart';
import 'package:luminous/features/review/presentation/widgets/shared/section_models.dart'
    show reviewMetricTitle;
import 'package:luminous/l10n/app_localizations.dart';

/// 指标网格：每个维度一张小卡，按可用宽度铺成 2 / 3 列。
///
/// 与 [ReviewCoverageStrip] 的分工：
/// - **strip** 是横向可滚动的一行，用于首屏概览——它假设用户只扫一眼；
/// - **grid** 是固定网格，一次看全所有维度、不横向滚动，用于「我想通读一遍」。
///
/// 两者读同一份 `metrics`，不各自取数：数据一致性由组件外部的 provider 保证，
/// 这里只决定排版。
///
/// 为什么不用 [`GridView`]：组件挂在 `ComponentHost` 的纵向滚动容器里，嵌套
/// 一个可滚动网格要么需要固定高度、要么会与外层抢手势。这里用 `Wrap` 按列宽
/// 换行——网格的视觉结果一样，但不引入第二个滚动轴。
class ReviewMetricGridSection extends StatelessWidget {
  const ReviewMetricGridSection({super.key, required this.metrics, this.onTap});

  /// 当前周期的各维度指标。
  final List<ReviewMetric> metrics;

  /// 点击某维度卡片的回调；null 时卡片只读。
  final ValueChanged<ReviewDataKind>? onTap;

  /// 窄屏 2 列、宽屏 3 列的断点。
  ///
  /// 用 `Spacing` 能表达的最小值而不是新造数字：两列各 148 宽 + 间距正好落在
  /// 360dp 内，这不是设计变量，而是「卡片最小可读宽度」的推导结果。
  static const _minCardWidth = 148.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (metrics.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reviewMetricGridTitle,
          style: context.theme.typography.body.md.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: Spacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            // 按可用宽度决定列数：能放下 3 张就 3 列，否则 2 列。不做 1 列——
            // 单列会让「网格」退化成列表，那时用户该用别的组件。
            final columns =
                constraints.maxWidth >= _minCardWidth * 3 + Spacing.md * 2
                ? 3
                : 2;
            final cardWidth =
                (constraints.maxWidth - Spacing.md * (columns - 1)) / columns;
            return Wrap(
              spacing: Spacing.md,
              runSpacing: Spacing.md,
              children: [
                for (final metric in metrics)
                  SizedBox(
                    width: cardWidth,
                    child: _MetricGridCard(
                      key: Key('review-metric-grid-card-${metric.kind.name}'),
                      metric: metric,
                      onTap: onTap,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _MetricGridCard extends StatelessWidget {
  const _MetricGridCard({super.key, required this.metric, required this.onTap});

  final ReviewMetric metric;
  final ValueChanged<ReviewDataKind>? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;
    final observed = metric.observedMetric;

    // 与 strip 同一套「数据是否够画一条结论」的判定：判据只该有一处，
    // 两处各写一份会让同一份数据在两张卡上给出不同结论。
    final sparse =
        observed == null ||
        observed.coverage ==
            ReviewObservedMetricCoverage
                .none || // tracked-by-TODO-ignore-deprecated-metric-migration
        observed.observedCount < 2;

    final card = FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  reviewIcon(metric.iconName),
                  size: IconSizeTokens.sm,
                  color: sparse
                      ? SemanticColor.neutral.solid(context)
                      : metric.color.solid(context),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    reviewMetricTitle(l10n, metric.kind),
                    style: typography.body.xs.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              sparse ? '--' : '${metric.value}${metric.unit}',
              style: typography.body.md.copyWith(fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (!sparse) ...[
              const SizedBox(height: Spacing.xs),
              Text(
                metric.delta,
                style: typography.body.xs.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );

    if (onTap == null) return card;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap!(metric.kind),
      child: card,
    );
  }
}
