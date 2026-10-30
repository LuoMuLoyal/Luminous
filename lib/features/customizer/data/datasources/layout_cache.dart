import 'dart:convert';

import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/storage/kv_store.dart';

/// 布局的本地缓存。
///
/// 用 KV 而不是 drift 表：布局是「一屏一份、整体读写」的小文档，不需要按行
/// 查询；放进 drift 会让表结构跟着 `SurfaceLayout` 演进而迁移，而布局模型恰恰
/// 是会随组件系统迭代的部分。
final class LayoutCache {
  LayoutCache(this._store);

  final KvStore _store;

  static String _key(SurfaceId surface) => 'layout.${surface.wireValue}';

  Future<Map<SurfaceId, SurfaceLayout>> readAll() async {
    final layouts = <SurfaceId, SurfaceLayout>{};
    for (final surface in SurfaceId.values) {
      final raw = _store.get<String>(_key(surface), fallback: '');
      if (raw.isEmpty) continue;
      // 解不开就当作没有缓存：用户的自定义丢了也好过整页崩掉。
      final layout = _tryParse(raw);
      if (layout != null) layouts[surface] = layout;
    }
    return layouts;
  }

  Future<void> write(SurfaceId surface, SurfaceLayout layout) async {
    await _store.set(_key(surface), jsonEncode(layout.toJson()));
  }

  SurfaceLayout? _tryParse(String raw) {
    try {
      return SurfaceLayout.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }
}
