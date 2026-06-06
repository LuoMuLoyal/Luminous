import 'e2e_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('mine profile edit saves health context and returns', (
    tester,
  ) async {
    final healthContextRepository = E2eHealthContextRepository();

    await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      healthContextRepository: healthContextRepository,
    );

    await openTab(tester, '我的');
    expect(find.byKey(const Key('mine-profile-grid')), findsOneWidget);

    final basicInfo = find.text('基础资料');
    await tester.scrollUntilVisible(
      basicInfo,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(basicInfo);
    await tester.pumpAndSettle();

    expect(find.text('编辑档案'), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '1998-06-07');
    await tester.enterText(fields.at(1), '171');
    await tester.enterText(fields.at(2), 'AB');

    final saveButton = find.text('保存');
    await tester.scrollUntilVisible(
      saveButton,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    final input = healthContextRepository.profileUpdate;
    expect(input, isNotNull);
    expect(input!.birthDate, '1998-06-07');
    expect(input.heightCm, 171);
    expect(input.bloodType, 'AB');
    expect(find.byKey(const Key('mine-profile-grid')), findsOneWidget);
  });

  testWidgets('mine allergy create saves health context and returns', (
    tester,
  ) async {
    final healthContextRepository = E2eHealthContextRepository();

    await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      healthContextRepository: healthContextRepository,
    );

    await openMineProfileEntry(tester, '过敏史');

    expect(find.text('新增过敏'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('allergy-label-field')),
      'E2E penicillin',
    );
    await tester.tap(find.byKey(const Key('allergy-save-button')));
    await tester.pumpAndSettle();

    final input = healthContextRepository.allergyCreate;
    expect(input, isNotNull);
    expect(input!.label, 'E2E penicillin');
    expect(input.kind, HealthAllergyKind.drug);
    expect(find.byKey(const Key('mine-profile-grid')), findsOneWidget);
  });

  testWidgets('mine condition create saves health context and returns', (
    tester,
  ) async {
    final healthContextRepository = E2eHealthContextRepository();

    await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      healthContextRepository: healthContextRepository,
    );

    await openMineProfileEntry(tester, '基础病史');

    expect(find.text('新增疾病'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('condition-label-field')),
      'E2E asthma',
    );
    await tester.tap(find.byKey(const Key('condition-save-button')));
    await tester.pumpAndSettle();

    final input = healthContextRepository.conditionCreate;
    expect(input, isNotNull);
    expect(input!.label, 'E2E asthma');
    expect(input.status, HealthConditionStatus.active);
    expect(find.byKey(const Key('mine-profile-grid')), findsOneWidget);
  });

  testWidgets('mine current medicine create saves health context and returns', (
    tester,
  ) async {
    final healthContextRepository = E2eHealthContextRepository();

    await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      healthContextRepository: healthContextRepository,
    );

    await openMineProfileEntry(tester, '当前用药');

    expect(find.text('新增用药'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('medicine-displayname-field')),
      'E2E ibuprofen',
    );
    final saveButton = find.byKey(const Key('medicine-save-button'));
    await tester.scrollUntilVisible(
      saveButton,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    final input = healthContextRepository.medicineCreate;
    expect(input, isNotNull);
    expect(input!.displayName, 'E2E ibuprofen');
    expect(input.source, HealthMedicineSource.manual);
    expect(find.byKey(const Key('mine-profile-grid')), findsOneWidget);
  });
}
