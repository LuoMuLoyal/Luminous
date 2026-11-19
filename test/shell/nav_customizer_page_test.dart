import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/features/shell/domain/entities/nav_config.dart';
import 'package:luminous/features/shell/presentation/pages/nav_customizer.dart';
import 'package:luminous/features/shell/presentation/providers/nav_config.dart';
import 'package:luminous/features/shell/presentation/providers/nav_draft.dart';
import 'package:luminous/features/shell/presentation/tab.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/kv_test_store.dart';
import '../helpers/test_forui_app.dart';
import '../helpers/test_helpers.dart';

/// 编排页的 widget 行为：行数、上下移动、显隐、名称。
///
/// 规则判定与草稿语义在 `nav_rules_test` / `nav_draft_test` 已覆盖；这里只钉
/// 「页面确实把用户操作翻译成了草稿编辑」这件事。
void main() {
  setUp(() {
    KvTestStore.install();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    setMobileScreenSize(tester);
    await tester.pumpWidget(
      const ProviderScope(child: TestForuiApp(home: NavCustomizerPage())),
    );
    await tester.pumpAndSettle();
  }

  Finder rowFor(String tabId) => find.byKey(ValueKey<String>('nav-row-$tabId'));

  testWidgets('renders one row per registered tab', (tester) async {
    await pumpPage(tester);

    expect(find.byType(FTile), findsNWidgets(shellTabRegistry.length));
    for (final tab in shellTabRegistry) {
      expect(rowFor(tab.id.value), findsOneWidget);
    }
  });

  testWidgets('shows the page title and description', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    await pumpPage(tester);

    expect(find.text(l10n.shellNavCustomizeTitle), findsOneWidget);
    expect(find.text(l10n.shellNavCustomizeDescription), findsOneWidget);
  });

  testWidgets('renders the localised tab labels', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    await pumpPage(tester);

    expect(find.text(l10n.tabToday), findsOneWidget);
    expect(find.text(l10n.tabMedicine), findsOneWidget);
    // 名称下面是路由路径（稳定的身份提示）。
    expect(find.text('/medicine'), findsOneWidget);
  });

  testWidgets('visiting the page fills the draft', (tester) async {
    await pumpPage(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(NavCustomizerPage)),
    );
    expect(container.read(navDraftProvider)!.tabs, hasLength(5));
  });

  testWidgets('tapping move-down reorders the row', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    await pumpPage(tester);

    // today 在第一行；下移后它应该变成第二行。
    // 按钮经 `semanticsLabel` 标识（FTooltip 的文案不在 widget 树上，
    // `find.byTooltip` 匹配不到）。
    final moveDown = find.descendant(
      of: rowFor('today'),
      matching: find.bySemanticsLabel(l10n.shellNavMoveDown),
    );
    await tester.tap(moveDown.first);
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(NavCustomizerPage)),
    );
    final ids = container.read(navDraftRowsProvider).map((r) => r.id).toList();
    expect(ids.indexOf(TabId.today), 1);
  });

  testWidgets('toggling visibility updates the draft', (tester) async {
    await pumpPage(tester);

    final reviewRow = rowFor('review');
    final toggle = find.descendant(
      of: reviewRow,
      matching: find.byType(FSwitch),
    );
    await tester.tap(toggle.first);
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(NavCustomizerPage)),
    );
    expect(container.read(navConfigProvider).isDefault, isTrue);
    expect(
      container
          .read(navDraftRowsProvider)
          .firstWhere((r) => r.id == TabId.review)
          .isVisible,
      isFalse,
    );
  });

  testWidgets('renders the restore-defaults button', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    await pumpPage(tester);

    expect(find.text(l10n.shellNavRestoreDefaults), findsOneWidget);
  });
}
