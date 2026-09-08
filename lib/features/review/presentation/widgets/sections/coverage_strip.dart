import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show OrdinalSortKey;
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/presentation/widgets/shared/section_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// ① 覆盖率概览行：每维度一张紧凑小卡，横向可滑动。
///
/// 展示当前周期内各健康维度的记录覆盖率（有记录天数 / 范围天数）与最新
/// 值与变化方向，让用户先在顶部感知"这周期记录得到底够不够、值怎么变"，
/// 再看下方值得注意/趋势。点击小卡可将下方单维趋势卡切到该维度（[onTap]）。
class ReviewCoverageStrip extends StatelessWidget {
  const ReviewCoverageStrip({super.key, required this.metrics, this.onTap});

  /// 当前周期的各维度指标。指标为主路径 dashboard 的 metrics 列表。
  final List<ReviewMetric> metrics;

  /// 点击某维度小卡的回调（切下方趋势维度 / 可选滚动定位）；null 时卡片
  /// 只读。
  final ValueChanged<ReviewDataKind>? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (metrics.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reviewTrendSectionTitle,
          style: context.theme.typography.body.md.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: Spacing.level3),
        Semantics(
          container: true,
          explicitChildNodes: true,
          sortKey: const OrdinalSortKey(0.1),
          child: SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: metrics.length,
              separatorBuilder: (_, _) => const SizedBox(width: Spacing.level3),
              itemBuilder: (context, index) {
                final metric = metrics[index];
                return _CoverageCard(
                  key: Key('review-coverage-card-${metric.kind.name}'),
                  metric: metric,
                  onTap: onTap,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _CoverageCard extends StatelessWidget {
  const _CoverageCard({super.key, required this.metric, required this.onTap});

  final ReviewMetric metric;
  final ValueChanged<ReviewDataKind>? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;
    final observed = metric.observedMetric;
    final sparse =
        observed == null ||
        observed.coverage ==
            ReviewObservedMetricCoverage
                .none || // tracked-by-TODO-ignore-deprecated-metric-migration
        observed.observedCount < 2;

    final coverageLabel = sparse
        ? l10n.reviewCoverageSparseLabel
        : l10n.reviewCoverageDaysCount(
            observed.observedCount,
            observed.expectedCount ?? observed.observedCount,
          );

    final card = FCard(
      style: const FCardStyleDelta.delta(
        padding: EdgeInsetsGeometryDelta.value(EdgeInsets.zero),
      ),
      child: SizedBox(
        width: 148,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.level3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    metric.icon,
                    size: Spacing.level4,
                    color: sparse
                        ? SemanticColor.neutral.solid(context)
                        : metric.color.solid(context),
                  ),
                  const SizedBox(width: Spacing.level2),
                  Expanded(
                    child: Text(
                      reviewMetricTitle(l10n, metric.kind),
                      style: typography.body.xs.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.level2),
              Text(
                coverageLabel,
                style: typography.body.xs.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: Spacing.level1),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      sparse ? '--' : '${metric.value}${metric.unit}',
                      style: typography.body.md.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (metric.delta.isNotEmpty && metric.delta != '--')
                    _DeltaLabel(metric: metric),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (onTap == null) return card;
    return Semantics(
      button: true,
      child: FTappable(onPress: () => onTap!(metric.kind), child: card),
    );
  }
}

class _DeltaLabel extends StatelessWidget {
  const _DeltaLabel({required this.metric});

  final ReviewMetric metric;

  @override
  Widget build(BuildContext context) {
    final color = switch (metric.direction) {
      ReviewMetricDirection.up => SemanticColor.success,
      ReviewMetricDirection.down => SemanticColor.warning,
      ReviewMetricDirection.flat => SemanticColor.neutral,
    };
    return Padding(
      padding: const EdgeInsets.only(left: Spacing.level2),
      child: Text(
        metric.delta,
        style: context.theme.typography.body.xs.copyWith(
          color: color.solid(context),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
