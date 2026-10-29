import 'package:drift/drift.dart';

import '../../database.dart';
import '../../tables/daily_record_summaries.dart';

part 'daily_record_summary.g.dart';

/// Data access object for the per-day record summary cache.
///
/// Follows the same cache-first shape as [DailyRecordDao]: [fetchByDate] returns
/// the cached summary, [replaceByDate] overwrites it after a refresh,
/// [invalidate] drops it when the underlying records change, and [cleanup]
/// removes rows older than the retention period.
@DriftAccessor(tables: [DailyRecordSummaryCacheEntries])
class DailyRecordSummaryDao extends DatabaseAccessor<AppDatabase>
    with _$DailyRecordSummaryDaoMixin {
  DailyRecordSummaryDao(super.db);

  /// Returns the cached summary JSON for [date], or null on a cache miss.
  Future<String?> fetchByDate(String date) async {
    final row = await (select(
      dailyRecordSummaryCacheEntries,
    )..where((t) => t.recordDate.equals(date))).getSingleOrNull();
    return row?.data;
  }

  /// Overwrites the cached summary for [date].
  Future<void> replaceByDate(String date, String json) async {
    await into(dailyRecordSummaryCacheEntries).insertOnConflictUpdate(
      DailyRecordSummaryCacheEntriesCompanion.insert(
        recordDate: date,
        data: json,
        cachedAt: DateTime.now(),
      ),
    );
  }

  /// Drops the cached summary for [date].
  ///
  /// Called after a write (create/edit/delete) so the next read refreshes
  /// instead of serving a summary that no longer matches the records.
  Future<void> invalidate(String date) async {
    await (delete(
      dailyRecordSummaryCacheEntries,
    )..where((t) => t.recordDate.equals(date))).go();
  }

  /// Removes summaries cached before [cutoff].
  Future<int> cleanup(DateTime cutoff) async {
    return (delete(
      dailyRecordSummaryCacheEntries,
    )..where((t) => t.cachedAt.isSmallerThanValue(cutoff))).go();
  }
}
