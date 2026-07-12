import 'package:luminous/features/shell/presentation/tab.dart';

import '../support/e2e_test_helpers.dart';
import '../support/fullstack_e2e_helpers.dart';

void main() {
  patrolTest('full-stack sleep lane: create sleep via structured fields', (
    $,
  ) async {
    final config = FullstackE2eConfig.fromEnvironment();
    final targetDate = parseRecordDate(config.recordDate);

    await prepareFullstackRecordLane(config);
    final container = await pumpFullstackApp($, config: config);

    await signInThroughUi($, config: config);
    await waitForAuthenticatedSession($, container);
    expect(container.read(authSessionProvider).isAuthenticated, isTrue);

    // ── Record tab: create a sleep record ──────────────────────────

    await openRecordTabForDate($, container, targetDate: targetDate);

    await tapVisible($, find.byKey(const Key('record-quick-sleep')));
    await pumpUntilFound(
      $,
      find.byKey(const Key('record-fast-entry-sleep')),
      timeout: const Duration(seconds: 10),
    );
    await tapVisible($, find.byKey(const Key('record-fast-entry-more-action')));
    await pumpUntilFound(
      $,
      find.byKey(const Key('sleep-quality-field')),
      timeout: const Duration(seconds: 10),
    );
    expect(find.byKey(const Key('sleep-quality-field')), findsOneWidget);

    // Bedtime: 23:00 (11:00 PM).
    await $.tester.tap(find.byKey(const Key('sleep-bedtime-picker')));
    await settleE2e($);
    await _confirmTimePicker($, hour: 23, minute: 0);

    // Wake time: 07:00.
    await $.tester.tap(find.byKey(const Key('sleep-waketime-picker')));
    await settleE2e($);
    await _enterTimeAndConfirm($, hour: 7, minute: 0);

    // Quality: select "good".
    await $.tester.tap(find.byKey(const Key('sleep-quality-field')));
    await settleE2e($);
    final goodOption = find.text('良好').evaluate().isNotEmpty
        ? find.text('良好')
        : find.text('Good');
    await $.tester.tap(goodOption.last);
    await settleE2e($);

    // Save.
    await $.tester.tap(find.byKey(const Key('record-create-save-action')));
    await settleE2e($);

    await waitForRoute(
      $,
      predicate: (uri) => uri.path == '/',
      description: 'return to shell after saving sleep record',
      timeout: const Duration(seconds: 15),
    );
    await openRecordTabForDate($, container, targetDate: targetDate);

    // ── Today tab: health summary renders ──────────────────────────

    await openShellTab($, ShellTab.today, timeout: const Duration(seconds: 15));
    await pumpUntilFound(
      $,
      find.byKey(const Key('today-summary-card')),
      timeout: const Duration(seconds: 15),
    );
    expect(find.byKey(const Key('today-summary-card')), findsOneWidget);

    // ── Report tab: trend section renders ──────────────────────────

    await openShellTab(
      $,
      ShellTab.report,
      timeout: const Duration(seconds: 15),
    );
    await pumpUntilFound(
      $,
      find.byKey(const Key('report-snapshot-status')),
      timeout: const Duration(seconds: 15),
    );

    // Scroll to the trend section.
    final reportScrollable = find.byType(Scrollable).first;
    final trendSection = find.byKey(const Key('report-trend-section'));
    await $.tester.scrollUntilVisible(
      trendSection,
      260,
      scrollable: reportScrollable,
    );
    expect(trendSection, findsOneWidget);
  });
}

// ── FTimeField.picker helpers ────────────────────────────────────────────
//
// FTimeField.picker opens an FPopover containing an FTimePicker with
// ListWheelScrollView wheels. The app uses the zh-CN locale, so the
// picker renders in 12-hour format ("a h:mm") with three wheels:
//
//   Wheel 0 — Period (上午/下午, 2 items: AM=0, PM=1)
//   Wheel 1 — Hour    (1-12, 12 items: index 0→12, 1→1, …, 11→11)
//   Wheel 2 — Minute  (0-59, 60 items)
//
// Dragging UP (negative Y) increases the selected index.
// FixedExtentScrollPhysics snaps to the nearest item, so the drag
// distance per item only needs to be approximately correct.

const _itemExtent = 40.0;

Future<void> _confirmTimePicker(
  PatrolIntegrationTester $, {
  required int hour,
  required int minute,
}) async {
  await _scrollTimePickerWheels($, hour: hour, minute: minute);
  await _closePopover($);
}

Future<void> _enterTimeAndConfirm(
  PatrolIntegrationTester $, {
  required int hour,
  required int minute,
}) async {
  await _scrollTimePickerWheels($, hour: hour, minute: minute);
  await _closePopover($);
}

Future<void> _scrollTimePickerWheels(
  PatrolIntegrationTester $, {
  required int hour,
  required int minute,
}) async {
  // Find the FTimePicker inside the open popover.
  final pickerFinder = find.byType(FTimePicker);
  expect(pickerFinder, findsOneWidget);

  // Locate the three ListWheelScrollView scrollables inside the picker.
  final wheels = find.descendant(
    of: pickerFinder,
    matching: find.byType(Scrollable),
  );
  expect(wheels, findsNWidgets(3));

  // zh-CN 12-hour layout: wheel 0 = period, wheel 1 = hour, wheel 2 = minute.
  final periodWheel = find
      .descendant(of: pickerFinder, matching: find.byType(Scrollable))
      .at(0);
  final hourWheel = find
      .descendant(of: pickerFinder, matching: find.byType(Scrollable))
      .at(1);
  final minuteWheel = find
      .descendant(of: pickerFinder, matching: find.byType(Scrollable))
      .at(2);

  // The picker opens at 12:00 AM (FTime(0, 0)) by default.
  // Period wheel: AM=0 (current), PM=1. Scroll to PM if hour >= 12.
  final targetPeriod = hour < 12 ? 0 : 1;
  await _dragWheel($, periodWheel, 0, targetPeriod);

  // Hour wheel: 12-hour format, index 0→12, 1→1, …, 11→11.
  // The hour value in 12-hour mode: hour % 12 (but 0 maps to 12 on display).
  final targetHourIndex = hour % 12;
  await _dragWheel($, hourWheel, 0, targetHourIndex);

  // Minute wheel: 0-59, index = minute / minuteInterval (interval = 1).
  await _dragWheel($, minuteWheel, 0, minute);
}

Future<void> _dragWheel(
  PatrolIntegrationTester $,
  Finder wheel,
  int fromIndex,
  int toIndex,
) async {
  if (fromIndex == toIndex) return;
  final delta = toIndex - fromIndex;
  // Drag up (negative Y) to increase the index.
  await $.tester.drag(wheel, Offset(0, -delta * _itemExtent));
  await $.tester.pumpAndSettle(const Duration(milliseconds: 300));
}

Future<void> _closePopover(PatrolIntegrationTester $) async {
  // Tap outside the popover content to dismiss it.
  // FPopover with hideRegion.excludeChild hides when tapping outside.
  await $.tester.tapAt(const Offset(10, 10));
  await $.tester.pumpAndSettle(const Duration(milliseconds: 300));
}
