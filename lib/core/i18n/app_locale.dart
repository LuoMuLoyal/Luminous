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

  static AppLocale fromFlutterLocale(Locale locale) {
    return switch (locale.languageCode) {
      'zh' => AppLocale.zhCn,
      _ => AppLocale.en,
    };
  }
}
