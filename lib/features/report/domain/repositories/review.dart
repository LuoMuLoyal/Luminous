import 'package:luminous/features/report/domain/entities/review.dart';

/// 健康事件回顾的仓储接口。
///
/// 实现负责调用 Lucent 的 event review read model 端点并映射为领域实体：
/// - current：优先 active 事件，否则最近 ended 事件；无事件时返回 null。
/// - list：事件回顾历史，cursor 分页。
/// - detail：按事件 ID 取完整回顾；事件不存在或不属于当前用户时抛错。
abstract interface class ReviewRepository {
  /// 取当前事件的回顾。
  ///
  /// 用户没有任何健康事件时返回 null（后端返回空信封，不是 404）。
  Future<EventReview?> fetchCurrentReview();

  /// 取一页事件回顾历史，按开始时间倒序。
  Future<ReviewEventPage> fetchHistory({
    ReviewEventStatus? status,
    String? cursor,
    int limit = 20,
  });

  /// 取指定事件的完整回顾。
  ///
  /// 事件不存在或不属于当前用户时抛出异常。
  Future<EventReview> fetchReview(String eventId);
}
