import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/analytics/product_event_service.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_cached.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';

/// Registers every pending-sync replay handler on [container].
///
/// The foreground app registers handlers lazily as feature providers are read.
/// The background isolate has no widget tree, so it calls this once to build the
/// same handler set before flushing. All handlers target the `SyncWorker`
/// supplied by the container (the background entry overrides
/// `syncWorkerProvider` so no connectivity listener starts).
void registerSyncHandlers(ProviderContainer container) {
  container.read(dailyRecordRepositoryProvider);
  container.read(healthContextRepositoryProvider);
  container.read(cachedDoseLogDataSourceProvider);
  container.read(productEventServiceProvider);
}
