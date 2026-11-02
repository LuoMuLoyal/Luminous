import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/undo/quick_entry_undo.dart';

/// The write-side verbs a quick-entry use case needs from the daily-record
/// repository.
///
/// Declared in the domain so use cases receive their dependencies as plain
/// constructor arguments; the provider layer adapts `DailyRecordRepository`
/// onto it.
abstract interface class DailyRecordWriter {
  /// Creates a record, returning the stored item.
  ///
  /// Throws when the write fails; use cases own the mapping from a failed
  /// write to a user-facing outcome.
  Future<DailyRecordItem> create(DailyRecordCreateInput input);

  /// Updates a record's mutable fields (throws on failure).
  Future<DailyRecordItem> update(String id, DailyRecordUpdateInput input);

  /// Deletes a record (throws on failure).
  Future<void> delete(String id);

  /// Uploads an attachment for a record about to be created (throws on
  /// failure).
  Future<DailyRecordAttachmentInput> uploadImage(
    DailyRecordImageUploadInput input,
  );
}

/// Which gesture asked for the meal confirmation dialog.
enum MealQuickEntrySource {
  /// Single tap: open the camera first; a cancelled camera writes nothing.
  camera,

  /// Long press: manual no-photo meal entry (per the quick-entry UX spec, long
  /// press is the manual fallback for the camera-first path).
  manual,
}

/// Which meal title the confirmation dialog pre-fills, from the wall clock.
enum MealTitleSlot { breakfast, lunch, dinner, snack }

/// Resolves the default meal title slot for [now].
///
/// < 10:00 breakfast · < 15:00 lunch · < 21:00 dinner · otherwise snack.
MealTitleSlot mealTitleSlotAt(DateTime now) {
  final hour = now.hour;
  if (hour < 10) return MealTitleSlot.breakfast;
  if (hour < 15) return MealTitleSlot.lunch;
  if (hour < 21) return MealTitleSlot.dinner;
  return MealTitleSlot.snack;
}

/// Evidence a quick-surface success toast needs in order to offer "undo".
///
/// The presentation layer shows the toast and, on tap, hands the action back to
/// [QuickEntryUndoService]; use cases and flows never touch the UI.
sealed class QuickEntryUndoHint {
  const QuickEntryUndoHint();
}

/// Nothing to undo (the write replaced/updated an existing record).
final class NoQuickEntryUndo extends QuickEntryUndoHint {
  const NoQuickEntryUndo();
}

/// The undoable unit of work, in domain vocabulary.
final class QuickEntryUndoOffer extends QuickEntryUndoHint {
  const QuickEntryUndoOffer(this.action);

  final QuickEntryUndoAction action;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuickEntryUndoOffer && other.action == action;

  @override
  int get hashCode => action.hashCode;

  @override
  String toString() => 'QuickEntryUndoOffer($action)';
}
