import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/network/config/pref_keys.dart';
import 'package:luminous/core/network/i18n/app_locale.dart';
import 'package:luminous/core/storage/kv_store.dart';

export 'package:luminous/core/network/i18n/app_locale.dart';

class LocaleController extends AsyncNotifier<AppLocale> {
  static const _storageKey = PrefKeys.appLocale;

  @override
  Future<AppLocale> build() async {
    final preferences = KvStore.instance;
    return AppLocale.fromStorage(preferences.getOrNull<String>(_storageKey));
  }

  Future<void> setLocale(AppLocale locale) async {
    state = AsyncData(locale);
    final preferences = KvStore.instance;
    await preferences.set(_storageKey, locale.storageValue);
  }
}

final localeControllerProvider =
    AsyncNotifierProvider<LocaleController, AppLocale>(LocaleController.new);
