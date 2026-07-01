import 'package:flutter/material.dart';

String speechLocaleIdForAppLocale(Locale locale) {
  return locale.languageCode == 'zh' ? 'zh_CN' : 'en_US';
}

String? resolveSpeechLocaleId(Locale locale, Iterable<String> availableIds) {
  final preferred = speechLocaleIdForAppLocale(locale);
  final normalizedAvailable = <String, String>{
    for (final id in availableIds) _normalizeLocaleId(id): id,
  };

  final exact = normalizedAvailable[_normalizeLocaleId(preferred)];
  if (exact != null) {
    return exact;
  }

  final languageCode = preferred.split(RegExp('[-_]')).first.toLowerCase();
  for (final entry in normalizedAvailable.entries) {
    final parts = entry.key.split('_');
    if (parts.isNotEmpty && parts.first == languageCode) {
      return entry.value;
    }
  }
  return null;
}

String _normalizeLocaleId(String localeId) {
  return localeId.trim().replaceAll('-', '_').toLowerCase();
}
