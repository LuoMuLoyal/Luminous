import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
  AppDatabase() : super(_open());

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
      await customStatement('PRAGMA journal_mode = WAL');
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

LazyDatabase _open() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'luminous.db'));
    return NativeDatabase.createInBackground(file);
  });
}
