import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/app.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/pages/account_settings_page.dart';
import 'package:luminous/features/auth/presentation/pages/login_page.dart';
import 'package:luminous/features/settings/data/providers/notification_permission_providers.dart';
import 'package:luminous/features/settings/data/services/notification_permission_service.dart';
import 'package:luminous/features/settings/presentation/pages/language_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/more_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/notification_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'Language settings updates a visible localized string and persists preference',
    (tester) async {
      SharedPreferences.setMockInitialValues(const <String, Object>{
        'app.locale': 'zh-CN',
      });

      await _pumpApp(tester, fakeNotificationPermission: true);

      expect(find.text('设置'), findsOneWidget);

      await tester.tap(find.byKey(const Key('settings-row-language')));
      await tester.pumpAndSettle();

      expect(find.text('English'), findsWidgets);

      await tester.tap(find.text('English').last);
      await tester.pumpAndSettle();

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString('app.locale'), 'en');

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

    await _pumpApp(tester, fakeNotificationPermission: true);

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
    await _pumpApp(tester, fakeNotificationPermission: true);

    await tester.tap(find.byKey(const Key('settings-row-notifications')));
    await tester.pumpAndSettle();

    expect(
      _readSwitchValue(
        tester,
        find.descendant(
          of: find.byKey(const Key('notification-row-medication')),
          matching: _findAnySwitch(),
        ).first,
      ),
      afterValue,
    );
  });
}

Future<void> _pumpApp(
  WidgetTester tester, {
  bool fakeNotificationPermission = false,
}) async {
  final container = ProviderContainer(
    overrides: [
      authSessionProvider.overrideWith(() => _StaticAuthSessionNotifier()),
      if (fakeNotificationPermission)
        notificationPermissionServiceProvider.overrideWith(
          (ref) => _FakeNotificationPermissionService(),
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
        emailVerified: true,
        createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
      ),
    );
  }

  @override
  Future<void> restore() async {}
}

class _FakeNotificationPermissionService
    extends NotificationPermissionService {
  @override
  Future<void> ensureInitialized() async {}

  @override
  Future<NotificationPermissionState> getPermissionState() async {
    return NotificationPermissionState.unsupported;
  }

  @override
  Future<NotificationPermissionState> requestPermission() async {
    return NotificationPermissionState.unsupported;
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
