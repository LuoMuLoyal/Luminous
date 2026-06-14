import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/report/domain/entities/report_ai_summary.dart';
import 'package:luminous/features/report/presentation/providers/report_ai_summary_provider.dart';
import 'package:luminous/features/shell/presentation/shell_tab.dart';
import 'package:luminous/features/today/domain/entities/today_ai_analysis.dart';
import 'package:luminous/features/today/presentation/providers/today_ai_analysis_provider.dart';

import '../support/e2e_test_helpers.dart';
import '../support/fullstack_e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'full-stack today and report lane loads protected dashboards and refreshes report',
    (tester) async {
      final config = FullstackE2eConfig.fromEnvironment();

      await prepareFullstackRecordLane(config);
      final container = await pumpFullstackApp(tester, config: config);

      await signInThroughUi(tester, config: config);
      await waitForAuthenticatedSession(tester, container);
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);

      await openShellTab(
        tester,
        ShellTab.today,
        timeout: const Duration(seconds: 15),
      );
      await pumpUntilFound(
        tester,
        find.byKey(const Key('today-health-summary-card')),
        timeout: const Duration(seconds: 15),
      );
      await tester.scrollUntilVisible(
        find.byKey(const Key('today-ai-summary-card')),
        220,
      );
      expect(
        find.byKey(const Key('today-health-summary-card')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('today-ai-summary-card')), findsOneWidget);
      expect(find.byKey(const Key('today-medication-card')), findsOneWidget);
      expect(find.byKey(const Key('today-water-card')), findsOneWidget);

      final todayStates = <TodayAiAnalysisCardState>[];
      final todaySubscription = container.listen(
        todayAiAnalysisControllerProvider,
        (previous, next) => todayStates.add(next),
        fireImmediately: true,
      );
      addTearDown(todaySubscription.close);

      final todayCard = find.byKey(const Key('today-ai-summary-card'));
      final todayGenerateButton = find.descendant(
        of: todayCard,
        matching: find.byType(TextButton),
      ).first;
      await tester.ensureVisible(todayGenerateButton);
      await settleE2e(tester, frames: 4);
      await tester.tap(todayGenerateButton);
      await settleE2e(tester, frames: 4);
      await waitUntil(
        tester,
        () =>
            container.read(todayAiAnalysisControllerProvider).status ==
            TodayAiAnalysisCardStatus.success,
      );
      expect(
        todayStates.any(
          (state) =>
              state.status == TodayAiAnalysisCardStatus.loading &&
              (state.streamingSummary?.isNotEmpty ?? false),
        ),
        isTrue,
      );

      await openShellTab(
        tester,
        ShellTab.report,
        timeout: const Duration(seconds: 15),
      );
      await pumpUntilFound(
        tester,
        find.byKey(const Key('report-snapshot-status')),
        timeout: const Duration(seconds: 15),
      );
      expect(find.byKey(const Key('report-generate-action')), findsOneWidget);
      expect(find.byKey(const Key('report-sync-action')), findsOneWidget);

      final reportStates = <ReportAiSummaryCardState>[];
      final reportSubscription = container.listen(
        reportAiSummaryControllerProvider(ReportAiSummaryRange.last7Days),
        (previous, next) => reportStates.add(next),
        fireImmediately: true,
      );
      addTearDown(reportSubscription.close);

      final reportScrollable = find.byType(Scrollable).first;
      for (final key in const <String>[
        'report-score-hero',
        'report-trend-section',
        'report-ai-summary-section',
        'report-reference-notice',
      ]) {
        final finder = find.byKey(Key(key));
        await tester.scrollUntilVisible(
          finder,
          260,
          scrollable: reportScrollable,
        );
        await settleE2e(tester, frames: 4);
        expect(finder, findsOneWidget);
      }

      await tester.scrollUntilVisible(
        find.byKey(const Key('report-sync-action')),
        -260,
        scrollable: reportScrollable,
      );
      await settleE2e(tester, frames: 4);
      await tapVisible(tester, find.byKey(const Key('report-sync-action')));
      await pumpUntilFound(
        tester,
        find.byKey(const Key('report-snapshot-status')),
        timeout: const Duration(seconds: 15),
      );
      expect(find.byType(RefreshIndicator), findsOneWidget);
      expect(find.byType(AppStateErrorView), findsNothing);

      final reportSection = find.byKey(const Key('report-ai-summary-section'));
      final reportGenerateAction = find.descendant(
        of: reportSection,
        matching: find.byKey(const Key('report-ai-summary-generate-action')),
      );
      await pumpUntilFound(
        tester,
        reportGenerateAction,
        timeout: const Duration(seconds: 15),
      );
      await tester.ensureVisible(reportGenerateAction);
      await settleE2e(tester, frames: 4);
      await tester.tap(reportGenerateAction);
      await settleE2e(tester, frames: 4);
      await waitUntil(
        tester,
        () =>
            container
                .read(
                  reportAiSummaryControllerProvider(
                    ReportAiSummaryRange.last7Days,
                  ),
                )
                .status ==
            ReportAiSummaryCardStatus.success,
      );
      expect(
        reportStates.any(
          (state) =>
              state.status == ReportAiSummaryCardStatus.loading &&
              (state.streamingSummary?.isNotEmpty ?? false),
        ),
        isTrue,
      );
    },
  );
}

Future<void> waitUntil(
  WidgetTester tester,
  bool Function() predicate, {
  Duration timeout = const Duration(seconds: 120),
  Duration step = const Duration(milliseconds: 100),
}) async {
  final endTime = tester.binding.clock.fromNowBy(timeout);

  do {
    await tester.pump(step);
    if (predicate()) {
      return;
    }
  } while (tester.binding.clock.now().isBefore(endTime));

  fail('Timed out waiting for condition.');
}
