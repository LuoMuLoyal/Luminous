import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/shell/presentation/shell_tab.dart';

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
    },
  );
}
