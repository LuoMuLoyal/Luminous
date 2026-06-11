import 'e2e_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('settings theme flow uses system back button and persists mode', (
    tester,
  ) async {
    await pumpOfflineApp(tester);

    await openTab(tester, '我的');
    await tester.tap(find.byKey(const Key('mine-settings-action')));
    await settleE2e(tester);

    expect(find.byKey(const Key('settings-row-theme')), findsOneWidget);

    await tester.tap(find.byKey(const Key('settings-row-theme')));
    await settleE2e(tester);

    expect(find.text('主题模式'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.tap(find.byKey(const Key('theme-row-dark')));
    await settleE2e(tester);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('theme.mode'), 'dark');

    await tester.tap(find.byType(BackButton).first);
    await settleE2e(tester);

    expect(find.byKey(const Key('settings-row-theme')), findsOneWidget);
    expect(find.text('深色 · 默认'), findsOneWidget);

    await tester.tap(find.byType(BackButton).first);
    await settleE2e(tester);

    await pumpUntilFound(tester, find.byType(NavigationBar));
    await openTab(tester, '我的');
    await pumpUntilFound(tester, find.text('当前未登录'));
    expect(find.text('当前未登录'), findsOneWidget);
  });

  testWidgets('settings language flow persists selected locale', (
    tester,
  ) async {
    await pumpOfflineApp(tester);

    await openSettings(tester);

    await tester.tap(find.byKey(const Key('settings-row-language')));
    await settleE2e(tester);

    expect(find.text('语言'), findsOneWidget);
    expect(find.byKey(const Key('language-row-en')), findsOneWidget);

    await tester.tap(find.byKey(const Key('language-row-en')));
    await settleE2e(tester);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('app.locale'), 'en');

    await tester.tap(find.byType(BackButton).first);
    await settleE2e(tester);

    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('settings footer login action routes signed-out user to login', (
    tester,
  ) async {
    await pumpOfflineApp(tester);

    await openSettings(tester);

    await tapSettingsFooterAction(tester);

    expect(find.text('邮箱'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '登录'), findsOneWidget);
  });

  testWidgets('settings footer sign out clears session and routes to login', (
    tester,
  ) async {
    final remote = E2eAuthRemoteDataSource();
    final container = await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      authRemoteDataSource: remote,
    );

    await openSettings(tester);

    await tapSettingsFooterAction(tester);

    expect(remote.logoutCalled, isTrue);
    expect(container.read(authSessionProvider).isAuthenticated, isFalse);
    expect(find.text('邮箱'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '登录'), findsOneWidget);
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
    await settleE2e(tester);

    expect(find.text('通知设置'), findsOneWidget);
    expect(find.text('系统通知已开启'), findsOneWidget);

    final medicationRow = find.byKey(const Key('notification-row-medication'));
    final before = readSwitchValue(tester, switchIn(medicationRow));

    await tester.tap(medicationRow);
    await settleE2e(tester);

    final after = readSwitchValue(tester, switchIn(medicationRow));
    expect(after, isNot(before));

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getBool('settings.notifications.medicationReminders'),
      after,
    );

    await tester.tap(find.byType(BackButton).first);
    await settleE2e(tester);

    expect(find.text('设置'), findsOneWidget);
  });

  testWidgets('settings notification permission row requests permission', (
    tester,
  ) async {
    final permissionService = E2eNotificationPermissionService(
      state: NotificationPermissionState.denied,
    );

    await pumpOfflineApp(
      tester,
      notificationPermissionService: permissionService,
    );

    await openSettings(tester);

    await tester.tap(find.byKey(const Key('settings-row-notifications')));
    await settleE2e(tester);

    expect(find.text('通知设置'), findsOneWidget);
    expect(find.text('系统通知未开启'), findsOneWidget);
    expect(permissionService.requestCount, 0);

    await tester.tap(find.byKey(const Key('notification-row-permission')));
    await settleE2e(tester);

    expect(permissionService.requestCount, 1);
    expect(find.text('系统通知未开启'), findsOneWidget);
  });
}
