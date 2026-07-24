import 'dart:async';

import 'package:integration_test/integration_test.dart';

import '../support/e2e_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('mine signed-out notice routes to login', (tester) async {
    await pumpOfflineApp(tester);

    await openTab(tester, '我的');

    expect(find.text('当前未登录'), findsWidgets);

    await tester.tap(find.widgetWithText(OutlinedButton, '去登录'));
    await settleE2e(tester);

    expect(find.text('邮箱'), findsWidgets);
    expect(find.widgetWithText(FilledButton, '登录'), findsOneWidget);
  });

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
    expect(find.byKey(const Key('mine-archive-section')), findsOneWidget);

    final basicInfo = find.text('基础信息');
    await tapVisible(tester, basicInfo);

    expect(find.text('编辑档案'), findsWidgets);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '1998-06-07');
    await tester.enterText(fields.at(1), '171');
    await tester.enterText(fields.at(2), 'AB');

    final saveButton = find.text('保存');
    await tapVisible(tester, saveButton);

    final input = healthContextRepository.profileUpdate;
    expect(input, isNotNull);
    expect(input!.birthDate, '1998-06-07');
    expect(input.heightCm, 171);
    expect(input.bloodType, 'AB');
    expect(find.byKey(const Key('mine-archive-section')), findsOneWidget);
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

    expect(find.text('新增过敏'), findsWidgets);

    await tester.enterText(
      find.byKey(const Key('allergy-label-field')),
      'E2E penicillin',
    );
    await tester.tap(find.byKey(const Key('allergy-save-button')));
    await settleE2e(tester);

    final input = healthContextRepository.allergyCreate;
    expect(input, isNotNull);
    expect(input!.label, 'E2E penicillin');
    expect(input.kind, HealthAllergyKind.drug);
    expect(find.byKey(const Key('mine-archive-section')), findsOneWidget);
  });

  testWidgets('mine condition create saves health context and returns', (
    tester,
  ) async {
    final healthContextRepository = E2eHealthContextRepository();

    final container = await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      healthContextRepository: healthContextRepository,
    );

    await openTab(tester, '我的');
    unawaited(container.read(appRouterProvider).push('/mine/condition/new'));
    await settleE2e(tester);

    expect(find.text('新增疾病'), findsWidgets);

    await tester.enterText(
      find.byKey(const Key('condition-label-field')),
      'E2E asthma',
    );
    await tester.tap(find.byKey(const Key('condition-save-button')));
    await settleE2e(tester);

    final input = healthContextRepository.conditionCreate;
    expect(input, isNotNull);
    expect(input!.label, 'E2E asthma');
    expect(input.status, HealthConditionStatus.active);
    await openTab(tester, '我的');
    expect(find.byKey(const Key('mine-archive-section')), findsOneWidget);
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

    expect(find.text('新增用药'), findsWidgets);

    await tester.enterText(
      find.byKey(const Key('medicine-displayname-field')),
      'E2E ibuprofen',
    );
    final saveButton = find.byKey(const Key('medicine-save-button'));
    await tapVisible(tester, saveButton);

    final input = healthContextRepository.medicineCreate;
    expect(input, isNotNull);
    expect(input!.displayName, 'E2E ibuprofen');
    expect(input.source, HealthMedicineSource.manual);
    expect(find.byKey(const Key('mine-archive-section')), findsOneWidget);
  });
}
