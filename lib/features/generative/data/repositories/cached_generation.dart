import 'package:fpdart/fpdart.dart';
import 'package:luminous/features/generative/data/datasources/generation_cache.dart';
import 'package:luminous/features/generative/domain/entities/generation.dart';
import 'package:luminous/features/generative/domain/repositories/generation.dart';
import 'package:luminous/shared/domain/composition/surface.dart';
import 'package:luminous/shared/domain/failure.dart';

/// cache-first 的生成结果仓储。
///
/// A7a 阶段它只有缓存这一条腿；A7b 接上 SSE 之后，`generate` 走远端、这条
/// 缓存继续负责「冷启动重放」。**先读本地、命中即返回**是 ADR-0006 的默认
/// 形态，这里没有理由例外——重放一份已存的消息序列不产生网络请求。
///
/// 它不做校验：校验是 `catalog_policy` 的职责，在应用层对**刚落地的消息**
/// 做（见 `application/orchestrators/generation_session.dart`）。把校验塞进
/// 缓存层会让「读历史的旧结果」也过一次当前规则，升级后旧结果会突然消失。
final class CachedGenerationRepository implements GenerationRepository {
  CachedGenerationRepository(this._cache);

  final GenerativeMessageCache _cache;

  @override
  Future<Either<LucentFailure, GenerativeSurfaceDocument?>> read(
    SurfaceId surface,
  ) => _cache.read(surface);

  @override
  Future<Either<LucentFailure, Unit>> write(
    GenerativeSurfaceDocument document,
  ) => _cache.write(document);

  @override
  Future<Either<LucentFailure, Unit>> clear(SurfaceId surface) =>
      _cache.clear(surface);
}
