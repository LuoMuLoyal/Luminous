import 'package:integration_test/integration_test.dart';
import '../support/e2e_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shell renders all five tabs with correct labels', (
    tester,
  ) async {
    await pumpOfflineApp(tester);

    // Verify all five tab keys are visible.
    expect(find.byKey(const Key('shell-tab-today')), findsOneWidget);
    expect(find.byKey(const Key('shell-tab-record')), findsOneWidget);
    expect(find.byKey(const Key('shell-tab-medicine')), findsOneWidget);
    expect(find.byKey(const Key('shell-tab-report')), findsOneWidget);
    expect(find.byKey(const Key('shell-tab-mine')), findsOneWidget);
  });

  testWidgets('shell tab navigation round-trip visits all tabs', (
    tester,
  ) async {
    await pumpOfflineApp(tester);

    // Navigate through all tabs in order.
    await openTab(tester, '记录');
    await pumpUntilFound(
      tester,
      find.byKey(const Key('record-timeline')),
      timeout: const Duration(seconds: 10),
    );
    expect(find.byKey(const Key('record-timeline')), findsOneWidget);

    await openTab(tester, '用药');
    await pumpUntilFound(
      tester,
      find.byKey(const Key('medicine-today-plan')),
      timeout: const Duration(seconds: 10),
    );
    expect(find.byKey(const Key('medicine-today-plan')), findsOneWidget);

    await openTab(tester, '报告');
    await pumpUntilFound(
      tester,
      find.byKey(const Key('review-no-event-card')),
      timeout: const Duration(seconds: 10),
    );
    expect(find.byKey(const Key('review-no-event-card')), findsOneWidget);

    await openTab(tester, '我的');
    await pumpUntilFound(
      tester,
      find.byKey(const Key('mine-archive-section')),
      timeout: const Duration(seconds: 10),
    );
    expect(find.byKey(const Key('mine-archive-section')), findsOneWidget);

    // Return to today — should still render dashboard.
    await openTab(tester, '今日');
    await pumpUntilFound(
      tester,
      find.byKey(const Key('today-summary-card')),
      timeout: const Duration(seconds: 10),
    );
    expect(find.byKey(const Key('today-summary-card')), findsOneWidget);
  });

  testWidgets('shell preserves tab state when navigating away and back', (
    tester,
  ) async {
    await pumpOfflineApp(tester);

    // Load Today dashboard.
    await openTab(tester, '今日');
    await pumpUntilFound(tester, find.byKey(const Key('today-summary-card')));

    // Navigate to Record and load its content.
    await openTab(tester, '记录');
    await pumpUntilFound(tester, find.byKey(const Key('record-timeline')));

    // Navigate back to Today — dashboard should still be loaded.
    await openTab(tester, '今日');
    await pumpUntilFound(tester, find.byKey(const Key('today-summary-card')));
    expect(find.byKey(const Key('today-summary-card')), findsOneWidget);

    // Navigate to Medicine and back.
    await openTab(tester, '用药');
    await pumpUntilFound(
      tester,
      find.byKey(const Key('medicine-today-plan')),
      timeout: const Duration(seconds: 10),
    );

    await openTab(tester, '今日');
    await pumpUntilFound(tester, find.byKey(const Key('today-summary-card')));
    expect(find.byKey(const Key('today-summary-card')), findsOneWidget);
  });

  testWidgets('shell today tab is selected by default', (tester) async {
    await pumpOfflineApp(tester);

    // The Today tab should be the initial tab.
    // Verify by checking that the Today dashboard renders.
    await pumpUntilFound(tester, find.byKey(const Key('today-summary-card')));
    expect(find.byKey(const Key('today-summary-card')), findsOneWidget);
  });
}
