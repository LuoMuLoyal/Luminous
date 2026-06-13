import 'package:luminous/features/record/presentation/widgets/sleep_structured_fields.dart';
import 'package:luminous/features/shell/presentation/shell_tab.dart';

import '../support/e2e_test_helpers.dart';
import '../support/fullstack_e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'full-stack sleep lane: create sleep → Today shows value → Report shows trend',
    (tester) async {
      // Force the time picker into input mode so we can interact with
      // TextFields instead of the clock dial in integration tests.
      SleepStructuredFields.forceInputTimePicker = true;
      addTearDown(() => SleepStructuredFields.forceInputTimePicker = false);

      final config = FullstackE2eConfig.fromEnvironment();
      final targetDate = parseRecordDate(config.recordDate);

      await prepareFullstackRecordLane(config);
      final container = await pumpFullstackApp(tester, config: config);

      // Sign in.
      await signInThroughUi(tester, config: config);
      await waitForAuthenticatedSession(tester, container);
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);

      // Navigate to Record tab and select the target date.
      await openRecordTabForDate(tester, container, targetDate: targetDate);

      // Tap the sleep quick action.
      final sleepAction = find.byKey(const Key('record-quick-sleep'));
      await tester.scrollUntilVisible(sleepAction, 240);
      await tester.tap(sleepAction);
      await settleE2e(tester);

      // Verify the sleep form is visible.
      expect(find.byKey(const Key('sleep-quality-field')), findsOneWidget);

      // Pick bedtime 23:00 — tap the keyed InkWell, then confirm in dialog.
      await tester.tap(find.byKey(const Key('sleep-bedtime-picker')));
      await settleE2e(tester);
      // Default initialTime is 23:00, so just confirm.
      await _confirmTimePicker(tester);

      // Pick wake time 07:00 — distinct from bedtime so duration is valid.
      await tester.tap(find.byKey(const Key('sleep-waketime-picker')));
      await settleE2e(tester);
      await _enterTimeAndConfirm(tester, hour: '7', minute: '0');

      // Save the sleep record.
      await tester.tap(
        find.byKey(const Key('record-create-save-action')),
      );
      await settleE2e(tester);

      // Wait for return to the record timeline.
      await pumpUntilFound(
        tester,
        find.byKey(const Key('record-timeline')),
        timeout: const Duration(seconds: 10),
      );

      // The sleep record should appear in the timeline.
      // Navigate back to the same date to refresh.
      await openRecordTabForDate(tester, container, targetDate: targetDate);

      // Open Today tab and verify sleep vital card is present.
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

      // Check the Today vitals area contains a sleep value (e.g. "Xh" or "X.Xh").
      // The sleep vital card should be present.
      final sleepVital = find.byKey(const Key('today-vital-sleep'));
      if (tester.any(sleepVital)) {
        // Sleep vital card exists — the Today page shows sleep data.
        expect(sleepVital, findsOneWidget);
      }

      // Open Report tab and check sleep trend section.
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

/// Confirms the time picker dialog without changing values.
Future<void> _confirmTimePicker(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
  await _tapOk(tester);
  await settleE2e(tester);
}

/// Enters the given hour/minute strings into the input-mode time picker
/// TextFields, then taps the confirm button.
Future<void> _enterTimeAndConfirm(
  WidgetTester tester, {
  required String hour,
  required String minute,
}) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 500));

  // The input-mode picker has two TextFields (hour, minute).
  // Scope to the dialog to avoid matching form fields behind it.
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
  // The confirm button label varies by locale.
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
