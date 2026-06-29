import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/settings/data/providers/notification_permission_providers.dart';
import 'package:luminous/features/settings/data/services/notification_permission_service.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/settings/presentation/pages/settings_page.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings_controller.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Settings page renders grouped settings sections', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

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

    expect(
      find.byKey(const Key('settings-row-account-security')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('settings-row-notifications')), findsOneWidget);
    expect(
      find.byKey(const Key('settings-row-privacy-report')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('settings-row-ai')), findsOneWidget);
    expect(find.byKey(const Key('settings-row-theme')), findsOneWidget);
    expect(find.byKey(const Key('settings-row-language')), findsOneWidget);
    expect(find.byKey(const Key('settings-row-advanced')), findsOneWidget);
    expect(find.byKey(const Key('settings-row-help')), findsOneWidget);
    expect(find.byKey(const Key('settings-row-about')), findsOneWidget);
    expect(find.byKey(const Key('settings-row-export')), findsOneWidget);
    expect(find.text(l10n.desktopSidebarSettings), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
    expect(find.text(l10n.mineSettingsAccountTitle), findsWidgets);
    expect(find.text(l10n.mineSettingsThemeTitle), findsOneWidget);
    expect(find.text(l10n.mineSettingsLanguageTitle), findsOneWidget);
    expect(find.text(l10n.minePrivacyReportTitle), findsOneWidget);
    expect(find.text(l10n.settingsAiTitle), findsOneWidget);
    expect(find.text(l10n.mineSettingsNotificationsTitle), findsOneWidget);
    expect(find.text(l10n.mineSettingExportTitle), findsOneWidget);
    expect(find.text(l10n.mineSettingHelpTitle), findsOneWidget);
    expect(find.text(l10n.mineSettingAboutTitle), findsOneWidget);
    expect(find.text(l10n.mineSettingsAdvancedTitle), findsOneWidget);
    expect(find.text(l10n.authSignOut), findsOneWidget);
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

    unawaited(router.push('/settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(BackButton).first);
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
    await tester.tap(find.byKey(const Key('settings-row-account-security')));
    await tester.pumpAndSettle();

    expect(find.text('account-settings-page'), findsOneWidget);
  });

  testWidgets('Settings account row shows login dialog when signed out', (
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
                builder: (context, state) => Scaffold(
                  body: Text(
                    "login-page:${state.uri.queryParameters['returnTo']}",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.tap(find.byKey(const Key('settings-row-account-security')));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsPage), findsOneWidget);
    expect(find.byKey(const Key('auth-required-dialog')), findsOneWidget);
    expect(find.text('尚未登录'), findsOneWidget);
    expect(find.text('是否去登录'), findsOneWidget);
    expect(find.text('login-page:/settings'), findsNothing);

    await tester.tap(find.byKey(const Key('auth-required-cancel-action')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('auth-required-dialog')), findsNothing);
    expect(find.byType(SettingsPage), findsOneWidget);

    await tester.tap(find.byKey(const Key('settings-row-account-security')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('auth-required-login-action')));
    await tester.pumpAndSettle();

    expect(find.text('login-page:/settings'), findsOneWidget);
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
    await tester.scrollUntilVisible(
      find.byKey(const Key('settings-row-language')),
      240,
    );
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
    await tester.scrollUntilVisible(
      find.byKey(const Key('settings-row-theme')),
      240,
    );
    await tester.tap(find.byKey(const Key('settings-row-theme')));
    await tester.pumpAndSettle();

    expect(find.text('theme-settings-page'), findsOneWidget);
  });

  testWidgets(
    'Settings notifications row routes to notification settings page',
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
                  const Scaffold(body: Text('notification-settings-page')),
            ),
          ],
        ),
      );

      await tester.pump();
      await tester.scrollUntilVisible(
        find.byKey(const Key('settings-row-notifications')),
        240,
      );
      await tester.tap(find.byKey(const Key('settings-row-notifications')));
      await tester.pumpAndSettle();

      expect(find.text('notification-settings-page'), findsOneWidget);
    },
  );

  testWidgets('Settings advanced row routes to advanced settings page', (
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
            path: '/settings/more',
            builder: (context, state) =>
                const Scaffold(body: Text('advanced-settings-page')),
          ),
        ],
      ),
    );

    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const Key('settings-row-advanced')),
      240,
    );
    await tester.tap(find.byKey(const Key('settings-row-advanced')));
    await tester.pumpAndSettle();

    expect(find.text('advanced-settings-page'), findsOneWidget);
  });

  testWidgets('Settings assistant row routes to assistant page', (
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
            path: '/settings/ai',
            builder: (context, state) =>
                const Scaffold(body: Text('ai-settings-page')),
          ),
        ],
      ),
    );

    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const Key('settings-row-ai')),
      240,
    );
    await tester.tap(find.byKey(const Key('settings-row-ai')));
    await tester.pumpAndSettle();

    expect(find.text('ai-settings-page'), findsOneWidget);
  });

  testWidgets('Settings export row routes to data export page', (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(
            () => _SignedInAuthSessionNotifier(),
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
                path: '/settings/export',
                builder: (context, state) =>
                    const Scaffold(body: Text('data-export-page')),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const Key('settings-row-export')),
      240,
    );
    await tester.tap(find.byKey(const Key('settings-row-export')));
    await tester.pumpAndSettle();

    expect(find.text('data-export-page'), findsOneWidget);
  });

  testWidgets('Data sharing toggle shows confirmation dialog before changing', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final fakeController = _FakeUserSettingsController();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(
            () => _SignedInAuthSessionNotifier(),
          ),
          userSettingsControllerProvider.overrideWith(() => fakeController),
          notificationPermissionServiceProvider.overrideWithValue(
            _FakeNotificationPermissionService(),
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
            ],
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const Key('settings-row-privacy-report')),
      240,
    );

    final switchFinder = find.descendant(
      of: find.byKey(const Key('settings-row-privacy-report')),
      matching: find.byType(Switch),
    );

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    expect(find.text(l10n.settingsDataSharingConfirmTitle), findsOneWidget);

    await tester.tap(find.text(l10n.settingsDataSharingCancelAction));
    await tester.pumpAndSettle();

    expect(fakeController.lastDataSharingConsent, isNull);

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.settingsDataSharingConfirmAction));
    await tester.pumpAndSettle();

    expect(fakeController.lastDataSharingConsent, isTrue);
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
    await tester.scrollUntilVisible(
      find.byKey(const Key('settings-footer-action')),
      240,
    );
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
        notificationPermissionServiceProvider.overrideWithValue(
          _FakeNotificationPermissionService(),
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

class _FakeNotificationPermissionService extends NotificationPermissionService {
  @override
  Future<void> ensureInitialized() async {}

  @override
  Future<NotificationPermissionState> getPermissionState() async =>
      NotificationPermissionState.granted;

  @override
  Future<NotificationPermissionState> requestPermission() async =>
      NotificationPermissionState.granted;
}

class _FakeUserSettingsController extends UserSettingsController {
  bool? lastDataSharingConsent;

  @override
  Future<UserSettingsDataDto> build() async {
    return UserSettingsDataDto(
      aiSummariesEnabled: false,
      dataSharingConsent: false,
      assistantEnabled: false,
      assistantMemoryEnabled: false,
      assistantContext: AssistantContextSettingsDto(
        healthProfile: false,
        dailyRecords: false,
        sleepRecords: false,
        currentMedicines: false,
      ),
      updatedAt: '2026-06-28T00:00:00Z',
    );
  }

  @override
  Future<void> setDataSharingConsent(bool consent) async {
    lastDataSharingConsent = consent;
    state = AsyncData(
      UserSettingsDataDto(
        aiSummariesEnabled: false,
        dataSharingConsent: consent,
        assistantEnabled: false,
        assistantMemoryEnabled: false,
        assistantContext: AssistantContextSettingsDto(
          healthProfile: false,
          dailyRecords: false,
          sleepRecords: false,
          currentMedicines: false,
        ),
        updatedAt: '2026-06-28T00:00:00Z',
      ),
    );
  }
}

class _SignedOutAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return const AuthSessionState(isAuthenticated: false, isLoading: false);
  }
}
