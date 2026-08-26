import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/config/pref_keys.dart';
import 'package:luminous/core/theme/theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  Future<ThemePreference> build() async {
    final preferences = await SharedPreferences.getInstance();
    return ThemePreference(
      mode: AppThemeModePreference.fromStorage(
        preferences.getString(_modeStorageKey),
      ),
      family: AppThemeFamily.fromStorage(
        preferences.getString(_familyStorageKey),
      ),
    );
  }

  Future<void> setMode(AppThemeModePreference preference) async {
    state = AsyncData(_currentPreference.copyWith(mode: preference));
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_modeStorageKey, preference.storageValue);
  }

  Future<void> setFamily(AppThemeFamily family) async {
    state = AsyncData(_currentPreference.copyWith(family: family));
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_familyStorageKey, family.storageValue);
  }

  ThemePreference get _currentPreference =>
      state.asData?.value ?? const ThemePreference();
}

final themeControllerProvider =
    AsyncNotifierProvider<ThemeController, ThemePreference>(
      ThemeController.new,
    );
