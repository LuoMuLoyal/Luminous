import '../support/e2e_test_helpers.dart';

void main() {
  patrolTest('settings advanced reset defaults restores app preferences', (
    $,
  ) async {
    await pumpOfflineApp(
      $,
      notificationPermissionService: E2eNotificationPermissionService(
        state: NotificationPermissionState.granted,
      ),
    );

    await openSettings($);

    await $.tester.tap(find.byKey(const Key('settings-row-theme')));
    await settleE2e($);
    await $.tester.tap(find.byKey(const Key('theme-row-dark')));
    await settleE2e($);
    await $.tester.tap(find.byKey(const Key('theme-palette-row-blue-pink')));
    await settleE2e($);
    await $.tester.tap(find.byType(BackButton).first);
    await settleE2e($);

    await $.tester.tap(find.byKey(const Key('settings-row-language')));
    await settleE2e($);
    await $.tester.tap(find.byKey(const Key('language-row-en')));
    await settleE2e($);
    await $.tester.tap(find.byType(BackButton).first);
    await $.pumpAndSettle();

    await tapVisible($, find.byKey(const Key('settings-row-notifications')));
    await settleE2e($);
    final medicationSwitch = find.byKey(
      const Key('notification-switch-medication'),
    );
    expect(readSwitchValue($, switchIn(medicationSwitch)), isTrue);
    await $.tester.tap(medicationSwitch);
    await settleE2e($);
    expect(readSwitchValue($, switchIn(medicationSwitch)), isFalse);
    await $.tester.tap(find.byType(BackButton).first);
    await settleE2e($);

    var preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('theme.mode'), 'dark');
    expect(preferences.getString('theme.palette'), 'blue-pink');
    expect(preferences.getString('app.locale'), 'en');
    expect(
      preferences.getBool('settings.notifications.medicationReminders'),
      isFalse,
    );

    await tapVisible($, find.byKey(const Key('settings-row-advanced')));
    await $.tester.tap(
      find.byKey(const Key('advanced-settings-row-reset-defaults')),
    );
    await settleE2e($);

    preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('theme.mode'), 'system');
    expect(preferences.getString('theme.palette'), 'classic');
    expect(preferences.getString('app.locale'), 'system');
    expect(
      preferences.getBool('settings.notifications.medicationReminders'),
      isNull,
    );

    await $.tester.tap(find.byType(BackButton).first);
    await settleE2e($);
    await $.tester.tap(find.byKey(const Key('settings-row-notifications')));
    await settleE2e($);
    expect(
      readSwitchValue(
        $,
        switchIn(find.byKey(const Key('notification-switch-medication'))),
      ),
      isTrue,
    );
  });
}
