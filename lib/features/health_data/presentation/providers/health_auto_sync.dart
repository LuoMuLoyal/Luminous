import 'dart:async';

import 'package:luminous/core/config/pref_keys.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'health_auto_sync.g.dart';

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
    unawaited(_initFromPrefs());
    return false;
  }

  Future<void> _initFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(PrefKeys.healthAutoSyncEnabled) ?? false;
  }

  Future<void> toggle() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !state;
    await prefs.setBool(PrefKeys.healthAutoSyncEnabled, newValue);
    state = newValue;
  }
}
