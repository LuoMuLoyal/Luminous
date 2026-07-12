import 'package:luminous/core/database/database.dart';
import 'package:luminous/core/database/daos/daily_record_dao.dart';
import 'package:luminous/core/database/daos/medicine_dose_log_dao.dart';
import 'package:luminous/core/database/daos/current_medicine_dao.dart';
import 'package:luminous/core/database/daos/health_context_dao.dart';
import 'package:luminous/core/database/daos/today_suggestion_dao.dart';
import 'package:luminous/core/database/daos/pending_sync_dao.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_providers.g.dart';

/// Provides the singleton [AppDatabase] instance.
///
/// The database is kept alive for the entire app lifecycle.
/// It is closed when the provider is disposed.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

/// DAO providers — thin wrappers that extract the DAO from the database.
/// Feature code should depend on these rather than the raw database.

@riverpod
DailyRecordDao dailyRecordDao(Ref ref) {
  return ref.watch(appDatabaseProvider).dailyRecordDao;
}

@riverpod
MedicineDoseLogDao medicineDoseLogDao(Ref ref) {
  return ref.watch(appDatabaseProvider).medicineDoseLogDao;
}

@riverpod
CurrentMedicineDao currentMedicineDao(Ref ref) {
  return ref.watch(appDatabaseProvider).currentMedicineDao;
}

@riverpod
HealthContextDao healthContextDao(Ref ref) {
  return ref.watch(appDatabaseProvider).healthContextDao;
}

@riverpod
TodaySuggestionDao todaySuggestionDao(Ref ref) {
  return ref.watch(appDatabaseProvider).todaySuggestionDao;
}

@riverpod
PendingSyncDao pendingSyncDao(Ref ref) {
  return ref.watch(appDatabaseProvider).pendingSyncDao;
}
