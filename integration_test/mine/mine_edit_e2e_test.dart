import 'dart:async';

import 'package:integration_test/integration_test.dart';

import '../support/e2e_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('allergy edit prefills from snapshot and saves update', (
    tester,
  ) async {
    final healthRepo = E2eHealthContextRepositoryWithItems();

    final container = await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      healthContextRepository: healthRepo,
    );

    // Navigate to the allergy edit page for an existing allergy.
    unawaited(
      container
          .read(appRouterProvider)
          .push('/mine/allergy/e2e-allergy-1/edit'),
    );
    await settleE2e(tester, frames: 10);

    // The label field should be prefilled with the existing allergy label.
    final labelField = find.byKey(const Key('allergy-label-field'));
    await pumpUntilFound(tester, labelField);
    final editable = find.descendant(
      of: labelField,
      matching: find.byType(EditableText),
    );
    expect(
      tester.widget<EditableText>(editable).controller.text,
      'E2E Penicillin',
    );

    // Change the label and save.
    await tester.enterText(labelField, 'E2E Updated Allergy');
    await tester.tap(find.byKey(const Key('allergy-save-button')));
    await settleE2e(tester, frames: 10);

    // Verify the update was called with the correct payload.
    expect(healthRepo.allergyUpdate, isNotNull);
    expect(healthRepo.allergyUpdate!.label, 'E2E Updated Allergy');
  });

  testWidgets('allergy edit delete button calls deleteAllergy', (tester) async {
    final healthRepo = E2eHealthContextRepositoryWithItems();

    final container = await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      healthContextRepository: healthRepo,
    );

    unawaited(
      container
          .read(appRouterProvider)
          .push('/mine/allergy/e2e-allergy-1/edit'),
    );
    await settleE2e(tester, frames: 10);

    // The delete button should be visible on edit pages.
    final deleteButton = find.byKey(const Key('allergy-delete-button'));
    await pumpUntilFound(tester, deleteButton);
    expect(deleteButton, findsOneWidget);

    await tester.tap(deleteButton);
    await settleE2e(tester, frames: 10);

    expect(healthRepo.allergyDeleteId, 'e2e-allergy-1');
  });

  testWidgets('condition edit prefills from snapshot and saves update', (
    tester,
  ) async {
    final healthRepo = E2eHealthContextRepositoryWithItems();

    final container = await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      healthContextRepository: healthRepo,
    );

    unawaited(
      container
          .read(appRouterProvider)
          .push('/mine/condition/e2e-condition-1/edit'),
    );
    await settleE2e(tester, frames: 10);

    // The label field should be prefilled with the existing condition label.
    final labelField = find.byKey(const Key('condition-label-field'));
    await pumpUntilFound(tester, labelField);
    final editable = find.descendant(
      of: labelField,
      matching: find.byType(EditableText),
    );
    expect(tester.widget<EditableText>(editable).controller.text, 'E2E Asthma');

    // Change the label and save.
    await tester.enterText(labelField, 'E2E Updated Condition');
    await tester.tap(find.byKey(const Key('condition-save-button')));
    await settleE2e(tester, frames: 10);

    expect(healthRepo.conditionUpdate, isNotNull);
    expect(healthRepo.conditionUpdate!.label, 'E2E Updated Condition');
  });

  testWidgets('condition edit delete button calls deleteCondition', (
    tester,
  ) async {
    final healthRepo = E2eHealthContextRepositoryWithItems();

    final container = await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      healthContextRepository: healthRepo,
    );

    unawaited(
      container
          .read(appRouterProvider)
          .push('/mine/condition/e2e-condition-1/edit'),
    );
    await settleE2e(tester, frames: 10);

    final deleteButton = find.byKey(const Key('condition-delete-button'));
    await pumpUntilFound(tester, deleteButton);
    expect(deleteButton, findsOneWidget);

    await tester.tap(deleteButton);
    await settleE2e(tester, frames: 10);

    expect(healthRepo.conditionDeleteId, 'e2e-condition-1');
  });

  testWidgets('allergy edit with non-existent id shows not-found error', (
    tester,
  ) async {
    final healthRepo = E2eHealthContextRepositoryWithItems();

    final container = await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      healthContextRepository: healthRepo,
    );

    unawaited(
      container.read(appRouterProvider).push('/mine/allergy/non-existent/edit'),
    );
    await settleE2e(tester, frames: 10);

    // Should show an error view (not-found state).
    expect(find.byType(BackButton), findsWidgets);
    // The allergy form fields should NOT be visible.
    expect(find.byKey(const Key('allergy-label-field')), findsNothing);
  });
}
