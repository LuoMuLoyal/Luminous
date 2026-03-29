import 'dart:ui';

import 'package:get/get.dart';
import 'package:luminous/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLocalePreference {
  system,
  zh,
  en;

  static AppLocalePreference fromStorage(String? value) {
    return AppLocalePreference.values.firstWhere(
      (item) => item.name == value,
      orElse: () => AppLocalePreference.system,
    );
  }
}

class LocaleController extends GetxController {
  final Rx<AppLocalePreference> localePreference =
      AppLocalePreference.system.obs;

  Future<SharedPreferences>? _prefsFuture;

  Future<SharedPreferences> get _prefs async {
    return _prefsFuture ??= SharedPreferences.getInstance();
  }

  Future<void> init() async {
    final prefs = await _prefs;
    final stored = prefs.getString(GlobalConstants.LOCALE_KEY);
    localePreference.value = AppLocalePreference.fromStorage(stored);
  }

  Locale? get locale {
    switch (localePreference.value) {
      case AppLocalePreference.system:
        return null;
      case AppLocalePreference.zh:
        return const Locale('zh');
      case AppLocalePreference.en:
        return const Locale('en');
    }
  }

  Future<void> setLocalePreference(AppLocalePreference preference) async {
    if (localePreference.value == preference) {
      return;
    }
    localePreference.value = preference;
    final prefs = await _prefs;
    await prefs.setString(GlobalConstants.LOCALE_KEY, preference.name);
  }
}
