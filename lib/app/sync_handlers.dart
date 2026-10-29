import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/analytics/product_event_service.dart';
import 'package:luminous/core/database/sync/handlers.dart';
import 'package:luminous/app/composition/health_context/health_context.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_cached.dart';
import 'package:luminous/app/composition/record/record_access.dart';

/// Default registrar list baked into the app's root `ProviderContainer`.
///
/// `lib/core/database/sync/handlers.dart` cannot import features, so the
/// feature registrars are collected here, in the composition root, and handed
/// to core through [syncHandlerRegistrarsProvider].
///
/// The background isolate builds its own container from `lib/main.dart`'s
/// entry, so this list travels with the same override.
const List<SyncHandlerRegistrar> appSyncHandlerRegistrars = [
  _RecordSyncRegistrar(),
  _HealthContextSyncRegistrar(),
  _MedicineDoseLogSyncRegistrar(),
  _ProductEventSyncRegistrar(),
];

class _RecordSyncRegistrar implements SyncHandlerRegistrar {
  const _RecordSyncRegistrar();

  @override
  String get name => 'record';

  @override
  void register(ProviderContainer container) {
    container.read(dailyRecordRepositoryProvider);
  }
}

class _HealthContextSyncRegistrar implements SyncHandlerRegistrar {
  const _HealthContextSyncRegistrar();

  @override
  String get name => 'health_context';

  @override
  void register(ProviderContainer container) {
    container.read(healthContextRepositoryProvider);
  }
}

class _MedicineDoseLogSyncRegistrar implements SyncHandlerRegistrar {
  const _MedicineDoseLogSyncRegistrar();

  @override
  String get name => 'medicine_dose_log';

  @override
  void register(ProviderContainer container) {
    container.read(cachedDoseLogDataSourceProvider);
  }
}

class _ProductEventSyncRegistrar implements SyncHandlerRegistrar {
  const _ProductEventSyncRegistrar();

  @override
  String get name => 'product_event';

  @override
  void register(ProviderContainer container) {
    container.read(productEventServiceProvider);
  }
}
