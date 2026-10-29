import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/services/hour_minute.dart';
import 'package:luminous/features/record/domain/services/quick_entry.dart';
import 'package:luminous/features/record/domain/undo/quick_entry_undo.dart';

/// Outcome of [ChangeRecordDateUseCase.call].
sealed class ChangeRecordDateOutcome {
  const ChangeRecordDateOutcome();
}

/// The record was moved to the new day.
final class ChangeRecordDateSucceeded extends ChangeRecordDateOutcome {
  const ChangeRecordDateSucceeded(this.newDate);

  final DateTime newDate;
}

/// The update failed; the caller surfaces a "date change failed" toast.
final class ChangeRecordDateFailed extends ChangeRecordDateOutcome {
  const ChangeRecordDateFailed(this.error);

  final Object error;
}

/// Moves a record to another day and broadcasts the change.
///
/// Pure: the `occurredAt` wire value is derived here, the repository write is a
/// plain argument, and the caller (presentation) decides how to toast and
/// whether to update the selected date.
class ChangeRecordDateUseCase {
  const ChangeRecordDateUseCase({
    required this.repository,
    required this.emitDataChange,
  });

  final DailyRecordWriter repository;
  final EmitDataChangeTopic emitDataChange;

  Future<ChangeRecordDateOutcome> call({
    required String recordId,
    required DateTime newDate,
  }) async {
    try {
      await repository.update(
        recordId,
        DailyRecordUpdateInput(occurredAt: formatCalendarDateKey(newDate)),
      );
    } catch (error) {
      return ChangeRecordDateFailed(error);
    }
    emitDataChange(QuickEntryDataChange.dailyRecords);
    return ChangeRecordDateSucceeded(newDate);
  }
}
