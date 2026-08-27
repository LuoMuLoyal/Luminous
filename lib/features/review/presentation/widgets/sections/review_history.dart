import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/divider.dart';
import 'package:luminous/features/review/domain/entities/review.dart';
import 'package:luminous/features/review/presentation/utils/review_formatters.dart';
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
///
/// 翻页：当首页 [ReviewEventPage.nextCursor] 非空时，卡片底部渲染「加载更多」
/// 按钮；点击后通过 [onLoadMore] 回调请求下一页，追加渲染并防重入。筛选切换
/// 或 DataChangeBus 刷新时重置为第一页。
class ReviewHistorySection extends ConsumerStatefulWidget {
  const ReviewHistorySection({
    super.key,
    required this.history,
    this.onRetry,
    this.selectedStatus,
    this.onStatusChanged,
    this.onEventTap,
    this.onLoadMore,
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

  /// 加载更多回调；传入当前页的 nextCursor，返回下一页。
  /// 为 null 时不显示「加载更多」按钮（测试/独立使用场景）。
  final Future<ReviewEventPage> Function(String cursor)? onLoadMore;

  @override
  ConsumerState<ReviewHistorySection> createState() =>
      _ReviewHistorySectionState();
}

class _ReviewHistorySectionState extends ConsumerState<ReviewHistorySection> {
  /// 累积的额外页事件（不含首页）。首页数据来自 [widget.history]。
  List<ReviewEvent> _appendedItems = const [];

  /// 额外页的合并 nextCursor；null 表示无更多或未初始化。
  String? _appendedNextCursor;

  /// 是否正在加载更多（防重入）。
  bool _loadingMore = false;

  /// 加载更多失败时的错误信息（非 null 时显示重试）。
  Object? _loadMoreError;

  /// 当前正在请求的 cursor 值，用于在异步完成后校验是否仍然有效
  /// （筛选切换后旧请求迟到不应覆盖新状态）。
  String? _pendingCursor;

  /// 用来跟踪首页数据是否发生了变化（nextCursor 改变意味着筛选/刷新重取）。
  /// 当首页 nextCursor 与上次记录的不一致时，重置累积列表。
  String? _lastFirstPageNextCursor;
  ReviewEventStatus? _lastStatus;

  @override
  void initState() {
    super.initState();
    // If the first page is already available synchronously (e.g. cached),
    // seed the tracking fields so the first build doesn't falsely detect a
    // "change" and reset. didUpdateWidget handles subsequent updates.
    final firstPage = widget.history.asData?.value;
    if (firstPage != null) {
      _lastFirstPageNextCursor = firstPage.nextCursor;
      _lastStatus = widget.selectedStatus;
    }
  }

  @override
  void didUpdateWidget(covariant ReviewHistorySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync from the first page whenever the widget is updated (filter switch,
    // DataChangeBus refresh, etc.). This was previously done in build(),
    // which is a violation of the build purity contract — state mutations
    // must happen in lifecycle methods, not during build.
    final firstPage = widget.history.asData?.value;
    if (firstPage != null) {
      _syncFromFirstPage(firstPage);
    }
  }

  void _syncFromFirstPage(ReviewEventPage firstPage) {
    final status = widget.selectedStatus;
    // 筛选切换或首页 nextCursor 变化（DataChangeBus 刷新重取）时重置。
    if (_lastStatus != status ||
        _lastFirstPageNextCursor != firstPage.nextCursor) {
      // 重置所有累积状态，包括 _pendingCursor：一个在途的 loadMore
      // 请求返回后，其 cursor 与 _pendingCursor（已清为 null）不匹配，
      // 因此迟到结果会被正确丢弃，不会混入新筛选的数据。
      _appendedItems = const [];
      _appendedNextCursor = null;
      _loadMoreError = null;
      _pendingCursor = null;
      _lastFirstPageNextCursor = firstPage.nextCursor;
      _lastStatus = status;
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore) return;

    final cursor =
        _appendedNextCursor ?? widget.history.asData?.value.nextCursor;
    if (cursor == null) return;
    if (widget.onLoadMore == null) return;

    setState(() {
      _loadingMore = true;
      _loadMoreError = null;
      _pendingCursor = cursor;
    });

    try {
      final page = await widget.onLoadMore!(cursor);
      if (!mounted) return;
      // 迟到的旧请求：筛选切换后 cursor 已过期，丢弃结果。
      if (_pendingCursor != cursor) return;
      setState(() {
        _appendedItems = [..._appendedItems, ...page.items];
        _appendedNextCursor = page.nextCursor;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      if (_pendingCursor != cursor) return;
      setState(() {
        _loadMoreError = e;
        _loadingMore = false;
      });
    }
  }

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
                    l10n.reviewReviewHistoryTitle,
                    style: TypographyToken.level5
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.level3),
            _StatusFilterRow(
              selectedStatus: widget.selectedStatus,
              onStatusChanged: widget.onStatusChanged,
            ),
            const SizedBox(height: Spacing.level3),
            widget.history.when(
              skipLoadingOnRefresh: true,
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: Spacing.level3),
                child: Center(child: FProgress()),
              ),
              error: (_, __) => Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.reviewReviewHistoryLoadFailed,
                      style: TypographyToken.level3
                          .body(context)
                          .copyWith(
                            color: context.theme.colors.mutedForeground,
                          ),
                    ),
                  ),
                  if (widget.onRetry != null) ...[
                    const SizedBox(width: Spacing.level3),
                    FButton(
                      key: const Key('review-history-retry'),
                      variant: FButtonVariant.outline,
                      size: FButtonSizeVariant.sm,
                      onPress: widget.onRetry,
                      child: Text(l10n.todayRetryAction),
                    ),
                  ],
                ],
              ),
              data: (firstPage) {
                final allItems = [...firstPage.items, ..._appendedItems];

                if (allItems.isEmpty) {
                  return Text(
                    l10n.reviewReviewHistoryEmpty,
                    style: TypographyToken.level3
                        .body(context)
                        .copyWith(color: context.theme.colors.mutedForeground),
                  );
                }

                // 合并后的 nextCursor：已经加载过追加页时用追加页的 cursor
                // （可能为 null 表示无更多），否则用首页的 cursor。
                final mergedNextCursor = _appendedItems.isNotEmpty
                    ? _appendedNextCursor
                    : firstPage.nextCursor;
                final canLoadMore =
                    mergedNextCursor != null && widget.onLoadMore != null;

                return Column(
                  children: [
                    for (final (index, event) in allItems.indexed) ...[
                      if (index > 0) const AppDivider(),
                      _HistoryEventRow(
                        event: event,
                        onTap: widget.onEventTap == null
                            ? null
                            : () => widget.onEventTap!(event),
                      ),
                    ],
                    if (canLoadMore) ...[
                      const SizedBox(height: Spacing.level3),
                      _LoadMoreControl(
                        loading: _loadingMore,
                        hasError: _loadMoreError != null,
                        onLoad: _loadMore,
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadMoreControl extends StatelessWidget {
  const _LoadMoreControl({
    required this.loading,
    required this.hasError,
    required this.onLoad,
  });

  final bool loading;
  final bool hasError;
  final VoidCallback onLoad;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: Spacing.level2),
        child: Center(child: FProgress()),
      );
    }

    return Row(
      children: [
        if (hasError)
          Expanded(
            child: Text(
              l10n.reviewReviewHistoryLoadMoreFailed,
              style: TypographyToken.level3
                  .body(context)
                  .copyWith(color: context.theme.colors.mutedForeground),
            ),
          )
        else
          const Spacer(),
        FButton(
          key: const Key('review-history-load-more'),
          variant: FButtonVariant.outline,
          size: FButtonSizeVariant.sm,
          onPress: onLoad,
          child: Text(
            hasError ? l10n.todayRetryAction : l10n.reviewReviewHistoryLoadMore,
          ),
        ),
      ],
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
        : l10n.reviewReviewWindowUntilNow;

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
              label: l10n.reviewReviewStatusActive,
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
      ('all', null, l10n.reviewReviewHistoryFilterAll),
      ('active', ReviewEventStatus.active, l10n.reviewReviewStatusActive),
      ('ended', ReviewEventStatus.ended, l10n.reviewReviewStatusEnded),
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
