import 'package:drift/drift.dart';

/// Pending sync queue for offline writes.
///
/// When a write operation (create/update/delete) fails due to network
/// issues, the request is serialized as JSON in [payload] and enqueued
/// here. The [SyncWorker] replays these items when connectivity is restored.
class PendingSyncItems extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text().nullable()();
  TextColumn get operation => text()(); // 'create' | 'update' | 'delete'
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  IntColumn get maxRetry => integer().withDefault(const Constant(5))();
  BoolColumn get isSyncing => boolean().withDefault(const Constant(false))();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
