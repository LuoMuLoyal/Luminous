import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Platform-agnostic database connection via conditional imports.
//
// Known risk: HarmonyOS ArkWeb may not expose `dart.library.js_interop`,
// causing the stub to throw UnsupportedError at runtime. This is a known
// limitation — if ArkWeb support is needed, test on a real device and
// consider adding `if (dart.library.html)` as an additional fallback.
import 'connection.dart'
    if (dart.library.io) 'connection_io.dart'
    if (dart.library.js_interop) 'connection_web.dart'
    as conn;
import 'daos/current_medicine.dart';
import 'daos/daily_record.dart';
import 'daos/daily_record_summary.dart';
import 'daos/health_context.dart';
import 'daos/medicine_dose_log.dart';
import 'daos/medicine_workspace.dart';
import 'daos/mine_dashboard.dart';
import 'daos/notification_page.dart';
import 'daos/pending_sync.dart';
import 'daos/review.dart';
import 'daos/review_dashboard.dart';
import 'daos/search_result.dart';
import 'daos/today_suggestion.dart';
import 'daos/user_settings_cache.dart';
import 'tables/current_medicines.dart';
import 'tables/daily_record_summaries.dart';
import 'tables/daily_records.dart';
import 'tables/health_context.dart';
import 'tables/medicine_dose_logs.dart';
import 'tables/medicine_workspaces.dart';
import 'tables/mine_dashboards.dart';
import 'tables/notification_pages.dart';
import 'tables/pending_sync_queue.dart';
import 'tables/review_dashboards.dart';
import 'tables/reviews.dart';
import 'tables/search_results.dart';
import 'tables/today_suggestions.dart';
import 'tables/user_settings_cache.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    DailyRecordCacheEntries,
    DailyRecordSummaryCacheEntries,
    MedicineDoseLogCacheEntries,
    CurrentMedicineCacheEntries,
    HealthContextCacheEntries,
    TodaySuggestionCacheEntries,
    PendingSyncItems,
    ReviewCacheEntries,
    ReviewDashboardCacheEntries,
    NotificationPageCacheEntries,
    MineDashboardCacheEntries,
    MedicineWorkspaceCacheEntries,
    SearchResultCacheEntries,
    UserSettingsCacheEntries,
  ],
  daos: [
    DailyRecordDao,
    DailyRecordSummaryDao,
    MedicineDoseLogDao,
    CurrentMedicineDao,
    HealthContextDao,
    TodaySuggestionDao,
    PendingSyncDao,
    ReviewDao,
    ReviewDashboardDao,
    NotificationPageDao,
    MineDashboardDao,
    MedicineWorkspaceDao,
    SearchResultDao,
    UserSettingsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(conn.connect());

  /// For testing: pass an in-memory or custom executor.
  AppDatabase.forTesting(super.e);

  /// The local database holds only disposable cache state, so there is no
  /// migration chain: the schema is defined as a fresh install and any older
  /// database on disk is discarded rather than upgraded.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),

    beforeOpen: (details) async {
      // WAL mode is only supported on native SQLite (not WASM).
      if (!kIsWeb) {
        await customStatement('PRAGMA journal_mode = WAL');
      }
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
