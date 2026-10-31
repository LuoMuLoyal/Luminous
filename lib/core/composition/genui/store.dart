import 'dart:convert';

import 'package:luminous/core/storage/kv_store.dart';
import 'package:luminous/shared/domain/composition/surface.dart';

/// 生成结果的持久化。
///
/// 存的是 **A2UI 消息序列**（`createSurface` + `updateComponents` +
/// `updateDataModel`）的原始 JSON 行，不是渲染树：
/// - 序列是协议的稳定表示，`genui` 升级后重放同一条序列仍能重建；
/// - 树依赖当前版本的内部模型，存下来等于把 `genui` 的内部结构钉死。
///
/// 冷启动重放，不重复烧 LLM。
final class GenerativeStore {
  GenerativeStore(this._store);

  final KvStore _store;

  static String _key(SurfaceId surface) => 'genui.${surface.wireValue}.surface';

  /// 读出该 surface 上次生成的消息序列；没有或解不开返回 `null`。
  List<String>? read(SurfaceId surface) {
    final raw = _store.get<String>(_key(surface), fallback: '');
    if (raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      return decoded.whereType<String>().toList(growable: false);
    } on FormatException {
      // 解不开当作没有：宁可让用户重新生成，也不要整页崩。
      return null;
    }
  }

  Future<void> write(SurfaceId surface, List<String> messages) async {
    await _store.set(_key(surface), jsonEncode(messages));
  }

  Future<void> clear(SurfaceId surface) async {
    await _store.remove(_key(surface));
  }
}
