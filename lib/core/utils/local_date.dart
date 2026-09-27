/// User-timezone-aware local date helpers.
///
/// Health-event check-ins and daily-record lookups must use the date in the
/// user's profile timezone (matching the backend's "today" semantics) instead
/// of the device-local date. This file holds the pure formatting half —
/// resolving the IANA timezone from the health context snapshot is derived
/// state and lives with its feature in
/// `features/today/presentation/providers/user_timezone.dart`, so that `core`
/// stays free of feature imports.
library;

import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

/// Formats [date] as a `yyyy-MM-dd` key in [timeZoneName].
///
/// Falls back to `Asia/Shanghai` (the backend's default timezone) when
/// [timeZoneName] is null or empty, and to the backend default offset when the
/// bundled timezone data is unavailable — never throws.
String localDateKey(DateTime date, {String? timeZoneName}) {
  const fallbackTimeZoneName = 'Asia/Shanghai';
  DateTime value;
  try {
    timezone_data.initializeTimeZones();
    value = timezone.TZDateTime.from(
      date.toUtc(),
      timezone.getLocation(
        timeZoneName == null || timeZoneName.isEmpty
            ? fallbackTimeZoneName
            : timeZoneName,
      ),
    );
  } catch (_) {
    // Keep the backend's default timezone when the bundled timezone data is
    // unavailable, rather than using a potentially different device date.
    value = date.toUtc().add(const Duration(hours: 8));
  }
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
