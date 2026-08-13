import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/report/domain/entities/review.dart';
import 'package:luminous/features/report/presentation/utils/review_formatters.dart';
import 'package:luminous/features/report/presentation/widgets/shared/constrained_action_button.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 回顾首屏的事件头部：标题、进行中/已结束状态、观察时段与关联用药。
///
/// - active 事件：可用且今天尚未确认时提供今日 check-in，同时保留结束入口；
/// - ended 事件：展示用户确认的结果（outcome），不提供 check-in。
class EventHeaderSection extends StatelessWidget {
  const EventHeaderSection({
    super.key,
    required this.event,
    required this.todayCheckIn,
    required this.showCheckInAction,
    required this.showEndAction,
    required this.onCheckIn,
    required this.onEndEvent,
  });

  final ReviewEvent event;
  final ReviewTodayCheckIn? todayCheckIn;
  final bool showCheckInAction;
  final bool showEndAction;
  final VoidCallback onCheckIn;
  final VoidCallback onEndEvent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    final isActive = event.status == ReviewEventStatus.active;
    final canCheckIn = isActive && showCheckInAction && todayCheckIn == null;

    return FCard(
      key: const Key('review-event-header'),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 事件标题在最前：TalkBack/VoiceOver 语义顺序与视觉一致，
            // 先读标题再读状态/结果（Task 9 a11y 顺序校验）。
            Text(
              event.title,
              style: TypographyToken.level6
                  .display(context)
                  .copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: Spacing.level3),
            Row(
              children: [
                // chip 参与 flex 收缩：英文等长文案下避免与结束按钮同行
                // 溢出（RenderFlex overflow 回归，Task 9 en 矩阵）。
                Flexible(
                  child: _ReviewStatusChip(
                    key: const Key('review-event-status-chip'),
                    label: switch (event.status) {
                      ReviewEventStatus.active => l10n.reportReviewStatusActive,
                      ReviewEventStatus.ended => l10n.reportReviewStatusEnded,
                      ReviewEventStatus.unknown =>
                        l10n.reportReviewStatusUnknown,
                    },
                    tone: isActive
                        ? SemanticColor.primary
                        : SemanticColor.neutral,
                  ),
                ),
                const Spacer(),
                if (isActive && showEndAction)
                  FButton(
                    key: const Key('review-end-event-action'),
                    variant: FButtonVariant.ghost,
                    size: FButtonSizeVariant.sm,
                    onPress: onEndEvent,
                    child: Text(l10n.reportReviewEndEventAction),
                  ),
              ],
            ),
            const SizedBox(height: Spacing.level2),
            Text(
              reviewEventKindLabel(l10n, event.kind),
              style: TypographyToken.level3
                  .body(context)
                  .copyWith(color: colors.mutedForeground),
            ),
            const SizedBox(height: Spacing.level2),
            Text(
              l10n.reportReviewStartedLabel(
                reviewShortDateLabel(context, event.startedAt),
              ),
              style: TypographyToken.level3
                  .body(context)
                  .copyWith(color: colors.mutedForeground),
            ),
            if (event.endedAt != null) ...[
              const SizedBox(height: Spacing.level1),
              Text(
                l10n.reportReviewEndedLabel(
                  reviewShortDateLabel(context, event.endedAt!),
                ),
                style: TypographyToken.level3
                    .body(context)
                    .copyWith(color: colors.mutedForeground),
              ),
            ],
            if (event.currentMedicineIds.isNotEmpty) ...[
              const SizedBox(height: Spacing.level1),
              Text(
                l10n.reportReviewMedicineCountLabel(
                  event.currentMedicineIds.length,
                ),
                style: TypographyToken.level3
                    .body(context)
                    .copyWith(color: colors.mutedForeground),
              ),
            ],
            if (!isActive && event.outcome != null) ...[
              const SizedBox(height: Spacing.level3),
              Row(
                children: [
                  Text(
                    l10n.reportReviewOutcomeLabel,
                    style: TypographyToken.level3
                        .body(context)
                        .copyWith(color: colors.mutedForeground),
                  ),
                  const SizedBox(width: Spacing.level2),
                  _ReviewStatusChip(
                    label: reviewOutcomeLabel(l10n, event.outcome!),
                    tone: _outcomeTone(event.outcome!),
                  ),
                ],
              ),
            ],
            if (canCheckIn) ...[
              const SizedBox(height: Spacing.level4),
              ConstrainedActionButton(
                key: const Key('review-check-in-action'),
                onPress: onCheckIn,
                label: l10n.reportReviewCheckInAction,
              ),
            ] else if (isActive && todayCheckIn != null) ...[
              const SizedBox(height: Spacing.level3),
              Text(
                l10n.reportReviewCheckInDoneToday(
                  reviewOutcomeLabel(l10n, todayCheckIn!.outcome),
                ),
                style: TypographyToken.level3
                    .body(context)
                    .copyWith(color: colors.mutedForeground),
              ),
            ],
          ],
        ),
      ),
    );
  }

  SemanticColor _outcomeTone(ReviewEventOutcome outcome) {
    return switch (outcome) {
      ReviewEventOutcome.improved => SemanticColor.success,
      ReviewEventOutcome.unchanged => SemanticColor.neutral,
      ReviewEventOutcome.worsened => SemanticColor.warning,
      ReviewEventOutcome.unknown => SemanticColor.neutral,
    };
  }
}

/// 状态/结果徽标：带色调的小圆角 chip，非告警语义。
class _ReviewStatusChip extends StatelessWidget {
  const _ReviewStatusChip({super.key, required this.label, required this.tone});

  final String label;
  final SemanticColor tone;

  @override
  Widget build(BuildContext context) {
    final color = tone.solid(context);
    final background = tone.muted(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(RadiusTokens.levelFull),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level3,
          vertical: Spacing.level1,
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TypographyToken.level2
              .body(context)
              .copyWith(color: color, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
