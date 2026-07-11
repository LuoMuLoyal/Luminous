import '../support/e2e_test_helpers.dart';

void main() {
  patrolTest('record create saves daily record and returns to timeline', (
    $,
  ) async {
    final dailyRecordRepository = E2eDailyRecordRepository();

    await pumpOfflineApp(
      $,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      dailyRecordRepository: dailyRecordRepository,
    );

    await openTab($, '记录');

    await $.tester.tap(find.byIcon(Icons.add_rounded).last);
    await settleE2e($);

    expect($('类型').exists, true);
    expect($('饮水').exists, true);

    await $.tester.enterText(
      find.byKey(const Key('daily-record-value-field')),
      '6',
    );
    await $.tester.enterText(
      find.byKey(const Key('daily-record-note-field')),
      'E2E hydration note',
    );
    await $.tester.tap(find.widgetWithText(ElevatedButton, '保存'));
    await settleE2e($);

    final input = dailyRecordRepository.createInput;
    expect(input, isNotNull);
    expect(input!.kind, DailyRecordKind.water);
    expect(input.value, '6');
    expect(input.unit, 'ml');
    expect(input.note, 'E2E hydration note');
    expect(input.attachments, isEmpty);
    expect(find.byKey(const Key('record-timeline')), findsOneWidget);
  });

  patrolTest('record detail delete confirms and returns to timeline', (
    $,
  ) async {
    final dailyRecordRepository = E2eDailyRecordRepository();

    await pumpOfflineApp(
      $,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      dailyRecordRepository: dailyRecordRepository,
      recordRepository: E2eRecordRepository(),
    );

    await openTab($, '记录');

    final entry = find.text('E2E blood pressure');
    await $.tester.scrollUntilVisible(entry, 240);
    await $.tester.tap(entry);
    await settleE2e($);

    final deleteButton = find.widgetWithText(OutlinedButton, '删除');
    await $.tester.scrollUntilVisible(
      deleteButton,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await $.tester.tap(deleteButton);
    await settleE2e($);

    final confirmButton = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(FilledButton, '删除'),
    );
    await $.tester.tap(confirmButton);
    await settleE2e($);

    expect(dailyRecordRepository.deleteCalledWith, 'e2e-record-1');
    expect(find.byKey(const Key('record-timeline')), findsOneWidget);
  });

  patrolTest('record edit saves update and returns to detail', ($) async {
    final dailyRecordRepository = E2eDailyRecordRepository();

    await pumpOfflineApp(
      $,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      dailyRecordRepository: dailyRecordRepository,
      recordRepository: E2eRecordRepository(),
    );

    await openTab($, '记录');

    final entry = find.text('E2E blood pressure');
    await $.tester.scrollUntilVisible(entry, 240);
    await $.tester.tap(entry);
    await settleE2e($);

    await $.tester.tap(find.byTooltip('编辑'));
    await settleE2e($);

    final fields = find.byType(TextField);
    await $.tester.enterText(fields.at(0), '122/78');
    await $.tester.enterText(fields.at(1), 'mmHg');
    await $.tester.enterText(fields.at(2), 'E2E edited blood pressure');
    await $.tester.enterText(fields.at(3), 'E2E edited note');

    await $.tester.tap(find.widgetWithText(ElevatedButton, '保存'));
    await settleE2e($);

    final input = dailyRecordRepository.updateInput;
    expect(dailyRecordRepository.updateCalledWith, 'e2e-record-1');
    expect(input, isNotNull);
    expect(input!.kind, DailyRecordKind.vital);
    expect(input.value, '122/78');
    expect(input.unit, 'mmHg');
    expect(input.title, 'E2E edited blood pressure');
    expect(input.note, 'E2E edited note');
    expect(input.attachments, dailyRecordNoChange);
    expect($('记录详情').exists, true);
  });
}
