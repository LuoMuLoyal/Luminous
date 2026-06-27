import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/core/widgets/app_dialog.dart';
import 'package:luminous/features/settings/data/providers/notification_permission_providers.dart';
import 'package:luminous/features/settings/data/services/notification_permission_service.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/settings/presentation/pages/settings_page.dart';
import 'package:luminous/features/settings/presentation/providers/data_export_controller.dart';
import 'package:luminous/features/settings/presentation/providers/notification_settings_controller.dart';
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

    expect(find.byKey(const Key('settings-group-account')), findsOneWidget);
    expect(find.byKey(const Key('settings-group-preferences')), findsOneWidget);
    expect(find.byKey(const Key('settings-group-privacy')), findsOneWidget);
    expect(find.byKey(const Key('settings-group-reminders')), findsOneWidget);
    expect(find.byKey(const Key('settings-group-advanced')), findsOneWidget);
    expect(find.text(l10n.desktopSidebarSettings), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
    expect(find.text(l10n.mineSettingsAccountTitle), findsOneWidget);
    expect(find.text(l10n.mineSettingsThemeTitle), findsOneWidget);
    expect(find.text(l10n.mineSettingsLanguageTitle), findsOneWidget);
    expect(find.text(l10n.minePrivacyReportTitle), findsOneWidget);
    expect(find.text(l10n.minePrivacyAiTitle), findsOneWidget);
    expect(find.text(l10n.assistantEntryTitle), findsOneWidget);
    expect(find.text(l10n.mineSettingsNotificationsTitle), findsOneWidget);
    expect(find.text(l10n.mineReminderMedicineTitle), findsOneWidget);
    expect(find.text(l10n.mineReminderWaterTitle), findsOneWidget);
    expect(find.text(l10n.mineReminderSleepTitle), findsOneWidget);
    expect(find.text('未开启'), findsOneWidget);
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

    router.push('/settings');
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
    await tester.tap(find.byKey(const Key('settings-row-account')));
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
    await tester.tap(find.byKey(const Key('settings-row-account')));
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

    await tester.tap(find.byKey(const Key('settings-row-account')));
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

  testWidgets('Settings notifications row opens notification settings dialog', (
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
    await tester.scrollUntilVisible(
      find.byKey(const Key('settings-row-notifications')),
      240,
    );
    await tester.tap(find.byKey(const Key('settings-row-notifications')));
    await tester.pumpAndSettle();

    expect(find.byType(AppDialog), findsOneWidget);
    expect(find.text('系统通知已开启'), findsOneWidget);
  });

  testWidgets('Settings reminder rows open per-type reminder dialogs', (
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
    await tester.scrollUntilVisible(
      find.byKey(const Key('settings-row-reminder-medicine')),
      240,
    );
    await tester.tap(find.byKey(const Key('settings-row-reminder-medicine')));
    await tester.pumpAndSettle();

    expect(find.byType(AppDialog), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppDialog),
        matching: find.byType(Switch),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Settings sleep reminder row shows time range when enabled', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(
            () => _SignedInAuthSessionNotifier(),
          ),
          notificationSettingsControllerProvider.overrideWith(
            () => _StaticNotificationSettingsController(
              const NotificationSettingsState(
                sleepReminderEnabled: true,
                sleepBedtime: TimeOfDay(hour: 22, minute: 0),
                sleepWakeTime: TimeOfDay(hour: 7, minute: 0),
              ),
            ),
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
      find.byKey(const Key('settings-row-reminder-sleep')),
      240,
    );
    await tester.pumpAndSettle();

    expect(find.text('22:00 - 07:00'), findsOneWidget);
  });

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
            path: '/assistant',
            builder: (context, state) =>
                const Scaffold(body: Text('assistant-page')),
          ),
        ],
      ),
    );

    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const Key('settings-row-privacy-ai-chat')),
      240,
    );
    await tester.tap(find.byKey(const Key('settings-row-privacy-ai-chat')));
    await tester.pumpAndSettle();

    expect(find.text('assistant-page'), findsOneWidget);
  });

  testWidgets(
    'Settings export row shows unavailable status from latest export',
    (tester) async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});

      final exportRequest = DataExportRequestDataDto(
        id: 'req-unavailable',
        kind: DataExportKind.hospital,
        format: DataExportFormat.pdf,
        range: DataExportRange.last7Days,
        status: DataExportStatus.unavailable,
        requestedAt: '2026-06-12T00:00:00.000Z',
        errorMessage: 'COS unavailable',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(
              () => _SignedInAuthSessionNotifier(),
            ),
            dataExportControllerProvider.overrideWith(
              () => _StaticDataExportController(exportRequest),
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
        find.byKey(const Key('settings-row-export')),
        240,
      );
      await tester.pumpAndSettle();

      expect(find.text('暂不可用'), findsOneWidget);
    },
  );

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

class _SignedOutAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return const AuthSessionState(isAuthenticated: false, isLoading: false);
  }
}

class _StaticDataExportController extends DataExportController {
  _StaticDataExportController(this._value);

  final DataExportRequestDataDto? _value;

  @override
  Future<DataExportRequestDataDto?> build() async => _value;
}

class _StaticNotificationSettingsController
    extends NotificationSettingsController {
  _StaticNotificationSettingsController(this._value);

  final NotificationSettingsState _value;

  @override
  Future<NotificationSettingsState> build() async => _value;
}
