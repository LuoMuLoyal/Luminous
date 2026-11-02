/// 生成结果的仓储接口。
///
/// 仓储把「生成」与「本地消息序列」两件事收在同一个接缝后面：远端负责一次
/// 生成，缓存负责冷启动重放。调用方（应用层）只看得到这个接口，因此可以
/// 在测试里注入一个不触网的替身。
library;

import 'package:fpdart/fpdart.dart';
import 'package:luminous/features/generative/domain/entities/generation.dart';
import 'package:luminous/shared/domain/composition/surface.dart';
import 'package:luminous/shared/domain/failure.dart';

abstract interface class GenerationRepository {
  /// 读出该 surface 上次生成的文档；没生成过返回 `null`。
  ///
  /// 返回 `Either` 而不是直接给值：缓存层是唯一会接触坏数据的边界，坏数据
  /// 必须在这里变成 failure，不能让它带着形状继续往渲染层走。
  Future<Either<LucentFailure, GenerativeSurfaceDocument?>> read(
    SurfaceId surface,
  );

  /// 写回一次生成结果，供冷启动重放。
  Future<Either<LucentFailure, Unit>> write(GenerativeSurfaceDocument document);

  /// 清掉该 surface 的生成结果（「恢复默认」用）。
  ///
  /// 计划 §7 第 3 问的结论：没生成过的用户本来就不渲染，所以清不清对他们
  /// 没区别；对生成过的用户，恢复默认应当连带清掉，否则「恢复默认」之后
  /// 页面上还留着一块旧生成结果。
  Future<Either<LucentFailure, Unit>> clear(SurfaceId surface);

  /// 触发一次远端生成，返回**逐步到达**的事件流。
  ///
  /// 返回 `Stream` 而不是 `TaskEither`：增量 chunk 必须在生成过程中就被消费
  /// 才能给出进度反馈，而 `TaskEither` 只有一个终值。
  ///
  /// 流的失败语义：错误以 [LucentFailure] 在流上抛出（`event: error` 与开流
  /// 前的 HTTP 错误都已映射），由应用层捕获后落成「本次生成失败」。**成功
  /// 与否不看这个流的结束，而看是否收到了 `result` 事件**——流被中途关闭时
  /// 两者都没有，应用层据此判定失败。
  Stream<GenerationStreamEvent> generate(GenerationRequest request);
}

/// 一次生成在流上放出的两类事件。
///
/// 这里刻意**不复用** `data/` 的 `GenerationRemoteEvent`：`domain/` 不得依赖
/// `data/`。两者形状相近是刻意的——`data/` 那一份是线上协议的映射，这一份
/// 是应用层要的值，中间只差一次转换，让契约变化止步于数据层。
sealed class GenerationStreamEvent {
  const GenerationStreamEvent();
}

/// 增量到达的一条 A2UI 消息。
final class GenerationStreamChunk extends GenerationStreamEvent {
  const GenerationStreamChunk(this.message);

  final Map<String, Object?> message;
}

/// 生成完成，携带**权威**消息序列。
final class GenerationStreamResult extends GenerationStreamEvent {
  const GenerationStreamResult(this.messages);

  final List<Map<String, Object?>> messages;
}
