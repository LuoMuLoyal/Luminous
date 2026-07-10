import 'package:forui/forui.dart';

import '../support/e2e_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sleep create sends correct payload with wake-date convention', (
    tester,
  ) async {
    final dailyRecordRepository = E2eDailyRecordRepository();

    await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      dailyRecordRepository: dailyRecordRepository,
    );

    // Navigate to Record tab.
    await openTab(tester, '记录');

    // Tap the sleep quick action to open the fast-entry sheet, then choose
    // "更多" to reach the full create form.
    final sleepAction = find.byKey(const Key('record-quick-sleep'));
    await tester.scrollUntilVisible(sleepAction, 240);
    await tester.tap(sleepAction);
    await settleE2e(tester);

    await tester.tap(find.byKey(const Key('record-fast-entry-more-action')));
    await settleE2e(tester);

    // Verify the sleep form is shown with structured fields.
    expect(find.byKey(const Key('sleep-quality-field')), findsOneWidget);

    // Pick bedtime 23:00 — tap the FTimeField.picker to open the popover,
    // scroll the wheels to 23:00 (11:00 PM), then close the popover.
    await tester.tap(find.byKey(const Key('sleep-bedtime-picker')));
    await settleE2e(tester);
    await _confirmTimePicker(tester, hour: 23, minute: 0);

    // Pick wake time 07:00 — distinct from bedtime so duration is valid.
    await tester.tap(find.byKey(const Key('sleep-waketime-picker')));
    await settleE2e(tester);
    await _enterTimeAndConfirm(tester, hour: 7, minute: 0);

    // Save the record.
    await tester.tap(find.byKey(const Key('record-create-save-action')));
    await settleE2e(tester);

    // Verify the payload.
    final input = dailyRecordRepository.createInput;
    expect(input, isNotNull);
    expect(input!.kind, DailyRecordKind.sleep);
    expect(input.payload, isNotNull);
    expect(input.payload!['durationMinutes'], isA<int>());
    expect(input.payload!['durationMinutes'], greaterThan(0));
    expect(input.payload!['startAt'], isA<String>());
    expect(input.payload!['endAt'], isA<String>());
    final startAt = DateTime.parse(input.payload!['startAt'] as String);
    final endAt = DateTime.parse(input.payload!['endAt'] as String);
    expect(endAt.isAfter(startAt), isTrue);
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
  WidgetTester tester, {
  required int hour,
  required int minute,
}) async {
  await _scrollTimePickerWheels(tester, hour: hour, minute: minute);
  await _closePopover(tester);
}

Future<void> _enterTimeAndConfirm(
  WidgetTester tester, {
  required int hour,
  required int minute,
}) async {
  await _scrollTimePickerWheels(tester, hour: hour, minute: minute);
  await _closePopover(tester);
}

Future<void> _scrollTimePickerWheels(
  WidgetTester tester, {
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
  await _dragWheel(tester, periodWheel, 0, targetPeriod);

  // Hour wheel: 12-hour format, index 0→12, 1→1, …, 11→11.
  // The hour value in 12-hour mode: hour % 12 (but 0 maps to 12 on display).
  final targetHourIndex = hour % 12;
  await _dragWheel(tester, hourWheel, 0, targetHourIndex);

  // Minute wheel: 0-59, index = minute / minuteInterval (interval = 1).
  await _dragWheel(tester, minuteWheel, 0, minute);
}

Future<void> _dragWheel(
  WidgetTester tester,
  Finder wheel,
  int fromIndex,
  int toIndex,
) async {
  if (fromIndex == toIndex) return;
  final delta = toIndex - fromIndex;
  // Drag up (negative Y) to increase the index.
  await tester.drag(wheel, Offset(0, -delta * _itemExtent));
  await tester.pumpAndSettle(const Duration(milliseconds: 300));
}

Future<void> _closePopover(WidgetTester tester) async {
  // Tap outside the popover content to dismiss it.
  // FPopover with hideRegion.excludeChild hides when tapping outside.
  await tester.tapAt(const Offset(10, 10));
  await tester.pumpAndSettle(const Duration(milliseconds: 300));
}
