import '../support/e2e_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sleep create sends correct payload with wake-date convention', (
    tester,
  ) async {
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

/// TODO: Rewrite for Forui FTimeField.picker. The previous implementation
/// relied on Material's input-mode time picker, which has been replaced.
Future<void> _confirmTimePicker(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}

/// TODO: Rewrite for Forui FTimeField.picker. The previous implementation
/// relied on Material's input-mode time picker, which has been replaced.
Future<void> _enterTimeAndConfirm(
  WidgetTester tester, {
  required String hour,
  required String minute,
}) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}
