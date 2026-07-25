import 'package:integration_test/integration_test.dart';
import 'package:luminous/core/widgets/common/back_button.dart';

import '../support/e2e_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'today assistant entry navigates to assistant page when signed in',
    (tester) async {
      await pumpOfflineApp(
        tester,
        authSessionOverride: SignedInAuthSessionNotifier.new,
      );

      await openTab(tester, '今日');

      final assistantEntry = find.byKey(const Key('today-assistant-entry'));
      expect(assistantEntry, findsOneWidget);
      await tester.tap(assistantEntry);
      await pumpUntilFound(
        tester,
        find.byType(AppBackButton),
        timeout: const Duration(seconds: 10),
      );

      expect(find.text('AI 对话'), findsWidgets);
      expect(find.byType(AppBackButton), findsWidgets);

      // Allow pending Dio interceptor callbacks to settle before disposal
      // to prevent UnmountedRefException.
      await settleE2e(tester, frames: 30);
    },
  );

  testWidgets('today assistant entry shows auth dialog when signed out', (
    tester,
  ) async {
    await pumpOfflineApp(tester);

    await openTab(tester, '今日');

    final assistantEntry = find.byKey(const Key('today-assistant-entry'));
    expect(assistantEntry, findsOneWidget);
    await tester.tap(assistantEntry);
    await pumpUntilFound(tester, find.byKey(const Key('auth-required-dialog')));

    await tester.tap(find.byKey(const Key('auth-required-login-action')));
    await settleE2e(tester);

    expect(find.text('邮箱'), findsWidgets);
    expect(find.widgetWithText(FButton, '登录'), findsOneWidget);
  });

  testWidgets(
    'today quick action record navigates to record create when signed in',
    (tester) async {
      await pumpOfflineApp(
        tester,
        authSessionOverride: SignedInAuthSessionNotifier.new,
        dailyRecordRepository: E2eDailyRecordRepository(),
      );

      await openTab(tester, '今日');

      final primaryFinder = find.byKey(
        const Key('today-quick-actions-primary'),
      );
      for (var i = 0; i < 5 && !tester.any(primaryFinder); i++) {
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
        await settleE2e(tester);
      }
      expect(primaryFinder, findsOneWidget);

      final quickRecordAction = find.descendant(
        of: primaryFinder,
        matching: find.text('快速记录'),
      );
      expect(quickRecordAction, findsOneWidget);
      await tester.tap(quickRecordAction);
      await pumpUntilFound(
        tester,
        find.byKey(const Key('daily-record-value-field')),
      );

      expect(find.byKey(const Key('daily-record-value-field')), findsOneWidget);
    },
  );

  testWidgets('today quick action record redirects to login when signed out', (
    tester,
  ) async {
    await pumpOfflineApp(tester);

    await openTab(tester, '今日');

    final primaryFinder = find.byKey(const Key('today-quick-actions-primary'));
    for (var i = 0; i < 5 && !tester.any(primaryFinder); i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
      await settleE2e(tester);
    }
    expect(primaryFinder, findsOneWidget);

    final quickRecordAction = find.descendant(
      of: primaryFinder,
      matching: find.text('快速记录'),
    );
    expect(quickRecordAction, findsOneWidget);
    await tester.tap(quickRecordAction);
    await pumpUntilFound(
      tester,
      find.byKey(const Key('auth-login-submit-action')),
    );

    expect(find.text('邮箱'), findsWidgets);
    expect(find.widgetWithText(FButton, '登录'), findsOneWidget);
  });

  testWidgets('today quick action confirm meds navigates to medicine tab', (
    tester,
  ) async {
    await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      medicineWorkspaceRepository: E2eMedicineWorkspaceRepository(),
    );

    await openTab(tester, '今日');

    final primaryFinder = find.byKey(const Key('today-quick-actions-primary'));
    for (var i = 0; i < 5 && !tester.any(primaryFinder); i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
      await settleE2e(tester);
    }
    expect(primaryFinder, findsOneWidget);

    final confirmMedsAction = find.descendant(
      of: primaryFinder,
      matching: find.text('确认用药'),
    );
    expect(confirmMedsAction, findsOneWidget);
    await tester.tap(confirmMedsAction);
    await pumpUntilFound(tester, find.byKey(const Key('medicine-today-plan')));

    expect(find.byKey(const Key('medicine-today-plan')), findsOneWidget);
  });

  testWidgets('today secondary quick actions section renders with items', (
    tester,
  ) async {
    await pumpOfflineApp(tester);

    await openTab(tester, '今日');

    final secondaryFinder = find.byKey(
      const Key('today-quick-actions-secondary'),
    );
    for (var i = 0; i < 5 && !tester.any(secondaryFinder); i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
      await settleE2e(tester);
    }
    expect(secondaryFinder, findsOneWidget);

    expect(
      find.descendant(of: secondaryFinder, matching: find.byType(FTile)),
      findsWidgets,
    );
  });

  testWidgets('today observation card renders with content', (tester) async {
    await pumpOfflineApp(tester);

    await openTab(tester, '今日');

    final observationCard = find.byKey(const Key('today-observation-card'));
    expect(observationCard, findsOneWidget);

    expect(
      find.descendant(of: observationCard, matching: find.byType(Text)),
      findsWidgets,
    );
  });

  testWidgets('today summary card renders with content', (tester) async {
    await pumpOfflineApp(tester);

    await openTab(tester, '今日');

    final summaryCard = find.byKey(const Key('today-summary-card'));
    expect(summaryCard, findsOneWidget);

    expect(
      find.descendant(of: summaryCard, matching: find.byType(Text)),
      findsWidgets,
    );
  });
}
