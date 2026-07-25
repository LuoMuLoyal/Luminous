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

      // Sign-in hint banner should be visible in preview mode (at top).
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

      // Quick actions may be below the fold — scroll to find them.
      final primaryFinder = find.byKey(
        const Key('today-quick-actions-primary'),
      );
      for (var i = 0; i < 5 && !tester.any(primaryFinder); i++) {
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
        await settleE2e(tester);
      }
      expect(primaryFinder, findsOneWidget);
      final secondaryFinder = find.byKey(
        const Key('today-quick-actions-secondary'),
      );
      for (var i = 0; i < 5 && !tester.any(secondaryFinder); i++) {
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
        await settleE2e(tester);
      }
      expect(secondaryFinder, findsOneWidget);
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
    expect(find.widgetWithText(FButton, '登录'), findsOneWidget);
  });

  testWidgets('today signed-in renders all dashboard sections', (tester) async {
    await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
    );

    await openTab(tester, '今日');

    // When signed in, the dashboard provider fetches via the mock repository
    // but other providers (suggestions, settings) may hang on network calls.
    // Pump a few frames to let the mock data resolve without waiting for
    // network-dependent providers to settle.
    await settleE2e(tester, frames: 20);

    // Core dashboard sections should render with mock data.
    // Summary is near the top; observation may need a small scroll.
    expect(find.byKey(const Key('today-summary-card')), findsOneWidget);
    final observationFinder = find.byKey(const Key('today-observation-card'));
    for (var i = 0; i < 3 && !tester.any(observationFinder); i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
      await settleE2e(tester);
    }
    expect(observationFinder, findsOneWidget);

    // Quick actions may be below the fold — scroll to find them.
    final primaryFinder = find.byKey(const Key('today-quick-actions-primary'));
    for (var i = 0; i < 5 && !tester.any(primaryFinder); i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
      await settleE2e(tester);
    }
    expect(primaryFinder, findsOneWidget);
    final secondaryFinder = find.byKey(
      const Key('today-quick-actions-secondary'),
    );
    for (var i = 0; i < 5 && !tester.any(secondaryFinder); i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
      await settleE2e(tester);
    }
    expect(secondaryFinder, findsOneWidget);

    // No sign-in hint banner when signed in.
    expect(find.byKey(const Key('sign-in-hint-banner')), findsNothing);

    // Allow pending async work to settle before disposal.
    await settleE2e(tester, frames: 30);
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
