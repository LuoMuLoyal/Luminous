import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/storage/kv_store.dart';
import 'package:luminous/features/generative/domain/entities/generation.dart';
import 'package:luminous/features/generative/domain/repositories/generation.dart';
import 'package:luminous/shared/domain/composition/surface.dart';
import 'package:luminous/shared/domain/failure.dart';

/// 生成结果的消息序列缓存（`KvStore`）。
///
/// 存的是 **A2UI 消息序列**的原始 JSON，不是渲染树：
/// - 序列是协议的稳定表示，`genui` 升级后重放同一条序列仍能重建；
/// - 树依赖当前版本的内部模型，存下来等于把 `genui` 的内部结构钉死。
///
/// 冷启动重放，不重复烧 LLM。
///
/// **为什么在 `data/` 而不在 `core/composition/genui/`**：`GenerativeSurfaceDocument`
/// 带着 `SurfaceId`（shared 内核）和「消息序列」这个值类型，属于生成式 UI 自己的
/// 词汇；而 `KvStore` 只允许 `data/` 和 `core/` 碰。放在 core 会让 feature 的
/// domain 反过来依赖 core，放在这里则两边都合法：`data/` 允许 import
/// `core/storage`。
final class GenerativeMessageCache implements GenerationRepository {
  GenerativeMessageCache(this._store);

  final KvStore _store;

  static String _key(SurfaceId surface) => 'genui.${surface.wireValue}.surface';

  @override
  Future<Either<LucentFailure, GenerativeSurfaceDocument?>> read(
    SurfaceId surface,
  ) async {
    final raw = _store.get<String>(_key(surface), fallback: '');
    if (raw.isEmpty) return const Right(null);

    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException catch (error) {
      // 解不开当作「没生成过」，而不是失败：缓存坏掉不应该让页面进入错误态，
      // 也不应该让用户看到一块渲染不出来的旧结果。
      return Left(
        LucentFailure.business(
          message: 'generative_cache_corrupt',
          cause: error,
        ),
      );
    }

    if (decoded is! List) {
      return Left(LucentFailure.business(message: 'generative_cache_shape'));
    }

    final messages = <Map<String, Object?>>[];
    for (final entry in decoded) {
      if (entry is Map) {
        messages.add(<String, Object?>{
          for (final kv in entry.entries) kv.key.toString(): kv.value,
        });
      }
    }

    return Right(
      GenerativeSurfaceDocument(
        surface: surface,
        messages: messages,
        // 缓存不存生成时间戳：它只用来判断「有没有结果」，界面上不展示。
        // 用读到的时刻代替，避免为了一个展示字段多写一份状态。
        generatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<Either<LucentFailure, Unit>> write(
    GenerativeSurfaceDocument document,
  ) async {
    await _store.set(_key(document.surface), jsonEncode(document.messages));
    return const Right(unit);
  }

  @override
  Future<Either<LucentFailure, Unit>> clear(SurfaceId surface) async {
    await _store.remove(_key(surface));
    return const Right(unit);
  }
}
