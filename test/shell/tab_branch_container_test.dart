import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/shell/domain/entities/nav_config.dart';
import 'package:luminous/features/shell/domain/entities/tab_definition.dart';
import 'package:luminous/features/shell/presentation/tab.dart';
import 'package:luminous/features/shell/presentation/tab_branch_container.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/kv_test_store.dart';
import '../helpers/test_forui_app.dart';
import '../helpers/test_helpers.dart';

/// Widget tests for [ShellTabBranchContainer] — the custom branch container
/// that replaces `StatefulShellRoute.indexedStack` to cross-fade tab switches.
///
/// The container promises two things the rest of the app and the whole test
/// suite depend on: every visited branch stays mounted, and only the active
/// branch is onstage (so finders see a single tab's content). Both are asserted
/// here, together with the fade behaviour and the rapid-switch case that a
/// single-`int?` "transitioning from" field used to break.
void main() {
  setUpAll(() {
    KvTestStore.install(seed: const <String, Object>{});
  });

  /// A shell whose tab roots are trivial widgets, so the only thing under test
  /// is the branch container's own behaviour.
  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: _paths[TabId.today]!,
      routes: [
        StatefulShellRoute(
          // `builder` must hand the shell through untouched — the branch
          // Navigators and the surrounding chrome both live in
          // `navigatorContainerBuilder` (this is go_router's custom
          // StatefulShellRoute shape).
          builder: (context, state, navigationShell) => navigationShell,
          navigatorContainerBuilder: (context, navigationShell, children) =>
              Scaffold(
                body: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (final tab in shellTabRegistry)
                          TextButton(
                            key: shellTabKey(tab.id),
                            onPressed: () =>
                                navigationShell.goBranch(tab.branchIndex),
                            child: Text('${tab.branchIndex}'),
                          ),
                      ],
                    ),
                    Expanded(
                      child: ShellTabBranchContainer(
                        navigationShell: navigationShell,
                        children: children,
                      ),
                    ),
                  ],
                ),
              ),
          branches: [
            for (final tab in shellTabRegistry)
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: _paths[tab.id]!,
                    pageBuilder: (context, state) => NoTransitionPage(
                      key: state.pageKey,
                      child: SizedBox(
                        key: ValueKey<String>('page-${tab.id.value}'),
                        child: Text('page-${tab.id.value}'),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Future<void> pumpShell(WidgetTester tester, GoRouter router) async {
    await tester.pumpWidget(TestForuiRouterApp(routerConfig: router));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Finder branchRoot(TabDefinition tab) =>
      find.byKey(ValueKey<String>('page-${tab.id.value}'), skipOffstage: false);

  /// 按身份取注册表条目；测试里描述「哪个分支」比「第几条」更稳。
  TabDefinition tabDef(TabId id) =>
      shellTabRegistry.firstWhere((tab) => tab.id == id);

  /// Walks up from a branch's root element and returns the *innermost* ancestor
  /// of type [T] that was produced by the container.
  ///
  /// Both are needed: the branch Navigator nests its own `IgnorePointer` and
  /// `AnimatedOpacity` inside the container's wrappers, so the container's copy
  /// is the innermost match *below* the next [ShellTabBranchContainer]. Uses the
  /// element tree directly because `find.ancestor` cannot see an offstage
  /// branch's ancestors.
  T containerWrapper<T extends Widget>(WidgetTester tester, TabDefinition tab) {
    final elements = branchRoot(tab).evaluate();
    if (elements.length != 1) {
      throw StateError(
        'branch ${tab.id.value}: expected 1 element, got ${elements.length}',
      );
    }
    final chain = <Widget>[];
    elements.single.visitAncestorElements((element) {
      chain.add(element.widget);
      return true;
    });
    final containerIndex = chain.lastIndexWhere(
      (widget) => widget is ShellTabBranchContainer,
    );
    if (containerIndex < 0) {
      throw StateError(
        'branch ${tab.id.value}: no ShellTabBranchContainer ancestor',
      );
    }
    final scope = containerIndex == 0
        ? chain
        : chain.sublist(0, containerIndex);
    // Innermost match wins: the container nests its wrappers *inside* the branch
    // Navigator, so the deepest match is the one the container supplied.
    for (final widget in scope.reversed) {
      if (widget is T) {
        return widget;
      }
    }
    throw StateError('branch ${tab.id.value}: no $T supplied by the container');
  }

  /// The `AnimatedOpacity` the container wraps one branch in.
  AnimatedOpacity branchOpacity(WidgetTester tester, TabDefinition tab) =>
      containerWrapper<AnimatedOpacity>(tester, tab);

  /// The `IgnorePointer` the container wraps one branch in.
  IgnorePointer branchIgnorePointer(WidgetTester tester, TabDefinition tab) =>
      containerWrapper<IgnorePointer>(tester, tab);

  /// The branch roots currently laid out (i.e. not offstage).
  Set<TabId> onstageTabs(WidgetTester tester) => shellTabRegistry
      .where(
        (tab) => tester
            .widgetList<SizedBox>(
              find.byWidgetPredicate(
                (widget) =>
                    widget is SizedBox &&
                    widget.key == ValueKey<String>('page-${tab.id.value}'),
              ),
            )
            .isNotEmpty,
      )
      .map((tab) => tab.id)
      .toSet();

  group('ShellTabBranchContainer', () {
    testWidgets('lazily mounts branches and keeps visited ones alive', (
      tester,
    ) async {
      setMobileScreenSize(tester);
      await pumpShell(tester, buildRouter());

      // Only the current tab's branch exists on first paint.
      expect(onstageTabs(tester), {TabId.today});

      await tester.tap(find.byKey(shellTabKey(TabId.record)));
      await tester.pumpAndSettle();
      expect(onstageTabs(tester), {TabId.record});

      await tester.tap(find.byKey(shellTabKey(TabId.today)));
      await tester.pumpAndSettle();

      // Today is onstage again; Record is still *mounted* (offstage), which is
      // what preserves per-tab state across switches.
      expect(onstageTabs(tester), {TabId.today});
      expect(branchRoot(tabDef(TabId.record)), findsOneWidget);
      expect(find.text('page-record'), findsNothing);
    });

    testWidgets('non-current branches are onstage only while fading out', (
      tester,
    ) async {
      setMobileScreenSize(tester);
      await pumpShell(tester, buildRouter());

      await tester.tap(find.byKey(shellTabKey(TabId.record)));
      await tester.pump();
      // Right after the switch both branches are onstage: the outgoing one is
      // still mid fade-out.
      await tester.pump(const Duration(milliseconds: 32));
      expect(onstageTabs(tester), {TabId.today, TabId.record});

      // Once the fade finishes the outgoing branch is dropped offstage again.
      await tester.pumpAndSettle();
      expect(onstageTabs(tester), {TabId.record});
    });

    testWidgets('fades the incoming branch up and the outgoing branch down', (
      tester,
    ) async {
      setMobileScreenSize(tester);
      await pumpShell(tester, buildRouter());

      // Only Today is mounted yet (branches load on demand), and it is the
      // current one: full opacity, incoming duration.
      expect(branchOpacity(tester, tabDef(TabId.today)).opacity, 1.0);
      expect(
        branchOpacity(tester, tabDef(TabId.today)).duration,
        DurationTokens.tabFadeThrough,
      );

      // Sample early in the transition: both branches are on screen and neither
      // has taken over yet. This is exactly the window a front-loaded curve gets
      // wrong — with an M3 emphasized curve the outgoing branch is already down
      // to ~0.66 while the incoming one is only at ~0.15, so the switch reads as
      // washed out. `easeOut` keeps the hand-off monotone instead.
      await tester.tap(find.byKey(shellTabKey(TabId.record)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      expect(onstageTabs(tester), {TabId.today, TabId.record});
      expect(
        branchOpacity(tester, tabDef(TabId.today)).duration,
        DurationTokens.tabFadeThroughOut,
      );
      expect(
        branchOpacity(tester, tabDef(TabId.record)).duration,
        DurationTokens.tabFadeThrough,
      );
      // Neither curve may be the front-loaded M3 emphasized one: that is what
      // made both branches read as washed out in the middle of the hand-off.
      expect(
        branchOpacity(tester, tabDef(TabId.today)).curve,
        MotionTokens.snappy,
      );
      expect(
        branchOpacity(tester, tabDef(TabId.record)).curve,
        MotionTokens.snappy,
      );
      expect(
        branchOpacity(tester, tabDef(TabId.record)).curve,
        isNot(Curves.easeInOutCubicEmphasized),
      );
      expect(
        branchOpacity(tester, tabDef(TabId.today)).curve,
        isNot(Curves.easeInOutCubicEmphasized),
      );

      await tester.pumpAndSettle();
      expect(branchOpacity(tester, tabDef(TabId.today)).opacity, 0.0);
      expect(branchOpacity(tester, tabDef(TabId.record)).opacity, 1.0);
    });

    testWidgets('settles on the last branch after rapid consecutive switches', (
      tester,
    ) async {
      setMobileScreenSize(tester);
      await pumpShell(tester, buildRouter());

      // Today -> Record -> Medicine, each switch landing before the previous
      // fade finished. A single `int?` "transitioning from" field can only
      // remember one predecessor, which is exactly why the container tracks a
      // set; this asserts the end state is right and that no branch is left
      // behind half-faded. (The frame-level symptom — an earlier outgoing branch
      // being dropped offstage early — is not assertable through the element
      // tree here: go_router's branch Navigators live inside an Overlay whose
      // offstage handling is invisible to finders in this harness.)
      await tester.tap(find.byKey(shellTabKey(TabId.record)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      await tester.tap(find.byKey(shellTabKey(TabId.medicine)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      await tester.tap(find.byKey(shellTabKey(TabId.review)));
      await tester.pump();

      await tester.pumpAndSettle();

      expect(onstageTabs(tester), {TabId.review});
      expect(branchOpacity(tester, tabDef(TabId.review)).opacity, 1.0);
      for (final tab in [TabId.today, TabId.record, TabId.medicine]) {
        expect(
          branchOpacity(tester, tabDef(tab)).opacity,
          0.0,
          reason: '${tab.value} should have finished fading out',
        );
      }
    });

    testWidgets('ignores pointer events on a branch that is fading out', (
      tester,
    ) async {
      setMobileScreenSize(tester);
      await pumpShell(tester, buildRouter());

      expect(
        branchIgnorePointer(tester, tabDef(TabId.today)).ignoring,
        isFalse,
      );

      await tester.tap(find.byKey(shellTabKey(TabId.record)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 32));

      // The outgoing branch is visible but must not accept input.
      expect(branchIgnorePointer(tester, tabDef(TabId.today)).ignoring, isTrue);
      expect(
        branchIgnorePointer(tester, tabDef(TabId.record)).ignoring,
        isFalse,
      );

      await tester.pumpAndSettle();
    });
  });
}

/// 每个注册 tab 的根路径。直接用注册表的 `.path`，避免测试里再维护一份
/// 与生产代码同步的常量表——那正是「改了路径测试还是绿的」的来源。
final Map<TabId, String> _paths = {
  for (final tab in shellTabRegistry) tab.id: tab.path,
};
