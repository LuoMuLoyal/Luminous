/// 生成结果的仓储接口。
///
/// 仓储把两件事收在同一个接缝后面：远端负责生成与交互回合，缓存负责冷启动
/// 重放。调用方（应用层）只看得到这个接口，因此可以在测试里注入不触网的替身。
library;

import 'package:fpdart/fpdart.dart';
import 'package:luminous/features/generative/domain/entities/generation.dart';
import 'package:luminous/shared/domain/composition/surface.dart';
import 'package:luminous/shared/domain/failure.dart';

abstract interface class GenerationRepository {
  /// 读出该 surface 上次的文档；没生成过返回 `null`。
  ///
  /// 返回 `Either` 而不是直接给值：缓存层是唯一会接触坏数据的边界，坏数据
  /// 必须在这里变成 failure，不能让它带着形状继续往渲染层走。
  Future<Either<LucentFailure, GenerativeSurfaceDocument?>> read(
    SurfaceId surface,
  );

  /// 写回一次结果，供冷启动重放。
  Future<Either<LucentFailure, Unit>> write(GenerativeSurfaceDocument document);

  /// 清掉该 surface 的生成结果（「恢复默认」用）。
  Future<Either<LucentFailure, Unit>> clear(SurfaceId surface);

  /// 触发一次远端生成，返回**逐步到达**的事件流。
  ///
  /// 返回 `Stream` 而不是 `TaskEither`：增量 chunk 必须在生成过程中就被消费
  /// 才能给出进度反馈，而 `TaskEither` 只有一个终值。
  ///
  /// 流的失败语义：错误以 [LucentFailure] 在流上抛出（`event: error` 与开流前
  /// 的 HTTP 错误都已映射），由应用层捕获后落成「本次生成失败」。**成功与否
  /// 不看流的结束，而看是否收到了 `result` 事件**。
  Stream<GenerationStreamEvent> generate(GenerationRequest request);

  /// 一个交互回合：把渲染端产出的消息交给 agent，拿回它续写的消息。
  ///
  /// 与 [generate] 同一个事件流形状——对应用层来说，「用户点了按钮」与「用户
  /// 说了一句话」都是「agent 又写了一轮」。
  Stream<GenerationStreamEvent> turn(GenerationTurn turn);
}

/// 一次生成 / 交互在流上放出的两类事件。
///
/// 这里刻意**不复用** `data/` 的 `GenerationRemoteEvent`：`domain/` 不得依赖
/// `data/`。两者形状相近是刻意的——`data/` 那一份是线上协议的映射，这一份是
/// 应用层要的值。
sealed class GenerationStreamEvent {
  const GenerationStreamEvent();
}

/// 增量到达的一条 A2UI 消息。
final class GenerationStreamChunk extends GenerationStreamEvent {
  const GenerationStreamChunk(this.message);

  final Map<String, Object?> message;
}

/// 生成完成，携带**权威**消息序列。
///
/// `messages` 是这一轮的完整序列（不是增量）：服务端每次都返回重建整棵树所需
/// 的全部消息，客户端据此覆盖而不是追加——否则交互回合会不断叠加旧组件。
final class GenerationStreamResult extends GenerationStreamEvent {
  const GenerationStreamResult(this.messages, {this.dataModel});

  final List<Map<String, Object?>> messages;

  /// 服务端回传的数据模型（agent 要求 `sendDataModel` 时才有）。
  final Map<String, Object?>? dataModel;
}
