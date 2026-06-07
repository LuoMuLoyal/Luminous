import 'e2e_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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
