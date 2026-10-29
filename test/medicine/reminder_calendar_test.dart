import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/errors/client_error_code.dart';
import 'package:luminous/features/medicine/domain/entities/reminder.dart';
import 'package:luminous/features/medicine/presentation/controllers/reminder_calendar.dart';

MedicineReminderItem reminder({
  int hour = 8,
  int minute = 30,
  List<int>? daysOfWeek,
  String? startDate,
  String? endDate,
  String? note,
  String? label,
}) {
  return MedicineReminderItem(
    id: 'r1',
    currentMedicineId: 'm1',
    label: label,
    scheduledHour: hour,
    scheduledMinute: minute,
    daysOfWeek: daysOfWeek,
    startDate: startDate,
    endDate: endDate,
    isActive: true,
    note: note,
    createdAt: '2026-10-16T00:00:00.000Z',
    updatedAt: '2026-10-16T00:00:00.000Z',
  );
}

void main() {
  group('buildReminderCalendarEvent', () {
    test('maps the reminder time onto the event', () {
      final result = buildReminderCalendarEvent(
        reminders: [reminder(hour: 7, minute: 45)],
        title: 'Aspirin',
        timeZoneName: 'Asia/Shanghai',
        now: DateTime.utc(2026, 10, 16, 1),
      );

      final event = result.getRight().toNullable()!;
      expect(event.title, 'Aspirin');
      expect(event.timeZone, 'Asia/Shanghai');
      expect(event.startDate.hour, 7);
      expect(event.startDate.minute, 45);
      expect(event.endDate.isAfter(event.startDate), isTrue);
    });

    test('carries the note as the event description', () {
      final result = buildReminderCalendarEvent(
        reminders: [reminder(note: '饭后服用')],
        title: 'Aspirin',
        description: '饭后服用',
        timeZoneName: 'Asia/Shanghai',
        now: DateTime.utc(2026, 10, 16, 1),
      );

      expect(result.getRight().toNullable()!.description, '饭后服用');
    });

    test('leaves the recurrence open-ended when the group has no end date', () {
      final result = buildReminderCalendarEvent(
        reminders: [
          reminder(daysOfWeek: [1, 3, 5]),
        ],
        title: 'Aspirin',
        timeZoneName: 'Asia/Shanghai',
        now: DateTime.utc(2026, 10, 16, 1),
      );

      final recurrence = result.getRight().toNullable()!.recurrence!;
      expect(recurrence.frequency, Frequency.weekly);
      expect(recurrence.endDate, isNull);
    });

    test('bounds the recurrence when the group has an end date', () {
      final result = buildReminderCalendarEvent(
        reminders: [
          reminder(daysOfWeek: [1], endDate: '2026-12-31'),
        ],
        title: 'Aspirin',
        timeZoneName: 'Asia/Shanghai',
        now: DateTime.utc(2026, 10, 16, 1),
      );

      final recurrence = result.getRight().toNullable()!.recurrence!;
      expect(recurrence.endDate, isNotNull);
      expect(recurrence.endDate!.year, 2026);
      expect(recurrence.endDate!.month, 12);
      expect(recurrence.endDate!.day, 31);
    });

    test('omits recurrence for a daily reminder', () {
      final result = buildReminderCalendarEvent(
        reminders: [reminder()],
        title: 'Aspirin',
        timeZoneName: 'Asia/Shanghai',
        now: DateTime.utc(2026, 10, 16, 1),
      );

      expect(result.getRight().toNullable()!.recurrence, isNull);
    });

    test('anchors on the first matching weekday at/after today', () {
      // 2026-10-16 is a Friday (weekday 5). Asking for Monday (1) must land on
      // 2026-10-19, not on today.
      final result = buildReminderCalendarEvent(
        reminders: [
          reminder(daysOfWeek: [1], hour: 9),
        ],
        title: 'Aspirin',
        timeZoneName: 'Asia/Shanghai',
        now: DateTime.utc(2026, 10, 16, 1),
      );

      final start = result.getRight().toNullable()!.startDate;
      expect(start.weekday, DateTime.monday);
      expect(start.day, 19);
      expect(start.hour, 9);
    });

    test('falls back to the backend default timezone on unknown input', () {
      final result = buildReminderCalendarEvent(
        reminders: [reminder()],
        title: 'Aspirin',
        timeZoneName: 'Not/AZone',
        now: DateTime.utc(2026, 10, 16, 1),
      );

      expect(result.getRight().toNullable()!.timeZone, 'Asia/Shanghai');
    });

    test(
      'returns a failure instead of an event when there is nothing to export',
      () {
        final result = buildReminderCalendarEvent(
          reminders: const [],
          title: 'Aspirin',
        );

        expect(result.isLeft(), isTrue);
        expect(
          result.getLeft().toNullable()!.clientErrorCode,
          ClientErrorCode.reminderCalendarUnavailable,
        );
      },
    );
  });

  group('calendarWriteFailure', () {
    test('treats a saved event as success', () {
      expect(calendarWriteFailure(true), isNull);
    });

    test('maps dismissal or denied permission to a write failure', () {
      final failure = calendarWriteFailure(false);
      expect(failure, isNotNull);
      expect(
        failure!.clientErrorCode,
        ClientErrorCode.reminderCalendarWriteFailed,
      );
    });
  });
}
