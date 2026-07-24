import 'package:integration_test/integration_test.dart';
import '../support/e2e_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'today signed-out preview renders all dashboard sections and sign-in hint',
    (tester) async {
      await pumpOfflineApp(tester);

      await openTab(tester, '今日');

      // Core dashboard sections should render with mock data.
      expect(find.byKey(const Key('today-summary-card')), findsOneWidget);
      expect(find.byKey(const Key('today-observation-card')), findsOneWidget);
      expect(
        find.byKey(const Key('today-quick-actions-primary')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('today-quick-actions-secondary')),
        findsOneWidget,
      );

      // Sign-in hint banner should be visible in preview mode.
      expect(find.byKey(const Key('sign-in-hint-banner')), findsOneWidget);

      // Primary suggestion card should NOT render (no data when signed out).
      expect(
        find.byKey(const Key('today-primary-suggestion-card')),
        findsNothing,
      );

      // Secondary suggestions card container should still render.
      expect(
        find.byKey(const Key('today-secondary-suggestions-card')),
        findsOneWidget,
      );
    },
  );

  testWidgets('today sign-in hint banner routes to login', (tester) async {
    await pumpOfflineApp(tester);

    await openTab(tester, '今日');

    // Find and tap the sign-in button inside the hint banner.
    final signInButton = find.descendant(
      of: find.byKey(const Key('sign-in-hint-banner')),
      matching: find.byType(FButton),
    );
    expect(signInButton, findsOneWidget);
    await tester.tap(signInButton);
    await settleE2e(tester);

    expect(find.text('邮箱'), findsWidgets);
    expect(find.widgetWithText(FilledButton, '登录'), findsOneWidget);
  });

  testWidgets('today signed-in renders all dashboard sections', (tester) async {
    await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
    );

    await openTab(tester, '今日');

    // Core dashboard sections should render with mock data.
    expect(find.byKey(const Key('today-summary-card')), findsOneWidget);
    expect(find.byKey(const Key('today-observation-card')), findsOneWidget);
    expect(
      find.byKey(const Key('today-quick-actions-primary')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('today-quick-actions-secondary')),
      findsOneWidget,
    );

    // No sign-in hint banner when signed in.
    expect(find.byKey(const Key('sign-in-hint-banner')), findsNothing);
  });

  testWidgets('today assistant entry is visible in top bar', (tester) async {
    await pumpOfflineApp(tester);

    await openTab(tester, '今日');

    expect(find.byKey(const Key('today-assistant-entry')), findsOneWidget);
  });

  testWidgets('today tab navigation round-trip preserves state', (
    tester,
  ) async {
    await pumpOfflineApp(tester);

    // Start on Today tab.
    await openTab(tester, '今日');
    expect(find.byKey(const Key('today-summary-card')), findsOneWidget);

    // Navigate away and back — state should be preserved.
    await openTab(tester, '记录');
    await settleE2e(tester);
    expect(find.byKey(const Key('record-timeline')), findsOneWidget);

    await openTab(tester, '今日');
    await settleE2e(tester);
    expect(find.byKey(const Key('today-summary-card')), findsOneWidget);
  });
}
