import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/divider.dart';
import 'package:luminous/features/report/domain/entities/review.dart';
import 'package:luminous/features/report/presentation/utils/review_formatters.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 过去的观察历史：按事件逐条列出（最近在前），不按月份分组。
///
/// 列表项只读展示事件头部信息；点开查看完整回顾属于后续任务。
/// 历史加载失败不阻塞首屏——卡片内显示一行提示 + 轻量重试入口。
class ReviewHistorySection extends StatelessWidget {
  const ReviewHistorySection({super.key, required this.history, this.onRetry});

  final AsyncValue<ReviewEventPage> history;

  /// 历史加载失败时的重试回调（由页面装配层 invalidate history provider）。
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FCard(
      key: const Key('review-history-section'),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ExcludeSemantics(
                  child: Icon(
                    SemanticIcons.reportHistory,
                    size: Spacing.level5,
                    color: context.theme.colors.primary,
                  ),
                ),
                const SizedBox(width: Spacing.level3),
                Expanded(
                  child: Text(
                    l10n.reportReviewHistoryTitle,
                    style: TypographyToken.level5
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.level3),
            history.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: Spacing.level3),
                child: Center(child: FProgress()),
              ),
              error: (_, __) => Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.reportReviewHistoryLoadFailed,
                      style: TypographyToken.level3
                          .body(context)
                          .copyWith(
                            color: context.theme.colors.mutedForeground,
                          ),
                    ),
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(width: Spacing.level3),
                    FButton(
                      key: const Key('review-history-retry'),
                      variant: FButtonVariant.outline,
                      size: FButtonSizeVariant.sm,
                      onPress: onRetry,
                      child: Text(l10n.todayRetryAction),
                    ),
                  ],
                ],
              ),
              data: (page) => page.items.isEmpty
                  ? Text(
                      l10n.reportReviewHistoryEmpty,
                      style: TypographyToken.level3
                          .body(context)
                          .copyWith(
                            color: context.theme.colors.mutedForeground,
                          ),
                    )
                  : Column(
                      children: [
                        for (final (index, event) in page.items.indexed) ...[
                          if (index > 0) const AppDivider(),
                          _HistoryEventRow(event: event),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryEventRow extends StatelessWidget {
  const _HistoryEventRow({required this.event});

  final ReviewEvent event;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    final isActive = event.status == ReviewEventStatus.active;
    final endLabel = event.endedAt != null
        ? reviewShortDateLabel(context, event.endedAt!)
        : l10n.reportReviewWindowUntilNow;

    return Padding(
      key: Key('review-history-item-${event.id}'),
      padding: const EdgeInsets.symmetric(vertical: Spacing.level2),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TypographyToken.level4
                      .body(context)
                      .copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Spacing.level1),
                Text(
                  '${reviewShortDateLabel(context, event.startedAt)} – $endLabel',
                  style: TypographyToken.level3
                      .body(context)
                      .copyWith(color: colors.mutedForeground),
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.level3),
          if (isActive)
            _HistoryStatusChip(
              label: l10n.reportReviewStatusActive,
              tone: SemanticColor.primary,
            )
          else if (event.outcome != null)
            _HistoryStatusChip(
              label: reviewOutcomeLabel(l10n, event.outcome!),
              tone: switch (event.outcome!) {
                ReviewEventOutcome.improved => SemanticColor.success,
                ReviewEventOutcome.unchanged => SemanticColor.neutral,
                ReviewEventOutcome.worsened => SemanticColor.warning,
                ReviewEventOutcome.unknown => SemanticColor.neutral,
              },
            ),
        ],
      ),
    );
  }
}

class _HistoryStatusChip extends StatelessWidget {
  const _HistoryStatusChip({required this.label, required this.tone});

  final String label;
  final SemanticColor tone;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tone.muted(context),
        borderRadius: BorderRadius.circular(RadiusTokens.levelFull),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level3,
          vertical: Spacing.level1,
        ),
        child: Text(
          label,
          style: TypographyToken.level2
              .body(context)
              .copyWith(
                color: tone.solid(context),
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
