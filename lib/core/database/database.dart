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
import 'daos/health/health_context.dart';
import 'daos/medicine/current_medicine.dart';
import 'daos/medicine/medicine_dose_log.dart';
import 'daos/medicine/medicine_workspace.dart';
import 'daos/medicine/search_result.dart';
import 'daos/mine/mine_dashboard.dart';
import 'daos/notification/notification_page.dart';
import 'daos/records/daily_record.dart';
import 'daos/records/daily_record_summary.dart';
import 'daos/review/review.dart';
import 'daos/review/review_dashboard.dart';
import 'daos/review/today_suggestion.dart';
import 'daos/settings/user_settings_cache.dart';
import 'daos/sync/pending_sync.dart';
import 'tables/health/health_context.dart';
import 'tables/medicine/current_medicines.dart';
import 'tables/medicine/medicine_dose_logs.dart';
import 'tables/medicine/medicine_workspaces.dart';
import 'tables/medicine/search_results.dart';
import 'tables/mine/mine_dashboards.dart';
import 'tables/notification/notification_pages.dart';
import 'tables/records/daily_record_summaries.dart';
import 'tables/records/daily_records.dart';
import 'tables/review/review_dashboards.dart';
import 'tables/review/reviews.dart';
import 'tables/review/today_suggestions.dart';
import 'tables/settings/user_settings_cache.dart';
import 'tables/sync/pending_sync_queue.dart';

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
