import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'database_connection.dart'
    if (dart.library.io) 'database_connection_io.dart'
    if (dart.library.js_interop) 'database_connection_web.dart'
    as conn;

import 'tables/daily_records.dart';
import 'tables/medicine_dose_logs.dart';
import 'tables/current_medicines.dart';
import 'tables/health_context.dart';
import 'tables/today_suggestions.dart';
import 'tables/pending_sync_queue.dart';

import 'daos/daily_record_dao.dart';
import 'daos/medicine_dose_log_dao.dart';
import 'daos/current_medicine_dao.dart';
import 'daos/health_context_dao.dart';
import 'daos/today_suggestion_dao.dart';
import 'daos/pending_sync_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    DailyRecordCacheEntries,
    MedicineDoseLogCacheEntries,
    CurrentMedicineCacheEntries,
    HealthContextCacheEntries,
    TodaySuggestionCacheEntries,
    PendingSyncItems,
  ],
  daos: [
    DailyRecordDao,
    MedicineDoseLogDao,
    CurrentMedicineDao,
    HealthContextDao,
    TodaySuggestionDao,
    PendingSyncDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(conn.connect());

  /// For testing: pass an in-memory or custom executor.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),

    onUpgrade: (m, from, to) async {
      // Future migrations: step through each version sequentially.
      // if (from < 2) { ... }
    },

    beforeOpen: (details) async {
      // WAL mode is only supported on native SQLite (not WASM).
      if (!kIsWeb) {
        await customStatement('PRAGMA journal_mode = WAL');
      }
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
