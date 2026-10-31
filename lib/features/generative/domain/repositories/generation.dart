/// 生成结果的仓储接口。
///
/// A7a 只做**渲染链路**，不接 LLM（那是 A7b）：此时唯一的实现是
/// 「本地消息序列的读写」，接口仍按最终形态定义，免得 A7b 再改一次签名——
/// `generate` 会在 A7b 由远端实现接上，缓存实现继续负责 `read` / `write`。
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
}
