import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/network/config/pref_keys.dart';
import 'package:luminous/core/storage/kv_store.dart';
import 'package:luminous/features/shell/domain/entities/nav_config.dart';
import 'package:luminous/features/shell/domain/repositories/nav_config.dart';

/// KV 持久化的导航配置。
///
/// 存的是 `NavConfig.toJson()` 的 `Map<String, Object?>`——`KvStore` 只接受
/// 可被 Hive 序列化的基础类型，存 Dart 对象需要注册 adapter，而这份配置
/// 结构简单、量又小，手写 codec 比引入一台 adapter 更直白。
class CachedNavConfigRepository implements NavConfigRepository {
  const CachedNavConfigRepository(this._store);

  final KvStore _store;

  @override
  NavConfig read() {
    final raw = _store.getOrNull<Map<Object?, Object?>>(
      PrefKeys.shellNavConfig,
    );
    if (raw == null) return const NavConfig();

    // 坏数据 / 未知版本整体回退默认，**保留原始值**供诊断：不主动清除，
    // 否则用户下次升级到能读懂它的版本时已经没得读了。
    final parsed = NavConfig.fromJson(raw);
    return parsed ?? const NavConfig();
  }

  @override
  Future<void> write(NavConfig config) async {
    if (config.isDefault) {
      // 「恢复默认」就是删掉键：留一份与默认值逐字段相同的配置，
      // 会让以后改注册表默认值时这批用户卡在旧默认上。
      await _store.remove(PrefKeys.shellNavConfig);
      return;
    }
    await _store.set(PrefKeys.shellNavConfig, config.toJson());
  }
}

/// 装配：接口 → 实现。
///
/// 按仓库约定，`@riverpod` 的 repository provider 与实现同文件；presentation
/// 经本 feature 的 `presentation/providers/data_access.dart` 再导出访问，
/// **不直接 import `data/`**。
final navConfigRepositoryProvider = Provider<NavConfigRepository>(
  (ref) => CachedNavConfigRepository(KvStore.instance),
);
