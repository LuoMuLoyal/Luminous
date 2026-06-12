import '../support/e2e_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('medicine search route works with offline search data', (
    tester,
  ) async {
    await pumpOfflineApp(tester);

    await openTab(tester, '用药');
    expect(find.byKey(const Key('medicine-today-plan')), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search_rounded).last);
    await settleE2e(tester);

    expect(find.text('搜索药品'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '布洛芬');
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('布洛芬片'), findsOneWidget);

    await tester.tap(find.byType(BackButton).first);
    await settleE2e(tester);
    expect(find.byKey(const Key('medicine-today-plan')), findsOneWidget);
  });

  testWidgets('medicine search add writes signed-in current medicine', (
    tester,
  ) async {
    final healthContextRepository = E2eHealthContextRepository();

    await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      healthContextRepository: healthContextRepository,
    );

    await openTab(tester, '用药');
    await tester.tap(find.byIcon(Icons.search_rounded).last);
    await settleE2e(tester);

    await tester.enterText(find.byType(TextField), '布洛芬');
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('布洛芬片'), findsOneWidget);

    final addButton = find.text('加入药箱').first;
    await tester.scrollUntilVisible(
      addButton,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(addButton);
    await settleE2e(tester);

    final input = healthContextRepository.medicineCreate;
    expect(input, isNotNull);
    expect(input!.source, HealthMedicineSource.cn);
    expect(input.sourceRefId, 'cn_ibuprofen_1');
    expect(input.displayName, '布洛芬片');
    expect(find.text('布洛芬片'), findsOneWidget);
  });

  testWidgets('medicine search add routes signed-out user to login', (
    tester,
  ) async {
    final healthContextRepository = E2eHealthContextRepository();

    await pumpOfflineApp(
      tester,
      healthContextRepository: healthContextRepository,
    );

    await openTab(tester, '用药');
    await tester.tap(find.byIcon(Icons.search_rounded).last);
    await settleE2e(tester);

    await tester.enterText(find.byType(TextField), '布洛芬');
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('布洛芬片'), findsOneWidget);

    final addButton = find.text('加入药箱').first;
    await tester.scrollUntilVisible(
      addButton,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(addButton);
    await settleE2e(tester);

    expect(healthContextRepository.medicineCreate, isNull);
    expect(find.byKey(const Key('auth-required-dialog')), findsOneWidget);
    await tester.tap(find.byKey(const Key('auth-required-login-action')));
    await settleE2e(tester);
    expect(find.byType(EditableText), findsWidgets);
  });

  testWidgets('medicine dose action routes signed-out user to login', (
    tester,
  ) async {
    await pumpOfflineApp(
      tester,
      medicineWorkspaceRepository: E2eMedicineWorkspaceRepository(),
    );

    await openTab(tester, '用药');

    expect(
      find.byKey(const Key('medicine-next-dose-action-taken')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('medicine-next-dose-action-skipped')),
      findsNothing,
    );
  });

  testWidgets('medicine dose action saves signed-in dose log', (tester) async {
    final doseLogRemoteDataSource = E2eDoseLogRemoteDataSource();

    await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      medicineWorkspaceRepository: E2eMedicineWorkspaceRepository(),
      doseLogRemoteDataSource: doseLogRemoteDataSource,
    );

    await openTab(tester, '用药');

    await tapMedicineDoseAction(tester, '已服用');

    expect(doseLogRemoteDataSource.createCurrentMedicineId, 'e2e-medicine-1');
    expect(doseLogRemoteDataSource.createStatus, 'taken');
    expect(doseLogRemoteDataSource.createDate, todayDateString());
    expect(find.byKey(const Key('medicine-today-plan')), findsOneWidget);
  });

  testWidgets('medicine skipped dose action saves signed-in dose log', (
    tester,
  ) async {
    final doseLogRemoteDataSource = E2eDoseLogRemoteDataSource();

    await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      medicineWorkspaceRepository: E2eMedicineWorkspaceRepository(),
      doseLogRemoteDataSource: doseLogRemoteDataSource,
    );

    await openTab(tester, '用药');

    await tapMedicineDoseAction(tester, '跳过');

    expect(doseLogRemoteDataSource.createCurrentMedicineId, 'e2e-medicine-1');
    expect(doseLogRemoteDataSource.createStatus, 'skipped');
    expect(doseLogRemoteDataSource.createDate, todayDateString());
    expect(find.byKey(const Key('medicine-today-plan')), findsOneWidget);
  });
}
