import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/network/config/pref_keys.dart';
import 'package:luminous/core/storage/kv_store.dart';
import 'package:luminous/core/theme/family.dart';
import 'package:material_ui/material_ui.dart';

class ThemePreference {
  const ThemePreference({
    this.mode = AppThemeModePreference.system,
    this.family = appDefaultThemeFamily,
  });

  final AppThemeModePreference mode;
  final AppThemeFamily family;

  ThemePreference copyWith({
    AppThemeModePreference? mode,
    AppThemeFamily? family,
  }) {
    return ThemePreference(
      mode: mode ?? this.mode,
      family: family ?? this.family,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemePreference &&
          runtimeType == other.runtimeType &&
          mode == other.mode &&
          family == other.family;

  @override
  int get hashCode => Object.hash(mode, family);
}

enum AppThemeModePreference {
  system('system'),
  light('light'),
  dark('dark');

  const AppThemeModePreference(this.storageValue);

  final String storageValue;

  ThemeMode get themeMode => switch (this) {
    AppThemeModePreference.system => ThemeMode.system,
    AppThemeModePreference.light => ThemeMode.light,
    AppThemeModePreference.dark => ThemeMode.dark,
  };

  static AppThemeModePreference fromStorage(String? value) {
    for (final preference in AppThemeModePreference.values) {
      if (preference.storageValue == value) {
        return preference;
      }
    }
    return AppThemeModePreference.system;
  }
}

class ThemeController extends AsyncNotifier<ThemePreference> {
  static const _modeStorageKey = PrefKeys.themeMode;
  static const _familyStorageKey = PrefKeys.themeFamily;

  KvStore get _store => KvStore.instance;

  @override
  Future<ThemePreference> build() async {
    return ThemePreference(
      mode: AppThemeModePreference.fromStorage(
        _store.getOrNull<String>(_modeStorageKey),
      ),
      family: AppThemeFamily.fromStorage(
        _store.getOrNull<String>(_familyStorageKey),
      ),
    );
  }

  Future<void> setMode(AppThemeModePreference preference) async {
    state = AsyncData(_currentPreference.copyWith(mode: preference));
    await _store.set(_modeStorageKey, preference.storageValue);
  }

  Future<void> setFamily(AppThemeFamily family) async {
    state = AsyncData(_currentPreference.copyWith(family: family));
    await _store.set(_familyStorageKey, family.storageValue);
  }

  ThemePreference get _currentPreference =>
      state.asData?.value ?? const ThemePreference();
}

final themeControllerProvider =
    AsyncNotifierProvider<ThemeController, ThemePreference>(
      ThemeController.new,
    );
