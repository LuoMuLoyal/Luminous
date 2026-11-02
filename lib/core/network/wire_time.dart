/// Wire-format ISO-8601 parsers used when mapping server payloads to entities.
///
/// The `data/` layer may not import `core/utils/date_format.dart` (it also
/// carries locale-aware *label* formatting for the UI). Parsing a server value
/// is a wire concern: a malformed timestamp must never throw, it must fall
/// back. This file holds exactly that half, and `core/utils/date_format.dart`
/// re-exports it so there is a single implementation.
library;

/// Parses [value] (an ISO-8601 date-time string) safely.
///
/// Returns `null` when [value] is null, empty, or not a valid ISO-8601
/// string — never throws.
DateTime? parseDateTimeOrNull(Object? value) {
  final raw = value?.toString();
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}

/// Parses [value] as an ISO-8601 date-time string, falling back to
/// [fallback] (epoch by default) instead of throwing on malformed input.
///
/// Use for fields the entity requires to be non-null where a broken server
/// value must not crash the app.
DateTime parseDateTimeOrEpoch(Object? value, {DateTime? fallback}) {
  return parseDateTimeOrNull(value) ??
      fallback ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

/// Formats [value] as the `yyyy-MM-dd` day key day-scoped endpoints expect.
///
/// Uses the device-local date (`toLocal`) because those endpoints mean "the
/// user's day", not a UTC day.
String formatWireDateKey(DateTime date) {
  final local = date.toLocal();
  final year = local.year.toString().padLeft(4, '0');
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
