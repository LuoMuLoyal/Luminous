import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/review/presentation/widgets/shared/constrained_action_button.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// P0-5 冷启动/记录引导卡：无进行中事件且当前周期数据过稀时，引导用户
/// 去 record 补记，而不是展示「开始观察」动作（事件动作收口 Today）。
///
/// 顶部展示本周已记录 X/N 天（来自 reviewDashboard observedMetric 整体
/// 覆盖），下接「去记录」入口跳 record tab；下方仍保留事件历史与 preview
/// 教育。
class ReviewRecordGuideSection extends StatelessWidget {
  const ReviewRecordGuideSection({
    super.key,
    required this.observedCount,
    required this.expectedCount,
    required this.onGoRecord,
  });

  /// 当前周期有覆盖记录的天数（observedMetric.observedCount）。
  final int observedCount;

  /// 当前周期范围天数（observedMetric.expectedCount，null 时回退）。
  final int expectedCount;

  /// 「去记录」回调（页面层切 record tab）。
  final VoidCallback onGoRecord;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;
    final expected = expectedCount > 0 ? expectedCount : observedCount;
    final description = expected == 0 && observedCount == 0
        ? l10n.reviewRecordGuideEmptyRangeDescription
        : l10n.reviewRecordGuideDescription(observedCount, expected);
    return FCard(
      key: const Key('review-record-guide-card'),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  SemanticIcons.tabRecord,
                  size: IconSizeTokens.level3,
                  color: SemanticColor.primary.solid(context),
                ),
                const SizedBox(width: Spacing.level3),
                Expanded(
                  child: Text(
                    l10n.reviewRecordGuideTitle,
                    style: typography.body.md.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.level2),
            Text(
              description,
              style: typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
            const SizedBox(height: Spacing.level4),
            ConstrainedActionButton(
              key: const Key('review-record-guide-action'),
              onPress: onGoRecord,
              label: l10n.reviewRecordGuideGoRecordAction,
            ),
          ],
        ),
      ),
    );
  }
}
