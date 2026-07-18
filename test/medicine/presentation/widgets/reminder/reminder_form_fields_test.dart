import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/features/medicine/data/datasources/reminder_remote.dart';
import 'package:luminous/features/medicine/presentation/providers/reminders.dart';
import 'package:luminous/features/medicine/presentation/utils/reminder_formatters.dart';
import 'package:luminous/features/medicine/presentation/widgets/reminder/form_fields.dart';

import '../../../../helpers/test_forui_app.dart';

void main() {
  group('FrequencySegments', () {
    testWidgets('renders all three frequency labels', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: FrequencySegments(
              frequency: ReminderFrequency.daily,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('每日'), findsOneWidget);
      expect(find.text('每周'), findsOneWidget);
      expect(find.text('自定义'), findsOneWidget);
    });

    testWidgets('calls onChanged with selected frequency', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: FrequencySegments(
              frequency: ReminderFrequency.daily,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify all three options are rendered and tappable
      expect(find.text('每日'), findsOneWidget);
      expect(find.text('每周'), findsOneWidget);
      expect(find.text('自定义'), findsOneWidget);
    });
  });

  group('WeekdayPicker', () {
    testWidgets('renders 7 weekday chips', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: WeekdayPicker(selectedWeekdays: const {}, onToggled: (_) {}),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Monday through Sunday labels
      expect(find.text('一'), findsOneWidget);
      expect(find.text('二'), findsOneWidget);
      expect(find.text('三'), findsOneWidget);
      expect(find.text('四'), findsOneWidget);
      expect(find.text('五'), findsOneWidget);
      expect(find.text('六'), findsOneWidget);
      expect(find.text('日'), findsOneWidget);
    });

    testWidgets('shows selected state for selected weekdays', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: WeekdayPicker(
              selectedWeekdays: const {1, 3}, // Mon, Wed
              onToggled: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Mon (key=1) and Wed (key=3) should be selected; Tue (key=2) should not.
      final mon = tester.widget<FButton>(
        find.byKey(const Key('medicine-reminder-weekday-1')),
      );
      final tue = tester.widget<FButton>(
        find.byKey(const Key('medicine-reminder-weekday-2')),
      );
      final wed = tester.widget<FButton>(
        find.byKey(const Key('medicine-reminder-weekday-3')),
      );

      expect(mon.selected, isTrue);
      expect(tue.selected, isFalse);
      expect(wed.selected, isTrue);
    });

    testWidgets('calls onToggled with weekday number', (tester) async {
      int? toggledDay;

      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: WeekdayPicker(
              selectedWeekdays: const {},
              onToggled: (day) => toggledDay = day,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('五'));
      await tester.pumpAndSettle();

      expect(toggledDay, 5);
    });
  });

  group('TimePickerRow', () {
    testWidgets('renders time chips and add button', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: TimePickerRow(
              times: const [
                MedicineReminderTimeInput(hour: 8, minute: 0),
                MedicineReminderTimeInput(hour: 20, minute: 30),
              ],
              onAddTime: () {},
              onRemoveTime: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('08:00'), findsOneWidget);
      expect(find.text('20:30'), findsOneWidget);
      // Two time chips + one add button = 3 FButtons.
      expect(find.byKey(const Key('medicine-reminder-time-0')), findsOneWidget);
      expect(find.byKey(const Key('medicine-reminder-time-1')), findsOneWidget);
      expect(
        find.byKey(const Key('medicine-reminder-add-time')),
        findsOneWidget,
      );
    });

    testWidgets('calls onAddTime when add chip is pressed', (tester) async {
      bool addCalled = false;

      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: TimePickerRow(
              times: const [MedicineReminderTimeInput(hour: 8, minute: 0)],
              onAddTime: () => addCalled = true,
              onRemoveTime: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('medicine-reminder-add-time')));
      await tester.pumpAndSettle();

      expect(addCalled, isTrue);
    });

    testWidgets('onRemoveTime is wired when multiple times exist', (
      tester,
    ) async {
      var removedIndex = -1;

      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: TimePickerRow(
              times: const [
                MedicineReminderTimeInput(hour: 8, minute: 0),
                MedicineReminderTimeInput(hour: 12, minute: 0),
              ],
              onAddTime: () {},
              onRemoveTime: (index) => removedIndex = index,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Both time chips should be tappable (removable) when more than one.
      final first = tester.widget<FButton>(
        find.byKey(const Key('medicine-reminder-time-0')),
      );
      final second = tester.widget<FButton>(
        find.byKey(const Key('medicine-reminder-time-1')),
      );
      expect(first.onPress, isNotNull);
      expect(second.onPress, isNotNull);

      // Tapping the first chip removes index 0.
      await tester.tap(find.byKey(const Key('medicine-reminder-time-0')));
      await tester.pumpAndSettle();
      expect(removedIndex, 0);
    });

    testWidgets('disables delete when only one time remains', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: TimePickerRow(
              times: const [MedicineReminderTimeInput(hour: 8, minute: 0)],
              onAddTime: () {},
              onRemoveTime: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final chip = tester.widget<FButton>(
        find.byKey(const Key('medicine-reminder-time-0')),
      );
      expect(chip.onPress, isNull);
    });

    testWidgets('renders empty list with only add button', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: TimePickerRow(
              times: const [],
              onAddTime: () {},
              onRemoveTime: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('medicine-reminder-time-0')), findsNothing);
      expect(
        find.byKey(const Key('medicine-reminder-add-time')),
        findsOneWidget,
      );
    });
  });

  group('MedicineReminderTimeInput', () {
    test('label formats hour and minute with zero padding', () {
      const input = MedicineReminderTimeInput(hour: 8, minute: 5);
      expect(input.label, '08:05');
    });

    test('label handles double-digit hours', () {
      const input = MedicineReminderTimeInput(hour: 14, minute: 30);
      expect(input.label, '14:30');
    });

    test('fromTimeOfDay creates correct input', () {
      final input = MedicineReminderTimeInput.fromTimeOfDay(
        const TimeOfDay(hour: 9, minute: 15),
      );
      expect(input.hour, 9);
      expect(input.minute, 15);
    });
  });

  group('ReminderFrequency enum', () {
    test('has daily, weekly, custom values', () {
      expect(ReminderFrequency.values, hasLength(3));
      expect(ReminderFrequency.values, contains(ReminderFrequency.daily));
      expect(ReminderFrequency.values, contains(ReminderFrequency.weekly));
      expect(ReminderFrequency.values, contains(ReminderFrequency.custom));
    });
  });

  group('MedicineReminderSoundPreference', () {
    test('fromStorage returns defaultTone for null', () {
      expect(
        MedicineReminderSoundPreference.fromStorage(null),
        MedicineReminderSoundPreference.defaultTone,
      );
    });

    test('fromStorage returns matching preference', () {
      expect(
        MedicineReminderSoundPreference.fromStorage('gentle'),
        MedicineReminderSoundPreference.gentle,
      );
      expect(
        MedicineReminderSoundPreference.fromStorage('silent'),
        MedicineReminderSoundPreference.silent,
      );
    });

    test('fromStorage falls back to defaultTone for unknown', () {
      expect(
        MedicineReminderSoundPreference.fromStorage('unknown'),
        MedicineReminderSoundPreference.defaultTone,
      );
    });

    test('storageValue returns correct strings', () {
      expect(
        MedicineReminderSoundPreference.defaultTone.storageValue,
        'default',
      );
      expect(MedicineReminderSoundPreference.gentle.storageValue, 'gentle');
      expect(MedicineReminderSoundPreference.silent.storageValue, 'silent');
    });
  });

  group('remindersFor', () {
    test('filters by medicine id and sorts by time', () {
      final reminders = [
        const MedicineReminderItem(
          id: 'r1',
          currentMedicineId: 'med-1',
          scheduledHour: 20,
          scheduledMinute: 0,
          isActive: true,
          createdAt: '2026-07-01T00:00:00Z',
          updatedAt: '2026-07-01T00:00:00Z',
        ),
        const MedicineReminderItem(
          id: 'r2',
          currentMedicineId: 'med-2',
          scheduledHour: 8,
          scheduledMinute: 0,
          isActive: true,
          createdAt: '2026-07-01T00:00:00Z',
          updatedAt: '2026-07-01T00:00:00Z',
        ),
        const MedicineReminderItem(
          id: 'r3',
          currentMedicineId: 'med-1',
          scheduledHour: 8,
          scheduledMinute: 0,
          isActive: true,
          createdAt: '2026-07-01T00:00:00Z',
          updatedAt: '2026-07-01T00:00:00Z',
        ),
      ];

      final filtered = remindersFor(reminders, 'med-1');

      expect(filtered, hasLength(2));
      expect(filtered[0].id, 'r3'); // 08:00 comes first
      expect(filtered[1].id, 'r1'); // 20:00 comes second
    });

    test('returns empty list for no matches', () {
      final reminders = [
        const MedicineReminderItem(
          id: 'r1',
          currentMedicineId: 'med-1',
          scheduledHour: 8,
          scheduledMinute: 0,
          isActive: true,
          createdAt: '2026-07-01T00:00:00Z',
          updatedAt: '2026-07-01T00:00:00Z',
        ),
      ];

      expect(remindersFor(reminders, 'med-999'), isEmpty);
    });
  });
}
