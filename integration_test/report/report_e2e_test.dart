import '../support/e2e_test_helpers.dart';

void main() {
  patrolTest('report signed-out shows readiness card with sign-in action', (
    $,
  ) async {
    await pumpOfflineApp($);

    await openTab($, '报告');

    // Readiness card should be visible with sign-in action (signed out).
    expect(find.byKey(const Key('report-readiness-card')), findsOneWidget);
    expect(
      find.byKey(const Key('report-readiness-sign-in-action')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('report-readiness-record-action')),
      findsNothing,
    );

    // Core dashboard sections should render with preview/placeholder data.
    expect(find.byKey(const Key('report-score-hero')), findsOneWidget);
    expect(find.byKey(const Key('report-trend-section')), findsOneWidget);
    expect(find.byKey(const Key('report-findings-section')), findsOneWidget);

    // Locked features — AI summary and export should NOT render when
    // signed out (canShowFullReport is false).
    expect(find.byKey(const Key('report-ai-summary-section')), findsNothing);
    expect(find.byKey(const Key('report-export-section')), findsNothing);
    expect(find.byKey(const Key('report-patterns-section')), findsNothing);
  });

  patrolTest('report readiness sign-in action routes to login', ($) async {
    await pumpOfflineApp($);

    await openTab($, '报告');

    final signInAction = find.byKey(
      const Key('report-readiness-sign-in-action'),
    );
    await tapVisible($, signInAction);

    expect($('邮箱').exists, true);
    expect(find.widgetWithText(FilledButton, '登录'), findsOneWidget);
  });

  patrolTest(
    'report signed-in renders score hero, trend section, and findings',
    ($) async {
      await pumpOfflineApp(
        $,
        authSessionOverride: SignedInAuthSessionNotifier.new,
        reportRepository: const MockReportRepository(),
      );

      await openTab($, '报告');

      // Readiness card should be visible with record action (insufficient
      // data because the mock sleep metric has insufficientData status).
      expect(find.byKey(const Key('report-readiness-card')), findsOneWidget);
      expect(
        find.byKey(const Key('report-readiness-record-action')),
        findsOneWidget,
      );

      // No sign-in action when signed in.
      expect(
        find.byKey(const Key('report-readiness-sign-in-action')),
        findsNothing,
      );

      // Core dashboard sections should be visible.
      expect(find.byKey(const Key('report-score-hero')), findsOneWidget);
      expect(find.byKey(const Key('report-trend-section')), findsOneWidget);
      expect(find.byKey(const Key('report-findings-section')), findsOneWidget);

      // Locked features — AI summary/export/patterns should NOT render when
      // readiness status is insufficient (canShowFullReport is false).
      expect(find.byKey(const Key('report-ai-summary-section')), findsNothing);
      expect(find.byKey(const Key('report-export-section')), findsNothing);
      expect(find.byKey(const Key('report-patterns-section')), findsNothing);
    },
  );

  patrolTest('report readiness record action routes to record create page', (
    $,
  ) async {
    await pumpOfflineApp(
      $,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      reportRepository: const MockReportRepository(),
    );

    await openTab($, '报告');

    final recordAction = find.byKey(
      const Key('report-readiness-record-action'),
    );
    await tapVisible($, recordAction);

    // Should navigate to the record create page.
    expect(find.byKey(const Key('daily-record-value-field')), findsOneWidget);
  });

  patrolTest('report tab navigation round-trip preserves state', ($) async {
    await pumpOfflineApp($);

    // Start on Report tab.
    await openTab($, '报告');
    expect(find.byKey(const Key('report-readiness-card')), findsOneWidget);

    // Navigate away and back — state should be preserved.
    await openTab($, '记录');
    await settleE2e($);
    expect(find.byKey(const Key('record-timeline')), findsOneWidget);

    await openTab($, '报告');
    await settleE2e($);
    expect(find.byKey(const Key('report-readiness-card')), findsOneWidget);
  });
}
