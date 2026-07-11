import '../support/e2e_test_helpers.dart';

void main() {
  patrolTest('record timeline opens detail and edit with system back', (
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

    expect(dailyRecordRepository.getCalledWith, 'e2e-record-1');
    expect($('记录详情').exists, true);
    expect($('E2E blood pressure').exists, true);
    expect($('118/76 mmHg').exists, true);
    expect($('E2E detail note').exists, true);

    await $.tester.tap(find.byTooltip('编辑'));
    await settleE2e($);

    expect(dailyRecordRepository.getCalledWith, 'e2e-record-1');
    expect($('编辑').exists, true);
    expect(find.byType(TextField), findsWidgets);

    await $.tester.tap(find.byType(BackButton).first);
    await settleE2e($);
    expect($('记录详情').exists, true);

    await $.tester.tap(find.byType(BackButton).first);
    await settleE2e($);
    expect(find.byKey(const Key('record-timeline')), findsOneWidget);
  });

  patrolTest('record previous day action reloads selected timeline', ($) async {
    final recordRepository = E2eRecordRepository();

    await pumpOfflineApp(
      $,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      recordRepository: recordRepository,
    );

    await openTab($, '记录');

    expect(recordRepository.requestedDates, isNotEmpty);
    final initialDate = recordRepository.requestedDates.last;

    await $.tester.tap(find.byKey(const Key('record-date-previous-action')));
    await settleE2e($);

    expect(
      recordRepository.requestedDates,
      contains(initialDate.subtract(const Duration(days: 1))),
    );
    expect(find.byKey(const Key('record-timeline')), findsOneWidget);
  });

  patrolTest(
    'record next day and previous day actions reload selected timeline',
    ($) async {
      final recordRepository = E2eRecordRepository();

      await pumpOfflineApp(
        $,
        authSessionOverride: SignedInAuthSessionNotifier.new,
        recordRepository: recordRepository,
      );

      await openTab($, '记录');

      expect(recordRepository.requestedDates, isNotEmpty);
      final initialDate = recordRepository.requestedDates.last;

      await $.tester.tap(find.byKey(const Key('record-date-next-action')));
      await settleE2e($);

      expect(
        recordRepository.requestedDates,
        contains(initialDate.add(const Duration(days: 1))),
      );

      await $.tester.tap(find.byKey(const Key('record-date-previous-action')));
      await settleE2e($);

      expect(recordRepository.requestedDates.last, initialDate);
      expect(find.byKey(const Key('record-timeline')), findsOneWidget);
    },
  );
}
