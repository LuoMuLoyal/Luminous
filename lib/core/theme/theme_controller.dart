import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemePreference {
  const AppThemePreference({
    this.mode = AppThemeModePreference.system,
    this.family = appDefaultThemeFamily,
  });

  final AppThemeModePreference mode;
  final AppThemeFamily family;

  AppThemePreference copyWith({
    AppThemeModePreference? mode,
    AppThemeFamily? family,
  }) {
    return AppThemePreference(
      mode: mode ?? this.mode,
      family: family ?? this.family,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppThemePreference &&
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

class AppThemeController extends AsyncNotifier<AppThemePreference> {
  static const _modeStorageKey = 'theme.mode';
  static const _familyStorageKey = 'theme.family';

  @override
  Future<AppThemePreference> build() async {
    final preferences = await SharedPreferences.getInstance();
    return AppThemePreference(
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

  AppThemePreference get _currentPreference =>
      state.asData?.value ?? const AppThemePreference();
}

final appThemeControllerProvider =
    AsyncNotifierProvider<AppThemeController, AppThemePreference>(
      AppThemeController.new,
    );
