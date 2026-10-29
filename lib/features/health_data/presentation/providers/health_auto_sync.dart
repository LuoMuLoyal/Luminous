import 'dart:async';
import 'package:luminous/core/network/config/pref_keys.dart';

import 'package:luminous/core/providers/storage/preferences_store.dart';
import 'package:luminous/features/health_data/presentation/providers/data_access.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'health_auto_sync.g.dart';

/// Why background health synchronization is or is not available.
enum HealthAutoSyncAvailability {
  /// The current device cannot expose a supported native health platform.
  unsupported,

  /// The native platform exists, but this app has no configured executor for
  /// running synchronization in the background.
  notConfigured,

  /// A platform and a background executor are both available.
  available,
}

/// Capability seam for the future background sync executor.
///
/// There is currently no executor registered in the app. Keeping this as a
/// provider makes that fact explicit and lets the capability be verified at
/// the same boundary when an executor is introduced.
@riverpod
bool healthAutoSyncExecutorConfigured(Ref ref) => false;

@riverpod
HealthAutoSyncAvailability healthAutoSyncAvailability(Ref ref) {
  final repository = ref.watch(healthSyncRepositoryProvider);
  if (!repository.isPlatformAvailable) {
    return HealthAutoSyncAvailability.unsupported;
  }
  if (!ref.watch(healthAutoSyncExecutorConfiguredProvider)) {
    return HealthAutoSyncAvailability.notConfigured;
  }
  return HealthAutoSyncAvailability.available;
}

/// Local preference for whether health data auto-sync is enabled.
///
/// When enabled, the app automatically syncs the last 24 hours of health
/// data from Apple Health / Health Connect when it enters the foreground.
///
/// This is a local-only preference stored in [SharedPreferences]; it is
/// not synced to the backend.
@Riverpod(keepAlive: true)
class HealthAutoSyncPreference extends _$HealthAutoSyncPreference {
  @override
  bool build() {
    if (ref.watch(healthAutoSyncAvailabilityProvider) !=
        HealthAutoSyncAvailability.available) {
      return false;
    }
    unawaited(_initFromPrefs());
    return false;
  }

  Future<void> _initFromPrefs() async {
    final prefs = KvStore.instance;
    state = prefs.get<bool>(PrefKeys.healthAutoSyncEnabled, fallback: false);
  }

  Future<void> toggle() async {
    if (ref.read(healthAutoSyncAvailabilityProvider) !=
        HealthAutoSyncAvailability.available) {
      return;
    }
    final prefs = KvStore.instance;
    final newValue = !state;
    await prefs.set(PrefKeys.healthAutoSyncEnabled, newValue);
    state = newValue;
  }
}
