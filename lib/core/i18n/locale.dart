import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/config/pref_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLocale {
  system('system'),
  en('en'),
  zhCn('zh-CN');

  const AppLocale(this.storageValue);

  final String storageValue;

  Locale? get flutterLocale => switch (this) {
    AppLocale.system => null,
    AppLocale.en => const Locale('en'),
    AppLocale.zhCn => const Locale('zh'),
  };

  String get acceptLanguage {
    return switch (this) {
      AppLocale.system => fromFlutterLocale(
        ui.PlatformDispatcher.instance.locale,
      ).acceptLanguage,
      AppLocale.en => 'en',
      AppLocale.zhCn => 'zh-CN',
    };
  }

  static AppLocale fromStorage(String? value) {
    for (final locale in AppLocale.values) {
      if (locale.storageValue == value) {
        return locale;
      }
    }
    return AppLocale.system;
  }

  static AppLocale? fromBackendPreference(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return AppLocale.system;
    }

    final lower = normalized.toLowerCase();
    if (lower.startsWith('zh')) {
      return AppLocale.zhCn;
    }
    if (lower.startsWith('en')) {
      return AppLocale.en;
    }
    return null;
  }

  static AppLocale fromFlutterLocale(Locale locale) {
    return switch (locale.languageCode) {
      'zh' => AppLocale.zhCn,
      _ => AppLocale.en,
    };
  }
}

class LocaleController extends AsyncNotifier<AppLocale> {
  static const _storageKey = PrefKeys.appLocale;

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

final localeControllerProvider =
    AsyncNotifierProvider<LocaleController, AppLocale>(LocaleController.new);
