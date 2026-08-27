import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/review/domain/entities/review.dart';

/// 健康事件回顾的仓储接口。
///
/// Repository boundary: every expected recoverable failure (network, server
/// business failure) is a `TaskEither` Left produced via
/// `LucentErrorMapper.fromObject`; a successful response is a Right.
/// 实现负责调用 Lucent 的 event review read model 端点并映射为领域实体：
/// - current：优先 active 事件，否则最近 ended 事件；无事件时返回
///   `Right(null)`（后端返回空信封，不是 404，也不是错误）。
/// - list：事件回顾历史，cursor 分页；合法空列表保持 Right。
/// - detail：按事件 ID 取完整回顾；事件不存在或不属于当前用户时后端返回
///   404 Problem Details，为 Left 保留 code/status（不本地猜 status）。
abstract interface class ReviewRepository {
  TaskEither<LucentFailure, EventReview?> fetchCurrentReview();

  TaskEither<LucentFailure, ReviewEventPage> fetchHistory({
    ReviewEventStatus? status,
    String? cursor,
    int limit = 20,
  });

  TaskEither<LucentFailure, EventReview> fetchReview(String eventId);
}
