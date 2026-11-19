import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/network/config/pref_keys.dart';
import 'package:luminous/features/shell/domain/entities/nav_config.dart';
import 'package:luminous/features/shell/presentation/page.dart';
import 'package:luminous/features/shell/presentation/providers/nav_config.dart';
import 'package:luminous/features/shell/presentation/tab.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/kv_test_store.dart';
import '../helpers/test_forui_app.dart';
import '../helpers/test_helpers.dart';

/// 配置化导航的**端到端**行为：用户配置改了之后，底栏真的按配置渲染。
///
/// 这里不重跑 `nav_rules` 的单测覆盖（规则本身另有测试），只钉住一件事：
/// 渲染层确实消费了 `visibleNavProvider`，而不是还看着注册表的固定顺序。
void main() {
  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        // 默认的 IndexedStack 容器即可：这个文件测的是底栏数据驱动，
        // 交叉淡化的行为另有 tab_branch_container_test 覆盖。
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              ShellPage(navigationShell: navigationShell),
          branches: [
            for (final tab in shellTabRegistry)
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: tab.path,
                    builder: (context, state) =>
                        SizedBox(key: ValueKey<String>('page-${tab.id.value}')),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Future<void> pumpShell(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(child: TestForuiRouterApp(routerConfig: buildRouter())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  /// 底栏当前渲染的 label 文案，按位置顺序。
  List<String> renderedLabels(WidgetTester tester) {
    return tester
        .widgetList<FBottomNavigationBarItem>(
          find.byType(FBottomNavigationBarItem),
        )
        .map((item) {
          final label = item.label;
          if (label is Text) return label.data ?? '';
          return '';
        })
        .toList();
  }

  group('默认配置', () {
    testWidgets('底部导航按注册表顺序渲染五个 tab', (tester) async {
      setMobileScreenSize(tester);
      KvTestStore.install();
      await pumpShell(tester);

      expect(find.byType(FBottomNavigationBarItem), findsNWidgets(5));

      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(renderedLabels(tester), [
        l10n.tabToday,
        l10n.tabRecord,
        l10n.tabMedicine,
        l10n.tabReview,
        l10n.tabMine,
      ]);
    });

    testWidgets('每个 tab 的 test key 都在', (tester) async {
      setMobileScreenSize(tester);
      KvTestStore.install();
      await pumpShell(tester);

      for (final tab in shellTabRegistry) {
        expect(find.byKey(shellTabKey(tab.id)), findsOneWidget);
      }
    });
  });

  group('自定义顺序', () {
    testWidgets('底栏按用户顺序渲染', (tester) async {
      // 让 medicine 排到第一位，today 退到第二。
      KvTestStore.install(
        seed: {
          PrefKeys.shellNavConfig: const NavConfig(
            tabs: [
              TabPlacement(tabId: TabId.medicine, order: 0),
              TabPlacement(tabId: TabId.today, order: 1),
              TabPlacement(tabId: TabId.record, order: 2),
              TabPlacement(tabId: TabId.review, order: 3),
              TabPlacement(tabId: TabId.mine, order: 4),
            ],
          ).toJson(),
        },
      );
      setMobileScreenSize(tester);
      await pumpShell(tester);

      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(renderedLabels(tester), [
        l10n.tabMedicine,
        l10n.tabToday,
        l10n.tabRecord,
        l10n.tabReview,
        l10n.tabMine,
      ]);
    });

    testWidgets('点第一格跳到它对应的分支，而不是 branch 0', (tester) async {
      // 顺序打乱后，底栏第 0 格是 medicine；点它必须落到 medicine 的页面。
      KvTestStore.install(
        seed: {
          PrefKeys.shellNavConfig: const NavConfig(
            tabs: [
              TabPlacement(tabId: TabId.medicine, order: 0),
              TabPlacement(tabId: TabId.today, order: 1),
              TabPlacement(tabId: TabId.record, order: 2),
            ],
          ).toJson(),
        },
      );
      setMobileScreenSize(tester);
      await pumpShell(tester);

      await tester.tap(find.byKey(shellTabKey(TabId.medicine)));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('page-medicine')),
        findsOneWidget,
      );
    });

    testWidgets('底栏选中态跟着用户的顺序走', (tester) async {
      KvTestStore.install(
        seed: {
          PrefKeys.shellNavConfig: const NavConfig(
            tabs: [
              TabPlacement(tabId: TabId.review, order: 0),
              TabPlacement(tabId: TabId.today, order: 1),
              TabPlacement(tabId: TabId.record, order: 2),
              TabPlacement(tabId: TabId.medicine, order: 3),
              TabPlacement(tabId: TabId.mine, order: 4),
            ],
          ).toJson(),
        },
      );
      setMobileScreenSize(tester);
      await pumpShell(tester);

      // 冷启动落在 today（branch 0）。配置里 today 排在 review 之后 →
      // 它是第 1 格；底栏的选中态必须报 1，而不是 branch 下标 0。
      final bar = tester.widget<FBottomNavigationBar>(
        find.byType(FBottomNavigationBar),
      );
      expect(bar.index, 1);
    });
  });

  group('自定义名称与图标', () {
    testWidgets('自定义名称替换 ARB 默认文案', (tester) async {
      KvTestStore.install(
        seed: {
          PrefKeys.shellNavConfig: const NavConfig(
            tabs: [
              TabPlacement(tabId: TabId.today, order: 0, customLabel: '总结'),
              TabPlacement(tabId: TabId.record, order: 1),
              TabPlacement(tabId: TabId.medicine, order: 2),
            ],
          ).toJson(),
        },
      );
      setMobileScreenSize(tester);
      await pumpShell(tester);

      expect(find.text('总结'), findsOneWidget);

      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(find.text(l10n.tabToday), findsNothing);
    });

    testWidgets('没自定义的 tab 仍显示 ARB 默认文案', (tester) async {
      KvTestStore.install(
        seed: {
          PrefKeys.shellNavConfig: const NavConfig(
            tabs: [
              TabPlacement(tabId: TabId.today, order: 0, customLabel: '总结'),
              TabPlacement(tabId: TabId.record, order: 1),
              TabPlacement(tabId: TabId.medicine, order: 2),
            ],
          ).toJson(),
        },
      );
      setMobileScreenSize(tester);
      await pumpShell(tester);

      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(find.text(l10n.tabRecord), findsOneWidget);
    });
  });

  group('隐藏 tab', () {
    testWidgets('隐藏的 tab 不出现在底栏', (tester) async {
      KvTestStore.install(
        seed: {
          PrefKeys.shellNavConfig: const NavConfig(
            tabs: [
              TabPlacement(tabId: TabId.today, order: 0),
              TabPlacement(tabId: TabId.record, order: 1),
              TabPlacement(tabId: TabId.medicine, order: 2),
              TabPlacement(tabId: TabId.review, order: 3, isVisible: false),
              TabPlacement(tabId: TabId.mine, order: 4, isVisible: false),
            ],
          ).toJson(),
        },
      );
      setMobileScreenSize(tester);
      await pumpShell(tester);

      expect(find.byType(FBottomNavigationBarItem), findsNWidgets(3));
      expect(find.byKey(shellTabKey(TabId.review)), findsNothing);
      expect(find.byKey(shellTabKey(TabId.mine)), findsNothing);
      expect(find.byKey(shellTabKey(TabId.today)), findsOneWidget);
    });

    testWidgets('隐藏后其余 tab 的顺序保持', (tester) async {
      KvTestStore.install(
        seed: {
          PrefKeys.shellNavConfig: const NavConfig(
            tabs: [
              TabPlacement(tabId: TabId.mine, order: 0),
              TabPlacement(tabId: TabId.today, order: 1),
              TabPlacement(tabId: TabId.record, order: 2, isVisible: false),
              TabPlacement(tabId: TabId.medicine, order: 3),
              TabPlacement(tabId: TabId.review, order: 4, isVisible: false),
            ],
          ).toJson(),
        },
      );
      setMobileScreenSize(tester);
      await pumpShell(tester);

      // 只列出配置里的每一项，隐藏的两项不出现，其余保持相对顺序。
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(renderedLabels(tester), [
        l10n.tabMine,
        l10n.tabToday,
        l10n.tabMedicine,
      ]);
    });
  });

  group('坏数据降级', () {
    testWidgets('未知 schemaVersion 回退默认顺序', (tester) async {
      KvTestStore.install(
        seed: {
          PrefKeys.shellNavConfig: {
            'schemaVersion': 999,
            'tabs': [
              {'tabId': 'medicine', 'order': 0},
            ],
          },
        },
      );
      setMobileScreenSize(tester);
      await pumpShell(tester);

      // 回退默认 = 五个 tab、注册表顺序。
      expect(find.byType(FBottomNavigationBarItem), findsNWidgets(5));

      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(renderedLabels(tester).first, l10n.tabToday);
    });

    testWidgets('配置里缺失的 tab 由注册表补全', (tester) async {
      // 只存了两项：其余三个必须补回来，否则用户会少掉几个 tab。
      KvTestStore.install(
        seed: {
          PrefKeys.shellNavConfig: const NavConfig(
            tabs: [
              TabPlacement(tabId: TabId.today, order: 0),
              TabPlacement(tabId: TabId.mine, order: 1),
            ],
          ).toJson(),
        },
      );
      setMobileScreenSize(tester);
      await pumpShell(tester);

      expect(find.byType(FBottomNavigationBarItem), findsNWidgets(5));
      for (final tab in shellTabRegistry) {
        expect(find.byKey(shellTabKey(tab.id)), findsOneWidget);
      }
    });
  });

  group('编排 → 渲染的往返', () {
    testWidgets('改配置后底栏立即重建', (tester) async {
      KvTestStore.install();
      setMobileScreenSize(tester);
      await pumpShell(tester);

      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(renderedLabels(tester).first, l10n.tabToday);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(ShellPage)),
      );
      final resolution = container
          .read(navConfigProvider.notifier)
          .commit(
            const NavConfig(
              tabs: [
                TabPlacement(tabId: TabId.mine, order: 0),
                TabPlacement(tabId: TabId.today, order: 1),
                TabPlacement(tabId: TabId.record, order: 2),
              ],
            ),
          );
      expect(resolution.isAccepted, isTrue);

      await tester.pumpAndSettle();

      expect(renderedLabels(tester).first, l10n.tabMine);
    });

    testWidgets('非法编辑被拒绝，底栏保持原样', (tester) async {
      KvTestStore.install();
      setMobileScreenSize(tester);
      await pumpShell(tester);

      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      final before = renderedLabels(tester);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(ShellPage)),
      );
      final resolution = container
          .read(navConfigProvider.notifier)
          .commit(
            // 全部隐藏：可见数 0 < 3，必须被拒。
            const NavConfig(
              tabs: [
                TabPlacement(tabId: TabId.today, order: 0, isVisible: false),
                TabPlacement(tabId: TabId.record, order: 1, isVisible: false),
                TabPlacement(tabId: TabId.medicine, order: 2, isVisible: false),
              ],
            ),
          );

      expect(resolution.isAccepted, isFalse);
      await tester.pumpAndSettle();

      expect(renderedLabels(tester), before);
      expect(renderedLabels(tester).first, l10n.tabToday);
    });
  });
}
