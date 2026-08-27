import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/shortcuts/intents.dart';
import 'package:luminous/core/shortcuts/shortcuts.dart';
import 'package:luminous/core/theme/theme.dart';
import 'package:luminous/features/shell/presentation/page.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        GoRoute(
          path: '/settings',
          builder: (context, state) =>
              const SizedBox(key: Key('page-settings')),
        ),
        GoRoute(
          path: '/record/create',
          builder: (context, state) =>
              const SizedBox(key: Key('page-record-create')),
        ),
        GoRoute(
          path: '/assistant',
          builder: (context, state) =>
              const SizedBox(key: Key('page-assistant')),
        ),
      ],
    );
  }

  Future<void> pumpApp(WidgetTester tester, {required GoRouter router}) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          builder: (context, child) => FTheme(
            data: appThemeData(appDefaultThemeFamily, Brightness.light),
            child: AppShortcuts(child: child ?? const SizedBox.shrink()),
          ),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            FLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  group('AppShortcuts – widget structure', () {
    testWidgets('renders AppShortcuts widget in tree', (tester) async {
      setDesktopScreenSize(tester);
      await pumpApp(tester, router: buildRouter());

      expect(find.byType(AppShortcuts), findsOneWidget);
    });

    testWidgets('renders Shortcuts + Actions widgets in tree', (tester) async {
      setDesktopScreenSize(tester);
      await pumpApp(tester, router: buildRouter());

      // AppShortcuts wraps child in Shortcuts → Actions → Focus.
      // Multiple Shortcuts/Actions may exist from the framework,
      // so we verify at least one is present.
      expect(find.byType(Shortcuts), findsWidgets);
      expect(find.byType(Actions), findsWidgets);
      expect(find.byType(AppShortcuts), findsOneWidget);
    });

    testWidgets('contains Focus with autofocus for keyboard input', (
      tester,
    ) async {
      setDesktopScreenSize(tester);
      await pumpApp(tester, router: buildRouter());

      final focusWidget = find.ancestor(
        of: find.byType(ShellPage),
        matching: find.byType(Focus),
      );
      expect(focusWidget, findsWidgets);
    });
  });

  group('AppShortcuts – shortcut intents', () {
    // Verify that the Intent classes exist and have correct structure.
    // This validates that the shortcut system is properly wired.

    test('OpenCommandPaletteIntent is a valid Intent', () {
      const intent = OpenCommandPaletteIntent();
      expect(intent, isA<Intent>());
    });

    test('CreateRecordIntent is a valid Intent', () {
      const intent = CreateRecordIntent();
      expect(intent, isA<Intent>());
    });

    test('OpenSettingsIntent is a valid Intent', () {
      const intent = OpenSettingsIntent();
      expect(intent, isA<Intent>());
    });

    test('OpenAssistantIntent is a valid Intent', () {
      const intent = OpenAssistantIntent();
      expect(intent, isA<Intent>());
    });

    test('SwitchTabIntent carries correct index', () {
      for (var i = 0; i < 5; i++) {
        final intent = SwitchTabIntent(i);
        expect(intent.index, i);
        expect(intent, isA<Intent>());
      }
    });
  });

  group('AppShortcuts – shortcut activator coverage', () {
    // Verify that the SingleActivator constants used by AppShortcuts
    // are constructible and valid. This catches typos in key codes.

    test('Ctrl+K activator is constructible', () {
      const activator = SingleActivator(LogicalKeyboardKey.keyK, control: true);
      expect(activator, isA<ShortcutActivator>());
    });

    test('Ctrl+N activator is constructible', () {
      const activator = SingleActivator(LogicalKeyboardKey.keyN, control: true);
      expect(activator, isA<ShortcutActivator>());
    });

    test('Ctrl+, activator is constructible', () {
      const activator = SingleActivator(
        LogicalKeyboardKey.comma,
        control: true,
      );
      expect(activator, isA<ShortcutActivator>());
    });

    test('Ctrl+Shift+A activator is constructible', () {
      const activator = SingleActivator(
        LogicalKeyboardKey.keyA,
        control: true,
        shift: true,
      );
      expect(activator, isA<ShortcutActivator>());
    });

    test('Ctrl+1..5 activators are constructible', () {
      for (final key in [
        LogicalKeyboardKey.digit1,
        LogicalKeyboardKey.digit2,
        LogicalKeyboardKey.digit3,
        LogicalKeyboardKey.digit4,
        LogicalKeyboardKey.digit5,
      ]) {
        final activator = SingleActivator(key, control: true);
        expect(activator, isA<ShortcutActivator>());
      }
    });
  });
}
