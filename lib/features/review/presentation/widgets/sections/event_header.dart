import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/review/domain/entities/review.dart';
import 'package:luminous/features/review/presentation/utils/review_formatters.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 回顾首屏的事件头部（被动展示）。
///
/// P0-6：check-in / end 动作从 review 主路径移除（动作收口 Today），此头部
/// 只做信息呈现：active 事件渲染紧凑被动卡（标题、状态 chip、已进行天数、
/// 今日是否已确认一行 + 「去今日 check-in」浅链接切 today tab）；ended 事件
/// 保留结果/时段展示，不含任何动作。完整四段回顾仍走 `/review/:eventId`
/// 详情页。
class EventHeaderSection extends StatelessWidget {
  const EventHeaderSection({
    super.key,
    required this.event,
    required this.todayCheckIn,
    required this.onGoTodayCheckIn,
  });

  final ReviewEvent event;
  final ReviewTodayCheckIn? todayCheckIn;

  /// 「去今日 check-in」浅链接回调（页面层切 today tab）。
  final VoidCallback onGoTodayCheckIn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isActive = event.status == ReviewEventStatus.active;
    final typography = context.theme.typography;
    final started = DateTime.tryParse(event.startedAt)?.toLocal();
    final elapsedDays = started == null
        ? null
        : DateTime.now().difference(started).inDays + 1;

    return FCard(
      key: const Key('review-event-header'),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 事件标题在最前：TalkBack/VoiceOver 语义顺序与视觉一致。
            Text(
              event.title,
              style: typography.display.lg.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: Spacing.level3),
            Row(
              children: [
                Flexible(
                  child: _ReviewStatusChip(
                    key: const Key('review-event-status-chip'),
                    label: switch (event.status) {
                      ReviewEventStatus.active => l10n.reviewReviewStatusActive,
                      ReviewEventStatus.ended => l10n.reviewReviewStatusEnded,
                      ReviewEventStatus.unknown =>
                        l10n.reviewReviewStatusUnknown,
                    },
                    tone: isActive
                        ? SemanticColor.primary
                        : SemanticColor.neutral,
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: Spacing.level2),
            Text(
              reviewEventKindLabel(l10n, event.kind),
              style: typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
            if (isActive && elapsedDays != null) ...[
              const SizedBox(height: Spacing.level2),
              Text(
                l10n.reviewActiveEventElapsedDays(elapsedDays),
                style: typography.body.xs.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
              ),
            ],
            const SizedBox(height: Spacing.level2),
            Text(
              l10n.reviewReviewStartedLabel(
                reviewShortDateLabel(context, event.startedAt),
              ),
              style: typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
            if (event.endedAt != null) ...[
              const SizedBox(height: Spacing.level1),
              Text(
                l10n.reviewReviewEndedLabel(
                  reviewShortDateLabel(context, event.endedAt!),
                ),
                style: typography.body.xs.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
              ),
            ],
            if (event.currentMedicineIds.isNotEmpty) ...[
              const SizedBox(height: Spacing.level1),
              Text(
                l10n.reviewReviewMedicineCountLabel(
                  event.currentMedicineIds.length,
                ),
                style: typography.body.xs.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
              ),
            ],
            if (!isActive && event.outcome != null) ...[
              const SizedBox(height: Spacing.level3),
              Row(
                children: [
                  Text(
                    l10n.reviewReviewOutcomeLabel,
                    style: typography.body.xs.copyWith(
                      color: SemanticColor.neutral.solid(context),
                    ),
                  ),
                  const SizedBox(width: Spacing.level2),
                  _ReviewStatusChip(
                    label: reviewOutcomeLabel(l10n, event.outcome!),
                    tone: _outcomeTone(event.outcome!),
                  ),
                ],
              ),
            ],
            if (isActive) ...[
              const SizedBox(height: Spacing.level3),
              if (todayCheckIn != null)
                Text(
                  l10n.reviewReviewCheckInDoneToday(
                    reviewOutcomeLabel(l10n, todayCheckIn!.outcome),
                  ),
                  style: typography.body.xs.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                )
              else
                // 今日尚未确认：浅链接切到 today tab 自行呈现 check-in。
                FButton(
                  key: const Key('review-go-today-check-in'),
                  variant: FButtonVariant.ghost,
                  size: FButtonSizeVariant.sm,
                  onPress: onGoTodayCheckIn,
                  // Forui 按钮内部 Row 对大字号不收缩，包一层 Expanded 让其
                  // 受约束并省略号截断，避免长文本横溢。
                  child: Expanded(
                    child: Text(
                      l10n.reviewActiveEventGoTodayCheckIn,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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
        borderRadius: context.theme.style.borderRadius.pill,
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
          style: context.theme.typography.body.xs2.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
