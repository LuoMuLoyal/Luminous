import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';

DailyRecordKind? dailyRecordKindForEntryType(RecordEntryType type) {
  return switch (type) {
    RecordEntryType.water => DailyRecordKind.water,
    RecordEntryType.meal => DailyRecordKind.meal,
    RecordEntryType.vitals => DailyRecordKind.vital,
    RecordEntryType.mood => DailyRecordKind.mood,
    RecordEntryType.symptom => DailyRecordKind.symptom,
    RecordEntryType.activity => DailyRecordKind.activity,
    RecordEntryType.note => DailyRecordKind.note,
    RecordEntryType.sleep => DailyRecordKind.sleep,
    RecordEntryType.medication ||
    RecordEntryType.heartRate ||
    RecordEntryType.weight => null,
  };
}

RecordEntryType recordEntryTypeForDailyRecordKind(DailyRecordKind kind) {
  return switch (kind) {
    DailyRecordKind.water => RecordEntryType.water,
    DailyRecordKind.meal => RecordEntryType.meal,
    DailyRecordKind.vital => RecordEntryType.vitals,
    DailyRecordKind.mood => RecordEntryType.mood,
    DailyRecordKind.symptom => RecordEntryType.symptom,
    DailyRecordKind.activity => RecordEntryType.activity,
    DailyRecordKind.note => RecordEntryType.note,
    DailyRecordKind.sleep => RecordEntryType.sleep,
  };
}

DailyRecordKind? dailyRecordKindFromName(String? value) {
  if (value == null) return null;
  final name = value.trim();
  if (name.isEmpty) return null;

  for (final kind in DailyRecordKind.values) {
    if (kind.name == name) return kind;
  }
  return null;
}
