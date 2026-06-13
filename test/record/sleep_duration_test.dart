import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/record/presentation/widgets/sleep_structured_fields.dart';

void main() {
  group('computeSleepDurationMinutes', () {
    test('returns null when either time is null', () {
      expect(computeSleepDurationMinutes(null, const TimeOfDay(hour: 7, minute: 0)), isNull);
      expect(computeSleepDurationMinutes(const TimeOfDay(hour: 23, minute: 0), null), isNull);
      expect(computeSleepDurationMinutes(null, null), isNull);
    });

    test('returns 480 for 23:00 → 07:00 (normal overnight)', () {
      expect(
        computeSleepDurationMinutes(
          const TimeOfDay(hour: 23, minute: 0),
          const TimeOfDay(hour: 7, minute: 0),
        ),
        480,
      );
    });

    test('returns 90 for 23:30 → 01:00 (short overnight)', () {
      expect(
        computeSleepDurationMinutes(
          const TimeOfDay(hour: 23, minute: 30),
          const TimeOfDay(hour: 1, minute: 0),
        ),
        90,
      );
    });

    test('returns 60 for 14:00 → 15:00 (same-day nap)', () {
      expect(
        computeSleepDurationMinutes(
          const TimeOfDay(hour: 14, minute: 0),
          const TimeOfDay(hour: 15, minute: 0),
        ),
        60,
      );
    });

    test('returns null for identical bedtime and wake time', () {
      // Same time is ambiguous — must not be treated as 24h sleep.
      expect(
        computeSleepDurationMinutes(
          const TimeOfDay(hour: 23, minute: 0),
          const TimeOfDay(hour: 23, minute: 0),
        ),
        isNull,
      );
      expect(
        computeSleepDurationMinutes(
          const TimeOfDay(hour: 7, minute: 0),
          const TimeOfDay(hour: 7, minute: 0),
        ),
        isNull,
      );
      expect(
        computeSleepDurationMinutes(
          const TimeOfDay(hour: 0, minute: 0),
          const TimeOfDay(hour: 0, minute: 0),
        ),
        isNull,
      );
    });
  });
}
