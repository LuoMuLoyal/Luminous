import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/medicine/domain/services/reminder_notification_payload.dart';

void main() {
  group('ReminderNotificationPayload.encode', () {
    test('produces a JSON string with reminderId, date and time', () {
      const payload = ReminderNotificationPayload(
        reminderId: 'reminder-1',
        date: '2026-06-10',
        time: '21:30',
      );

      expect(
        payload.encode(),
        '{"reminderId":"reminder-1","date":"2026-06-10","time":"21:30"}',
      );
    });
  });

  group('ReminderNotificationPayload.tryParse', () {
    test('round-trips an encoded payload', () {
      const payload = ReminderNotificationPayload(
        reminderId: 'reminder-1',
        date: '2026-06-10',
        time: '21:30',
      );

      final parsed = ReminderNotificationPayload.tryParse(payload.encode());

      expect(parsed, isNotNull);
      expect(parsed!.reminderId, 'reminder-1');
      expect(parsed.date, '2026-06-10');
      expect(parsed.time, '21:30');
    });

    test('returns null for null or empty input', () {
      expect(ReminderNotificationPayload.tryParse(null), isNull);
      expect(ReminderNotificationPayload.tryParse(''), isNull);
      expect(ReminderNotificationPayload.tryParse('   '), isNull);
    });

    test('returns null for malformed JSON', () {
      expect(ReminderNotificationPayload.tryParse('not json'), isNull);
      expect(ReminderNotificationPayload.tryParse('{"reminderId":'), isNull);
    });

    test('returns null for non-map JSON', () {
      expect(ReminderNotificationPayload.tryParse('[1, 2, 3]'), isNull);
      expect(ReminderNotificationPayload.tryParse('"plain string"'), isNull);
      expect(ReminderNotificationPayload.tryParse('42'), isNull);
    });

    test('returns null when a required field is missing', () {
      expect(
        ReminderNotificationPayload.tryParse('{"date":"2026-06-10"}'),
        isNull,
      );
      expect(
        ReminderNotificationPayload.tryParse(
          '{"reminderId":"r","time":"21:30"}',
        ),
        isNull,
      );
    });

    test('returns null when fields have non-string types', () {
      expect(
        ReminderNotificationPayload.tryParse(
          '{"reminderId":123,"date":"2026-06-10","time":"21:30"}',
        ),
        isNull,
      );
      expect(
        ReminderNotificationPayload.tryParse(
          '{"reminderId":"r","date":null,"time":"21:30"}',
        ),
        isNull,
      );
    });

    test('returns null for non-conforming date or time values', () {
      expect(
        ReminderNotificationPayload.tryParse(
          '{"reminderId":"r","date":"2026/06/10","time":"21:30"}',
        ),
        isNull,
      );
      expect(
        ReminderNotificationPayload.tryParse(
          '{"reminderId":"r","date":"2026-06-10","time":"9:30"}',
        ),
        isNull,
      );
      expect(
        ReminderNotificationPayload.tryParse(
          '{"reminderId":"r","date":"2026-06-10","time":"21:30:00"}',
        ),
        isNull,
      );
    });

    test('returns null for out-of-range times', () {
      expect(
        ReminderNotificationPayload.tryParse(
          '{"reminderId":"r","date":"2026-06-10","time":"24:00"}',
        ),
        isNull,
      );
      expect(
        ReminderNotificationPayload.tryParse(
          '{"reminderId":"r","date":"2026-06-10","time":"25:30"}',
        ),
        isNull,
      );
      expect(
        ReminderNotificationPayload.tryParse(
          '{"reminderId":"r","date":"2026-06-10","time":"21:60"}',
        ),
        isNull,
      );
      expect(
        ReminderNotificationPayload.tryParse(
          '{"reminderId":"r","date":"2026-06-10","time":"21:5"}',
        ),
        isNull,
      );
    });

    test('accepts boundary times', () {
      expect(
        ReminderNotificationPayload.tryParse(
          '{"reminderId":"r","date":"2026-06-10","time":"00:00"}',
        ),
        isNotNull,
      );
      expect(
        ReminderNotificationPayload.tryParse(
          '{"reminderId":"r","date":"2026-06-10","time":"23:59"}',
        ),
        isNotNull,
      );
      expect(
        ReminderNotificationPayload.tryParse(
          '{"reminderId":"r","date":"2026-06-10","time":"09:05"}',
        ),
        isNotNull,
      );
    });
  });
}
