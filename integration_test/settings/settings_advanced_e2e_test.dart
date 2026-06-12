import '../support/e2e_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('settings advanced reset defaults restores app preferences', (
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
    await settleE2e(tester);
    await tester.tap(find.byKey(const Key('theme-row-dark')));
    await settleE2e(tester);
    await tester.tap(find.byKey(const Key('theme-palette-row-blue-pink')));
    await settleE2e(tester);
    await tester.tap(find.byType(BackButton).first);
    await settleE2e(tester);

    await tester.tap(find.byKey(const Key('settings-row-language')));
    await settleE2e(tester);
    await tester.tap(find.byKey(const Key('language-row-en')));
    await settleE2e(tester);
    await tester.tap(find.byType(BackButton).first);
    await settleE2e(tester);

    await tester.tap(find.byKey(const Key('settings-row-notifications')));
    await settleE2e(tester);
    final medicationRow = find.byKey(const Key('notification-row-medication'));
    expect(readSwitchValue(tester, switchIn(medicationRow)), isTrue);
    await tester.tap(medicationRow);
    await settleE2e(tester);
    expect(readSwitchValue(tester, switchIn(medicationRow)), isFalse);
    await tester.tap(find.byType(BackButton).first);
    await settleE2e(tester);

    var preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('theme.mode'), 'dark');
    expect(preferences.getString('theme.palette'), 'blue-pink');
    expect(preferences.getString('app.locale'), 'en');
    expect(
      preferences.getBool('settings.notifications.medicationReminders'),
      isFalse,
    );

    await tapVisible(tester, find.byKey(const Key('settings-row-advanced')));
    await tester.tap(
      find.byKey(const Key('advanced-settings-row-reset-defaults')),
    );
    await settleE2e(tester);

    preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('theme.mode'), 'system');
    expect(preferences.getString('theme.palette'), 'classic');
    expect(preferences.getString('app.locale'), 'system');
    expect(
      preferences.getBool('settings.notifications.medicationReminders'),
      isNull,
    );

    await tester.tap(find.byType(BackButton).first);
    await settleE2e(tester);
    await tester.tap(find.byKey(const Key('settings-row-notifications')));
    await settleE2e(tester);
    expect(
      readSwitchValue(
        tester,
        switchIn(find.byKey(const Key('notification-row-medication'))),
      ),
      isTrue,
    );
  });
}
