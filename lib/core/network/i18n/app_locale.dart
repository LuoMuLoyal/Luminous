/// Locale value model shared with the `data/` layer.
///
/// Repositories that send an `Accept-Language` header or a `lang` query
/// parameter need the locale *value* (and how it maps to a wire tag), not the
/// locale *state*: the Riverpod `localeControllerProvider`, the `Locale`
/// resolution and the stored preference all stay in `core/i18n/locale.dart`.
///
/// `core/i18n/locale.dart` re-exports this file, so there is one definition.
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

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
