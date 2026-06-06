import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/app.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/pages/account_settings_page.dart';
import 'package:luminous/features/auth/presentation/pages/login_page.dart';
import 'package:luminous/features/settings/data/datasources/settings_profile_remote_data_source.dart';
import 'package:luminous/features/settings/data/providers/notification_permission_providers.dart';
import 'package:luminous/features/settings/data/providers/settings_profile_data_providers.dart';
import 'package:luminous/features/settings/data/services/notification_permission_service.dart';
import 'package:luminous/features/settings/presentation/pages/language_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/more_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/notification_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/theme_settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

late _FakeSettingsProfileRemoteDataSource _fakeSettingsProfileRemote;

void main() {
  setUp(() {
    _fakeSettingsProfileRemote = _FakeSettingsProfileRemoteDataSource();
  });

  testWidgets(
    'Language settings updates a visible localized string and persists preference',
    (tester) async {
      SharedPreferences.setMockInitialValues(const <String, Object>{
        'app.locale': 'zh-CN',
      });

      await _pumpApp(
        tester,
        notificationService: _FakeNotificationPermissionService(
          state: NotificationPermissionState.granted,
        ),
      );

      expect(find.text('设置'), findsOneWidget);

      await tester.tap(find.byKey(const Key('settings-row-language')));
      await tester.pumpAndSettle();

      expect(find.text('English'), findsWidgets);

      await tester.tap(find.text('English').last);
      await tester.pumpAndSettle();

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString('app.locale'), 'en');
      expect(_fakeSettingsProfileRemote.lastLocale, 'en');

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded).first);
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);

      final snapshot = _snapshotPreferences(preferences);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      SharedPreferences.setMockInitialValues(snapshot);
      await _pumpApp(tester);

      expect(find.text('Settings'), findsOneWidget);
    },
  );

  testWidgets('Notification settings toggles a switch and persists the value', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{
      'app.locale': 'zh-CN',
    });

    await _pumpApp(
      tester,
      notificationService: _FakeNotificationPermissionService(
        state: NotificationPermissionState.granted,
      ),
    );

    await tester.tap(find.byKey(const Key('settings-row-notifications')));
    await tester.pumpAndSettle();

    final medicationRow = find.byKey(const Key('notification-row-medication'));
    final switchFinder = find.descendant(
      of: medicationRow,
      matching: _findAnySwitch(),
    );
    expect(switchFinder, findsOneWidget);

    final beforeValue = _readSwitchValue(tester, switchFinder.first);

    await tester.tap(medicationRow);
    await tester.pumpAndSettle();

    final afterValue = _readSwitchValue(
      tester,
      find.descendant(of: medicationRow, matching: _findAnySwitch()).first,
    );
    expect(afterValue, isNot(beforeValue));

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getBool('settings.notifications.medicationReminders'),
      afterValue,
    );

    final snapshot = _snapshotPreferences(preferences);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    SharedPreferences.setMockInitialValues(snapshot);
    await _pumpApp(
      tester,
      notificationService: _FakeNotificationPermissionService(
        state: NotificationPermissionState.granted,
      ),
    );

    await tester.tap(find.byKey(const Key('settings-row-notifications')));
    await tester.pumpAndSettle();

    expect(
      _readSwitchValue(
        tester,
        find
            .descendant(
              of: find.byKey(const Key('notification-row-medication')),
              matching: _findAnySwitch(),
            )
            .first,
      ),
      afterValue,
    );
  });

  testWidgets('Notification settings shows granted permission state', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{
      'app.locale': 'zh-CN',
    });

    await _pumpApp(
      tester,
      notificationService: _FakeNotificationPermissionService(
        state: NotificationPermissionState.granted,
      ),
    );

    await tester.tap(find.byKey(const Key('settings-row-notifications')));
    await tester.pumpAndSettle();

    expect(find.text('系统通知已开启'), findsOneWidget);
    expect(find.text('通知已授权。下方开关可控制各类通知的显示。'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });

  testWidgets('Notification settings shows denied permission state', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{
      'app.locale': 'zh-CN',
    });

    await _pumpApp(
      tester,
      notificationService: _FakeNotificationPermissionService(
        state: NotificationPermissionState.denied,
      ),
    );

    await tester.tap(find.byKey(const Key('settings-row-notifications')));
    await tester.pumpAndSettle();

    expect(find.text('系统通知未开启'), findsOneWidget);
    expect(
      find.text('点击可打开系统权限对话框。系统通知权限未开启时，本地提醒无法显示。'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
  });

  testWidgets('Theme settings updates mode and palette preferences', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{
      'app.locale': 'zh-CN',
    });

    await _pumpApp(tester);

    await tester.tap(find.byKey(const Key('settings-row-theme')));
    await tester.pumpAndSettle();

    expect(find.text('主题模式'), findsOneWidget);
    expect(find.byKey(const Key('theme-row-dark')), findsOneWidget);
    expect(
      find.byKey(const Key('theme-palette-row-blue-pink')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('theme-row-dark')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('theme-palette-row-blue-pink')));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('theme.mode'), 'dark');
    expect(preferences.getString('theme.palette'), 'blue-pink');

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(app.theme?.colorScheme.primary, const Color(0xFF47A0C9));
    expect(app.darkTheme?.colorScheme.primary, const Color(0xFF95CEE8));

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('深色 · 蓝粉'), findsOneWidget);

    final snapshot = _snapshotPreferences(preferences);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    SharedPreferences.setMockInitialValues(snapshot);
    await _pumpApp(tester);

    final restoredApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(restoredApp.themeMode, ThemeMode.dark);
    expect(restoredApp.theme?.colorScheme.primary, const Color(0xFF47A0C9));
    expect(find.text('深色 · 蓝粉'), findsOneWidget);
  });
}

Future<void> _pumpApp(
  WidgetTester tester, {
  NotificationPermissionService? notificationService,
}) async {
  final container = ProviderContainer(
    overrides: [
      authSessionProvider.overrideWith(() => _StaticAuthSessionNotifier()),
      settingsProfileRemoteDataSourceProvider.overrideWithValue(
        _fakeSettingsProfileRemote,
      ),
      notificationPermissionServiceProvider.overrideWithValue(
        notificationService ?? _FakeNotificationPermissionService(),
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: LuminousApp(routerConfig: _buildSettingsTestRouter()),
    ),
  );

  await tester.pump();
  await tester.pumpAndSettle();
}

Finder _findAnySwitch() {
  return find.byWidgetPredicate(
    (widget) => widget is Switch || widget is CupertinoSwitch,
    description: 'switch',
  );
}

bool _readSwitchValue(WidgetTester tester, Finder finder) {
  final widget = tester.widget(finder);
  if (widget is Switch) {
    return widget.value;
  }
  if (widget is CupertinoSwitch) {
    return widget.value;
  }
  throw StateError('Unsupported switch widget: ${widget.runtimeType}');
}

Map<String, Object> _snapshotPreferences(SharedPreferences preferences) {
  final snapshot = <String, Object>{};
  for (final key in preferences.getKeys()) {
    final value = preferences.get(key);
    if (value is Object) {
      snapshot[key] = value;
    }
  }
  return snapshot;
}

class _StaticAuthSessionNotifier extends AuthSessionNotifier {
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

  @override
  Future<void> restore() async {}
}

class _FakeNotificationPermissionService extends NotificationPermissionService {
  _FakeNotificationPermissionService({this.state = NotificationPermissionState.unsupported});

  final NotificationPermissionState state;

  @override
  Future<void> ensureInitialized() async {}

  @override
  Future<NotificationPermissionState> getPermissionState() async {
    return state;
  }

  @override
  Future<NotificationPermissionState> requestPermission() async {
    return state;
  }
}

class _FakeSettingsProfileRemoteDataSource
    extends SettingsProfileRemoteDataSource {
  _FakeSettingsProfileRemoteDataSource() : super(dio: Dio());

  Object? lastLocale;
  Object? lastTimezone = settingsProfileNoChange;
  Object? lastUnitSystem = settingsProfileNoChange;

  @override
  Future<HealthContextDataDto> updatePreferences({
    Object? locale = settingsProfileNoChange,
    Object? timezone = settingsProfileNoChange,
    Object? unitSystem = settingsProfileNoChange,
  }) async {
    lastLocale = locale;
    lastTimezone = timezone;
    lastUnitSystem = unitSystem;
    return HealthContextDataDto(
      summary: UserHealthSummaryDto(
        age: null,
        onboardingCompleted: false,
        activeAllergyCount: 0,
        conditionCount: 0,
        currentMedicineCount: 0,
        missingCoreProfileFields: const [],
      ),
      profile: UserHealthProfileDto(
        birthDate: null,
        sexAtBirth: null,
        heightCm: null,
        pregnancyState: null,
        lactationState: null,
        bloodType: null,
        locale: identical(locale, settingsProfileNoChange) ? null : locale,
        timezone: identical(timezone, settingsProfileNoChange)
            ? null
            : timezone,
        unitSystem: identical(unitSystem, settingsProfileNoChange)
            ? null
            : unitSystem as UnitSystem?,
        onboardingCompletedAt: null,
        extras: const <String, Object>{},
      ),
      allergies: const [],
      conditions: const [],
      currentMedicines: const [],
    );
  }
}

GoRouter _buildSettingsTestRouter() {
  return GoRouter(
    initialLocation: '/settings',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/account',
        builder: (context, state) => const AccountSettingsPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/settings/language',
        builder: (context, state) => const LanguageSettingsPage(),
      ),
      GoRoute(
        path: '/settings/theme',
        builder: (context, state) => const ThemeSettingsPage(),
      ),
      GoRoute(
        path: '/settings/notifications',
        builder: (context, state) => const NotificationSettingsPage(),
      ),
      GoRoute(
        path: '/settings/more',
        builder: (context, state) => const MoreSettingsPage(),
      ),
    ],
  );
}
