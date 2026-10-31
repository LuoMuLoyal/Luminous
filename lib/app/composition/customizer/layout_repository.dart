import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/storage/kv_store.dart';
import 'package:luminous/features/customizer/data/datasources/layout_cache.dart';
import 'package:luminous/features/customizer/data/datasources/layout_remote.dart';
import 'package:luminous/features/customizer/data/repositories/cached_layout.dart';
import 'package:luminous/features/customizer/domain/repositories/layout.dart';

/// 布局仓储的装配点。
///
/// 放在组合根而不是 `customizer/application/`：装配要同时看见 `data/` 实现
/// 与 `core/storage`，而 `application/` 层既不许 import `data/`，也不许 import
/// `core/storage`（分层门禁 R3）。application 只声明「需要一个
/// [LayoutRepository]」，谁来实现由这里决定。
///
/// cache-first 读 + 乐观写都在实现里；这里只回答「用哪一个实现」。
final layoutRepositoryProvider = Provider<LayoutRepository>((ref) {
  return CachedLayoutRepository(
    cache: LayoutCache(KvStore.instance),
    remote: const LayoutRemote(),
  );
});
