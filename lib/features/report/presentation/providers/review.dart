import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/report/data/providers/review.dart';
import 'package:luminous/features/report/domain/entities/review.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'review.g.dart';

const _reviewTimeout = Duration(seconds: 10);

/// Caches the last successfully loaded current [EventReview] so that a
/// failed refresh can keep stale data instead of a full skeleton. A null
/// value means either "no events" or "nothing loaded yet" — combine with
/// [reviewCurrentProvider] to tell the two apart.
class ReviewLastCurrentNotifier extends Notifier<EventReview?> {
  @override
  EventReview? build() => null;

  void set(EventReview? review) {
    state = review;
  }
}

final reviewLastCurrentProvider =
    NotifierProvider<ReviewLastCurrentNotifier, EventReview?>(
      ReviewLastCurrentNotifier.new,
    );

/// 当前事件的回顾：后端优先 active 事件，否则最近 ended；用户没有任何
/// 事件时 data 为 null（空信封语义，不是错误）。
///
/// keepAlive 缓存最近结果；当 dailyRecords / doseLogs 变化时自动刷新。
/// 失败时 riverpod 3 默认按指数退避自动重试（期间状态携带上一次数据），
/// 重试耗尽后进入 error；无论哪种情况 [reviewLastCurrentProvider] 都保留
/// 最后一次成功数据，`ref.invalidate(reviewCurrentProvider)` 即手动 retry。
@Riverpod(keepAlive: true)
Future<EventReview?> reviewCurrent(Ref ref) {
  // Review 事实来自每日记录与剂量日志，数据变化后自动重取。
  ref.watch(dataChangeVersionProvider(DataChangeTopic.dailyRecords));
  ref.watch(dataChangeVersionProvider(DataChangeTopic.doseLogs));

  return authGuarded(
    ref: ref,
    fetch: () async {
      final review = await ref
          .watch(reviewRepositoryProvider)
          .fetchCurrentReview()
          .timeout(
            _reviewTimeout,
            onTimeout: () => throw TimeoutException('review_current_timeout'),
          );
      ref.read(reviewLastCurrentProvider.notifier).set(review);
      return review;
    },
    signedOutFallback: () async => null,
  );
}

/// 最近事件回顾历史（第一页，默认 20 条），keepAlive 缓存。
///
/// `ref.invalidate(reviewHistoryProvider)` 即 retry；后续翻页由
/// presentation 层直接调用 repository。
@Riverpod(keepAlive: true)
Future<ReviewEventPage> reviewHistory(Ref ref) {
  return authGuarded(
    ref: ref,
    fetch: () => ref
        .watch(reviewRepositoryProvider)
        .fetchHistory()
        .timeout(
          _reviewTimeout,
          onTimeout: () => throw TimeoutException('review_history_timeout'),
        ),
    signedOutFallback: () async => const ReviewEventPage(items: [], total: 0),
  );
}

/// 指定事件 ID 的完整回顾。
///
/// autoDispose family：切换 event ID 时上一个实例被丢弃，旧结果不会
/// 串到新事件上；`ref.invalidate(reviewDetailProvider(eventId))` 即 retry。
@riverpod
Future<EventReview> reviewDetail(Ref ref, String eventId) {
  return authGuarded(
    ref: ref,
    fetch: () => ref
        .watch(reviewRepositoryProvider)
        .fetchReview(eventId)
        .timeout(
          _reviewTimeout,
          onTimeout: () => throw TimeoutException('review_detail_timeout'),
        ),
  );
}
