import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/record/presentation/utils/record_date_time_formatters.dart';

void main() {
  group('formatRecordDate', () {
    test('formats as YYYY-MM-DD', () {
      expect(formatRecordDate(DateTime(2026, 6, 15)), '2026-06-15');
    });
    test('zero-pads single-digit month and day', () {
      expect(formatRecordDate(DateTime(2026, 1, 5)), '2026-01-05');
    });
    test('handles year-month-day edge values', () {
      expect(formatRecordDate(DateTime(2026, 12, 31)), '2026-12-31');
    });
  });

  group('formatRecordTimeLabel', () {
    test('returns --:-- for null', () {
      expect(formatRecordTimeLabel(null), '--:--');
    });
    test('returns --:-- for empty or whitespace', () {
      expect(formatRecordTimeLabel(''), '--:--');
      expect(formatRecordTimeLabel('   '), '--:--');
    });
    test('returns trimmed value', () {
      expect(formatRecordTimeLabel('09:45'), '09:45');
      expect(formatRecordTimeLabel('  09:45  '), '09:45');
    });
  });

  group('formatRecordTimeValue', () {
    test('formats HH:mm', () {
      expect(formatRecordTimeValue(DateTime(2026, 6, 15, 9, 45)), '09:45');
    });
    test('zero-pads single-digit', () {
      expect(formatRecordTimeValue(DateTime(2026, 6, 15, 1, 5)), '01:05');
    });
    test('midnight and end-of-day', () {
      expect(formatRecordTimeValue(DateTime(2026, 6, 15, 0, 0)), '00:00');
      expect(formatRecordTimeValue(DateTime(2026, 6, 15, 23, 59)), '23:59');
    });
  });

  group('parseRecordDate', () {
    test('null/empty returns null', () {
      expect(parseRecordDate(null), isNull);
      expect(parseRecordDate(''), isNull);
    });
    test('parses and strips time', () {
      final r = parseRecordDate('2026-06-15');
      expect(r!.year, 2026);
      expect(r.month, 6);
      expect(r.day, 15);
      expect(r.hour, 0);
    });
    test('invalid returns null', () {
      expect(parseRecordDate('not-a-date'), isNull);
    });
  });

  group('parseRecordTime', () {
    test('parses HH:mm', () {
      final r = parseRecordTime('09:45');
      expect(r!.hour, 9);
      expect(r.minute, 45);
    });
    test('null/empty/whitespace returns null', () {
      expect(parseRecordTime(null), isNull);
      expect(parseRecordTime(''), isNull);
      expect(parseRecordTime('   '), isNull);
    });
    test('invalid returns null', () {
      expect(parseRecordTime('0945'), isNull);
      expect(parseRecordTime('ab:cd'), isNull);
      expect(parseRecordTime('24:00'), isNull);
      expect(parseRecordTime('09:60'), isNull);
    });
    test('boundary values accepted', () {
      expect(parseRecordTime('00:00')!.hour, 0);
      expect(parseRecordTime('23:59')!.hour, 23);
    });
  });

  group('applyRecordTimeToDate', () {
    test('applies time string to date', () {
      final r = applyRecordTimeToDate(DateTime(2026, 6, 15), '09:45');
      expect(r!.hour, 9);
      expect(r.minute, 45);
    });
    test('null/empty time returns null', () {
      expect(applyRecordTimeToDate(DateTime(2026, 6, 15), null), isNull);
      expect(applyRecordTimeToDate(DateTime(2026, 6, 15), ''), isNull);
    });
  });

  group('parseRecordDateTime', () {
    test('combines date and time', () {
      final r = parseRecordDateTime('2026-06-15', occurredTime: '09:45');
      expect(r!.year, 2026);
      expect(r.hour, 9);
    });
    test('invalid date returns null', () {
      expect(parseRecordDateTime('invalid'), isNull);
    });
  });

  group('formatRecordDateTimeLabel', () {
    test('date + time', () {
      final r = formatRecordDateTimeLabel('2026-06-15', occurredTime: '09:45');
      expect(r, '2026-06-15 09:45');
    });
    test('date only fills HH:mm from parsed date', () {
      final r = formatRecordDateTimeLabel('2026-06-15');
      expect(r, startsWith('2026-06-15 '));
    });
    test('unparseable date falls back to raw', () {
      expect(
        formatRecordDateTimeLabel('not-a-date', occurredTime: '09:45'),
        'not-a-date 09:45',
      );
    });
  });
}
