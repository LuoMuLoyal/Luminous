import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/domain/entities/record_type_mapping.dart';

void main() {
  group('recordEntryTypeForDailyRecordKind', () {
    test('maps all kinds', () {
      expect(
        recordEntryTypeForDailyRecordKind(DailyRecordKind.water),
        RecordEntryType.water,
      );
      expect(
        recordEntryTypeForDailyRecordKind(DailyRecordKind.meal),
        RecordEntryType.meal,
      );
      expect(
        recordEntryTypeForDailyRecordKind(DailyRecordKind.vital),
        RecordEntryType.vitals,
      );
      expect(
        recordEntryTypeForDailyRecordKind(DailyRecordKind.mood),
        RecordEntryType.mood,
      );
      expect(
        recordEntryTypeForDailyRecordKind(DailyRecordKind.symptom),
        RecordEntryType.symptom,
      );
      expect(
        recordEntryTypeForDailyRecordKind(DailyRecordKind.sleep),
        RecordEntryType.sleep,
      );
      expect(
        recordEntryTypeForDailyRecordKind(DailyRecordKind.note),
        RecordEntryType.note,
      );
    });
    test('covers all DailyRecordKind values', () {
      for (final k in DailyRecordKind.values) {
        expect(recordEntryTypeForDailyRecordKind(k), isA<RecordEntryType>());
      }
    });
  });

  group('dailyRecordKindForEntryType', () {
    test('maps core types', () {
      expect(
        dailyRecordKindForEntryType(RecordEntryType.water),
        DailyRecordKind.water,
      );
      expect(
        dailyRecordKindForEntryType(RecordEntryType.meal),
        DailyRecordKind.meal,
      );
      expect(
        dailyRecordKindForEntryType(RecordEntryType.sleep),
        DailyRecordKind.sleep,
      );
    });
    test('non-mappable types return null', () {
      expect(dailyRecordKindForEntryType(RecordEntryType.medication), isNull);
      expect(dailyRecordKindForEntryType(RecordEntryType.heartRate), isNull);
      expect(dailyRecordKindForEntryType(RecordEntryType.weight), isNull);
    });
  });

  group('round-trip', () {
    test('kind → entryType → kind == original', () {
      for (final k in DailyRecordKind.values) {
        expect(
          dailyRecordKindForEntryType(recordEntryTypeForDailyRecordKind(k)),
          k,
        );
      }
    });
  });

  group('dailyRecordKindFromName', () {
    test('valid names', () {
      expect(dailyRecordKindFromName('water'), DailyRecordKind.water);
      expect(dailyRecordKindFromName('sleep'), DailyRecordKind.sleep);
    });
    test('null/empty/unknown returns null', () {
      expect(dailyRecordKindFromName(null), isNull);
      expect(dailyRecordKindFromName(''), isNull);
      expect(dailyRecordKindFromName('??'), isNull);
    });
  });
}
