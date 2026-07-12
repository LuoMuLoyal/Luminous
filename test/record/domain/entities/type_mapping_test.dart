import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/entities/type_mapping.dart';

void main() {
  group('dailyRecordKindForEntryType', () {
    test('maps water to DailyRecordKind.water', () {
      expect(
        dailyRecordKindForEntryType(RecordEntryType.water),
        DailyRecordKind.water,
      );
    });

    test('maps meal to DailyRecordKind.meal', () {
      expect(
        dailyRecordKindForEntryType(RecordEntryType.meal),
        DailyRecordKind.meal,
      );
    });

    test('maps vitals to DailyRecordKind.vital', () {
      expect(
        dailyRecordKindForEntryType(RecordEntryType.vitals),
        DailyRecordKind.vital,
      );
    });

    test('maps mood to DailyRecordKind.mood', () {
      expect(
        dailyRecordKindForEntryType(RecordEntryType.mood),
        DailyRecordKind.mood,
      );
    });

    test('maps symptom to DailyRecordKind.symptom', () {
      expect(
        dailyRecordKindForEntryType(RecordEntryType.symptom),
        DailyRecordKind.symptom,
      );
    });

    test('maps activity to DailyRecordKind.activity', () {
      expect(
        dailyRecordKindForEntryType(RecordEntryType.activity),
        DailyRecordKind.activity,
      );
    });

    test('maps note to DailyRecordKind.note', () {
      expect(
        dailyRecordKindForEntryType(RecordEntryType.note),
        DailyRecordKind.note,
      );
    });

    test('maps sleep to DailyRecordKind.sleep', () {
      expect(
        dailyRecordKindForEntryType(RecordEntryType.sleep),
        DailyRecordKind.sleep,
      );
    });

    test('returns null for medication', () {
      expect(dailyRecordKindForEntryType(RecordEntryType.medication), isNull);
    });

    test('returns null for heartRate', () {
      expect(dailyRecordKindForEntryType(RecordEntryType.heartRate), isNull);
    });

    test('returns null for weight', () {
      expect(dailyRecordKindForEntryType(RecordEntryType.weight), isNull);
    });
  });

  group('recordEntryTypeForDailyRecordKind', () {
    test('maps water to RecordEntryType.water', () {
      expect(
        recordEntryTypeForDailyRecordKind(DailyRecordKind.water),
        RecordEntryType.water,
      );
    });

    test('maps meal to RecordEntryType.meal', () {
      expect(
        recordEntryTypeForDailyRecordKind(DailyRecordKind.meal),
        RecordEntryType.meal,
      );
    });

    test('maps vital to RecordEntryType.vitals', () {
      expect(
        recordEntryTypeForDailyRecordKind(DailyRecordKind.vital),
        RecordEntryType.vitals,
      );
    });

    test('maps mood to RecordEntryType.mood', () {
      expect(
        recordEntryTypeForDailyRecordKind(DailyRecordKind.mood),
        RecordEntryType.mood,
      );
    });

    test('maps symptom to RecordEntryType.symptom', () {
      expect(
        recordEntryTypeForDailyRecordKind(DailyRecordKind.symptom),
        RecordEntryType.symptom,
      );
    });

    test('maps activity to RecordEntryType.activity', () {
      expect(
        recordEntryTypeForDailyRecordKind(DailyRecordKind.activity),
        RecordEntryType.activity,
      );
    });

    test('maps note to RecordEntryType.note', () {
      expect(
        recordEntryTypeForDailyRecordKind(DailyRecordKind.note),
        RecordEntryType.note,
      );
    });

    test('maps sleep to RecordEntryType.sleep', () {
      expect(
        recordEntryTypeForDailyRecordKind(DailyRecordKind.sleep),
        RecordEntryType.sleep,
      );
    });

    test('round-trip: all mappable types preserve identity', () {
      for (final kind in DailyRecordKind.values) {
        final entryType = recordEntryTypeForDailyRecordKind(kind);
        expect(dailyRecordKindForEntryType(entryType), kind);
      }
    });
  });

  group('dailyRecordKindFromName', () {
    test('returns correct kind for valid name', () {
      expect(dailyRecordKindFromName('water'), DailyRecordKind.water);
      expect(dailyRecordKindFromName('meal'), DailyRecordKind.meal);
      expect(dailyRecordKindFromName('vital'), DailyRecordKind.vital);
      expect(dailyRecordKindFromName('mood'), DailyRecordKind.mood);
      expect(dailyRecordKindFromName('symptom'), DailyRecordKind.symptom);
      expect(dailyRecordKindFromName('activity'), DailyRecordKind.activity);
      expect(dailyRecordKindFromName('note'), DailyRecordKind.note);
      expect(dailyRecordKindFromName('sleep'), DailyRecordKind.sleep);
    });

    test('returns null for null input', () {
      expect(dailyRecordKindFromName(null), isNull);
    });

    test('returns null for empty string', () {
      expect(dailyRecordKindFromName(''), isNull);
    });

    test('returns null for whitespace-only string', () {
      expect(dailyRecordKindFromName('   '), isNull);
    });

    test('returns null for unknown name', () {
      expect(dailyRecordKindFromName('unknown'), isNull);
    });

    test('trims whitespace before matching', () {
      expect(dailyRecordKindFromName('  water  '), DailyRecordKind.water);
    });

    test('is case-sensitive', () {
      expect(dailyRecordKindFromName('Water'), isNull);
      expect(dailyRecordKindFromName('WATER'), isNull);
    });
  });

  group('recordEntryTypeFromName', () {
    test('returns correct type for valid name', () {
      expect(recordEntryTypeFromName('meal'), RecordEntryType.meal);
      expect(recordEntryTypeFromName('vitals'), RecordEntryType.vitals);
      expect(recordEntryTypeFromName('water'), RecordEntryType.water);
      expect(recordEntryTypeFromName('mood'), RecordEntryType.mood);
      expect(recordEntryTypeFromName('symptom'), RecordEntryType.symptom);
      expect(recordEntryTypeFromName('activity'), RecordEntryType.activity);
      expect(recordEntryTypeFromName('medication'), RecordEntryType.medication);
      expect(recordEntryTypeFromName('sleep'), RecordEntryType.sleep);
      expect(recordEntryTypeFromName('heartRate'), RecordEntryType.heartRate);
      expect(recordEntryTypeFromName('weight'), RecordEntryType.weight);
      expect(recordEntryTypeFromName('note'), RecordEntryType.note);
    });

    test('returns null for null input', () {
      expect(recordEntryTypeFromName(null), isNull);
    });

    test('returns null for empty string', () {
      expect(recordEntryTypeFromName(''), isNull);
    });

    test('returns null for whitespace-only string', () {
      expect(recordEntryTypeFromName('   '), isNull);
    });

    test('returns null for unknown name', () {
      expect(recordEntryTypeFromName('unknown'), isNull);
    });

    test('trims whitespace before matching', () {
      expect(recordEntryTypeFromName('  water  '), RecordEntryType.water);
    });

    test('is case-sensitive', () {
      expect(recordEntryTypeFromName('Water'), isNull);
    });
  });
}
