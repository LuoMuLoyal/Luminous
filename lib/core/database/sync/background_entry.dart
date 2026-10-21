import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/core/database/sync/handlers.dart';
import 'package:luminous/core/database/sync/worker.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:workmanager/workmanager.dart';

/// Identifier shared by Android WorkManager and iOS BGTaskScheduler.
const String kBackgroundSyncTaskId = 'com.devluo.luminous.sync';

/// Android enforces a 15-minute floor for periodic work; iOS treats this as
/// the earliest begin date for the next processing task.
const Duration kBackgroundSyncInterval = Duration(minutes: 15);

/// Workmanager entry point for the background sync isolate.
///
/// The platform starts this top-level function with a fresh engine. It builds a
/// minimal container, checks for a persisted session, registers the same replay
/// handlers as the foreground, and flushes the pending queue.
@pragma('vm:entry-point')
void backgroundCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();

    if (task != kBackgroundSyncTaskId &&
        task != Workmanager.iOSBackgroundTask) {
      return true;
    }

    final base = ProviderContainer();
    var hasSession = false;
    try {
      hasSession = await _hasSession(base);
      if (!hasSession) return true;

      final worker = _createWorker(base);
      final container = ProviderContainer(
        parent: base,
        overrides: [syncWorkerProvider.overrideWithValue(worker)],
      );
      try {
        return await runBackgroundSync(container);
      } finally {
        container.dispose();
      }
    } catch (e, stackTrace) {
      base
          .read(talkerProvider)
          .error('Background sync failed: $e\n$stackTrace');
      return false;
    } finally {
      base.dispose();
      await _scheduleNextRun(hasSession: hasSession);
    }
  });
}

/// Flushes the queue once. Returns whether the task should be considered
/// successful by the platform.
///
/// Kept separate from [backgroundCallbackDispatcher] so tests can drive it with
/// overridden providers and a no-op handler registration.
Future<bool> runBackgroundSync(
  ProviderContainer container, {
  void Function(ProviderContainer)? registerHandlers,
}) async {
  final refreshToken = await container
      .read(lucentSessionStoreProvider)
      .readRefreshToken();
  if (refreshToken == null || refreshToken.trim().isEmpty) return true;

  (registerHandlers ?? registerSyncHandlers)(container);
  final result = await container.read(syncWorkerProvider).flush();
  return !result.shouldRetry;
}

Future<bool> _hasSession(ProviderContainer container) async {
  final refreshToken = await container
      .read(lucentSessionStoreProvider)
      .readRefreshToken();
  return refreshToken != null && refreshToken.trim().isNotEmpty;
}

SyncWorker _createWorker(ProviderContainer container) {
  final database = container.read(appDatabaseProvider);
  return SyncWorker(
    pendingSyncDao: database.pendingSyncDao,
    dio: container.read(lucentDioClientProvider).dio,
    talker: container.read(talkerProvider),
  );
}

/// iOS processing tasks are one-shot: re-arm after every run. Android keeps its
/// periodic request and needs no rescheduling.
Future<void> _scheduleNextRun({required bool hasSession}) async {
  if (!Platform.isIOS) return;
  if (!hasSession) {
    await Workmanager().cancelByUniqueName(kBackgroundSyncTaskId);
    return;
  }
  await Workmanager().registerProcessingTask(
    kBackgroundSyncTaskId,
    kBackgroundSyncTaskId,
    initialDelay: kBackgroundSyncInterval,
    constraints: Constraints(networkType: NetworkType.connected),
  );
}
