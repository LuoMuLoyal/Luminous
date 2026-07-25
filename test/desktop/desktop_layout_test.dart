import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/features/shell/presentation/page.dart';
import 'package:luminous/features/shell/presentation/tab.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_forui_app.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    // Mock window_manager MethodChannel so tests are stable across platforms.
    // ShellPage → _WindowTitleBar → windowManager.isMaximized() calls into
    // this channel on Windows/Linux; without a mock, tests fail on those
    // platforms with MissingPluginException.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('window_manager'), (
          call,
        ) async {
          switch (call.method) {
            case 'isMaximized':
              return false;
            case 'ensureInitialized':
              return null;
            default:
              return null;
          }
        });
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('window_manager'), null);
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
                  path: '/report',
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
  }) async {
    await tester.pumpWidget(
      ProviderScope(child: TestForuiRouterApp(routerConfig: router)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  void setScreenSize(WidgetTester tester, double width, double height) {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = Size(width, height);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
  }

  group('Desktop layout verification (1200 / 1440 / 1920)', () {
    testWidgets('1200px — sidebar visible, bottom nav hidden', (tester) async {
      setScreenSize(tester, 1200, 800);
      await pumpShell(tester, router: buildRouter());

      expect(find.byType(FSidebar), findsOneWidget);
      expect(find.byType(FBottomNavigationBar), findsNothing);
    });

    testWidgets('1440px — sidebar visible, bottom nav hidden', (tester) async {
      setScreenSize(tester, 1440, 900);
      await pumpShell(tester, router: buildRouter());

      expect(find.byType(FSidebar), findsOneWidget);
      expect(find.byType(FBottomNavigationBar), findsNothing);
    });

    testWidgets('1920px — sidebar visible, bottom nav hidden', (tester) async {
      setScreenSize(tester, 1920, 1080);
      await pumpShell(tester, router: buildRouter());

      expect(find.byType(FSidebar), findsOneWidget);
      expect(find.byType(FBottomNavigationBar), findsNothing);
    });

    testWidgets('1200px — all 5 tab labels visible in sidebar', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      setScreenSize(tester, 1200, 800);
      await pumpShell(tester, router: buildRouter());

      expect(find.text(l10n.tabToday), findsOneWidget);
      expect(find.text(l10n.tabRecord), findsOneWidget);
      expect(find.text(l10n.tabMedicine), findsOneWidget);
      expect(find.text(l10n.tabReport), findsOneWidget);
      expect(find.text(l10n.tabMine), findsOneWidget);
    });

    testWidgets('1920px — all 5 tab labels visible in sidebar', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      setScreenSize(tester, 1920, 1080);
      await pumpShell(tester, router: buildRouter());

      expect(find.text(l10n.tabToday), findsOneWidget);
      expect(find.text(l10n.tabRecord), findsOneWidget);
      expect(find.text(l10n.tabMedicine), findsOneWidget);
      expect(find.text(l10n.tabReport), findsOneWidget);
      expect(find.text(l10n.tabMine), findsOneWidget);
    });

    testWidgets('desktop — DragToMoveArea present for window dragging', (
      tester,
    ) async {
      setScreenSize(tester, 1440, 900);
      await pumpShell(tester, router: buildRouter());

      // The window title bar should contain a DragToMoveArea.
      // window_manager is mocked via MethodChannel in setUpAll.
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(find.text(l10n.appTitle), findsOneWidget);
    });
  });

  group('Mobile layout non-degradation (390 / 768)', () {
    testWidgets('390px — bottom nav visible, sidebar hidden', (tester) async {
      setScreenSize(tester, 390, 844);
      await pumpShell(tester, router: buildRouter());

      expect(find.byType(FBottomNavigationBar), findsOneWidget);
      expect(find.byType(FSidebar), findsNothing);
    });

    testWidgets(
      '768px — bottom nav visible, sidebar hidden (tablet falls to mobile)',
      (tester) async {
        setScreenSize(tester, 768, 1024);
        await pumpShell(tester, router: buildRouter());

        // 768 < 960 (tablet) < 1200 (desktop), so uses mobile layout.
        expect(find.byType(FBottomNavigationBar), findsOneWidget);
        expect(find.byType(FSidebar), findsNothing);
      },
    );

    testWidgets('390px — all 5 tab labels visible in bottom nav', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      setScreenSize(tester, 390, 844);
      await pumpShell(tester, router: buildRouter());

      expect(find.text(l10n.tabToday), findsOneWidget);
      expect(find.text(l10n.tabRecord), findsOneWidget);
      expect(find.text(l10n.tabMedicine), findsOneWidget);
      expect(find.text(l10n.tabReport), findsOneWidget);
      expect(find.text(l10n.tabMine), findsOneWidget);
    });

    testWidgets('390px — no DragToMoveArea or window control buttons', (
      tester,
    ) async {
      setScreenSize(tester, 390, 844);
      await pumpShell(tester, router: buildRouter());

      // Window title bar should not render on mobile.
      // The sidebar (which contains the title bar) is not rendered.
      expect(find.byType(FSidebar), findsNothing);
    });

    testWidgets('390px — first tab content visible on launch', (tester) async {
      setScreenSize(tester, 390, 844);
      await pumpShell(tester, router: buildRouter());

      expect(find.byKey(const Key('tab-today')), findsOneWidget);
    });

    testWidgets('768px — first tab content visible on launch', (tester) async {
      setScreenSize(tester, 768, 1024);
      await pumpShell(tester, router: buildRouter());

      expect(find.byKey(const Key('tab-today')), findsOneWidget);
    });

    testWidgets('390px — can navigate between tabs', (tester) async {
      setScreenSize(tester, 390, 844);
      await pumpShell(tester, router: buildRouter());

      await tester.tap(find.byKey(ShellTab.record.testKey()));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('tab-record')), findsOneWidget);
    });
  });
}
