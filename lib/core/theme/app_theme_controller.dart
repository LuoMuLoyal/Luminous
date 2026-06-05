import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

enum AppThemePalettePreference {
  classic('classic'),
  bluePink('blue-pink'),
  yellowGreen('yellow-green');

  const AppThemePalettePreference(this.storageValue);

  final String storageValue;

  static AppThemePalettePreference fromStorage(String? value) {
    for (final preference in AppThemePalettePreference.values) {
      if (preference.storageValue == value) {
        return preference;
      }
    }
    return AppThemePalettePreference.classic;
  }
}

class AppThemeController extends AsyncNotifier<AppThemeModePreference> {
  static const _storageKey = 'theme.mode';

  @override
  Future<AppThemeModePreference> build() async {
    final preferences = await SharedPreferences.getInstance();
    return AppThemeModePreference.fromStorage(
      preferences.getString(_storageKey),
    );
  }

  Future<void> setMode(AppThemeModePreference preference) async {
    state = AsyncData(preference);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, preference.storageValue);
  }
}

final appThemeControllerProvider =
    AsyncNotifierProvider<AppThemeController, AppThemeModePreference>(
      AppThemeController.new,
    );

class AppThemePaletteController
    extends AsyncNotifier<AppThemePalettePreference> {
  static const _storageKey = 'theme.palette';

  @override
  Future<AppThemePalettePreference> build() async {
    final preferences = await SharedPreferences.getInstance();
    return AppThemePalettePreference.fromStorage(
      preferences.getString(_storageKey),
    );
  }

  Future<void> setPalette(AppThemePalettePreference preference) async {
    state = AsyncData(preference);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, preference.storageValue);
  }
}

final appThemePaletteControllerProvider =
    AsyncNotifierProvider<AppThemePaletteController, AppThemePalettePreference>(
      AppThemePaletteController.new,
    );
