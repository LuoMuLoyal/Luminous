/// Locale-aware date/time formatting utilities.
///
/// All user-visible date/time strings should go through these helpers instead
/// of manual `padLeft`/string concatenation. They delegate to `intl.DateFormat`
/// so that locale-specific formatting (AM/PM, month names, etc.) is respected.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

/// Formats a time-only string (ISO-8601 or `HH:mm`) as a locale-aware time.
///
/// Returns an empty string if [isoOrTime] cannot be parsed.
String formatTimeOfDayLabel(String isoOrTime, Locale locale) {
  final dt = _parseFlexible(isoOrTime);
  if (dt == null) return '';
  return intl.DateFormat.Hm(locale.toLanguageTag()).format(dt.toLocal());
}

/// Formats a `TimeOfDay` as a locale-aware time string.
String formatTimeOfDay(TimeOfDay time, Locale locale) {
  final dt = DateTime(2000, 1, 1, time.hour, time.minute);
  return intl.DateFormat.Hm(locale.toLanguageTag()).format(dt);
}

/// Formats a [DateTime] as a locale-aware date (no time component).
///
/// e.g. "2026年7月18日" (zh) / "Jul 18, 2026" (en).
/// Returns an empty string if [value] is null.
String formatDateLabel(DateTime? value, Locale locale) {
  if (value == null) return '';
  return intl.DateFormat.yMMMd(locale.toLanguageTag()).format(value);
}

/// Formats a date-time string (ISO-8601) as a locale-aware date + time.
///
/// e.g. "2026-07-18T14:30:00Z" → "7月18日 14:30" (zh) / "Jul 18, 14:30" (en).
/// Returns [fallback] (defaults to the raw input) if parsing fails.
String formatDateTimeLabel(String iso8601, Locale locale, {String? fallback}) {
  final dt = DateTime.tryParse(iso8601);
  if (dt == null) return fallback ?? iso8601;
  return intl.DateFormat.MMMd(
    locale.toLanguageTag(),
  ).add_Hm().format(dt.toLocal());
}

/// Formats a date-time string (ISO-8601) as a locale-aware full date + time.
///
/// Uses `yMd` + `Hm` pattern, e.g. "2026/7/18 14:30" (zh) /
/// "7/18/2026 14:30" (en).
/// Returns [fallback] (defaults to the raw input) if parsing fails.
String formatDateTimeFull(String iso8601, Locale locale, {String? fallback}) {
  final dt = DateTime.tryParse(iso8601)?.toLocal();
  if (dt == null) return fallback ?? iso8601;
  return intl.DateFormat.yMd(locale.toLanguageTag()).add_Hm().format(dt);
}

/// Formats a date-time string (ISO-8601) as a locale-aware time if the date
/// is today, otherwise as a locale-aware short date.
///
/// Useful for list items where today's entries show only the time and older
/// entries show the date.
String formatRelativeTimeLabel(String iso8601, Locale locale) {
  final dt = DateTime.tryParse(iso8601);
  if (dt == null) return '';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(dt.year, dt.month, dt.day);
  if (date == today) {
    return intl.DateFormat.Hm(locale.toLanguageTag()).format(dt.toLocal());
  }
  return intl.DateFormat.Md(locale.toLanguageTag()).format(dt.toLocal());
}

DateTime? _parseFlexible(String value) {
  if (value.isEmpty) return null;
  // Try full ISO-8601 first.
  final dt = DateTime.tryParse(value);
  if (dt != null) return dt;
  // Try `HH:mm`.
  final parts = value.split(':');
  if (parts.length == 2) {
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour != null && minute != null) {
      return DateTime(2000, 1, 1, hour, minute);
    }
  }
  return null;
}
