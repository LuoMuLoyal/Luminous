import 'package:luminous/features/health_context/domain/services/unit_conversion.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Orders same-day records by occurrence date/time (ascending).
int compareRecords(DailyRecordItem a, DailyRecordItem b) {
  final byDate = a.occurredAt.compareTo(b.occurredAt);
  if (byDate != 0) return byDate;
  return (a.occurredTime ?? '').compareTo(b.occurredTime ?? '');
}

/// Returns the localized mood label for a mood record, or null when the
/// record is not a mood or has no recognizable mood payload.
String? moodLabel(AppLocalizations l10n, DailyRecordItem record) {
  if (record.kind != DailyRecordKind.mood) return null;
  final label = record.payload?['moodLabel'];
  if (label is! String) return null;
  return switch (label) {
    'great' => l10n.recordTimelineMoodGreat,
    'good' => l10n.recordTimelineMoodGood,
    'okay' => l10n.recordTimelineMoodOkay,
    'bad' => l10n.recordTimelineMoodBad,
    'terrible' => l10n.recordTimelineMoodTerrible,
    _ => null,
  };
}

String kindLabel(AppLocalizations l10n, DailyRecordKind kind) {
  return switch (kind) {
    DailyRecordKind.water => l10n.recordTypeWater,
    DailyRecordKind.meal => l10n.recordTypeMeal,
    DailyRecordKind.vital => l10n.recordTypeVitals,
    DailyRecordKind.mood => l10n.recordTypeMood,
    DailyRecordKind.symptom => l10n.recordTypeSymptom,
    DailyRecordKind.activity => l10n.recordTypeActivity,
    DailyRecordKind.note => l10n.recordCreateKindNote,
    DailyRecordKind.sleep => l10n.recordTypeSleep,
  };
}

String valueWithUnit(String value, String? unit) {
  final trimmedUnit = unit?.trim();
  if (trimmedUnit == null || trimmedUnit.isEmpty) return value;
  return '$value $trimmedUnit';
}

/// Formats an ml value as a fl oz string with one decimal place for the
/// imperial water progress label (e.g. "18.6"). Display-only conversion;
/// storage stays in ml.
String formatFlOz(num ml) => waterInFlOz(ml).toStringAsFixed(1);

String? nonEmpty(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

String sleepQualityLabel(AppLocalizations l10n, String quality) {
  return switch (quality) {
    'poor' => l10n.recordSleepQualityPoor,
    'fair' => l10n.recordSleepQualityFair,
    'good' => l10n.recordSleepQualityGood,
    'excellent' => l10n.recordSleepQualityExcellent,
    _ => quality,
  };
}

/// Maps a record source wire value to a user-facing label.
/// Returns the raw value for unknown sources so data is not hidden.
String sourceLabel(AppLocalizations l10n, String source) {
  return switch (source) {
    'manual' => l10n.recordSourceManual,
    'local' => l10n.recordSourceLocal,
    'ai' => l10n.recordSourceAi,
    'import' => l10n.recordSourceImport,
    _ => source,
  };
}
