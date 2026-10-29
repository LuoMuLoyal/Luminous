/// Locale-neutral `HH:mm` formatting.
///
/// Kept free of any `package:flutter` dependency so that non-UI layers
/// (`application/`, `domain/`) can format a wall-clock value without pulling
/// the framework in. User-visible, locale-aware formatting lives in
/// `core/utils/date_format.dart` instead.
library;

/// Formats an hour/minute pair as zero-padded `HH:mm`.
///
/// Out-of-range values are clamped to 0–23 / 0–59 rather than rejected: this
/// is used on already-validated wall-clock values (time-of-day pickers,
/// minute-of-day fields), where a throw would be worse than a clamped label.
String formatHourMinuteOfDay(int hour, int minute) {
  final h = hour < 0 ? 0 : (hour > 23 ? 23 : hour);
  final m = minute < 0 ? 0 : (minute > 59 ? 59 : minute);
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}

/// Formats the time-of-day part of [value] as zero-padded `HH:mm`.
String formatClockHourMinute(DateTime value) =>
    formatHourMinuteOfDay(value.hour, value.minute);

/// Formats [date]'s calendar day as the zero-padded `yyyy-MM-dd` wire key used
/// by the daily-record API.
///
/// Passes the value through as-is (no timezone shift); callers holding a
/// user-timezone moment should resolve it first.
String formatCalendarDateKey(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

/// Splits a `HH:mm` value into its hour/minute parts, returning `null` for
/// anything that is not a valid 24-hour wall-clock string.
({int hour, int minute})? parseHourMinuteOfDay(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  final parts = trimmed.split(':');
  if (parts.length != 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
  return (hour: hour, minute: minute);
}
