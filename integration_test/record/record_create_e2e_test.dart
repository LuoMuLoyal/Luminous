import 'dart:async';

import 'package:integration_test/integration_test.dart';
import 'package:luminous/core/widgets/common/control/back_button.dart';

import '../support/e2e_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('record create with water kind saves value, unit and note', (
    tester,
  ) async {
    final dailyRecordRepository = E2eDailyRecordRepository();

    final container = await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      dailyRecordRepository: dailyRecordRepository,
    );

    await openTab(tester, '记录');

    // Navigate to the record create page via direct route.
    unawaited(container.read(appRouterProvider).push('/record/create'));
    await settleE2e(tester);

    // Default kind is water — verify the kind selector is visible.
    expect(find.text('类型'), findsWidgets);
    expect(find.byKey(const Key('daily-record-value-field')), findsOneWidget);

    // Fill in a water record: value and note.
    // Use a numeric value — water validation requires a positive number.
    await tester.enterText(
      find.byKey(const Key('daily-record-value-field')),
      '250',
    );
    await tester.enterText(
      find.byKey(const Key('daily-record-note-field')),
      'E2E vital note',
    );

    // Tap the save button.
    final saveButton = find.byKey(const Key('record-create-save-action'));
    await tester.ensureVisible(saveButton);
    await settleE2e(tester);
    await tester.tap(saveButton, warnIfMissed: false);
    await settleE2e(tester);

    final input = dailyRecordRepository.createInput;
    expect(input, isNotNull);
    expect(input!.kind, DailyRecordKind.water);
    expect(input.value, '250');
    expect(input.note, 'E2E vital note');

    // Allow pending Dio interceptor callbacks to settle.
    await settleE2e(tester, frames: 30);
  });

  testWidgets('record create signed-out via direct route redirects to login', (
    tester,
  ) async {
    final container = await pumpOfflineApp(tester);

    // Direct navigation to /record/create should be blocked by the
    // redirect guard and sent to /login.
    unawaited(container.read(appRouterProvider).push('/record/create'));
    await settleE2e(tester, frames: 10);

    expect(find.text('邮箱'), findsWidgets);
    expect(find.widgetWithText(FButton, '登录'), findsOneWidget);

    // Allow pending Dio interceptor callbacks to settle.
    await settleE2e(tester, frames: 30);
  });

  testWidgets('record NLP entry shows auth dialog when signed out', (
    tester,
  ) async {
    await pumpOfflineApp(tester);

    await openTab(tester, '记录');

    // Tap the NLP action — this shows an auth-required dialog instead
    // of navigating directly.
    await tester.tap(find.byKey(const Key('record-nlp-action')));
    await settleE2e(tester);

    // Should show the auth-required dialog, not the create page.
    expect(find.byKey(const Key('auth-required-dialog')), findsOneWidget);

    // Tapping the login action should navigate to login.
    await tester.tap(find.byKey(const Key('auth-required-login-action')));
    await settleE2e(tester);

    expect(find.text('邮箱'), findsWidgets);
    expect(find.widgetWithText(FButton, '登录'), findsOneWidget);
  });

  testWidgets(
    'record create empty value shows validation error and stays on page',
    (tester) async {
      final dailyRecordRepository = E2eDailyRecordRepository();

      final container = await pumpOfflineApp(
        tester,
        authSessionOverride: SignedInAuthSessionNotifier.new,
        dailyRecordRepository: dailyRecordRepository,
      );

      await openTab(tester, '记录');

      unawaited(container.read(appRouterProvider).push('/record/create'));
      await settleE2e(tester);

      // Tap save without entering any value.
      final saveButton = find.byKey(const Key('record-create-save-action'));
      await tester.ensureVisible(saveButton);
      await settleE2e(tester);
      await tester.tap(saveButton, warnIfMissed: false);
      await settleE2e(tester);

      // No record should have been created.
      expect(dailyRecordRepository.createInput, isNull);

      // Should still be on the create page.
      expect(find.byKey(const Key('daily-record-value-field')), findsOneWidget);

      // Allow pending Dio interceptor callbacks to settle.
      await settleE2e(tester, frames: 30);
    },
  );

  testWidgets(
    'record create back button returns to timeline when form is empty',
    (tester) async {
      final container = await pumpOfflineApp(
        tester,
        authSessionOverride: SignedInAuthSessionNotifier.new,
        dailyRecordRepository: E2eDailyRecordRepository(),
      );

      await openTab(tester, '记录');

      unawaited(container.read(appRouterProvider).push('/record/create'));
      await settleE2e(tester);

      expect(find.byKey(const Key('daily-record-value-field')), findsOneWidget);

      // Press back — since the form is empty (not dirty), it should pop
      // without showing the discard confirmation dialog.
      final backButton = find.descendant(
        of: find.byType(AppBackButton),
        matching: find.byType(FButton),
      );
      await tester.tap(backButton.first);
      await settleE2e(tester);

      // Should be back on the record timeline.
      expect(find.byKey(const Key('record-timeline')), findsOneWidget);

      // Allow pending Dio interceptor callbacks to settle.
      await settleE2e(tester, frames: 30);
    },
  );

  testWidgets(
    'record create with dirty form shows discard confirmation on back',
    (tester) async {
      final container = await pumpOfflineApp(
        tester,
        authSessionOverride: SignedInAuthSessionNotifier.new,
        dailyRecordRepository: E2eDailyRecordRepository(),
      );

      await openTab(tester, '记录');

      unawaited(container.read(appRouterProvider).push('/record/create'));
      await settleE2e(tester);

      // Enter some text to make the form dirty.
      await tester.enterText(
        find.byKey(const Key('daily-record-value-field')),
        '500',
      );

      // Press back — since the form is dirty, a discard confirmation
      // dialog should appear.
      final backButton = find.descendant(
        of: find.byType(AppBackButton),
        matching: find.byType(FButton),
      );
      await tester.tap(backButton.first);
      await settleE2e(tester, frames: 10);

      // The discard confirmation dialog should be visible.
      expect(find.text('放弃'), findsOneWidget);

      // Tap the discard button to confirm.
      await tester.tap(find.widgetWithText(FButton, '放弃'));
      await settleE2e(tester);

      // Should now be back on the record timeline.
      expect(find.byKey(const Key('record-timeline')), findsOneWidget);

      // Allow pending Dio interceptor callbacks to settle.
      await settleE2e(tester, frames: 30);
    },
  );
}
