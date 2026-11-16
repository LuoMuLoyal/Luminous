import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/shell/domain/entities/nav_config.dart';

/// `NavConfig` 的 JSON 往返与**坏数据拒绝语义**。
///
/// 这一层是「配置能不能信」的唯一防线：`fromJson` 返回 null 的上层一律回退默认，
/// 所以每一条"能返回非 null"的结构约束都必须在这里钉住。
void main() {
  group('TabPlacement JSON', () {
    test('round-trips every field', () {
      const placement = TabPlacement(
        tabId: TabId.medicine,
        order: 3,
        customLabel: '用药台',
        iconName: 'pill',
        isVisible: false,
      );

      final parsed = TabPlacement.fromJson(placement.toJson());

      expect(parsed, placement);
    });

    test('omits null custom fields', () {
      const placement = TabPlacement(tabId: TabId.today, order: 0);
      final json = placement.toJson();

      expect(json.containsKey('customLabel'), isFalse);
      expect(json.containsKey('iconName'), isFalse);
      expect(json['isVisible'], isTrue);
    });

    test('defaults isVisible to true when absent', () {
      final parsed = TabPlacement.fromJson({'tabId': 'record', 'order': 1});

      expect(parsed!.isVisible, isTrue);
    });

    test('rejects a missing tabId', () {
      expect(TabPlacement.fromJson({'order': 0}), isNull);
    });

    test('rejects an empty tabId', () {
      expect(TabPlacement.fromJson({'tabId': '', 'order': 0}), isNull);
    });

    test('rejects a non-int order', () {
      expect(TabPlacement.fromJson({'tabId': 'today', 'order': '0'}), isNull);
    });

    test('rejects a non-bool isVisible', () {
      expect(
        TabPlacement.fromJson({
          'tabId': 'today',
          'order': 0,
          'isVisible': 'yes',
        }),
        isNull,
      );
    });

    test('rejects a non-string customLabel', () {
      expect(
        TabPlacement.fromJson({
          'tabId': 'today',
          'order': 0,
          'customLabel': 42,
        }),
        isNull,
      );
    });

    test('rejects a non-map payload', () {
      expect(TabPlacement.fromJson('today'), isNull);
      expect(TabPlacement.fromJson(null), isNull);
      expect(TabPlacement.fromJson(<Object?>[]), isNull);
    });

    test('copyWith can clear the custom label and icon', () {
      const placement = TabPlacement(
        tabId: TabId.today,
        order: 0,
        customLabel: 'x',
        iconName: 'pill',
      );

      final cleared = placement.copyWith(
        clearCustomLabel: true,
        clearIconName: true,
      );

      expect(cleared.customLabel, isNull);
      expect(cleared.iconName, isNull);
    });
  });

  group('NavConfig JSON', () {
    test('default config omits tabs and reports isDefault', () {
      const config = NavConfig();

      expect(config.isDefault, isTrue);
      expect(config.toJson().containsKey('tabs'), isFalse);
    });

    test('round-trips a customised config', () {
      const config = NavConfig(
        tabs: [
          TabPlacement(tabId: TabId.today, order: 0, customLabel: '总结'),
          TabPlacement(tabId: TabId.record, order: 1),
          TabPlacement(tabId: TabId.medicine, order: 2),
          TabPlacement(tabId: TabId.review, order: 3),
          TabPlacement(tabId: TabId.mine, order: 4, iconName: 'user'),
        ],
      );

      expect(NavConfig.fromJson(config.toJson()), config);
    });

    test('rejects an unknown schemaVersion outright', () {
      // 不猜、不部分修复：老版本客户端读到新结构时整体回退默认。
      expect(
        NavConfig.fromJson({
          'schemaVersion': currentNavSchemaVersion + 1,
          'tabs': <Object?>[],
        }),
        isNull,
      );
    });

    test('rejects a missing schemaVersion', () {
      expect(NavConfig.fromJson({'tabs': <Object?>[]}), isNull);
    });

    test('rejects duplicate tabIds', () {
      expect(
        NavConfig.fromJson({
          'schemaVersion': currentNavSchemaVersion,
          'tabs': [
            {'tabId': 'today', 'order': 0},
            {'tabId': 'today', 'order': 1},
          ],
        }),
        isNull,
      );
    });

    test('rejects a non-list tabs field', () {
      expect(
        NavConfig.fromJson({
          'schemaVersion': currentNavSchemaVersion,
          'tabs': 'today',
        }),
        isNull,
      );
    });

    test('rejects when any single placement is malformed', () {
      // 一项坏 → 整份回退，不是跳过坏项保留其余的"部分修复"。
      expect(
        NavConfig.fromJson({
          'schemaVersion': currentNavSchemaVersion,
          'tabs': [
            {'tabId': 'today', 'order': 0},
            {'order': 1},
          ],
        }),
        isNull,
      );
    });

    test('resetToDefault clears the tabs override', () {
      const config = NavConfig(
        tabs: [TabPlacement(tabId: TabId.today, order: 0)],
      );

      expect(config.resetToDefault().isDefault, isTrue);
    });

    test('equality compares tab contents', () {
      const a = NavConfig(tabs: [TabPlacement(tabId: TabId.today, order: 0)]);
      const b = NavConfig(tabs: [TabPlacement(tabId: TabId.today, order: 0)]);
      const c = NavConfig(tabs: [TabPlacement(tabId: TabId.today, order: 1)]);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });
  });
}
