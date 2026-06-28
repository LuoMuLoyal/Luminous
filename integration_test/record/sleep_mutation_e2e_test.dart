import 'package:luminous/features/record/presentation/widgets/sleep_structured_fields.dart';

import '../support/e2e_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sleep create sends correct payload with wake-date convention', (
    tester,
  ) async {
    // Force the time picker into input mode so we can interact with
    // TextFields instead of the clock dial in integration tests.
    SleepStructuredFields.forceInputTimePicker = true;
    addTearDown(() => SleepStructuredFields.forceInputTimePicker = false);

    final dailyRecordRepository = E2eDailyRecordRepository();

    await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      dailyRecordRepository: dailyRecordRepository,
    );

    // Navigate to Record tab.
    await openTab(tester, '记录');

    // Tap the sleep quick action to open the fast-entry sheet, then choose
    // "更多" to reach the full create form.
    final sleepAction = find.byKey(const Key('record-quick-sleep'));
    await tester.scrollUntilVisible(sleepAction, 240);
    await tester.tap(sleepAction);
    await settleE2e(tester);

    await tester.tap(find.byKey(const Key('record-fast-entry-more-action')));
    await settleE2e(tester);

    // Verify the sleep form is shown with structured fields.
    expect(find.byKey(const Key('sleep-quality-field')), findsOneWidget);

    // Pick bedtime 23:00 — tap the keyed InkWell, then confirm in dialog.
    await tester.tap(find.byKey(const Key('sleep-bedtime-picker')));
    await settleE2e(tester);
    // Default initialTime is 23:00, so just confirm.
    await _confirmTimePicker(tester);

    // Pick wake time 07:00 — distinct from bedtime so duration is valid.
    await tester.tap(find.byKey(const Key('sleep-waketime-picker')));
    await settleE2e(tester);
    await _enterTimeAndConfirm(tester, hour: '7', minute: '0');

    // Save the record.
    await tester.tap(find.byKey(const Key('record-create-save-action')));
    await settleE2e(tester);

    // Verify the payload.
    final input = dailyRecordRepository.createInput;
    expect(input, isNotNull);
    expect(input!.kind, DailyRecordKind.sleep);
    expect(input.payload, isNotNull);
    expect(input.payload!['durationMinutes'], isA<int>());
    expect(input.payload!['durationMinutes'], greaterThan(0));
    expect(input.payload!['startAt'], isA<String>());
    expect(input.payload!['endAt'], isA<String>());
    final startAt = DateTime.parse(input.payload!['startAt'] as String);
    final endAt = DateTime.parse(input.payload!['endAt'] as String);
    expect(endAt.isAfter(startAt), isTrue);
  });
}

/// Confirms the time picker dialog without changing values.
///
/// Assumes the picker opened in input mode
/// (`SleepStructuredFields.forceInputTimePicker = true`).
Future<void> _confirmTimePicker(WidgetTester tester) async {
  await _pumpDialog(tester);
  await _tapOk(tester);
  await settleE2e(tester);
}

/// Enters the given hour/minute strings into the input-mode time picker
/// TextFields, then taps the confirm button.
Future<void> _enterTimeAndConfirm(
  WidgetTester tester, {
  required String hour,
  required String minute,
}) async {
  await _pumpDialog(tester);

  // The input-mode picker has two TextFields (hour, minute).
  // Scope to the dialog to avoid matching form fields behind it.
  final dialogFields = find.descendant(
    of: find.byType(Dialog),
    matching: find.byType(TextField),
  );
  await pumpUntilFound(
    tester,
    dialogFields.first,
    timeout: const Duration(seconds: 5),
  );

  await tester.tap(dialogFields.first);
  await tester.enterText(dialogFields.first, hour);
  await settleE2e(tester);

  await tester.tap(dialogFields.at(1));
  await tester.enterText(dialogFields.at(1), minute);
  await settleE2e(tester);

  await _tapOk(tester);
  await settleE2e(tester);
}

Future<void> _pumpDialog(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}

Future<void> _tapOk(WidgetTester tester) async {
  // The confirm button label varies by locale.
  final okZh = find.widgetWithText(TextButton, '确定');
  final okEn = find.widgetWithText(TextButton, 'OK');
  // Wait for whichever label appears first.
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
  if (tester.any(okZh)) {
    await tester.tap(okZh);
  } else {
    await pumpUntilFound(tester, okEn, timeout: const Duration(seconds: 5));
    await tester.tap(okEn);
  }
}
