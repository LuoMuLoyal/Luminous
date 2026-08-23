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
///
/// 通过 `ref.listen` 只在 [reviewCurrentProvider] 真正采纳的 AsyncData 上
/// 更新：riverpod 会丢弃被更新重建覆盖的陈旧 fetch 完成，因此这里天然免疫
/// 慢请求迟到覆盖新数据。确认无事件或登出（AsyncData(null)）会清空缓存，
/// 加载中/错误态则保留最后一次成功数据。
class ReviewLastCurrentNotifier extends Notifier<EventReview?> {
  @override
  EventReview? build() {
    ref.listen<AsyncValue<EventReview?>>(reviewCurrentProvider, (_, next) {
      // 用 asData 而不是 hasValue：可空数据为 null 时 hasValue 为 false，
      // 但「确认无事件/登出」同样必须清空缓存。
      final data = next.asData;
      if (data != null) {
        state = data.value;
      }
    });
    // 初始状态直接取当前已采纳的数据，晚于 reviewCurrent 构建时也能播种。
    return ref.read(reviewCurrentProvider).asData?.value;
  }
}

final reviewLastCurrentProvider =
    NotifierProvider<ReviewLastCurrentNotifier, EventReview?>(
      ReviewLastCurrentNotifier.new,
    );

/// 当前事件的回顾：后端优先 active 事件，否则最近 ended；用户没有任何
/// 事件时 data 为 null（空信封语义，不是错误）。
///
/// keepAlive 缓存最近结果；当 dailyRecords / doseLogs / healthEvents 数据
/// 变化时自动刷新。失败时 riverpod 3 默认按指数退避自动重试（期间状态携带
/// 上一次数据），重试耗尽后进入 error；无论哪种情况
/// [reviewLastCurrentProvider] 都保留最后一次成功数据，
/// `ref.invalidate(reviewCurrentProvider)` 即手动 retry。
@Riverpod(keepAlive: true)
Future<EventReview?> reviewCurrent(Ref ref) {
  // Review 事实来自每日记录、剂量日志与事件本身，数据变化后自动重取。
  ref.watch(dataChangeVersionProvider(DataChangeTopic.dailyRecords));
  ref.watch(dataChangeVersionProvider(DataChangeTopic.doseLogs));
  ref.watch(dataChangeVersionProvider(DataChangeTopic.healthEvents));

  return authGuarded(
    ref: ref,
    fetch: () async {
      final result = await ref
          .watch(reviewRepositoryProvider)
          .fetchCurrentReview()
          .run()
          .timeout(
            _reviewTimeout,
            onTimeout: () => throw TimeoutException('review_current_timeout'),
          );
      // Left 投影到 AsyncValue.error。
      return result.fold((failure) => throw failure, (value) => value);
    },
    signedOutFallback: () async => null,
  );
}

/// 历史筛选切换后的失败立即进入 AsyncError，不走 riverpod 默认的指数
/// 退避自动重试（否则失败会被 ~40s 的静默重试掩盖）。手动重试仍由
/// `ref.invalidate(reviewHistoryProvider)` 驱动（section 内的 inline 重试）。
Duration? _noHistoryRetry(int retryCount, Object error) => null;

/// 最近事件回顾历史（第一页，默认 20 条），keepAlive 缓存。
///
/// 状态筛选由 [reviewHistoryStatusProvider] 驱动（null = 全部）；review
/// list 合同只有 status/cursor/limit 三个过滤参数，**没有日期范围参数**——
/// 时间范围（如旧 dashboard 的 7/30 天）属于历史筛选概念，不在当前合同
/// 内，客户端不发明日期过滤。
///
/// 事件创建/结束/check-in 后自动刷新；筛选切换时本 provider 重建重取；
/// `ref.invalidate(reviewHistoryProvider)` 即 retry；后续翻页由
/// presentation 层直接调用 repository。
@Riverpod(keepAlive: true, retry: _noHistoryRetry)
Future<ReviewEventPage> reviewHistory(Ref ref) {
  final status = ref.watch(reviewHistoryStatusProvider);
  ref.watch(dataChangeVersionProvider(DataChangeTopic.healthEvents));

  return authGuarded(
    ref: ref,
    fetch: () async {
      final result = await ref
          .watch(reviewRepositoryProvider)
          .fetchHistory(status: status)
          .run()
          .timeout(
            _reviewTimeout,
            onTimeout: () => throw TimeoutException('review_history_timeout'),
          );
      // Left 投影到 AsyncValue.error。
      return result.fold((failure) => throw failure, (value) => value);
    },
    signedOutFallback: () async => const ReviewEventPage(items: [], total: 0),
  );
}

/// 回顾历史的 status 筛选状态：null = 全部，active/ended 为合同内取值。
class ReviewHistoryStatusNotifier extends Notifier<ReviewEventStatus?> {
  @override
  ReviewEventStatus? build() => null;

  void select(ReviewEventStatus? status) => state = status;
}

final reviewHistoryStatusProvider =
    NotifierProvider<ReviewHistoryStatusNotifier, ReviewEventStatus?>(
      ReviewHistoryStatusNotifier.new,
    );

/// 指定事件 ID 的完整回顾。
///
/// autoDispose family：切换 event ID 时上一个实例被丢弃，旧结果不会
/// 串到新事件上；`ref.invalidate(reviewDetailProvider(eventId))` 即 retry。
@riverpod
Future<EventReview> reviewDetail(Ref ref, String eventId) {
  return authGuarded(
    ref: ref,
    fetch: () async {
      final result = await ref
          .watch(reviewRepositoryProvider)
          .fetchReview(eventId)
          .run()
          .timeout(
            _reviewTimeout,
            onTimeout: () => throw TimeoutException('review_detail_timeout'),
          );
      // Left 投影到 AsyncValue.error。
      return result.fold((failure) => throw failure, (value) => value);
    },
  );
}
