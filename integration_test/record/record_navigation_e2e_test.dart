import '../support/e2e_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('record timeline opens detail and edit with system back', (
    tester,
  ) async {
    final dailyRecordRepository = E2eDailyRecordRepository();

    await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      dailyRecordRepository: dailyRecordRepository,
      recordRepository: E2eRecordRepository(),
    );

    await openTab(tester, '记录');

    final entry = find.text('E2E blood pressure');
    await tester.scrollUntilVisible(entry, 240);
    await tester.tap(entry);
    await settleE2e(tester);

    expect(dailyRecordRepository.getCalledWith, 'e2e-record-1');
    expect(find.text('记录详情'), findsOneWidget);
    expect(find.text('E2E blood pressure'), findsOneWidget);
    expect(find.text('118/76 mmHg'), findsOneWidget);
    expect(find.text('E2E detail note'), findsOneWidget);

    await tester.tap(find.byTooltip('编辑'));
    await settleE2e(tester);

    expect(dailyRecordRepository.getCalledWith, 'e2e-record-1');
    expect(find.text('编辑'), findsOneWidget);
    expect(find.text('备注'), findsWidgets);

    await tester.tap(find.byType(BackButton).first);
    await settleE2e(tester);
    expect(find.text('记录详情'), findsOneWidget);

    await tester.tap(find.byType(BackButton).first);
    await settleE2e(tester);
    expect(find.byKey(const Key('record-timeline')), findsOneWidget);
  });

  testWidgets('record previous day action reloads selected timeline', (
    tester,
  ) async {
    final recordRepository = E2eRecordRepository();

    await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      recordRepository: recordRepository,
    );

    await openTab(tester, '记录');

    expect(recordRepository.requestedDates, isNotEmpty);
    final initialDate = recordRepository.requestedDates.last;

    await tester.tap(find.byKey(const Key('record-date-previous-action')));
    await settleE2e(tester);

    expect(
      recordRepository.requestedDates,
      contains(initialDate.subtract(const Duration(days: 1))),
    );
    expect(find.byKey(const Key('record-timeline')), findsOneWidget);
  });

  testWidgets(
    'record next day and previous day actions reload selected timeline',
    (tester) async {
      final recordRepository = E2eRecordRepository();

      await pumpOfflineApp(
        tester,
        authSessionOverride: SignedInAuthSessionNotifier.new,
        recordRepository: recordRepository,
      );

      await openTab(tester, '记录');

      expect(recordRepository.requestedDates, isNotEmpty);
      final initialDate = recordRepository.requestedDates.last;

      await tester.tap(find.byKey(const Key('record-date-next-action')));
      await settleE2e(tester);

      expect(
        recordRepository.requestedDates,
        contains(initialDate.add(const Duration(days: 1))),
      );

      await tester.tap(find.byKey(const Key('record-date-previous-action')));
      await settleE2e(tester);

      expect(recordRepository.requestedDates.last, initialDate);
      expect(find.byKey(const Key('record-timeline')), findsOneWidget);
    },
  );
}
