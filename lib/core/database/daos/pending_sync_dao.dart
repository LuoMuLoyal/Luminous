import 'dart:math';

import 'package:drift/drift.dart';

import '../cache_constants.dart';
import '../database.dart';
import '../tables/pending_sync_queue.dart';

part 'pending_sync_dao.g.dart';

/// Exponential backoff for [retryCount]: [syncBackoffBase] * 2^retryCount,
/// capped at [syncBackoffMax].
Duration backoffForRetryCount(int retryCount) {
  final baseSeconds = syncBackoffBase.inSeconds;
  final maxSeconds = syncBackoffMax.inSeconds;
  final seconds = baseSeconds * (1 << retryCount);
  return Duration(seconds: seconds.clamp(0, maxSeconds));
}

/// Pending sync item with decoded fields for the SyncWorker.
class PendingSyncEntry {
  PendingSyncEntry({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.createdAt,
    required this.retryCount,
    required this.maxRetry,
    this.lastError,
  });
  final String id;
  final String entityType;
  final String? entityId;
  final String operation;
  final String payload;
  final DateTime createdAt;
  final int retryCount;
  final int maxRetry;
  final String? lastError;

  /// Whether this entry has exceeded the max retry count.
  bool get isPermanentlyFailed => retryCount >= maxRetry;

  /// The minimum delay before the next retry attempt.
  /// Exponential backoff: [syncBackoffBase] * 2^retryCount,
  /// capped at [syncBackoffMax].
  Duration get backoffDelay => backoffForRetryCount(retryCount);
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
          return elapsed >= backoffForRetryCount(r.retryCount);
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

  /// Returns the count of permanently failed sync items
  /// (retryCount >= maxRetry).
  ///
  /// Used by [syncFailedCountProvider] to surface a warning in the Mine
  /// page when offline writes could not be synced after all retries.
  Future<int> permanentlyFailedCount() async {
    final count = countAll();
    final query = selectOnly(pendingSyncItems)
      ..addColumns([count])
      ..where(
        pendingSyncItems.retryCount.isBiggerOrEqual(pendingSyncItems.maxRetry),
      );
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Returns permanently failed items for the user-facing sync details view.
  Future<List<PendingSyncEntry>> fetchPermanentlyFailed() async {
    final query = select(pendingSyncItems)
      ..where((t) => t.retryCount.isBiggerOrEqual(t.maxRetry))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);

    final rows = await query.get();
    return rows.map(_toEntry).toList();
  }

  /// Resets a permanently failed item so [SyncWorker.flush] can retry it.
  Future<void> resetForRetry(String id) async {
    await (update(pendingSyncItems)..where((t) => t.id.equals(id))).write(
      const PendingSyncItemsCompanion(
        retryCount: Value(0),
        lastAttemptAt: Value(null),
        isSyncing: Value(false),
        lastError: Value(null),
      ),
    );
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
      lastError: r.lastError,
    );
  }

  String _generateId() {
    // Cryptographically random suffix — unlike a static counter it survives
    // hot restart and is unique across isolates, so the id cannot collide
    // with rows already persisted in the database.
    return 'pending_${DateTime.now().microsecondsSinceEpoch}_'
        '${_secureRandom.nextInt(1 << 32)}';
  }

  static final Random _secureRandom = Random.secure();
}
