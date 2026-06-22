import 'package:luminous/features/record/presentation/widgets/sleep_structured_fields.dart';
import 'package:luminous/features/shell/presentation/shell_tab.dart';

import '../support/e2e_test_helpers.dart';
import '../support/fullstack_e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'full-stack sleep lane: create sleep via structured fields',
    (tester) async {
      // Force the time picker into input mode so we can interact with
      // TextFields instead of the clock dial in integration tests.
      SleepStructuredFields.forceInputTimePicker = true;
      addTearDown(() => SleepStructuredFields.forceInputTimePicker = false);

      final config = FullstackE2eConfig.fromEnvironment();
      final targetDate = parseRecordDate(config.recordDate);

      await prepareFullstackRecordLane(config);
      final container = await pumpFullstackApp(tester, config: config);

      await signInThroughUi(tester, config: config);
      await waitForAuthenticatedSession(tester, container);
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);

      // ── Record tab: create a sleep record ──────────────────────────

      await openRecordTabForDate(tester, container, targetDate: targetDate);

      await tapVisible(tester, find.byKey(const Key('record-quick-sleep')));
      await pumpUntilFound(
        tester,
        find.byKey(const Key('record-fast-entry-sleep')),
        timeout: const Duration(seconds: 10),
      );
      await tapVisible(
        tester,
        find.byKey(const Key('record-fast-entry-more-action')),
      );
      await pumpUntilFound(
        tester,
        find.byKey(const Key('sleep-quality-field')),
        timeout: const Duration(seconds: 10),
      );
      expect(find.byKey(const Key('sleep-quality-field')), findsOneWidget);

      // Bedtime: accept default 23:00.
      await tester.tap(find.byKey(const Key('sleep-bedtime-picker')));
      await settleE2e(tester);
      await _confirmTimePicker(tester);

      // Wake time: enter 07:00.
      await tester.tap(find.byKey(const Key('sleep-waketime-picker')));
      await settleE2e(tester);
      await _enterTimeAndConfirm(tester, hour: '7', minute: '0');

      // Quality: select "good".
      await tester.tap(find.byKey(const Key('sleep-quality-field')));
      await settleE2e(tester);
      final goodOption = find.text('良好').evaluate().isNotEmpty
          ? find.text('良好')
          : find.text('Good');
      await tester.tap(goodOption.last);
      await settleE2e(tester);

      // Save.
      await tester.tap(find.byKey(const Key('record-create-save-action')));
      await settleE2e(tester);

      await waitForRoute(
        tester,
        predicate: (uri) => uri.path == '/',
        description: 'return to shell after saving sleep record',
        timeout: const Duration(seconds: 15),
      );
      await openRecordTabForDate(tester, container, targetDate: targetDate);

      // ── Today tab: health summary renders ──────────────────────────

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
      expect(
        find.byKey(const Key('today-health-summary-card')),
        findsOneWidget,
      );

      // ── Report tab: trend section renders ──────────────────────────

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

      // Scroll to the trend section.
      final reportScrollable = find.byType(Scrollable).first;
      final trendSection = find.byKey(const Key('report-trend-section'));
      await tester.scrollUntilVisible(
        trendSection,
        260,
        scrollable: reportScrollable,
      );
      expect(trendSection, findsOneWidget);
    },
  );
}

// ── Time picker helpers ──────────────────────────────────────────────────

Future<void> _confirmTimePicker(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
  await _tapOk(tester);
  await settleE2e(tester);
}

Future<void> _enterTimeAndConfirm(
  WidgetTester tester, {
  required String hour,
  required String minute,
}) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 500));

  final dialogFields = find.descendant(
    of: find.byType(Dialog),
    matching: find.byType(TextField),
  );
  await pumpUntilFound(
    tester,
    dialogFields.first,
    timeout: const Duration(seconds: 5),
  );

  await tester.tap(dialogFields.first);
  await tester.enterText(dialogFields.first, hour);
  await settleE2e(tester);

  await tester.tap(dialogFields.at(1));
  await tester.enterText(dialogFields.at(1), minute);
  await settleE2e(tester);

  await _tapOk(tester);
  await settleE2e(tester);
}

Future<void> _tapOk(WidgetTester tester) async {
  final okZh = find.widgetWithText(TextButton, '确定');
  final okEn = find.widgetWithText(TextButton, 'OK');
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
  if (tester.any(okZh)) {
    await tester.tap(okZh);
  } else {
    await pumpUntilFound(tester, okEn, timeout: const Duration(seconds: 5));
    await tester.tap(okEn);
  }
}
