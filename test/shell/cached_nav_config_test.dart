import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/network/config/pref_keys.dart';
import 'package:luminous/core/storage/kv_store.dart';
import 'package:luminous/features/shell/data/repositories/cached_nav_config.dart';
import 'package:luminous/features/shell/domain/entities/nav_config.dart';

import '../helpers/kv_test_store.dart';

/// `CachedNavConfigRepository` 的**降级语义**。
///
/// 这是"配置能不能信"的最后一层：上游 `NavConfig.fromJson` 拒绝的坏数据，
/// 到这里必须变成默认配置，而不是抛异常或半渲染。
void main() {
  late KvStore store;
  late CachedNavConfigRepository repository;

  setUp(() {
    store = KvTestStore.install();
    repository = CachedNavConfigRepository(store);
  });

  group('read', () {
    test('returns the default config when nothing is stored', () {
      final config = repository.read();

      expect(config.isDefault, isTrue);
    });

    test('round-trips a written config', () async {
      const config = NavConfig(
        tabs: [
          TabPlacement(tabId: TabId.today, order: 0, customLabel: '总结'),
          TabPlacement(tabId: TabId.record, order: 1, isVisible: false),
          TabPlacement(tabId: TabId.medicine, order: 2),
          TabPlacement(tabId: TabId.review, order: 3),
          TabPlacement(tabId: TabId.mine, order: 4),
        ],
      );

      await repository.write(config);

      expect(repository.read(), config);
    });

    test('falls back to the default on a non-map payload', () async {
      await store.set(PrefKeys.shellNavConfig, 'not-a-config');

      expect(repository.read().isDefault, isTrue);
    });

    test('falls back to the default on an unknown schemaVersion', () async {
      await store.set(PrefKeys.shellNavConfig, {
        'schemaVersion': currentNavSchemaVersion + 5,
        'tabs': <Object?>[],
      });

      expect(repository.read().isDefault, isTrue);
    });

    test(
      'falls back to the default when a stored placement is malformed',
      () async {
        await store.set(PrefKeys.shellNavConfig, {
          'schemaVersion': currentNavSchemaVersion,
          'tabs': [
            {'tabId': 'today', 'order': 0},
            {'order': 1},
          ],
        });

        expect(repository.read().isDefault, isTrue);
      },
    );

    test('does not delete the unreadable value', () async {
      // 保留原始值供诊断：用户升级到能读懂它的版本时还读得到。
      await store.set(PrefKeys.shellNavConfig, {'schemaVersion': 999});

      repository.read();

      expect(store.containsKey(PrefKeys.shellNavConfig), isTrue);
    });
  });

  group('write', () {
    test('removes the key when writing the default config', () async {
      await repository.write(
        const NavConfig(tabs: [TabPlacement(tabId: TabId.today, order: 0)]),
      );
      expect(store.containsKey(PrefKeys.shellNavConfig), isTrue);

      await repository.write(const NavConfig());

      // 「恢复默认」= 删键：留一份与默认逐字段相同的配置，会让以后改
      // 注册表默认值时这批用户卡在旧默认上。
      expect(store.containsKey(PrefKeys.shellNavConfig), isFalse);
    });

    test('stores a plain map, not a Dart object', () async {
      await repository.write(
        const NavConfig(tabs: [TabPlacement(tabId: TabId.today, order: 0)]),
      );

      final raw = store.getOrNull<Object>(PrefKeys.shellNavConfig);
      expect(raw, isA<Map<Object?, Object?>>());
    });
  });
}
