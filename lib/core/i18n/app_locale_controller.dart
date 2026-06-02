import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/i18n/app_locale.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocaleController extends AsyncNotifier<AppLocale> {
  static const _storageKey = 'app.locale';

  @override
  Future<AppLocale> build() async {
    final preferences = await SharedPreferences.getInstance();
    return AppLocale.fromStorage(preferences.getString(_storageKey));
  }

  Future<void> setLocale(AppLocale locale) async {
    state = AsyncData(locale);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, locale.storageValue);
  }
}

final appLocaleControllerProvider =
    AsyncNotifierProvider<AppLocaleController, AppLocale>(
      AppLocaleController.new,
    );
