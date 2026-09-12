import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/shell/presentation/tab.dart';
import 'package:luminous/features/shell/presentation/tab_branch_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  /// A shell whose tab roots are trivial widgets, so the only thing under test
  /// is the branch container's own behaviour.
  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: _paths[ShellTab.today]!,
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
                        for (final tab in ShellTab.values)
                          TextButton(
                            key: tab.testKey(),
                            onPressed: () =>
                                navigationShell.goBranch(tab.index),
                            child: Text('${tab.index}'),
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
            for (final tab in ShellTab.values)
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: _paths[tab]!,
                    pageBuilder: (context, state) => NoTransitionPage(
                      key: state.pageKey,
                      child: SizedBox(
                        key: ValueKey<String>('page-${tab.name}'),
                        child: Text('page-${tab.name}'),
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

  Finder branchRoot(ShellTab tab) =>
      find.byKey(ValueKey<String>('page-${tab.name}'), skipOffstage: false);

  /// Walks up from a branch's root element and returns the *innermost* ancestor
  /// of type [T] that was produced by the container.
  ///
  /// Both are needed: the branch Navigator nests its own `IgnorePointer` and
  /// `AnimatedOpacity` inside the container's wrappers, so the container's copy
  /// is the innermost match *below* the next [ShellTabBranchContainer]. Uses the
  /// element tree directly because `find.ancestor` cannot see an offstage
  /// branch's ancestors.
  T containerWrapper<T extends Widget>(WidgetTester tester, ShellTab tab) {
    final elements = branchRoot(tab).evaluate();
    if (elements.length != 1) {
      throw StateError(
        'branch ${tab.name}: expected 1 element, got ${elements.length}',
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
        'branch ${tab.name}: no ShellTabBranchContainer ancestor',
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
    throw StateError('branch ${tab.name}: no $T supplied by the container');
  }

  /// The `AnimatedOpacity` the container wraps one branch in.
  AnimatedOpacity branchOpacity(WidgetTester tester, ShellTab tab) =>
      containerWrapper<AnimatedOpacity>(tester, tab);

  /// The `IgnorePointer` the container wraps one branch in.
  IgnorePointer branchIgnorePointer(WidgetTester tester, ShellTab tab) =>
      containerWrapper<IgnorePointer>(tester, tab);

  /// The branch roots currently laid out (i.e. not offstage).
  Set<ShellTab> onstageTabs(WidgetTester tester) => ShellTab.values
      .where(
        (tab) => tester
            .widgetList<SizedBox>(
              find.byWidgetPredicate(
                (widget) =>
                    widget is SizedBox &&
                    widget.key == ValueKey<String>('page-${tab.name}'),
              ),
            )
            .isNotEmpty,
      )
      .toSet();

  group('ShellTabBranchContainer', () {
    testWidgets('lazily mounts branches and keeps visited ones alive', (
      tester,
    ) async {
      setMobileScreenSize(tester);
      await pumpShell(tester, buildRouter());

      // Only the current tab's branch exists on first paint.
      expect(onstageTabs(tester), {ShellTab.today});

      await tester.tap(find.byKey(ShellTab.record.testKey()));
      await tester.pumpAndSettle();
      expect(onstageTabs(tester), {ShellTab.record});

      await tester.tap(find.byKey(ShellTab.today.testKey()));
      await tester.pumpAndSettle();

      // Today is onstage again; Record is still *mounted* (offstage), which is
      // what preserves per-tab state across switches.
      expect(onstageTabs(tester), {ShellTab.today});
      expect(branchRoot(ShellTab.record), findsOneWidget);
      expect(find.text('page-record'), findsNothing);
    });

    testWidgets('non-current branches are onstage only while fading out', (
      tester,
    ) async {
      setMobileScreenSize(tester);
      await pumpShell(tester, buildRouter());

      await tester.tap(find.byKey(ShellTab.record.testKey()));
      await tester.pump();
      // Right after the switch both branches are onstage: the outgoing one is
      // still mid fade-out.
      await tester.pump(const Duration(milliseconds: 32));
      expect(onstageTabs(tester), {ShellTab.today, ShellTab.record});

      // Once the fade finishes the outgoing branch is dropped offstage again.
      await tester.pumpAndSettle();
      expect(onstageTabs(tester), {ShellTab.record});
    });

    testWidgets('fades the incoming branch up and the outgoing branch down', (
      tester,
    ) async {
      setMobileScreenSize(tester);
      await pumpShell(tester, buildRouter());

      // Only Today is mounted yet (branches load on demand), and it is the
      // current one: full opacity, incoming duration.
      expect(branchOpacity(tester, ShellTab.today).opacity, 1.0);
      expect(
        branchOpacity(tester, ShellTab.today).duration,
        DurationTokens.tabFadeThrough,
      );

      // Sample early in the transition: both branches are on screen and neither
      // has taken over yet. This is exactly the window a front-loaded curve gets
      // wrong — with an M3 emphasized curve the outgoing branch is already down
      // to ~0.66 while the incoming one is only at ~0.15, so the switch reads as
      // washed out. `easeOut` keeps the hand-off monotone instead.
      await tester.tap(find.byKey(ShellTab.record.testKey()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      expect(onstageTabs(tester), {ShellTab.today, ShellTab.record});
      expect(
        branchOpacity(tester, ShellTab.today).duration,
        DurationTokens.tabFadeThroughOut,
      );
      expect(
        branchOpacity(tester, ShellTab.record).duration,
        DurationTokens.tabFadeThrough,
      );
      // Neither curve may be the front-loaded M3 emphasized one: that is what
      // made both branches read as washed out in the middle of the hand-off.
      expect(branchOpacity(tester, ShellTab.today).curve, MotionTokens.snappy);
      expect(branchOpacity(tester, ShellTab.record).curve, MotionTokens.snappy);
      expect(
        branchOpacity(tester, ShellTab.record).curve,
        isNot(Curves.easeInOutCubicEmphasized),
      );
      expect(
        branchOpacity(tester, ShellTab.today).curve,
        isNot(Curves.easeInOutCubicEmphasized),
      );

      await tester.pumpAndSettle();
      expect(branchOpacity(tester, ShellTab.today).opacity, 0.0);
      expect(branchOpacity(tester, ShellTab.record).opacity, 1.0);
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
      await tester.tap(find.byKey(ShellTab.record.testKey()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      await tester.tap(find.byKey(ShellTab.medicine.testKey()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      await tester.tap(find.byKey(ShellTab.review.testKey()));
      await tester.pump();

      await tester.pumpAndSettle();

      expect(onstageTabs(tester), {ShellTab.review});
      expect(branchOpacity(tester, ShellTab.review).opacity, 1.0);
      for (final tab in [ShellTab.today, ShellTab.record, ShellTab.medicine]) {
        expect(
          branchOpacity(tester, tab).opacity,
          0.0,
          reason: '${tab.name} should have finished fading out',
        );
      }
    });

    testWidgets('ignores pointer events on a branch that is fading out', (
      tester,
    ) async {
      setMobileScreenSize(tester);
      await pumpShell(tester, buildRouter());

      expect(branchIgnorePointer(tester, ShellTab.today).ignoring, isFalse);

      await tester.tap(find.byKey(ShellTab.record.testKey()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 32));

      // The outgoing branch is visible but must not accept input.
      expect(branchIgnorePointer(tester, ShellTab.today).ignoring, isTrue);
      expect(branchIgnorePointer(tester, ShellTab.record).ignoring, isFalse);

      await tester.pumpAndSettle();
    });
  });
}

const Map<ShellTab, String> _paths = <ShellTab, String>{
  ShellTab.today: '/',
  ShellTab.record: '/record',
  ShellTab.medicine: '/medicine',
  ShellTab.review: '/review',
  ShellTab.mine: '/mine',
};
