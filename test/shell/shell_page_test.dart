import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/shell/presentation/page.dart';
import 'package:luminous/features/shell/presentation/tab.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_forui_app.dart';
import '../helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              ShellPage(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) =>
                      const SizedBox(key: Key('tab-today')),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/record',
                  builder: (context, state) =>
                      const SizedBox(key: Key('tab-record')),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/medicine',
                  builder: (context, state) =>
                      const SizedBox(key: Key('tab-medicine')),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/review',
                  builder: (context, state) =>
                      const SizedBox(key: Key('tab-report')),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/mine',
                  builder: (context, state) =>
                      const SizedBox(key: Key('tab-mine')),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Future<void> pumpShell(
    WidgetTester tester, {
    required GoRouter router,
    List<Override> overrides = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: TestForuiRouterApp(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  group('ShellPage – mobile layout', () {
    testWidgets('renders bottom navigation bar with 5 tabs', (tester) async {
      setMobileScreenSize(tester);
      await pumpShell(tester, router: buildRouter());

      expect(find.byType(FBottomNavigationBar), findsOneWidget);
      // 5 tab items
      expect(find.byType(FBottomNavigationBarItem), findsNWidgets(5));
    });

    testWidgets('renders all tab labels', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      setMobileScreenSize(tester);
      await pumpShell(tester, router: buildRouter());

      expect(find.text(l10n.tabToday), findsOneWidget);
      expect(find.text(l10n.tabRecord), findsOneWidget);
      expect(find.text(l10n.tabMedicine), findsOneWidget);
      expect(find.text(l10n.tabReview), findsOneWidget);
      expect(find.text(l10n.tabMine), findsOneWidget);
    });

    testWidgets('renders tab test keys', (tester) async {
      setMobileScreenSize(tester);
      await pumpShell(tester, router: buildRouter());

      for (final tab in ShellTab.values) {
        expect(find.byKey(tab.testKey()), findsOneWidget);
      }
    });

    testWidgets('does not render sidebar on mobile', (tester) async {
      setMobileScreenSize(tester);
      await pumpShell(tester, router: buildRouter());

      expect(find.byType(FSidebar), findsNothing);
    });

    testWidgets('shows first tab content on launch', (tester) async {
      setMobileScreenSize(tester);
      await pumpShell(tester, router: buildRouter());

      expect(find.byKey(const Key('tab-today')), findsOneWidget);
    });

    testWidgets('navigates to record tab on tap', (tester) async {
      setMobileScreenSize(tester);
      await pumpShell(tester, router: buildRouter());

      await tester.tap(find.byKey(ShellTab.record.testKey()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('tab-record')), findsOneWidget);
    });

    testWidgets('navigates to medicine tab on tap', (tester) async {
      setMobileScreenSize(tester);
      await pumpShell(tester, router: buildRouter());

      await tester.tap(find.byKey(ShellTab.medicine.testKey()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('tab-medicine')), findsOneWidget);
    });

    testWidgets('navigates to report tab on tap', (tester) async {
      setMobileScreenSize(tester);
      await pumpShell(tester, router: buildRouter());

      await tester.tap(find.byKey(ShellTab.review.testKey()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('tab-report')), findsOneWidget);
    });

    testWidgets('navigates to mine tab on tap', (tester) async {
      setMobileScreenSize(tester);
      await pumpShell(tester, router: buildRouter());

      await tester.tap(find.byKey(ShellTab.mine.testKey()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('tab-mine')), findsOneWidget);
    });
  });

  group('ShellPage – desktop layout', () {
    testWidgets('renders sidebar with 5 tabs', (tester) async {
      setDesktopScreenSize(tester);
      await pumpShell(tester, router: buildRouter());

      expect(find.byType(FSidebar), findsOneWidget);
      expect(
        find.byType(FSidebarItem),
        findsNWidgets(9),
      ); // 5 tabs + notifications + theme toggle + settings + help
    });

    testWidgets('renders tab labels in sidebar', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      setDesktopScreenSize(tester);
      await pumpShell(tester, router: buildRouter());

      expect(find.text(l10n.tabToday), findsOneWidget);
      expect(find.text(l10n.tabRecord), findsOneWidget);
      expect(find.text(l10n.tabMedicine), findsOneWidget);
      expect(find.text(l10n.tabReview), findsOneWidget);
      expect(find.text(l10n.tabMine), findsOneWidget);
    });

    testWidgets('renders app title in sidebar header', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      setDesktopScreenSize(tester);
      await pumpShell(tester, router: buildRouter());

      expect(find.text(l10n.appTitle), findsOneWidget);
    });

    testWidgets('renders settings and help in sidebar footer', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      setDesktopScreenSize(tester);
      await pumpShell(tester, router: buildRouter());

      expect(find.text(l10n.desktopSidebarSettings), findsOneWidget);
      expect(find.text(l10n.desktopSidebarHelp), findsOneWidget);
    });

    testWidgets('does not render bottom nav on desktop', (tester) async {
      setDesktopScreenSize(tester);
      await pumpShell(tester, router: buildRouter());

      expect(find.byType(FBottomNavigationBar), findsNothing);
    });

    testWidgets('shows first tab content on launch', (tester) async {
      setDesktopScreenSize(tester);
      await pumpShell(tester, router: buildRouter());

      expect(find.byKey(const Key('tab-today')), findsOneWidget);
    });

    testWidgets('navigates to medicine tab on sidebar click', (tester) async {
      setDesktopScreenSize(tester);
      await pumpShell(tester, router: buildRouter());

      await tester.tap(find.byKey(ShellTab.medicine.testKey()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('tab-medicine')), findsOneWidget);
    });

    testWidgets('renders profile user icon in authenticated header', (
      tester,
    ) async {
      setDesktopScreenSize(tester);
      await pumpShell(
        tester,
        router: buildRouter(),
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        ],
      );

      expect(find.byIcon(SemanticIcons.profileUser), findsOneWidget);
    });
  });
}
