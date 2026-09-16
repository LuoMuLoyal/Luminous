import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/record/presentation/models/meal_analysis_view_data.dart';
import 'package:luminous/features/record/presentation/widgets/meal/analysis_status_badge.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 餐食分析结果卡(契约 v2)。
///
/// 三种状态各给一块:
/// - `analyzing`:只显示状态,分析结果由详情页轮询后刷新;
/// - `analysis_failed`:原因码的本地化文案 + 「重新分析」入口(失败不能没有补救手段);
/// - `analyzed`:热量区间卡 + 按重要性排序的全部结论 + 可编辑菜名列表。
///
/// 纯展示组件:重试回调由调用方注入。
class MealAnalysisSummaryCard extends StatelessWidget {
  const MealAnalysisSummaryCard({
    super.key,
    required this.data,
    this.onRetry,
    this.isRetrying = false,
  });

  final MealAnalysisViewData data;

  /// 「重新分析」回调;只在失败态渲染,为空则不显示入口。
  final VoidCallback? onRetry;

  /// 重试请求是否在途(禁用按钮)。
  final bool isRetrying;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.recordMealAnalysisSectionTitle,
                    style: typography.body.md.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                MealAnalysisStatusBadge(status: data.status, large: true),
              ],
            ),
            if (data.isAnalyzing) ...[
              const SizedBox(height: Spacing.md),
              Text(
                l10n.recordMealAnalysisAnalyzingHint,
                style: typography.body.xs.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
              ),
            ],
            if (data.hasFailed) ...[
              const SizedBox(height: Spacing.md),
              Text(
                mealAnalysisFailureCopy(l10n, data.failureReason),
                style: typography.body.sm.copyWith(
                  color: SemanticColor.destructive.solid(context),
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: Spacing.lg),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FButton(
                    key: const Key('meal-analysis-retry-action'),
                    variant: FButtonVariant.outline,
                    onPress: isRetrying ? null : onRetry,
                    prefix: isRetrying
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: FCircularProgress(),
                          )
                        : null,
                    child: Text(l10n.recordMealAnalysisRetryAction),
                  ),
                ),
              ],
            ],
            if (data.calorieRange case final range?) ...[
              const SizedBox(height: Spacing.lg),
              _CalorieRangeCard(range: range),
            ],
            if (data.items.isNotEmpty) ...[
              const SizedBox(height: Spacing.xl),
              _SectionTitle(title: l10n.recordMealAnalysisInsightsTitle),
              SizedBox(height: context.titleContentGap),
              ...data.items.map((item) => _InsightRow(item: item)),
            ],
            if (data.dishes.isNotEmpty) ...[
              const SizedBox(height: Spacing.xl),
              _SectionTitle(title: l10n.recordMealAnalysisDishesTitle),
              SizedBox(height: context.titleContentGap),
              Wrap(
                spacing: Spacing.sm,
                runSpacing: Spacing.sm,
                children: data.dishes
                    .map((dish) => _DishChip(dish: dish))
                    .toList(growable: false),
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                l10n.recordMealAnalysisDishesHint,
                style: typography.body.xs.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 把稳定失败原因码翻成用户可读文案;未知码给通用兜底。
String mealAnalysisFailureCopy(AppLocalizations l10n, String? reasonCode) {
  return switch (reasonCode) {
    'image_count_invalid' => l10n.recordMealAnalysisFailureImageCount,
    'vision_unavailable' => l10n.recordMealAnalysisFailureVisionUnavailable,
    'model_timeout' => l10n.recordMealAnalysisFailureModelTimeout,
    'job_lost' => l10n.recordMealAnalysisFailureJobLost,
    'invalid_output' => l10n.recordMealAnalysisFailureInvalidOutput,
    _ => l10n.recordMealAnalysisFailureModelFailed,
  };
}

class _CalorieRangeCard extends StatelessWidget {
  const _CalorieRangeCard({required this.range});

  final MealCalorieRangeViewData range;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;
    // 档位只作配色语义:低/中用中性,高用提醒色。未知档位回落到中性。
    final color = switch (range.bucket) {
      'high' => SemanticColor.warning,
      _ => SemanticColor.primary,
    };

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: color.muted(context),
        shape: RoundedSuperellipseBorder(
          borderRadius: context.theme.style.borderRadius.sm,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                l10n.recordMealAnalysisCalorieRangeTitle,
                style: typography.body.xs.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
              ),
            ),
            Text(
              // 只给区间,不给单值:份量不确定性决定了单值精度是假的。
              '${range.min}–${range.max} ${l10n.recordMealAnalysisEnergyUnit}',
              style: typography.body.md.copyWith(
                color: color.solid(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({required this.item});

  final MealInsightViewData item;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    final (icon, color) = switch (item.polarity) {
      'good' => (SemanticIcons.statusSuccess, SemanticColor.success),
      'watch' => (SemanticIcons.statusWarning, SemanticColor.warning),
      _ => (SemanticIcons.statusInfo, SemanticColor.neutral),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 16, color: color.solid(context)),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.headline,
                  style: typography.body.sm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  item.detail,
                  style: typography.body.xs.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DishChip extends StatelessWidget {
  const _DishChip({required this.dish});

  final MealDishViewData dish;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    final color = dish.isUserEdited
        ? SemanticColor.primary
        : SemanticColor.neutral;

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: color.muted(context),
        shape: RoundedSuperellipseBorder(
          borderRadius: context.theme.style.borderRadius.xs,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.xs,
        ),
        child: Text(
          dish.name,
          style: typography.body.xs.copyWith(color: color.solid(context)),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.theme.typography.body.md.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
