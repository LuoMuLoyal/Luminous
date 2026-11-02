import 'package:intl/intl.dart';
import 'package:luminous/features/mine/presentation/providers/sync_failures.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// The two lines a failed sync entry shows once its card is collapsed:
/// *what* it was and *when* it was queued.
///
/// A failure list is scanned, not read: the user needs to recognise the
/// record ("18 Jun · blood pressure") before deciding whether to keep it.
/// Entity type, operation and record id are wire values
/// (`daily_record` / `create` / `daily-bp-20260618-0740`) — they stay in the
/// diagnostics payload, and these helpers turn them into the head line.
///
/// The entity type is the entry's stable identity; the record id's date
/// segment is only a fallback for types not in [_entityLabels] yet.
({String title, String subtitle}) syncEntryCaption(
  MineSyncEntry entry,
  AppLocalizations l10n,
  String locale,
) {
  final queuedAt = DateFormat.yMMMd(
    locale,
  ).add_Hm().format(entry.createdAt.toLocal());
  final title = _entityLabel(l10n, entry.entityType, entry.entityId);
  return (title: title, subtitle: queuedAt);
}

String _entityLabel(
  AppLocalizations l10n,
  String entityType,
  String? entityId,
) {
  final label = switch (entityType) {
    'daily_record' => l10n.mineSyncFailedEntityDailyRecord,
    'medicine' => l10n.mineSyncFailedEntityMedicine,
    'medicine_reminder' => l10n.mineSyncFailedEntityMedicineReminder,
    'medicine_dose_log' => l10n.mineSyncFailedEntityMedicineDoseLog,
    'health_allergy' => l10n.mineSyncFailedEntityHealthAllergy,
    'health_condition' => l10n.mineSyncFailedEntityHealthCondition,
    'health_context' => l10n.mineSyncFailedEntityHealthContext,
    'user_profile' => l10n.mineSyncFailedEntityUserProfile,
    _ => l10n.mineSyncFailedEntityOther,
  };
  final kind = _entityKind(l10n, entityType, entityId);
  return kind == null ? label : '$kind · $label';
}

/// The record kind inside a multi-kind entity type (`daily_record` covers
/// blood pressure, sleep, water, meals …). `null` when the entity type holds a
/// single record kind already named by [_entityLabel].
String? _entityKind(
  AppLocalizations l10n,
  String entityType,
  String? entityId,
) {
  if (entityType != 'daily_record' || entityId == null) return null;

  // Record ids are `<kind>-<yyyyMMdd>-<…>`; the kind wins over the record id's
  // date so the head line always reads as the record it came from.
  final kind = entityId.split('-').first;
  return switch (kind) {
    'bp' || 'blood_pressure' => l10n.mineSyncFailedKindBloodPressure,
    'sleep' => l10n.mineSyncFailedKindSleep,
    'water' => l10n.mineSyncFailedKindWater,
    'meal' || 'food' => l10n.mineSyncFailedKindMeal,
    'symptom' => l10n.mineSyncFailedKindSymptom,
    'mood' => l10n.mineSyncFailedKindMood,
    'weight' => l10n.mineSyncFailedKindWeight,
    'activity' || 'exercise' => l10n.mineSyncFailedKindActivity,
    'note' => l10n.mineSyncFailedKindNote,
    'caffeine' => l10n.mineSyncFailedKindCaffeine,
    _ => null,
  };
}
