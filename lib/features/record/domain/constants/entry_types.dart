import 'package:luminous/features/record/domain/entities/dashboard.dart';

/// Returns whether the given record entry type is currently active (shown) in
/// the record UI.
///
/// This is a copy predicate over the wire vocabulary, not a view concern, so
/// it lives in `domain/constants/` — both the data layer (record filtering)
/// and the application-layer dashboard mappers depend on it.
bool isActiveRecordEntryType(RecordEntryType type) {
  return switch (type) {
    RecordEntryType.symptom ||
    RecordEntryType.water ||
    RecordEntryType.meal ||
    RecordEntryType.sleep ||
    RecordEntryType.medication ||
    RecordEntryType.mood ||
    RecordEntryType.note ||
    RecordEntryType.vitals ||
    RecordEntryType.activity => true,
    _ => false,
  };
}
