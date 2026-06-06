import 'e2e_test_helpers.dart';

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
    await tester.pumpAndSettle();

    expect(dailyRecordRepository.getCalledWith, 'e2e-record-1');
    expect(find.text('记录详情'), findsOneWidget);
    expect(find.text('E2E blood pressure'), findsOneWidget);
    expect(find.text('118/76 mmHg'), findsOneWidget);
    expect(find.text('E2E detail note'), findsOneWidget);

    await tester.tap(find.byTooltip('编辑'));
    await tester.pumpAndSettle();

    expect(dailyRecordRepository.getCalledWith, 'e2e-record-1');
    expect(find.text('编辑'), findsOneWidget);
    expect(find.text('备注'), findsWidgets);

    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();
    expect(find.text('记录详情'), findsOneWidget);

    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('record-timeline')), findsOneWidget);
  });

  testWidgets('record create saves daily record and returns to timeline', (
    tester,
  ) async {
    final dailyRecordRepository = E2eDailyRecordRepository();

    await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      dailyRecordRepository: dailyRecordRepository,
    );

    await openTab(tester, '记录');

    await tester.tap(find.byIcon(Icons.add_rounded).last);
    await tester.pumpAndSettle();

    expect(find.text('类型'), findsOneWidget);
    expect(find.text('饮水'), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '6');
    await tester.enterText(fields.at(1), 'cups');
    await tester.enterText(fields.at(2), 'E2E hydration note');
    await tester.tap(find.widgetWithText(ElevatedButton, '保存'));
    await tester.pumpAndSettle();

    final input = dailyRecordRepository.createInput;
    expect(input, isNotNull);
    expect(input!.kind, DailyRecordKind.water);
    expect(input.value, '6');
    expect(input.unit, 'cups');
    expect(input.note, 'E2E hydration note');
    expect(input.attachments, isEmpty);
    expect(find.byKey(const Key('record-timeline')), findsOneWidget);
  });

  testWidgets('record detail delete confirms and returns to timeline', (
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
    await tester.pumpAndSettle();

    final deleteButton = find.widgetWithText(OutlinedButton, '删除');
    await tester.scrollUntilVisible(
      deleteButton,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    final confirmButton = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(FilledButton, '删除'),
    );
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    expect(dailyRecordRepository.deleteCalledWith, 'e2e-record-1');
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

    await tester.tap(find.byTooltip('上一天'));
    await tester.pumpAndSettle();

    expect(
      recordRepository.requestedDates,
      contains(initialDate.subtract(const Duration(days: 1))),
    );
    expect(find.byKey(const Key('record-timeline')), findsOneWidget);
  });
}
