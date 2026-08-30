import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/utils/date_format.dart';

void main() {
  group('parseDateTimeOrNull', () {
    test('returns null for null / empty input', () {
      expect(parseDateTimeOrNull(null), isNull);
      expect(parseDateTimeOrNull(''), isNull);
    });

    test('parses a valid ISO-8601 string', () {
      final dt = parseDateTimeOrNull('2026-08-08T08:00:00.000Z');
      expect(dt, isNotNull);
      expect(dt!.toUtc().year, 2026);
      expect(dt.toUtc().month, 8);
      expect(dt.toUtc().day, 8);
    });

    test('parses a date-only string', () {
      final dt = parseDateTimeOrNull('2026-08-08');
      expect(dt, isNotNull);
      expect(dt!.year, 2026);
    });

    test('returns null for malformed input instead of throwing', () {
      expect(parseDateTimeOrNull('not-a-date'), isNull);
      expect(parseDateTimeOrNull('2026/13/99'), isNull);
    });
  });

  group('parseDateTimeOrEpoch', () {
    test('falls back to epoch for malformed input', () {
      final dt = parseDateTimeOrEpoch('not-a-date');
      expect(dt, DateTime.fromMillisecondsSinceEpoch(0));
    });

    test('falls back to provided fallback when given', () {
      final fallback = DateTime(2000, 1, 1);
      expect(parseDateTimeOrEpoch('', fallback: fallback), fallback);
    });

    test('parses valid input normally', () {
      final dt = parseDateTimeOrEpoch('2026-08-08T08:00:00.000Z');
      expect(dt.toUtc().year, 2026);
    });
  });
}
