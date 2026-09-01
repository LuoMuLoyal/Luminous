import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/control/divider.dart';
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
/// 翻页：当首页 [ReviewEventPage.nextCursor] 非空时滚动到底自动加载下一页
/// （列表惰性绘制保证触发器被 paint 即“接近末尾”信号）；加载失败改为
/// 错误行 + 手动重试（不自动重试，避免错误循环）。追加渲染并防重入，
/// 筛选切换或 DataChangeBus 刷新时重置为第一页。
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
  /// 为 null 时不渲染自动翻页触发器（测试/独立使用场景）。
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
    final typography = context.theme.typography;

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
                    color: SemanticColor.primary.solid(context),
                  ),
                ),
                const SizedBox(width: Spacing.level3),
                Expanded(
                  child: Text(
                    l10n.reviewReviewHistoryTitle,
                    style: typography.body.md.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
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
                      style: typography.body.xs.copyWith(
                        color: SemanticColor.neutral.solid(context),
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
                    style: typography.body.xs.copyWith(
                      color: SemanticColor.neutral.solid(context),
                    ),
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
                      if (_loadingMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: Spacing.level2,
                          ),
                          child: Center(child: FProgress()),
                        )
                      else if (_loadMoreError != null)
                        _LoadMoreErrorRow(onRetry: _loadMore)
                      else
                        _AutoLoadMoreTrigger(onVisible: _loadMore),
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

/// 滚动到底自动翻页触发器。
///
/// ListView/SliverList 只会 build/layout/paint 视口（含 cacheExtent）内
/// 的子项——本触发器被 paint 即说明用户已滚到接近列表末尾，此时触发加载。
/// 正确性由 [_ReviewHistorySectionState._loadMore] 的防重入与迟到请求
/// 校验保证；加载中触发器被替换为进度条，不会连续重复触发。加载完成后
/// 若触发器仍在视口内会继续拉取下一页，直到 cursor 为 null（触发器从树
/// 中移除）。
class _AutoLoadMoreTrigger extends SingleChildRenderObjectWidget {
  const _AutoLoadMoreTrigger({required this.onVisible})
    : super(child: const SizedBox.shrink());

  final VoidCallback onVisible;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderAutoLoadMoreTrigger(onVisible);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderAutoLoadMoreTrigger renderObject,
  ) {
    renderObject.onVisible = onVisible;
  }
}

class _RenderAutoLoadMoreTrigger extends RenderProxyBox {
  _RenderAutoLoadMoreTrigger(this.onVisible);

  VoidCallback onVisible;

  /// 同一帧只调度一次回调（paint 可能在一帧内多次发生）。
  bool _scheduled = false;

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    if (_scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      // 加载中/筛选切换时触发器可能已从树中移除。
      if (attached) onVisible();
    });
  }
}

/// 加载更多失败行：错误提示 + 手动重试（失败后不自动重试，避免错误循环）。
class _LoadMoreErrorRow extends StatelessWidget {
  const _LoadMoreErrorRow({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.reviewReviewHistoryLoadMoreFailed,
            style: context.theme.typography.body.xs.copyWith(
              color: SemanticColor.neutral.solid(context),
            ),
          ),
        ),
        const SizedBox(width: Spacing.level3),
        FButton(
          key: const Key('review-history-load-more-retry'),
          variant: FButtonVariant.outline,
          size: FButtonSizeVariant.sm,
          onPress: onRetry,
          child: Text(l10n.todayRetryAction),
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
    final isActive = event.status == ReviewEventStatus.active;
    final endLabel = event.endedAt != null
        ? reviewShortDateLabel(context, event.endedAt!)
        : l10n.reviewReviewWindowUntilNow;
    final typography = context.theme.typography;

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
                  style: typography.body.sm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Spacing.level1),
                Text(
                  '${reviewShortDateLabel(context, event.startedAt)} – $endLabel',
                  style: typography.body.xs.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
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
          // 可点入详情的行右侧补 chevron 指向性；只读行不加，避免暗示可点。
          if (onTap != null) ...[
            const SizedBox(width: Spacing.level2),
            ExcludeSemantics(
              child: Icon(
                SemanticIcons.actionNext,
                size: IconSizeTokens.level2,
                color: SemanticColor.neutral.solid(context),
              ),
            ),
          ],
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
        borderRadius: context.theme.style.borderRadius.pill,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level3,
          vertical: Spacing.level1,
        ),
        child: Text(
          label,
          style: context.theme.typography.body.xs2.copyWith(
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
/// pill chip 风格（选中 primary muted 底），与 AI 范围切换、建议徽标共用
/// 同一套 pill 视觉语言；旧实现为 FButton outline/primary，按钮意象偏重。
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
          Semantics(
            key: Key('review-history-filter-$key'),
            selected: status == selectedStatus,
            button: true,
            child: FTappable(
              onPress: onStatusChanged == null
                  ? null
                  : () => onStatusChanged!(status),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: status == selectedStatus
                      ? SemanticColor.primary.muted(context)
                      : SemanticColor.neutral.muted(context),
                  borderRadius: context.theme.style.borderRadius.pill,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.level3,
                    vertical: Spacing.level2,
                  ),
                  child: Text(
                    label,
                    style: context.theme.typography.body.xs.copyWith(
                      color: status == selectedStatus
                          ? SemanticColor.primary.solid(context)
                          : SemanticColor.neutral.solid(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
