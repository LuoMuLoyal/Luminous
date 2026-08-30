import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/review/domain/entities/review.dart';
import 'package:luminous/features/review/presentation/utils/review_formatters.dart';
import 'package:luminous/features/review/presentation/widgets/shared/review_section_card.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 「有什么变化」段落：只描述观察到的变化趋势，不做因果推断。
///
/// 契约 fact code 为 `observed_changes`，包含三个可空维度：
/// - `checkIns`：首次与最近一次结果确认之间的变化方向；
/// - `water` / `sleep`：单维度数值趋势（ml / 小时）。
/// 全部为空时后端不会返回 available；客户端仍做防御，降级为缺失原因。
class KeyChangesSection extends StatelessWidget {
  const KeyChangesSection({super.key, required this.section});

  final ReviewSection section;

  static const factCodeObservedChanges = 'observed_changes';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final facts = section.facts;
    final isAvailable =
        section.state == ReviewSectionState.available &&
        facts != null &&
        facts.code == factCodeObservedChanges;

    if (!isAvailable) {
      return ReviewSectionCard(
        key: const Key('review-key-changes-section'),
        icon: SemanticIcons.reportTrend,
        title: l10n.reviewReviewSectionKeyChanges,
        child: ReviewUnknownReason(
          reason: reviewReasonLabel(l10n, section.reasonCode),
        ),
      );
    }

    final args = facts.arguments;
    final checkIns = reviewArgMap(args, 'checkIns');
    final water = reviewArgMap(args, 'water');
    final sleep = reviewArgMap(args, 'sleep');

    final rows = <Widget>[
      if (checkIns != null) _outcomeTrendRow(context, l10n, checkIns),
      if (water != null)
        _numericTrendRow(
          context,
          l10n,
          title: l10n.reviewReviewChangeWaterTitle,
          trend: water,
          unit: l10n.reviewReviewChangeUnitMl,
        ),
      if (sleep != null)
        _numericTrendRow(
          context,
          l10n,
          title: l10n.reviewReviewChangeSleepTitle,
          trend: sleep,
          unit: l10n.reviewReviewChangeUnitHour,
          fractionDigits: 1,
        ),
    ];

    return ReviewSectionCard(
      key: const Key('review-key-changes-section'),
      icon: SemanticIcons.reportTrend,
      title: l10n.reviewReviewSectionKeyChanges,
      child: rows.isEmpty
          ? ReviewUnknownReason(reason: l10n.reviewReviewReasonUnknown)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rows,
            ),
    );
  }

  Widget _outcomeTrendRow(
    BuildContext context,
    AppLocalizations l10n,
    Map<String, dynamic> trend,
  ) {
    final from = reviewOutcomeFromArg(reviewArgString(trend, 'fromOutcome'));
    final to = reviewOutcomeFromArg(reviewArgString(trend, 'toOutcome'));
    final count = reviewArgInt(trend, 'count');

    return _TrendRow(
      title: l10n.reviewReviewChangeOutcomeTitle,
      chipLabel: reviewOutcomeLabel(l10n, to),
      chipTone: switch (to) {
        ReviewEventOutcome.improved => SemanticColor.success,
        ReviewEventOutcome.unchanged => SemanticColor.neutral,
        ReviewEventOutcome.worsened => SemanticColor.warning,
        ReviewEventOutcome.unknown => SemanticColor.neutral,
      },
      detail: l10n.reviewReviewChangeOutcomeDetail(
        reviewOutcomeLabel(l10n, from),
        reviewOutcomeLabel(l10n, to),
        count,
      ),
    );
  }

  Widget _numericTrendRow(
    BuildContext context,
    AppLocalizations l10n, {
    required String title,
    required Map<String, dynamic> trend,
    required String unit,
    int fractionDigits = 0,
  }) {
    final direction = reviewArgString(trend, 'direction');
    final firstValue = reviewArgNum(trend, 'firstValue');
    final lastValue = reviewArgNum(trend, 'lastValue');
    final days = reviewArgInt(trend, 'observedDays');

    return _TrendRow(
      title: title,
      chipLabel: reviewTrendDirectionLabel(l10n, direction),
      chipTone: switch (direction) {
        'up' => SemanticColor.primary,
        'down' => SemanticColor.warning,
        _ => SemanticColor.neutral,
      },
      detail: l10n.reviewReviewChangeNumericDetail(
        reviewTrendValueLabel(firstValue, fractionDigits: fractionDigits),
        reviewTrendValueLabel(lastValue, fractionDigits: fractionDigits),
        unit,
        days,
      ),
    );
  }
}

class _TrendRow extends StatelessWidget {
  const _TrendRow({
    required this.title,
    required this.chipLabel,
    required this.chipTone,
    required this.detail,
  });

  final String title;
  final String chipLabel;
  final SemanticColor chipTone;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.level3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TypographyToken.level4
                      .body(context)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: chipTone.muted(context),
                  borderRadius: context.theme.style.borderRadius.pill,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.level3,
                    vertical: Spacing.level1,
                  ),
                  child: Text(
                    chipLabel,
                    style: TypographyToken.level2
                        .body(context)
                        .copyWith(
                          color: chipTone.solid(context),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.level1),
          Text(
            detail,
            style: TypographyToken.level3
                .body(context)
                .copyWith(color: colors.mutedForeground),
          ),
        ],
      ),
    );
  }
}
