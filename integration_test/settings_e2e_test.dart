import 'e2e_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('settings theme flow uses system back button and persists mode', (
    tester,
  ) async {
    await pumpOfflineApp(tester);

    await openTab(tester, '我的');
    await tester.tap(find.byKey(const Key('mine-settings-action')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('settings-row-theme')), findsOneWidget);

    await tester.tap(find.byKey(const Key('settings-row-theme')));
    await tester.pumpAndSettle();

    expect(find.text('主题模式'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.tap(find.byKey(const Key('theme-row-dark')));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('theme.mode'), 'dark');

    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('settings-row-theme')), findsOneWidget);
    expect(find.text('深色 · 默认'), findsOneWidget);

    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();

    expect(find.text('当前未登录'), findsOneWidget);
  });

  testWidgets('settings language flow persists selected locale', (
    tester,
  ) async {
    await pumpOfflineApp(tester);

    await openSettings(tester);

    await tester.tap(find.byKey(const Key('settings-row-language')));
    await tester.pumpAndSettle();

    expect(find.text('语言'), findsOneWidget);
    expect(find.byKey(const Key('language-row-en')), findsOneWidget);

    await tester.tap(find.byKey(const Key('language-row-en')));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('app.locale'), 'en');

    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('settings notification toggle persists preference', (
    tester,
  ) async {
    await pumpOfflineApp(
      tester,
      notificationPermissionService: E2eNotificationPermissionService(
        state: NotificationPermissionState.granted,
      ),
    );

    await openSettings(tester);

    await tester.tap(find.byKey(const Key('settings-row-notifications')));
    await tester.pumpAndSettle();

    expect(find.text('通知设置'), findsOneWidget);
    expect(find.text('系统通知已开启'), findsOneWidget);

    final medicationRow = find.byKey(const Key('notification-row-medication'));
    final before = readSwitchValue(tester, switchIn(medicationRow));

    await tester.tap(medicationRow);
    await tester.pumpAndSettle();

    final after = readSwitchValue(tester, switchIn(medicationRow));
    expect(after, isNot(before));

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getBool('settings.notifications.medicationReminders'),
      after,
    );

    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();

    expect(find.text('设置'), findsOneWidget);
  });

  testWidgets('settings more reset defaults restores app preferences', (
    tester,
  ) async {
    await pumpOfflineApp(
      tester,
      notificationPermissionService: E2eNotificationPermissionService(
        state: NotificationPermissionState.granted,
      ),
    );

    await openSettings(tester);

    await tester.tap(find.byKey(const Key('settings-row-theme')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('theme-row-dark')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('theme-palette-row-blue-pink')));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings-row-language')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('language-row-en')));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings-row-notifications')));
    await tester.pumpAndSettle();
    final medicationRow = find.byKey(const Key('notification-row-medication'));
    expect(readSwitchValue(tester, switchIn(medicationRow)), isTrue);
    await tester.tap(medicationRow);
    await tester.pumpAndSettle();
    expect(readSwitchValue(tester, switchIn(medicationRow)), isFalse);
    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();

    var preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('theme.mode'), 'dark');
    expect(preferences.getString('theme.palette'), 'blue-pink');
    expect(preferences.getString('app.locale'), 'en');
    expect(
      preferences.getBool('settings.notifications.medicationReminders'),
      isFalse,
    );

    await tester.tap(find.byKey(const Key('settings-row-more')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('more-settings-row-reset-defaults')));
    await tester.pumpAndSettle();

    preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('theme.mode'), 'system');
    expect(preferences.getString('theme.palette'), 'classic');
    expect(preferences.getString('app.locale'), 'system');
    expect(
      preferences.getBool('settings.notifications.medicationReminders'),
      isNull,
    );

    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-row-notifications')));
    await tester.pumpAndSettle();
    expect(
      readSwitchValue(
        tester,
        switchIn(find.byKey(const Key('notification-row-medication'))),
      ),
      isTrue,
    );
  });
}
