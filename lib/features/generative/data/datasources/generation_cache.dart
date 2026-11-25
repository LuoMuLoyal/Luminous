import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/storage/kv_store.dart';
import 'package:luminous/features/generative/domain/entities/generation.dart';
import 'package:luminous/shared/domain/composition/surface.dart';
import 'package:luminous/shared/domain/failure.dart';

/// 生成结果的文档缓存（`KvStore`）。
///
/// 存的是 **A2UI 消息序列 + 数据模型**的原始 JSON，不是渲染树：序列是协议的
/// 稳定表示，包升级后重放同一条序列仍能重建；树依赖包内的内部模型，存下来
/// 等于把 0.x 的结构钉死。
///
/// ## 键：`a2ui.<surface>.document`
///
/// A2UI 1.0 迁移时换了键，**没有**为旧键 `genui.<surface>.surface` 留任何读取
/// 或清理路径：那一份存的是 v0.9 消息，这套代码重放不了，也就不该读到它。
///
/// 编排页的 `genui.<surface>.spec`（用户起的标题）与生成结果无关，键不动。
final class GenerativeMessageCache {
  GenerativeMessageCache(this._store);

  final KvStore _store;

  static String _key(SurfaceId surface) => 'a2ui.${surface.wireValue}.document';

  /// 读出该 surface 上次的文档；没生成过返回 `null`。
  Future<Either<LucentFailure, GenerativeSurfaceDocument?>> read(
    SurfaceId surface,
  ) async {
    final raw = _store.get<String>(_key(surface), fallback: '');
    if (raw.isEmpty) return const Right(null);

    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException catch (error) {
      // 解不开当作「没生成过」而不是失败：缓存坏掉不应该让页面进入错误态，
      // 也不应该让用户看到一块渲染不出来的旧结果。
      return Left(
        LucentFailure.business(
          message: 'generative_cache_corrupt',
          cause: error,
        ),
      );
    }

    if (decoded is! Map) {
      return Left(LucentFailure.business(message: 'generative_cache_shape'));
    }

    final messages = _readMessages(decoded['messages']);
    final dataModel = decoded['dataModel'];

    return Right(
      GenerativeSurfaceDocument(
        surface: surface,
        messages: messages,
        dataModel: dataModel is Map
            ? <String, Object?>{
                for (final kv in dataModel.entries) kv.key.toString(): kv.value,
              }
            : null,
        // 缓存不存生成时间戳：它只用来判断「有没有结果」，界面上不展示。
        generatedAt: DateTime.now(),
      ),
    );
  }

  /// 写回一次结果，供冷启动重放。
  Future<Either<LucentFailure, Unit>> write(
    GenerativeSurfaceDocument document,
  ) async {
    await _store.set(
      _key(document.surface),
      jsonEncode({
        'messages': document.messages,
        if (document.dataModel case final dataModel?) 'dataModel': dataModel,
      }),
    );
    return const Right(unit);
  }

  /// 清掉该 surface 的生成结果（「恢复默认」用）。
  Future<Either<LucentFailure, Unit>> clear(SurfaceId surface) async {
    await _store.remove(_key(surface));
    return const Right(unit);
  }

  List<Map<String, Object?>> _readMessages(Object? raw) {
    if (raw is! List) return const [];
    return [
      for (final entry in raw)
        if (entry is Map)
          <String, Object?>{
            for (final kv in entry.entries) kv.key.toString(): kv.value,
          },
    ];
  }
}
