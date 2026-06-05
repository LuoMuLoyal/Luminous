import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/settings/presentation/pages/settings_page.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Settings page renders grouped settings sections', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    await _pumpSettingsPage(
      tester,
      router: GoRouter(
        initialLocation: '/settings',
        routes: [
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('settings-group-account')), findsOneWidget);
    expect(find.byKey(const Key('settings-group-preferences')), findsOneWidget);
    expect(find.byKey(const Key('settings-group-more')), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    expect(find.text('账号与安全'), findsOneWidget);
    expect(find.text('主题模式'), findsOneWidget);
    expect(find.text('语言'), findsOneWidget);
    expect(find.text('通知设置'), findsOneWidget);
    expect(find.text('更多设置'), findsOneWidget);
    expect(find.text('退出登录'), findsOneWidget);
  });

  testWidgets('Settings back button routes to previous page', (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('mine-page')),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    );

    await _pumpSettingsPage(tester, router: router);

    router.push('/settings');
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('mine-page'), findsOneWidget);
  });

  testWidgets('Settings account row routes to account settings page', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    await _pumpSettingsPage(
      tester,
      router: GoRouter(
        initialLocation: '/settings',
        routes: [
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: '/account',
            builder: (context, state) =>
                const Scaffold(body: Text('account-settings-page')),
          ),
        ],
      ),
    );

    await tester.pump();
    await tester.tap(find.byKey(const Key('settings-row-account')));
    await tester.pumpAndSettle();

    expect(find.text('account-settings-page'), findsOneWidget);
  });

  testWidgets('Settings account row routes to login page when signed out', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(
            () => _SignedOutAuthSessionNotifier(),
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: const Locale('zh'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: GoRouter(
            initialLocation: '/settings',
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsPage(),
              ),
              GoRoute(
                path: '/login',
                builder: (context, state) =>
                    const Scaffold(body: Text('login-page')),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.tap(find.byKey(const Key('settings-row-account')));
    await tester.pumpAndSettle();

    expect(find.text('login-page'), findsOneWidget);
  });

  testWidgets('Settings language row routes to language settings page', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    await _pumpSettingsPage(
      tester,
      router: GoRouter(
        initialLocation: '/settings',
        routes: [
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: '/settings/language',
            builder: (context, state) =>
                const Scaffold(body: Text('language-settings-page')),
          ),
        ],
      ),
    );

    await tester.pump();
    await tester.tap(find.byKey(const Key('settings-row-language')));
    await tester.pumpAndSettle();

    expect(find.text('language-settings-page'), findsOneWidget);
  });

  testWidgets('Settings theme row routes to theme settings page', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    await _pumpSettingsPage(
      tester,
      router: GoRouter(
        initialLocation: '/settings',
        routes: [
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: '/settings/theme',
            builder: (context, state) =>
                const Scaffold(body: Text('theme-settings-page')),
          ),
        ],
      ),
    );

    await tester.pump();
    await tester.tap(find.byKey(const Key('settings-row-theme')));
    await tester.pumpAndSettle();

    expect(find.text('theme-settings-page'), findsOneWidget);
  });

  testWidgets(
    'Settings notifications row routes to notifications settings page',
    (tester) async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});

      await _pumpSettingsPage(
        tester,
        router: GoRouter(
          initialLocation: '/settings',
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
            ),
            GoRoute(
              path: '/settings/notifications',
              builder: (context, state) =>
                  const Scaffold(body: Text('notifications-settings-page')),
            ),
          ],
        ),
      );

      await tester.pump();
      await tester.tap(find.byKey(const Key('settings-row-notifications')));
      await tester.pumpAndSettle();

      expect(find.text('notifications-settings-page'), findsOneWidget);
    },
  );

  testWidgets('Settings more row routes to more settings page', (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    await _pumpSettingsPage(
      tester,
      router: GoRouter(
        initialLocation: '/settings',
        routes: [
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: '/settings/more',
            builder: (context, state) =>
                const Scaffold(body: Text('more-settings-page')),
          ),
        ],
      ),
    );

    await tester.pump();
    await tester.tap(find.byKey(const Key('settings-row-more')));
    await tester.pumpAndSettle();

    expect(find.text('more-settings-page'), findsOneWidget);
  });

  testWidgets('Settings footer action logs out and routes to login page', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(
          () => _LogoutTrackingAuthSessionNotifier(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: const Locale('zh'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: GoRouter(
            initialLocation: '/settings',
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsPage(),
              ),
              GoRoute(
                path: '/login',
                builder: (context, state) =>
                    const Scaffold(body: Text('login-page')),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.tap(find.byKey(const Key('settings-footer-action')));
    await tester.pumpAndSettle();

    final notifier =
        container.read(authSessionProvider.notifier)
            as _LogoutTrackingAuthSessionNotifier;
    expect(notifier.logoutCalled, isTrue);
    expect(find.text('login-page'), findsOneWidget);
  });
}

Future<void> _pumpSettingsPage(
  WidgetTester tester, {
  required GoRouter router,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authSessionProvider.overrideWith(() => _SignedInAuthSessionNotifier()),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        locale: const Locale('zh'),
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
}

class _SignedInAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return AuthSessionState(
      isAuthenticated: true,
      isLoading: false,
      user: AuthUser(
        id: 'user-1',
        email: 'user@example.com',
        nickname: 'Lumi',
        avatar: null,
        emailVerifiedAt: DateTime.parse('2026-01-01T00:00:00Z'),
        createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
      ),
    );
  }
}

class _LogoutTrackingAuthSessionNotifier extends AuthSessionNotifier {
  bool logoutCalled = false;

  @override
  AuthSessionState build() {
    return const AuthSessionState(isAuthenticated: true, isLoading: false);
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
    state = const AuthSessionState(isAuthenticated: false, isLoading: false);
  }
}

class _SignedOutAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return const AuthSessionState(isAuthenticated: false, isLoading: false);
  }
}
