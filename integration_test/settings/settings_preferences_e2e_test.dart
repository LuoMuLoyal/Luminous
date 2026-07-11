import '../support/e2e_test_helpers.dart';

void main() {
  patrolTest('settings theme flow uses system back button and persists mode', (
    $,
  ) async {
    await pumpOfflineApp($);

    await openTab($, '我的');
    await $.tester.tap(find.byKey(const Key('mine-settings-action')));
    await settleE2e($);

    expect(find.byKey(const Key('settings-row-theme')), findsOneWidget);

    await $.tester.tap(find.byKey(const Key('settings-row-theme')));
    await settleE2e($);

    expect($('主题模式').exists, true);
    expect(find.byType(BackButton), findsOneWidget);

    await $.tester.tap(find.byKey(const Key('theme-row-dark')));
    await settleE2e($);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('theme.mode'), 'dark');

    await $.tester.tap(find.byType(BackButton).first);
    await settleE2e($);

    expect(find.byKey(const Key('settings-row-theme')), findsOneWidget);
    expect($('深色 · 默认').exists, true);

    await $.tester.tap(find.byType(BackButton).first);
    await settleE2e($);

    await pumpUntilFound($, find.byType(NavigationBar));
    await openTab($, '我的');
    await pumpUntilFound($, find.text('当前未登录'));
    expect($('当前未登录').exists, true);
  });

  patrolTest('settings language flow persists selected locale', ($) async {
    await pumpOfflineApp($);

    await openSettings($);

    await $.tester.tap(find.byKey(const Key('settings-row-language')));
    await settleE2e($);

    expect($('语言').exists, true);
    expect(find.byKey(const Key('language-row-en')), findsOneWidget);

    await $.tester.tap(find.byKey(const Key('language-row-en')));
    await settleE2e($);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('app.locale'), 'en');

    await $.tester.tap(find.byType(BackButton).first);
    await settleE2e($);

    expect($('Settings').exists, true);
  });

  patrolTest('settings footer login action routes signed-out user to login', (
    $,
  ) async {
    await pumpOfflineApp($);

    await openSettings($);

    await tapSettingsFooterAction($);

    expect($('邮箱').exists, true);
    expect(find.widgetWithText(FilledButton, '登录'), findsOneWidget);
  });

  patrolTest('settings footer sign out clears session and routes to login', (
    $,
  ) async {
    final remote = E2eAuthRemoteDataSource();
    final container = await pumpOfflineApp(
      $,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      authRemoteDataSource: remote,
    );

    await openSettings($);

    await tapSettingsFooterAction($);

    expect(remote.logoutCalled, isTrue);
    expect(container.read(authSessionProvider).isAuthenticated, isFalse);
    expect($('邮箱').exists, true);
    expect(find.widgetWithText(FilledButton, '登录'), findsOneWidget);
  });

  patrolTest('settings notification toggle persists preference', ($) async {
    await pumpOfflineApp(
      $,
      notificationPermissionService: E2eNotificationPermissionService(
        state: NotificationPermissionState.granted,
      ),
    );

    await openSettings($);

    await $.tester.tap(find.byKey(const Key('settings-row-notifications')));
    await settleE2e($);

    expect($('通知设置').exists, true);
    expect($('系统通知已开启').exists, true);

    final medicationSwitch = find.byKey(
      const Key('notification-switch-medication'),
    );
    final before = readSwitchValue($, switchIn(medicationSwitch));

    await $.tester.tap(medicationSwitch);
    await settleE2e($);

    final after = readSwitchValue($, switchIn(medicationSwitch));
    expect(after, isNot(before));

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getBool('settings.notifications.medicationReminders'),
      after,
    );

    await $.tester.tap(find.byType(BackButton).first);
    await settleE2e($);

    expect($('设置').exists, true);
  });

  patrolTest('settings notification permission row requests permission', (
    $,
  ) async {
    final permissionService = E2eNotificationPermissionService(
      state: NotificationPermissionState.denied,
    );

    await pumpOfflineApp($, notificationPermissionService: permissionService);

    await openSettings($);

    await $.tester.tap(find.byKey(const Key('settings-row-notifications')));
    await settleE2e($);

    expect($('通知设置').exists, true);
    expect($('系统通知未开启').exists, true);
    expect(permissionService.requestCount, 0);

    await $.tester.tap(find.byKey(const Key('notification-permission-card')));
    await settleE2e($);

    expect(permissionService.requestCount, 1);
    expect($('系统通知未开启').exists, true);
  });
}
