import 'package:drift/drift.dart';

/// Cache table for per-day record summaries.
///
/// The summary carries the per-kind counts, latest values and payload snippets
/// the dashboard cards render. It used to be requested straight from the network
/// on every dashboard build, so the first frame waited for the network even when
/// the underlying records were already cached locally — the read path was not
/// cache-first like the record list.
///
/// One row per day: [recordDate] is the primary key. [cachedAt] is only used by
/// retention cleanup; there is no per-cache TTL (cache-first returns immediately
/// and refreshes in the background).
class DailyRecordSummaryCacheEntries extends Table {
  TextColumn get recordDate => text()();
  TextColumn get data => text()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {recordDate};
}
