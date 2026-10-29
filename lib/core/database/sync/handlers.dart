import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Registers the pending-sync replay handlers owned by one feature slice.
///
/// `lib/core/database/sync` used to read `features/medicine`, `features/record`
/// and `features/health_context` providers directly, which violates
/// `core_not_import_features`. Each feature now contributes a registrar that
/// the composition root (`lib/app/sync_handlers.dart`) collects and applies;
/// core only knows the contract.
///
/// A registrar is expected to be side-effect free beyond warming the handlers:
/// it reads the feature's sync-aware providers so their replay handlers are
/// registered on the shared `SyncWorker`.
abstract interface class SyncHandlerRegistrar {
  /// Stable identifier, used for logging when a registrar throws.
  String get name;

  /// Registers replay handlers on [container].
  void register(ProviderContainer container);
}

/// Composition-root seam: overridden in `ProviderScope` with the ordered list
/// of feature registrars.
final syncHandlerRegistrarsProvider = Provider<List<SyncHandlerRegistrar>>(
  (ref) => const <SyncHandlerRegistrar>[],
);

/// Registers every pending-sync replay handler on [container].
///
/// The foreground app registers handlers lazily as feature providers are read.
/// The background isolate has no widget tree, so it calls this once to build the
/// same handler set before flushing. All handlers target the `SyncWorker`
/// supplied by the container (the background entry overrides
/// `syncWorkerProvider` so no connectivity listener starts).
void registerSyncHandlers(ProviderContainer container) {
  for (final registrar in container.read(syncHandlerRegistrarsProvider)) {
    registrar.register(container);
  }
}
