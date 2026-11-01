import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/storage/kv_store.dart';
import 'package:luminous/features/generative/domain/entities/slot_spec.dart';
import 'package:luminous/shared/domain/composition/surface.dart';

/// 自定义生成式区块**声明**的本地存取（`KvStore`）。
///
/// 键：`genui.<surface>.spec`。与生成结果的键（`genui.<surface>.surface`，
/// 由 `GenerativeMessageCache` 拥有）刻意分开：用户写的标题与指示不该跟着
/// 一次生成结果一起被清掉。
///
/// 一个 surface 只有一个声明。`ComponentId` 被限制成 `a.b` 两段且只允许
/// `[a-z0-9_]`，无法为多个自定义实例分配稳定 id；布局里同一 id 也只挂一次。
/// 所以「每 surface 一个插槽」是这套 id 模型下唯一自洽的形态——要换内容就
/// 重新描述它，而不是并存两个。
final class GenerativeSlotCache {
  GenerativeSlotCache(this._store);

  final KvStore _store;

  static String _key(SurfaceId surface) => 'genui.${surface.wireValue}.spec';

  /// 读出该 surface 的自定义声明；没写过或已损坏时返回 `null`。
  ///
  /// 解不开当作「没写过」而不是抛错：一份坏掉的数据不该让编排页打不开。
  GenerativeSlotSpec? read(SurfaceId surface) {
    final raw = _store.get<String>(_key(surface), fallback: '');
    if (raw.isEmpty) return null;
    try {
      return GenerativeSlotSpec.fromJson(jsonDecode(raw));
    } on FormatException {
      return null;
    }
  }

  Future<void> write(SurfaceId surface, GenerativeSlotSpec spec) =>
      _store.set(_key(surface), jsonEncode(spec.toJson()));

  Future<void> clear(SurfaceId surface) => _store.remove(_key(surface));
}

final generativeSlotCacheProvider = Provider<GenerativeSlotCache>(
  (ref) => GenerativeSlotCache(KvStore.instance),
  name: 'generativeSlotCache',
);
