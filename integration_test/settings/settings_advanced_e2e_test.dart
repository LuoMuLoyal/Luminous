import 'package:integration_test/integration_test.dart';
import 'package:luminous/core/storage/kv_store.dart';
import 'package:luminous/features/settings/domain/entities/notification_permission_state.dart';

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
    await tester.pumpAndSettle();

    await tapVisible(
      tester,
      find.byKey(const Key('settings-row-notifications')),
    );
    await settleE2e(tester);
    final medicationSwitch = find.byKey(
      const Key('notification-switch-medication'),
    );
    expect(readSwitchValue(tester, switchIn(medicationSwitch)), isTrue);
    await tester.tap(medicationSwitch);
    await settleE2e(tester);
    expect(readSwitchValue(tester, switchIn(medicationSwitch)), isFalse);
    await tester.tap(find.byType(BackButton).first);
    await settleE2e(tester);

    var preferences = KvStore.instance;
    expect(preferences.getOrNull<String>('theme.mode'), 'dark');
    expect(preferences.getOrNull<String>('theme.palette'), 'blue-pink');
    expect(preferences.getOrNull<String>('app.locale'), 'en');
    expect(
      preferences.get<bool>(
        'settings.notifications.medicationReminders',
        fallback: false,
      ),
      isFalse,
    );

    await tapVisible(tester, find.byKey(const Key('settings-row-advanced')));
    await tester.tap(
      find.byKey(const Key('advanced-settings-row-reset-defaults')),
    );
    await settleE2e(tester);

    preferences = KvStore.instance;
    expect(preferences.getOrNull<String>('theme.mode'), 'system');
    expect(preferences.getOrNull<String>('theme.palette'), 'classic');
    expect(preferences.getOrNull<String>('app.locale'), 'system');
    expect(
      preferences.get<bool>(
        'settings.notifications.medicationReminders',
        fallback: false,
      ),
      isNull,
    );

    await tester.tap(find.byType(BackButton).first);
    await settleE2e(tester);
    await tester.tap(find.byKey(const Key('settings-row-notifications')));
    await settleE2e(tester);
    expect(
      readSwitchValue(
        tester,
        switchIn(find.byKey(const Key('notification-switch-medication'))),
      ),
      isTrue,
    );
  });
}
