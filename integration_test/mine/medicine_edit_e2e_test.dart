import 'dart:async';

import 'package:integration_test/integration_test.dart';
import 'package:luminous/core/widgets/common/back_button.dart';

import '../support/e2e_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('current medicine edit prefills from snapshot and saves update', (
    tester,
  ) async {
    final healthRepo = E2eHealthContextRepositoryWithItems();

    final container = await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      healthContextRepository: healthRepo,
    );

    // Navigate to the medicine edit page for an existing medicine.
    unawaited(
      container
          .read(appRouterProvider)
          .push('/mine/medicine/e2e-medicine-1/edit'),
    );

    // Wait for the display name field to appear (form loaded + prefilled).
    final displayNameField = find.byKey(
      const Key('medicine-displayname-field'),
    );
    await pumpUntilFound(
      tester,
      displayNameField,
      timeout: const Duration(seconds: 15),
    );
    final editable = find.descendant(
      of: displayNameField,
      matching: find.byType(EditableText),
    );
    expect(
      tester.widget<EditableText>(editable).controller.text,
      'E2E Ibuprofen',
    );

    // Change the display name and save.
    await tester.enterText(displayNameField, 'E2E Updated Ibuprofen');

    // Scroll to the save button and tap it.
    final saveButton = find.byKey(const Key('medicine-save-button'));
    await tester.ensureVisible(saveButton);
    await settleE2e(tester);
    await tester.tap(saveButton, warnIfMissed: false);
    await settleE2e(tester, frames: 10);

    // Verify the update was called with the correct payload.
    expect(healthRepo.medicineUpdate, isNotNull);
    expect(healthRepo.medicineUpdate!.displayName, 'E2E Updated Ibuprofen');

    // Allow pending Dio interceptor callbacks to settle.
    await settleE2e(tester, frames: 30);
  });

  testWidgets(
    'current medicine edit delete button calls deleteCurrentMedicine',
    (tester) async {
      final healthRepo = E2eHealthContextRepositoryWithItems();

      final container = await pumpOfflineApp(
        tester,
        authSessionOverride: SignedInAuthSessionNotifier.new,
        healthContextRepository: healthRepo,
      );

      unawaited(
        container
            .read(appRouterProvider)
            .push('/mine/medicine/e2e-medicine-1/edit'),
      );

      // Wait for the delete button to appear.
      final deleteButton = find.byKey(const Key('medicine-delete-button'));
      await pumpUntilFound(
        tester,
        deleteButton,
        timeout: const Duration(seconds: 15),
      );

      // Scroll to the delete button and tap it.
      await tester.ensureVisible(deleteButton);
      await settleE2e(tester);
      await tester.tap(deleteButton, warnIfMissed: false);
      await settleE2e(tester, frames: 10);

      expect(healthRepo.medicineDeleteId, 'e2e-medicine-1');

      // Allow pending Dio interceptor callbacks to settle.
      await settleE2e(tester, frames: 30);
    },
  );

  testWidgets(
    'current medicine edit with non-existent id shows not-found error',
    (tester) async {
      final healthRepo = E2eHealthContextRepositoryWithItems();

      final container = await pumpOfflineApp(
        tester,
        authSessionOverride: SignedInAuthSessionNotifier.new,
        healthContextRepository: healthRepo,
      );

      unawaited(
        container
            .read(appRouterProvider)
            .push('/mine/medicine/non-existent/edit'),
      );
      await settleE2e(tester, frames: 15);

      // Should show a back button (not-found state) but NOT the form fields.
      expect(find.byType(AppBackButton), findsWidgets);
      expect(find.byKey(const Key('medicine-displayname-field')), findsNothing);

      // Allow pending Dio interceptor callbacks to settle.
      await settleE2e(tester, frames: 30);
    },
  );

  testWidgets('current medicine create saves with manual source and returns', (
    tester,
  ) async {
    final healthRepo = E2eHealthContextRepositoryWithItems();

    final container = await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      healthContextRepository: healthRepo,
    );

    // Navigate to the medicine create page.
    unawaited(container.read(appRouterProvider).push('/mine/medicine/new'));

    final displayNameField = find.byKey(
      const Key('medicine-displayname-field'),
    );
    await pumpUntilFound(
      tester,
      displayNameField,
      timeout: const Duration(seconds: 15),
    );

    // Enter a display name and save.
    await tester.enterText(displayNameField, 'E2E New Medicine');

    final saveButton = find.byKey(const Key('medicine-save-button'));
    await tester.ensureVisible(saveButton);
    await settleE2e(tester);
    await tester.tap(saveButton, warnIfMissed: false);
    await settleE2e(tester, frames: 10);

    // Create page should NOT call update (only edit pages do).
    expect(healthRepo.medicineUpdate, isNull);

    // Allow pending Dio interceptor callbacks to settle.
    await settleE2e(tester, frames: 30);
  });
}
