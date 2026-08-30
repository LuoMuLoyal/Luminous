import 'package:luminous/core/database/daos/current_medicine.dart';
import 'package:luminous/core/database/daos/daily_record.dart';
import 'package:luminous/core/database/daos/health_context.dart';
import 'package:luminous/core/database/daos/medicine_dose_log.dart';
import 'package:luminous/core/database/daos/pending_sync.dart';
import 'package:luminous/core/database/daos/review.dart';
import 'package:luminous/core/database/daos/review_dashboard.dart';
import 'package:luminous/core/database/daos/today_suggestion.dart';
import 'package:luminous/core/database/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connection_providers.g.dart';

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

@Riverpod(keepAlive: true)
DailyRecordDao dailyRecordDao(Ref ref) {
  return ref.read(appDatabaseProvider).dailyRecordDao;
}

@Riverpod(keepAlive: true)
MedicineDoseLogDao medicineDoseLogDao(Ref ref) {
  return ref.read(appDatabaseProvider).medicineDoseLogDao;
}

@Riverpod(keepAlive: true)
CurrentMedicineDao currentMedicineDao(Ref ref) {
  return ref.read(appDatabaseProvider).currentMedicineDao;
}

@Riverpod(keepAlive: true)
HealthContextDao healthContextDao(Ref ref) {
  return ref.read(appDatabaseProvider).healthContextDao;
}

@Riverpod(keepAlive: true)
TodaySuggestionDao todaySuggestionDao(Ref ref) {
  return ref.read(appDatabaseProvider).todaySuggestionDao;
}

@Riverpod(keepAlive: true)
PendingSyncDao pendingSyncDao(Ref ref) {
  return ref.read(appDatabaseProvider).pendingSyncDao;
}

@Riverpod(keepAlive: true)
ReviewDao reviewDao(Ref ref) {
  return ref.read(appDatabaseProvider).reviewDao;
}

@Riverpod(keepAlive: true)
ReviewDashboardDao reviewDashboardDao(Ref ref) {
  return ref.read(appDatabaseProvider).reviewDashboardDao;
}
