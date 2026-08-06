import 'package:flutter/material.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// A single quick-entry option shown in the fast record dialog.
///
/// The quick-entry option lists (labels, default values, supported units) are
/// currently hardcoded per [DailyRecordKind]. When a remote-configuration or
/// local-config system becomes available, [recordFastEntryChoicesFor] should
/// read from it so that options can be adjusted without a full app release.
@immutable
class RecordFastChoice {
  const RecordFastChoice({
    required this.label,
    this.prefix,
    this.title,
    this.value,
    this.unit,
    this.note,
    this.payload,
  });

  final String label;
  final Widget? prefix;
  final String? title;
  final String? value;
  final String? unit;
  final String? note;
  final Map<String, dynamic>? payload;
}

/// Default sleep-duration quick-entry options in minutes (6h, 7h, 8h, 9h).
///
/// Extracted as a named constant so that adjustments only need to happen in
/// one place. When remote config is available, replace this with a dynamic
/// list loaded at runtime.
const kSleepDurationOptions = <int>[360, 420, 480, 540];

/// Returns the quick-entry choices for the given record [kind].
List<RecordFastChoice> recordFastEntryChoicesFor(
  DailyRecordKind kind,
  AppLocalizations l10n,
) {
  return switch (kind) {
    DailyRecordKind.water => [
      RecordFastChoice(
        label: l10n.recordFastChoiceWater250ml,
        value: '250',
        unit: l10n.recordWaterUnitMl,
      ),
      RecordFastChoice(
        label: l10n.recordFastChoiceWater500ml,
        value: '500',
        unit: l10n.recordWaterUnitMl,
      ),
      RecordFastChoice(
        label: l10n.recordFastChoiceWater1Cup,
        value: '1',
        unit: l10n.recordWaterUnitCup,
      ),
      RecordFastChoice(
        label: l10n.recordFastChoiceWater1Time,
        value: '1',
        unit: l10n.recordWaterUnitTimes,
      ),
    ],
    DailyRecordKind.meal => [
      RecordFastChoice(
        label: l10n.recordFastChoiceMealBreakfast,
        title: l10n.recordFastChoiceMealBreakfast,
      ),
      RecordFastChoice(
        label: l10n.recordFastChoiceMealLunch,
        title: l10n.recordFastChoiceMealLunch,
      ),
      RecordFastChoice(
        label: l10n.recordFastChoiceMealDinner,
        title: l10n.recordFastChoiceMealDinner,
      ),
      RecordFastChoice(
        label: l10n.recordFastChoiceMealSnack,
        title: l10n.recordFastChoiceMealSnack,
      ),
    ],
    DailyRecordKind.symptom => [
      RecordFastChoice(
        label: l10n.recordFastChoiceSymptomHeadache,
        title: l10n.recordFastChoiceSymptomHeadache,
        value: l10n.recordFastChoiceSeverityMild,
      ),
      RecordFastChoice(
        label: l10n.recordFastChoiceSymptomStomachache,
        title: l10n.recordFastChoiceSymptomStomachache,
        value: l10n.recordFastChoiceSeverityMild,
      ),
      RecordFastChoice(
        label: l10n.recordFastChoiceSymptomDizzy,
        title: l10n.recordFastChoiceSymptomDizzy,
        value: l10n.recordFastChoiceSeverityMild,
      ),
      RecordFastChoice(
        label: l10n.recordFastChoiceSymptomFever,
        title: l10n.recordFastChoiceSymptomFever,
        value: l10n.recordFastChoiceSeverityMild,
      ),
    ],
    DailyRecordKind.note => [
      RecordFastChoice(
        label: l10n.recordFastChoiceNoteStable,
        title: l10n.recordFastChoiceNoteStable,
        note: l10n.recordFastChoiceNoteStable,
      ),
      RecordFastChoice(
        label: l10n.recordFastChoiceNoteTired,
        title: l10n.recordFastChoiceNoteTired,
        note: l10n.recordFastChoiceNoteTired,
      ),
      RecordFastChoice(
        label: l10n.recordFastChoiceNoteBusy,
        title: l10n.recordFastChoiceNoteBusy,
        note: l10n.recordFastChoiceNoteBusy,
      ),
      RecordFastChoice(
        label: l10n.recordFastChoiceNoteRecovered,
        title: l10n.recordFastChoiceNoteRecovered,
        note: l10n.recordFastChoiceNoteRecovered,
      ),
    ],
    DailyRecordKind.sleep => [
      for (final minutes in kSleepDurationOptions)
        RecordFastChoice(
          label: '${minutes ~/ 60}h',
          payload: <String, dynamic>{'durationMinutes': minutes},
        ),
    ],
    DailyRecordKind.mood => [
      RecordFastChoice(
        label: l10n.recordFastChoiceMoodGreat,
        prefix: const Text('😄'),
        payload: <String, dynamic>{'moodLevel': 5, 'moodLabel': 'great'},
      ),
      RecordFastChoice(
        label: l10n.recordFastChoiceMoodGood,
        prefix: const Text('🙂'),
        payload: <String, dynamic>{'moodLevel': 4, 'moodLabel': 'good'},
      ),
      RecordFastChoice(
        label: l10n.recordFastChoiceMoodOkay,
        prefix: const Text('😐'),
        payload: <String, dynamic>{'moodLevel': 3, 'moodLabel': 'okay'},
      ),
      RecordFastChoice(
        label: l10n.recordFastChoiceMoodBad,
        prefix: const Text('😟'),
        payload: <String, dynamic>{'moodLevel': 2, 'moodLabel': 'bad'},
      ),
      RecordFastChoice(
        label: l10n.recordFastChoiceMoodTerrible,
        prefix: const Text('😫'),
        payload: <String, dynamic>{'moodLevel': 1, 'moodLabel': 'terrible'},
      ),
    ],
    _ => const [],
  };
}
