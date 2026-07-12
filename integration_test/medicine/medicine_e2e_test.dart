import '../support/e2e_test_helpers.dart';

void main() {
  patrolTest('medicine search route works with offline search data', ($) async {
    await pumpOfflineApp($);

    await openTab($, '用药');
    expect(find.byKey(const Key('medicine-today-plan')), findsOneWidget);

    await $.tester.tap(find.byIcon(FLucideIcons.search).last);
    await settleE2e($);

    expect($('搜索药品').exists, true);
    await $.tester.enterText(find.byType(TextField), '布洛芬');
    await $.pump(const Duration(seconds: 1));

    expect($('布洛芬片').exists, true);

    await $.tester.tap(find.byType(BackButton).first);
    await settleE2e($);
    expect(find.byKey(const Key('medicine-today-plan')), findsOneWidget);
  });

  patrolTest('medicine search add writes signed-in current medicine', (
    $,
  ) async {
    final healthContextRepository = E2eHealthContextRepository();

    await pumpOfflineApp(
      $,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      healthContextRepository: healthContextRepository,
    );

    await openTab($, '用药');
    await $.tester.tap(find.byIcon(FLucideIcons.search).last);
    await settleE2e($);

    await $.tester.enterText(find.byType(TextField), '布洛芬');
    await $.pump(const Duration(seconds: 1));

    expect($('布洛芬片').exists, true);

    final addButton = find.text('加入药箱').first;
    await $.tester.scrollUntilVisible(
      addButton,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await $.tester.tap(addButton);
    await settleE2e($);

    final input = healthContextRepository.medicineCreate;
    expect(input, isNotNull);
    expect(input!.source, HealthMedicineSource.cn);
    expect(input.sourceRefId, '__mock_cn_ibuprofen__');
    expect(input.displayName, '[DEMO] 布洛芬片');
    expect($('布洛芬片').exists, true);
  });

  patrolTest('medicine search add routes signed-out user to login', ($) async {
    final healthContextRepository = E2eHealthContextRepository();

    await pumpOfflineApp($, healthContextRepository: healthContextRepository);

    await openTab($, '用药');
    await $.tester.tap(find.byIcon(FLucideIcons.search).last);
    await settleE2e($);

    await $.tester.enterText(find.byType(TextField), '布洛芬');
    await $.pump(const Duration(seconds: 1));

    expect($('布洛芬片').exists, true);

    final addButton = find.text('加入药箱').first;
    await $.tester.scrollUntilVisible(
      addButton,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await $.tester.tap(addButton);
    await settleE2e($);

    expect(healthContextRepository.medicineCreate, isNull);
    expect(find.byKey(const Key('auth-required-dialog')), findsOneWidget);
    await $.tester.tap(find.byKey(const Key('auth-required-login-action')));
    await settleE2e($);
    expect(find.byType(EditableText), findsWidgets);
  });

  patrolTest('medicine dose action routes signed-out user to login', ($) async {
    await pumpOfflineApp(
      $,
      medicineWorkspaceRepository: E2eMedicineWorkspaceRepository(),
    );

    await openTab($, '用药');

    expect(
      find.byKey(const Key('medicine-next-dose-action-taken')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('medicine-next-dose-action-skipped')),
      findsNothing,
    );
  });

  patrolTest('medicine dose action saves signed-in dose log', ($) async {
    final doseLogRemoteDataSource = E2eDoseLogRemoteDataSource();

    await pumpOfflineApp(
      $,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      medicineWorkspaceRepository: E2eMedicineWorkspaceRepository(),
      doseLogRemoteDataSource: doseLogRemoteDataSource,
    );

    await openTab($, '用药');

    await tapMedicineDoseAction($, '已服用');

    expect(doseLogRemoteDataSource.createCurrentMedicineId, 'e2e-medicine-1');
    expect(doseLogRemoteDataSource.createStatus, 'taken');
    expect(doseLogRemoteDataSource.createDate, todayDateString());
    expect(find.byKey(const Key('medicine-today-plan')), findsOneWidget);
  });

  patrolTest('medicine skipped dose action saves signed-in dose log', (
    $,
  ) async {
    final doseLogRemoteDataSource = E2eDoseLogRemoteDataSource();

    await pumpOfflineApp(
      $,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      medicineWorkspaceRepository: E2eMedicineWorkspaceRepository(),
      doseLogRemoteDataSource: doseLogRemoteDataSource,
    );

    await openTab($, '用药');

    await tapMedicineDoseAction($, '跳过');

    expect(doseLogRemoteDataSource.createCurrentMedicineId, 'e2e-medicine-1');
    expect(doseLogRemoteDataSource.createStatus, 'skipped');
    expect(doseLogRemoteDataSource.createDate, todayDateString());
    expect(find.byKey(const Key('medicine-today-plan')), findsOneWidget);
  });
}
