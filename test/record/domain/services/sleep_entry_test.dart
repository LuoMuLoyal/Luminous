import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/record/domain/services/sleep_entry.dart';

void main() {
  const bed2300 = TimeOfDay(hour: 23, minute: 0);
  const wake0700 = TimeOfDay(hour: 7, minute: 0);
  final recordDate = DateTime(2026, 9, 14);

  group('computeSleepDurationMinutes', () {
    test('returns null when either time is null', () {
      expect(computeSleepDurationMinutes(null, wake0700), isNull);
      expect(computeSleepDurationMinutes(bed2300, null), isNull);
      expect(computeSleepDurationMinutes(null, null), isNull);
    });

    test('returns 480 for 23:00 → 07:00 (normal overnight)', () {
      expect(computeSleepDurationMinutes(bed2300, wake0700), 480);
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
      for (final hour in [0, 7, 23]) {
        expect(
          computeSleepDurationMinutes(
            TimeOfDay(hour: hour, minute: 0),
            TimeOfDay(hour: hour, minute: 0),
          ),
          isNull,
        );
      }
    });
  });

  group('resolveSleepWindow', () {
    test('night sleep crossing midnight starts the previous day', () {
      final window = resolveSleepWindow(
        recordDate: recordDate,
        bedtime: bed2300,
        wakeTime: wake0700,
        kind: SleepEntryKind.nightSleep,
      );

      expect(window, isNotNull);
      expect(window!.startedAt, DateTime(2026, 9, 13, 23));
      expect(window.endedAt, DateTime(2026, 9, 14, 7));
      expect(window.durationMinutes, 480);
    });

    test('night sleep within one day stays on the record date', () {
      final window = resolveSleepWindow(
        recordDate: recordDate,
        bedtime: const TimeOfDay(hour: 14, minute: 0),
        wakeTime: const TimeOfDay(hour: 15, minute: 0),
        kind: SleepEntryKind.nightSleep,
      );

      expect(window!.startedAt, DateTime(2026, 9, 14, 14));
      expect(window.endedAt, DateTime(2026, 9, 14, 15));
    });

    test('nap stays on the record date', () {
      final window = resolveSleepWindow(
        recordDate: recordDate,
        bedtime: const TimeOfDay(hour: 13, minute: 0),
        wakeTime: const TimeOfDay(hour: 13, minute: 30),
        kind: SleepEntryKind.nap,
      );

      expect(window!.startedAt, DateTime(2026, 9, 14, 13));
      expect(window.endedAt, DateTime(2026, 9, 14, 13, 30));
      expect(window.durationMinutes, 30);
    });

    test('nap may not cross midnight', () {
      expect(
        resolveSleepWindow(
          recordDate: recordDate,
          bedtime: bed2300,
          wakeTime: wake0700,
          kind: SleepEntryKind.nap,
        ),
        isNull,
      );
    });

    test('never spans more than one midnight', () {
      // Worst case a night sleep can produce: 23:59 → 23:58 still fits in <24h.
      final window = resolveSleepWindow(
        recordDate: recordDate,
        bedtime: const TimeOfDay(hour: 23, minute: 59),
        wakeTime: const TimeOfDay(hour: 23, minute: 58),
        kind: SleepEntryKind.nightSleep,
      );

      expect(window!.durationMinutes, 1439);
      expect(
        window.endedAt.difference(window.startedAt).inMinutes,
        window.durationMinutes,
      );
    });
  });

  group('validateSleepEntry', () {
    test('reports missing times', () {
      expect(
        validateSleepEntry(
          bedtime: null,
          wakeTime: wake0700,
          kind: SleepEntryKind.nightSleep,
        ),
        SleepEntryValidationError.missingTimes,
      );
    });

    test('reports a wake time that is not after bedtime', () {
      expect(
        validateSleepEntry(
          bedtime: bed2300,
          wakeTime: bed2300,
          kind: SleepEntryKind.nightSleep,
        ),
        SleepEntryValidationError.wakeNotAfterBedtime,
      );
    });

    test('reports a nap that crosses midnight', () {
      expect(
        validateSleepEntry(
          bedtime: bed2300,
          wakeTime: wake0700,
          kind: SleepEntryKind.nap,
        ),
        SleepEntryValidationError.napCrossesMidnight,
      );
    });

    test('reports a nap longer than 3 hours', () {
      expect(
        validateSleepEntry(
          bedtime: const TimeOfDay(hour: 10, minute: 0),
          wakeTime: const TimeOfDay(hour: 14, minute: 0),
          kind: SleepEntryKind.nap,
        ),
        SleepEntryValidationError.napTooLong,
      );
    });

    test('reports a night sleep longer than 16 hours', () {
      expect(
        validateSleepEntry(
          bedtime: const TimeOfDay(hour: 5, minute: 0),
          wakeTime: const TimeOfDay(hour: 22, minute: 0),
          kind: SleepEntryKind.nightSleep,
        ),
        SleepEntryValidationError.nightSleepTooLong,
      );
    });

    test('accepts valid nap and night sleep', () {
      expect(
        validateSleepEntry(
          bedtime: const TimeOfDay(hour: 13, minute: 0),
          wakeTime: const TimeOfDay(hour: 13, minute: 30),
          kind: SleepEntryKind.nap,
        ),
        isNull,
      );
      expect(
        validateSleepEntry(
          bedtime: bed2300,
          wakeTime: wake0700,
          kind: SleepEntryKind.nightSleep,
        ),
        isNull,
      );
    });
  });

  group('buildSleepPayload', () {
    test('writes the canonical key set with UTC instants', () {
      final payload = buildSleepPayload(
        recordDate: recordDate,
        bedtime: bed2300,
        wakeTime: wake0700,
        kind: SleepEntryKind.nightSleep,
      );

      expect(payload, isNotNull);
      expect(payload!.keys, containsAll(['startedAt', 'endedAt']));
      expect(
        payload.keys.where((key) => key == 'startAt' || key == 'endAt'),
        isEmpty,
      );
      expect(
        DateTime.parse(payload['startedAt']! as String).toLocal(),
        DateTime(2026, 9, 13, 23),
      );
      expect(
        DateTime.parse(payload['endedAt']! as String).toLocal(),
        DateTime(2026, 9, 14, 7),
      );
      expect(payload['durationMinutes'], 480);
      expect(payload['sleepType'], 'nightSleep');
    });

    test('writes the nap sleep type', () {
      final payload = buildSleepPayload(
        recordDate: recordDate,
        bedtime: const TimeOfDay(hour: 13, minute: 0),
        wakeTime: const TimeOfDay(hour: 13, minute: 30),
        kind: SleepEntryKind.nap,
      );

      expect(payload!['sleepType'], 'nap');
      expect(payload['durationMinutes'], 30);
    });

    test('includes optional quality and device sleep stages', () {
      final payload = buildSleepPayload(
        recordDate: recordDate,
        bedtime: bed2300,
        wakeTime: wake0700,
        kind: SleepEntryKind.nightSleep,
        quality: 'good',
        deepMinutes: 90,
        lightMinutes: 240,
        remMinutes: 110,
      );

      expect(payload!['quality'], 'good');
      expect(payload['deepMinutes'], 90);
      expect(payload['lightMinutes'], 240);
      expect(payload['remMinutes'], 110);
    });

    test('omits empty optional fields', () {
      final payload = buildSleepPayload(
        recordDate: recordDate,
        bedtime: bed2300,
        wakeTime: wake0700,
        kind: SleepEntryKind.nightSleep,
        deepMinutes: 0,
      );

      expect(payload!.containsKey('quality'), isFalse);
      expect(payload.containsKey('deepMinutes'), isFalse);
    });

    test('returns null when the times are unusable', () {
      expect(
        buildSleepPayload(
          recordDate: recordDate,
          bedtime: null,
          wakeTime: wake0700,
          kind: SleepEntryKind.nightSleep,
        ),
        isNull,
      );
      expect(
        buildSleepPayload(
          recordDate: recordDate,
          bedtime: bed2300,
          wakeTime: bed2300,
          kind: SleepEntryKind.nightSleep,
        ),
        isNull,
      );
      expect(
        buildSleepPayload(
          recordDate: recordDate,
          bedtime: bed2300,
          wakeTime: wake0700,
          kind: SleepEntryKind.nap,
        ),
        isNull,
      );
    });
  });

  group('SleepEntryKind', () {
    test('parses the wire value, defaulting to night sleep', () {
      expect(SleepEntryKind.fromPayload('nap'), SleepEntryKind.nap);
      expect(
        SleepEntryKind.fromPayload('nightSleep'),
        SleepEntryKind.nightSleep,
      );
      expect(SleepEntryKind.fromPayload(null), SleepEntryKind.nightSleep);
      expect(SleepEntryKind.fromPayload('unknown'), SleepEntryKind.nightSleep);
      expect(SleepEntryKind.nap.wireValue, 'nap');
      expect(SleepEntryKind.nightSleep.wireValue, 'nightSleep');
    });
  });
}
