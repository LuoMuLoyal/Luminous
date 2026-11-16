import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/shell/domain/entities/nav_config.dart';
import 'package:luminous/features/shell/domain/services/nav_rules.dart';
import 'package:luminous/features/shell/presentation/providers/nav_config.dart';
import 'package:luminous/features/shell/presentation/providers/nav_draft.dart';
import 'package:luminous/features/shell/presentation/tab.dart';

import '../helpers/kv_test_store.dart';

/// 编排页草稿的生命周期与拒绝语义。
///
/// 真正的规则判定在 `nav_rules` 里已经单测过；这里只钉「草稿层」的额外约定：
/// 非法编辑不污染草稿、越界移动是无操作、取消可回到进来时的状态。
void main() {
  late ProviderContainer container;

  ProviderContainer makeContainer() {
    KvTestStore.install();
    final c = ProviderContainer();
    addTearDown(c.dispose);
    return c;
  }

  NavDraftController notifier() => container.read(navDraftProvider.notifier);
  List<TabId> order() =>
      container.read(navDraftRowsProvider).map((row) => row.id).toList();

  setUp(() {
    container = makeContainer();
  });

  group('begin', () {
    test('starts from the completed saved config', () {
      notifier().begin();

      expect(order(), shellTabDefaultOrder);
      expect(container.read(navDraftProvider), isNotNull);
    });

    test('backfills tabs missing from a partial saved config', () {
      // 已保存配置只有两项：进页面应立即看到完整的五行。
      container = makeContainer();
      container
          .read(navConfigProvider.notifier)
          .commit(
            const NavConfig(
              tabs: [
                TabPlacement(tabId: TabId.today, order: 0),
                TabPlacement(tabId: TabId.mine, order: 1),
              ],
            ),
          );

      notifier().begin();

      expect(order(), hasLength(shellTabRegistry.length));
    });

    test('discard clears the draft', () {
      notifier().begin();
      notifier().discard();

      expect(container.read(navDraftProvider), isNull);
    });
  });

  group('move', () {
    setUp(() => notifier().begin());

    test('moves a tab up', () {
      final resolution = notifier().move(TabId.medicine, -1);

      expect(resolution.isAccepted, isTrue);
      expect(order().indexOf(TabId.medicine), 1);
    });

    test('moves a tab down', () {
      notifier().move(TabId.today, 1);

      expect(order().indexOf(TabId.today), 1);
    });

    test('moving the first tab up is a no-op, not an error', () {
      final before = order();
      final resolution = notifier().move(TabId.today, -1);

      // 按钮已经在界面上置灰；这一层不该再报错。
      expect(resolution.isAccepted, isTrue);
      expect(order(), before);
    });

    test('moving the last tab down is a no-op', () {
      final before = order();
      final resolution = notifier().move(TabId.mine, 1);

      expect(resolution.isAccepted, isTrue);
      expect(order(), before);
    });

    test('orders stay normalised after repeated moves', () {
      notifier().move(TabId.mine, -1);
      notifier().move(TabId.mine, -1);

      final tabs = container.read(navDraftProvider)!.tabs!;
      expect(tabs.map((t) => t.order), [0, 1, 2, 3, 4]);
    });
  });

  group('rename', () {
    setUp(() => notifier().begin());

    test('accepts a valid custom label', () {
      final resolution = notifier().rename(TabId.today, '总结');

      expect(resolution.isAccepted, isTrue);
      final today = container
          .read(navDraftProvider)!
          .tabs!
          .firstWhere((t) => t.tabId == TabId.today);
      expect(today.customLabel, '总结');
    });

    test('null clears the custom label', () {
      notifier().rename(TabId.today, '总结');
      notifier().rename(TabId.today, null);

      final today = container
          .read(navDraftProvider)!
          .tabs!
          .firstWhere((t) => t.tabId == TabId.today);
      expect(today.customLabel, isNull);
    });

    test('rejects a too-long label and leaves the draft untouched', () {
      notifier().rename(TabId.today, '总结');
      final before = container.read(navDraftProvider);

      final resolution = notifier().rename(TabId.today, 'a' * 40);

      expect(resolution.rejection, NavRuleViolation.invalidLabel);
      expect(container.read(navDraftProvider), before);
    });

    test('rejects invisible characters', () {
      final resolution = notifier().rename(TabId.today, '用\u202E药');

      expect(resolution.rejection, NavRuleViolation.invalidLabel);
    });
  });

  group('setVisible', () {
    setUp(() => notifier().begin());

    test('hides a non-home tab', () {
      final resolution = notifier().setVisible(TabId.review, false);

      expect(resolution.isAccepted, isTrue);
      expect(
        container.read(navDraftRowsProvider).where((r) => r.isVisible).length,
        shellTabRegistry.length - 1,
      );
    });

    test('rejects hiding the home tab', () {
      final before = container.read(navDraftProvider);

      final resolution = notifier().setVisible(TabId.today, false);

      expect(resolution.rejection, NavRuleViolation.homeTabHidden);
      expect(container.read(navDraftProvider), before);
    });

    test('rejects dropping below the visible minimum', () {
      notifier().setVisible(TabId.review, false);
      notifier().setVisible(TabId.mine, false);
      final before = container.read(navDraftProvider);

      // 第三个隐藏会只剩 2 个可见，低于下限。
      final resolution = notifier().setVisible(TabId.record, false);

      expect(resolution.rejection, NavRuleViolation.tooFewVisible);
      expect(container.read(navDraftProvider), before);
    });
  });

  group('setIcon', () {
    setUp(() => notifier().begin());

    test('accepts a known lucide name', () {
      final resolution = notifier().setIcon(TabId.today, 'pill');

      expect(resolution.isAccepted, isTrue);
    });

    test('rejects an unknown icon name', () {
      final resolution = notifier().setIcon(TabId.today, 'not-a-real-icon');

      expect(resolution.rejection, NavRuleViolation.unknownIcon);
    });

    test('null clears back to the registry default', () {
      notifier().setIcon(TabId.today, 'pill');
      notifier().setIcon(TabId.today, null);

      final today = container
          .read(navDraftProvider)!
          .tabs!
          .firstWhere((t) => t.tabId == TabId.today);
      expect(today.iconName, isNull);
    });
  });

  group('commit', () {
    setUp(() => notifier().begin());

    test('writes the draft into the saved config and ends the draft', () {
      notifier().move(TabId.medicine, -1);
      final resolution = notifier().commit();

      expect(resolution.isAccepted, isTrue);
      expect(container.read(navDraftProvider), isNull);
      expect(
        container.read(resolvedNavProvider).map((r) => r.id).toList(),
        orderWithMedicineSecond(),
      );
    });

    test('an unedited draft commits to the default ordering', () {
      // 提交一份没改过的草稿等价于「把补全后的默认配置存一份」——
      // 内容与默认一致，因此渲染结果不变。
      final resolution = notifier().commit();

      expect(resolution.isAccepted, isTrue);
      expect(
        container.read(resolvedNavProvider).map((r) => r.id).toList(),
        shellTabDefaultOrder,
      );
    });

    test('discard leaves the saved config untouched', () {
      notifier().move(TabId.mine, -3);
      notifier().discard();

      expect(container.read(navConfigProvider).isDefault, isTrue);
      expect(container.read(navDraftProvider), isNull);
    });
  });

  group('restoreDefaults', () {
    test('clears a customised config', () async {
      container
          .read(navConfigProvider.notifier)
          .commit(
            const NavConfig(
              tabs: [
                TabPlacement(tabId: TabId.today, order: 0, customLabel: '总结'),
                TabPlacement(tabId: TabId.record, order: 1),
                TabPlacement(tabId: TabId.medicine, order: 2),
                TabPlacement(tabId: TabId.review, order: 3),
                TabPlacement(tabId: TabId.mine, order: 4),
              ],
            ),
          );

      notifier().begin();
      await notifier().restoreDefaults();

      expect(container.read(navConfigProvider).isDefault, isTrue);
      expect(container.read(navDraftProvider), isNull);
    });
  });
}

/// 把 medicine 上移一位之后的预期顺序。
List<TabId> orderWithMedicineSecond() => const [
  TabId.today,
  TabId.medicine,
  TabId.record,
  TabId.review,
  TabId.mine,
];
