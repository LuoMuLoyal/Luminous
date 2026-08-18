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
/// 列表项只读展示事件头部信息；传入 [onEventTap] 时整行可点（FTappable），
/// 由页面装配层 push 完整回顾详情页。历史加载失败不阻塞首屏——卡片内显示
/// 一行提示 + 轻量重试入口。
///
/// 筛选：提供 status（全部 / 进行中 / 已结束）轻量筛选，由页面装配层的
/// [reviewHistoryStatusProvider] 驱动重新拉取。时间范围**不是** review
/// list 合同的一部分（合同只有 status/cursor/limit），不提供日期过滤。
class ReviewHistorySection extends StatelessWidget {
  const ReviewHistorySection({
    super.key,
    required this.history,
    this.onRetry,
    this.selectedStatus,
    this.onStatusChanged,
    this.onEventTap,
  });

  final AsyncValue<ReviewEventPage> history;

  /// 历史加载失败时的重试回调（由页面装配层 invalidate history provider）。
  final VoidCallback? onRetry;

  /// 当前选中的 status 筛选（null = 全部）。
  final ReviewEventStatus? selectedStatus;

  /// 筛选变化回调；为 null 时筛选按钮禁用（测试/独立使用场景）。
  final ValueChanged<ReviewEventStatus?>? onStatusChanged;

  /// 历史行点击回调；为 null 时行不可点（只读）。
  final ValueChanged<ReviewEvent>? onEventTap;

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
            _StatusFilterRow(
              selectedStatus: selectedStatus,
              onStatusChanged: onStatusChanged,
            ),
            const SizedBox(height: Spacing.level3),
            history.when(
              skipLoadingOnRefresh: true,
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
                          _HistoryEventRow(
                            event: event,
                            onTap: onEventTap == null
                                ? null
                                : () => onEventTap!(event),
                          ),
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
  const _HistoryEventRow({required this.event, this.onTap});

  final ReviewEvent event;

  /// 行点击回调；null 时整行不可点（只读展示）。
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    final isActive = event.status == ReviewEventStatus.active;
    final endLabel = event.endedAt != null
        ? reviewShortDateLabel(context, event.endedAt!)
        : l10n.reportReviewWindowUntilNow;

    final row = Padding(
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

    // onTap 为空时保持纯只读行（不包 FTappable），避免禁用态把整行文本
    // 合并进单一语义节点、破坏既有语义遍历顺序；可点时才赋予按压反馈。
    return onTap == null ? row : FTappable(onPress: onTap, child: row);
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

/// 历史的 status 轻量筛选行：全部 / 进行中 / 已结束。
///
/// 只做合同内的 status 过滤；时间范围不属于 review list 合同。
class _StatusFilterRow extends StatelessWidget {
  const _StatusFilterRow({
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  final ReviewEventStatus? selectedStatus;
  final ValueChanged<ReviewEventStatus?>? onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final options = <(String, ReviewEventStatus?, String)>[
      ('all', null, l10n.reportReviewHistoryFilterAll),
      ('active', ReviewEventStatus.active, l10n.reportReviewStatusActive),
      ('ended', ReviewEventStatus.ended, l10n.reportReviewStatusEnded),
    ];

    return Wrap(
      spacing: Spacing.level2,
      runSpacing: Spacing.level2,
      children: [
        for (final (key, status, label) in options)
          FButton(
            key: Key('review-history-filter-$key'),
            variant: status == selectedStatus
                ? FButtonVariant.primary
                : FButtonVariant.outline,
            size: FButtonSizeVariant.sm,
            onPress: onStatusChanged == null
                ? null
                : () => onStatusChanged!(status),
            child: Text(label),
          ),
      ],
    );
  }
}
