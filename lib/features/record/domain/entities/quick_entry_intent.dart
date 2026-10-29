import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';

part 'quick_entry_intent.freezed.dart';

/// What a quick-entry tap should open, decided purely from the action.
///
/// This is the "which surface does this gesture lead to" half of the old
/// `presentation/services/quick_entry_executor.dart`: the presentation layer
/// maps each case onto a sheet / dialog / route, and the application layer
/// only decides.
@freezed
sealed class RecordQuickEntryIntent with _$RecordQuickEntryIntent {
  /// Record water: amount sheet, then a single water record.
  const factory RecordQuickEntryIntent.water() = WaterQuickEntryIntent;

  /// Record symptoms: symptom sheet, then one or more symptom records.
  const factory RecordQuickEntryIntent.symptom() = SymptomQuickEntryIntent;

  /// Mood / note: the legacy fast-entry dialog.
  const factory RecordQuickEntryIntent.fastEntry({
    required RecordEntryType type,
  }) = FastEntryQuickEntryIntent;

  /// Everything else (sleep, medication, meal, vitals, activity…): the full
  /// record-create route with the kind/date/time preselected.
  const factory RecordQuickEntryIntent.createRoute({
    required RecordEntryType type,
  }) = CreateRouteQuickEntryIntent;
}

/// Resolves the tap intent for [type].
///
/// Water and symptom have dedicated quick surfaces; mood and note use the
/// legacy fast-entry dialog; every other type goes to the full create route.
/// [RecordEntryType.meal], [RecordEntryType.sleep] and
/// [RecordEntryType.medication] are intercepted by the record page before this
/// dispatcher runs, so they never reach this function in practice — they fall
/// through to [CreateRouteQuickEntryIntent] when they do.
RecordQuickEntryIntent quickEntryTapIntentFor(RecordEntryType type) {
  return switch (type) {
    RecordEntryType.water => const RecordQuickEntryIntent.water(),
    RecordEntryType.symptom => const RecordQuickEntryIntent.symptom(),
    RecordEntryType.mood ||
    RecordEntryType.note => RecordQuickEntryIntent.fastEntry(type: type),
    _ => RecordQuickEntryIntent.createRoute(type: type),
  };
}
