/// User-timezone-aware local date helpers shared by the today and report
/// features.
///
/// Health-event check-ins and daily-record lookups must use the date in the
/// user's profile timezone (matching the backend's "today" semantics) instead
/// of the device-local date, so both features resolve the IANA timezone from
/// the health context snapshot and format the same `yyyy-MM-dd` key.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

/// Reads the user's IANA timezone from the health context snapshot.
///
/// Returns `null` when the snapshot is unavailable (e.g. network failure), so
/// callers fall back to the backend's default timezone instead of crashing.
Future<String?> readUserTimezone(WidgetRef ref) async {
  final cached = ref.read(healthContextSnapshotProvider);
  if (cached.hasValue) return cached.value!.profile.timezone;
  try {
    return (await ref.read(
      healthContextSnapshotProvider.future,
    )).profile.timezone;
  } catch (_) {
    return null;
  }
}

/// Formats [date] as a `yyyy-MM-dd` key in [timeZoneName].
///
/// Falls back to `Asia/Shanghai` (the backend's default timezone) when
/// [timeZoneName] is null or empty, and to the backend default offset when the
/// bundled timezone data is unavailable — never throws.
String localDateKey(DateTime date, {String? timeZoneName}) {
  const fallbackTimeZoneName = 'Asia/Shanghai';
  var value = date.toLocal();
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
