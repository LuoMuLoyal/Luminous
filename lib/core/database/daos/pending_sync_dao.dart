import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/pending_sync_queue.dart';

part 'pending_sync_dao.g.dart';

/// Pending sync item with decoded fields for the SyncWorker.
class PendingSyncEntry {
  final String id;
  final String entityType;
  final String? entityId;
  final String operation;
  final String payload;
  final DateTime createdAt;
  final int retryCount;
  final int maxRetry;

  PendingSyncEntry({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.createdAt,
    required this.retryCount,
    required this.maxRetry,
  });

  /// Whether this entry has exceeded the max retry count.
  bool get isPermanentlyFailed => retryCount >= maxRetry;

  /// The minimum delay before the next retry attempt.
  /// Exponential backoff: 30s * 2^retryCount, capped at 30 minutes.
  Duration get backoffDelay {
    final seconds = 30 * (1 << retryCount);
    return Duration(seconds: seconds.clamp(0, 1800));
  }
}

/// Data access object for the pending sync queue.
///
/// Manages offline write operations that need to be replayed
/// when network connectivity is restored.
@DriftAccessor(tables: [PendingSyncItems])
class PendingSyncDao extends DatabaseAccessor<AppDatabase>
    with _$PendingSyncDaoMixin {
  PendingSyncDao(super.db);

  /// Enqueues a new pending sync item.
  Future<String> enqueue({
    required String entityType,
    String? entityId,
    required String operation,
    required String payload,
  }) async {
    final id = _generateId();
    await into(pendingSyncItems).insert(
      PendingSyncItemsCompanion.insert(
        id: id,
        entityType: entityType,
        entityId: Value(entityId),
        operation: operation,
        payload: payload,
        createdAt: DateTime.now(),
      ),
    );
    return id;
  }

  /// Returns all pending pendingSyncItems that are ready for retry
  /// (not currently syncing, not permanently failed, backoff elapsed).
  Future<List<PendingSyncEntry>> fetchReady() async {
    final now = DateTime.now();
    final query = select(pendingSyncItems)
      ..where((t) => t.isSyncing.equals(false))
      ..where((t) => t.retryCount.isSmallerThan(t.maxRetry))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);

    final rows = await query.get();
    return rows
        .where((r) {
          if (r.lastAttemptAt == null) return true;
          final elapsed = now.difference(r.lastAttemptAt!);
          final entry = _toEntry(r);
          return elapsed >= entry.backoffDelay;
        })
        .map(_toEntry)
        .toList();
  }

  /// Marks an item as currently syncing.
  Future<void> markSyncing(String id) async {
    await (update(pendingSyncItems)..where((t) => t.id.equals(id))).write(
      const PendingSyncItemsCompanion(isSyncing: Value(true)),
    );
  }

  /// Marks a sync attempt as failed, increments retry count.
  Future<void> markFailed(String id, String error) async {
    final current = await (select(
      pendingSyncItems,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (current == null) return;

    await (update(pendingSyncItems)..where((t) => t.id.equals(id))).write(
      PendingSyncItemsCompanion(
        isSyncing: const Value(false),
        retryCount: Value(current.retryCount + 1),
        lastAttemptAt: Value(DateTime.now()),
        lastError: Value(error),
      ),
    );
  }

  /// Removes a successfully synced item.
  Future<void> remove(String id) async {
    await (delete(pendingSyncItems)..where((t) => t.id.equals(id))).go();
  }

  /// Returns the count of pending pendingSyncItems.
  Future<int> pendingCount() async {
    final count = countAll();
    final query = selectOnly(pendingSyncItems)
      ..addColumns([count])
      ..where(pendingSyncItems.isSyncing.equals(false));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  PendingSyncEntry _toEntry(PendingSyncItem r) {
    return PendingSyncEntry(
      id: r.id,
      entityType: r.entityType,
      entityId: r.entityId,
      operation: r.operation,
      payload: r.payload,
      createdAt: r.createdAt,
      retryCount: r.retryCount,
      maxRetry: r.maxRetry,
    );
  }

  String _generateId() {
    return 'pending_${DateTime.now().microsecondsSinceEpoch}_${_counter++}';
  }

  int _counter = 0;
}
