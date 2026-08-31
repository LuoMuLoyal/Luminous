import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:luminous/core/database/models/pending_sync_error_details.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/core/network/contract/error_mapper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talker_flutter/talker_flutter.dart' as talker_pkg;

import '../connection_providers.dart';
import '../daos/pending_sync.dart';

part 'worker.g.dart';

/// Replays pending sync items when network connectivity is restored.
///
/// Listens to [Connectivity] stream and triggers [flush] when the device
/// goes from offline to online. Uses the main [Dio] instance to replay
/// queued write operations.
///
/// Each entity type's replay logic is delegated to a registered handler.
/// Handlers are simple async functions that take the raw payload and
/// perform the actual HTTP request.
class SyncWorker {
  SyncWorker({
    required this.pendingSyncDao,
    required this.dio,
    required this.talker,
    Map<String, SyncHandler> handlers = const {},
  }) : _handlers = Map.from(handlers);

  final PendingSyncDao pendingSyncDao;
  final Dio dio;
  final talker_pkg.Talker talker;
  final Map<String, SyncHandler> _handlers;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isFlushing = false;

  /// Registers a handler for an entity type.
  void registerHandler(String entityType, SyncHandler handler) {
    _handlers[entityType] = handler;
  }

  /// Starts listening to connectivity changes.
  Future<void> start() async {
    await _subscription?.cancel();
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection) {
        unawaited(flush());
      }
    });
  }

  /// Stops listening to connectivity changes.
  void stop() {
    unawaited(_subscription?.cancel());
    _subscription = null;
  }

  /// Attempts to replay all ready pending items.
  ///
  /// Called automatically on connectivity restore, or can be called
  /// manually (e.g. after a write operation).
  Future<void> flush() async {
    if (_isFlushing) return;
    _isFlushing = true;

    try {
      final ready = await pendingSyncDao.fetchReady();
      for (final entry in ready) {
        await _replayEntry(entry);
      }
    } catch (e) {
      talker.error('SyncWorker.flush: unexpected error: $e');
    } finally {
      _isFlushing = false;
    }
  }

  Future<void> _replayEntry(PendingSyncEntry entry) async {
    final handler = _handlers[entry.entityType];
    if (handler == null) {
      talker.warning(
        'SyncWorker: no handler for entityType="${entry.entityType}", '
        'skipping item ${entry.id}',
      );
      return;
    }

    await pendingSyncDao.markSyncing(entry.id);

    try {
      await handler(entry);
      await pendingSyncDao.remove(entry.id);
      talker.info('SyncWorker: synced ${entry.entityType} ${entry.id}');
    } on DioException catch (e) {
      final isPermanentlyFailed = entry.retryCount + 1 >= entry.maxRetry;
      final failure = LucentErrorMapper.fromObject(e);
      await pendingSyncDao.markFailed(
        entry.id,
        raw: e.toString(),
        details: PendingSyncErrorDetails.fromLucentFailure(
          failure,
          e.toString(),
        ),
      );
      if (isPermanentlyFailed) {
        talker.error(
          'SyncWorker: item ${entry.id} permanently failed after '
          '${entry.maxRetry} retries: $e',
        );
      } else {
        talker.warning(
          'SyncWorker: item ${entry.id} failed (retry '
          '${entry.retryCount + 1}/${entry.maxRetry}): $e',
        );
      }
    } catch (e) {
      final failure = LucentErrorMapper.fromObject(e);
      await pendingSyncDao.markFailed(
        entry.id,
        raw: e.toString(),
        details: PendingSyncErrorDetails.fromLucentFailure(
          failure,
          e.toString(),
        ),
      );
      talker.error('SyncWorker: item ${entry.id} unexpected error: $e');
    }
  }
}

/// Handler function type for replaying a pending sync item.
typedef SyncHandler = Future<void> Function(PendingSyncEntry entry);

/// Riverpod provider for [SyncWorker].
///
/// The worker is created lazily and starts listening to connectivity
/// changes. Handlers are registered for each entity type that supports
/// offline writes.
@Riverpod(keepAlive: true)
SyncWorker syncWorker(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final dio = ref.watch(lucentDioClientProvider).dio;
  final talker = ref.watch(talkerProvider);

  final worker = SyncWorker(
    pendingSyncDao: db.pendingSyncDao,
    dio: dio,
    talker: talker,
  );

  // Register handlers — initially empty; repositories register their
  // own handlers when they come online. This avoids circular dependencies.
  // See LucentDailyRecordRepository for an example of handler registration.

  // start() is async (awaits subscription cancellation before listening).
  // Fire-and-forget is safe here — the worker starts listening as soon as
  // the previous subscription (if any) is cancelled.
  unawaited(worker.start());
  ref.onDispose(worker.stop);

  return worker;
}

/// Exposes the count of permanently failed sync items.
///
/// When > 0, the Mine page shows a warning banner so the user knows some
/// offline writes could not be synced. The count is re-evaluated after
/// each [SyncWorker.flush] cycle.
@Riverpod(keepAlive: true)
Future<int> syncFailedCount(Ref ref) async {
  final dao = ref.watch(pendingSyncDaoProvider);
  return dao.permanentlyFailedCount();
}
