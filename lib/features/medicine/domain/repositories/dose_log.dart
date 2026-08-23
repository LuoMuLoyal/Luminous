import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/medicine/domain/entities/dose_log.dart';

/// Domain interface for reading and writing medicine dose logs.
///
/// Implemented by [CachedDoseLogDataSource] in the data layer. Consumers
/// in other features should depend on this interface, not the concrete
/// data source.
///
/// Repository boundary: every expected recoverable failure (network, server
/// business failure) is a `TaskEither` Left produced via
/// `LucentErrorMapper.fromObject`; a legal empty item set stays a Right.
abstract interface class DoseLogRepository {
  /// Fetches dose logs for the given [date] (ISO `yyyy-MM-dd`).
  ///
  /// Cache-first: returns cached items immediately when available, then
  /// background-refreshes. If the cache is empty, fetches from the network.
  TaskEither<LucentFailure, List<DoseLogItem>> fetchForDate(String date);

  /// Creates a new dose log entry.
  TaskEither<LucentFailure, DoseLogItem> create(
    String currentMedicineId,
    String status,
    String date,
  );

  /// Updates the status of an existing dose log entry.
  TaskEither<LucentFailure, DoseLogItem> update(
    String doseLogId,
    String status,
  );

  /// Deletes a dose log entry.
  TaskEither<LucentFailure, void> delete(
    String doseLogId, {
    required String date,
  });

  /// Marks a dose log with the full context (reminder ID, scheduled time).
  TaskEither<LucentFailure, DoseLogItem> mark({
    required String currentMedicineId,
    required String status,
    required String date,
    String? reminderId,
    String? scheduledTime,
  });
}
