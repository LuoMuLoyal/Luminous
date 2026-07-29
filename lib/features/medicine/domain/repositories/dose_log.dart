import 'package:luminous/features/medicine/domain/entities/dose_log.dart';

/// Domain interface for reading and writing medicine dose logs.
///
/// Implemented by [CachedDoseLogDataSource] in the data layer. Consumers
/// in other features should depend on this interface, not the concrete
/// data source.
abstract interface class DoseLogRepository {
  /// Fetches dose logs for the given [date] (ISO `yyyy-MM-dd`).
  ///
  /// Cache-first: returns cached items immediately when available, then
  /// background-refreshes. If the cache is empty, fetches from the network.
  Future<List<DoseLogItem>> fetchForDate(String date);

  /// Creates a new dose log entry.
  Future<DoseLogItem> create(
    String currentMedicineId,
    String status,
    String date,
  );

  /// Updates the status of an existing dose log entry.
  Future<DoseLogItem> update(String doseLogId, String status);

  /// Deletes a dose log entry.
  Future<void> delete(String doseLogId, {required String date});

  /// Marks a dose log with the full context (reminder ID, scheduled time).
  Future<DoseLogItem> mark({
    required String currentMedicineId,
    required String status,
    required String date,
    String? reminderId,
    String? scheduledTime,
  });
}
