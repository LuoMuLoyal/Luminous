import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/database/sync/background_entry.dart';
import 'package:workmanager/workmanager.dart';

/// Foreground-facing scheduling adapter for background sync.
abstract interface class BackgroundSyncScheduler {
  Future<void> schedule({
    Duration minimumInterval = kBackgroundSyncInterval,
    bool requiresNetwork = true,
  });

  Future<void> cancel();
}

/// Wires Workmanager to the app's background entry point.
///
/// Must run before `runApp` so Android can persist the callback handle and iOS
/// can restore BGTaskScheduler launch handlers.
Future<void> initializeBackgroundSync() async {
  if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;
  await Workmanager().initialize(backgroundCallbackDispatcher);
}

class WorkmanagerBackgroundSyncScheduler implements BackgroundSyncScheduler {
  const WorkmanagerBackgroundSyncScheduler();

  @override
  Future<void> schedule({
    Duration minimumInterval = kBackgroundSyncInterval,
    bool requiresNetwork = true,
  }) async {
    if (kIsWeb) return;
    final constraints = Constraints(
      networkType: requiresNetwork
          ? NetworkType.connected
          : NetworkType.notRequired,
    );

    if (Platform.isAndroid) {
      await Workmanager().registerPeriodicTask(
        kBackgroundSyncTaskId,
        kBackgroundSyncTaskId,
        frequency: minimumInterval,
        initialDelay: minimumInterval,
        constraints: constraints,
        existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      );
      return;
    }

    if (Platform.isIOS) {
      await Workmanager().registerProcessingTask(
        kBackgroundSyncTaskId,
        kBackgroundSyncTaskId,
        initialDelay: minimumInterval,
        constraints: constraints,
      );
    }
  }

  @override
  Future<void> cancel() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;
    await Workmanager().cancelByUniqueName(kBackgroundSyncTaskId);
  }
}

final backgroundSyncSchedulerProvider = Provider<BackgroundSyncScheduler>(
  (ref) => const WorkmanagerBackgroundSyncScheduler(),
);
