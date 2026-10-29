import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/features/medicine/domain/entities/reminder.dart';
import 'package:luminous/shared/domain/failure.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

part 'reminder_calendar.g.dart';

/// Adds a one-way copy of a reminder group to the device's system calendar.
///
/// The drift database stays the single source of truth: the calendar is a view
/// in the user's own ecosystem, and edits made there are not read back.
/// A future bidirectional sync would need conflict resolution and is a separate
/// design effort.
abstract interface class ReminderCalendarWriter {
  /// Returns `true` when the event was saved.
  ///
  /// Returns `false` when the user dismissed the calendar sheet, denied
  /// permission, or no calendar app handled the request. Throws
  /// [LucentFailure] when the platform channel itself failed.
  Future<bool> addEvent(Event event);
}

/// [ReminderCalendarWriter] backed by the `add_2_calendar` plugin.
///
/// On Android the plugin fires `Intent.ACTION_INSERT`, so the calendar app
/// itself writes the row and **no `WRITE_CALENDAR` permission is required**.
/// On iOS it presents `EKEventEditViewController`; on iOS <17 that path calls
/// `requestAccess`, which needs `NSCalendarsUsageDescription` in `Info.plist`.
final class PlatformReminderCalendarWriter implements ReminderCalendarWriter {
  const PlatformReminderCalendarWriter();

  @override
  Future<bool> addEvent(Event event) => Add2Calendar.addEvent2Cal(event);
}

@Riverpod(keepAlive: true)
ReminderCalendarWriter reminderCalendarWriter(Ref ref) {
  return const PlatformReminderCalendarWriter();
}

/// Builds the calendar event for [reminders] (all times of one reminder group).
///
/// Returns a [LucentFailure] when there is nothing usable to export.
Either<LucentFailure, Event> buildReminderCalendarEvent({
  required List<MedicineReminderItem> reminders,
  required String title,
  String? description,
  String? timeZoneName,
  DateTime? now,
}) {
  if (reminders.isEmpty) {
    return left(_calendarUnavailable());
  }

  final first = reminders.first;
  final location = _resolveLocation(timeZoneName);
  final today = _todayIn(location, now ?? DateTime.now());

  // Reminders are recurring (daysOfWeek) and bounded by startDate/endDate.
  // `add_2_calendar` takes one concrete occurrence plus an optional recurrence
  // rule, so anchor the occurrence on the first matching day at/after today.
  final startDate = _firstMatchingDate(
    reminders: reminders,
    from: today,
    location: location,
  );
  final endDate = startDate.add(const Duration(hours: 1));

  // Only set the recurrence end when the reminder group actually has one:
  // passing a null endDate keeps the series open-ended.
  final seriesEnd = _parseDateOnly(first.endDate);
  final recurrence = first.daysOfWeek == null || first.daysOfWeek!.isEmpty
      ? null
      : Recurrence(
          frequency: Frequency.weekly,
          interval: 1,
          endDate: seriesEnd == null
              ? null
              : timezone.TZDateTime(
                  location,
                  seriesEnd.year,
                  seriesEnd.month,
                  seriesEnd.day,
                ),
        );

  return right(
    Event(
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      timeZone: location.name,
      recurrence: recurrence,
      iosParams: const IOSParams(reminder: Duration(minutes: 10)),
    ),
  );
}

/// Resolves the IANA timezone, falling back to the backend's default.
///
/// Mirrors `core/utils/local_date.dart`: the reminder's wall-clock hour must be
/// interpreted in the user's profile timezone, not the device's.
timezone.Location _resolveLocation(String? timeZoneName) {
  try {
    timezone_data.initializeTimeZones();
    return timezone.getLocation(
      timeZoneName == null || timeZoneName.isEmpty
          ? 'Asia/Shanghai'
          : timeZoneName,
    );
  } catch (_) {
    timezone_data.initializeTimeZones();
    return timezone.getLocation('Asia/Shanghai');
  }
}

timezone.TZDateTime _todayIn(timezone.Location location, DateTime now) {
  final local = timezone.TZDateTime.from(now.toUtc(), location);
  return timezone.TZDateTime(location, local.year, local.month, local.day);
}

/// First date at/after [from] whose weekday is in `daysOfWeek`, at the
/// reminder's scheduled time. Falls back to [from] at the scheduled time when
/// the group has no weekday filter (i.e. it fires every day).
timezone.TZDateTime _firstMatchingDate({
  required List<MedicineReminderItem> reminders,
  required timezone.TZDateTime from,
  required timezone.Location location,
}) {
  final first = reminders.first;
  final days = first.daysOfWeek;
  final hour = first.scheduledHour;
  final minute = first.scheduledMinute;

  timezone.TZDateTime atDay(DateTime day) =>
      timezone.TZDateTime(location, day.year, day.month, day.day, hour, minute);

  if (days == null || days.isEmpty) return atDay(from);

  // `daysOfWeek` uses Dart's Sunday=0 convention (`date.weekday % 7`), matching
  // `MedicineReminderItem.matchesDate`.
  for (var offset = 0; offset < 7; offset++) {
    final candidate = from.add(Duration(days: offset));
    if (days.contains(candidate.weekday % 7)) return atDay(candidate);
  }
  return atDay(from);
}

DateTime? _parseDateOnly(String? value) {
  if (value == null || value.isEmpty) return null;
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return null;
  return DateTime(parsed.year, parsed.month, parsed.day);
}

LucentFailure _calendarUnavailable() {
  return LucentFailure.client(
    clientErrorCode: ClientErrorCode.reminderCalendarUnavailable,
    message: 'Reminder calendar export has no usable occurrence.',
  );
}

/// Maps a calendar write outcome to a failure, or `null` on success.
///
/// `false` from the plugin means "the user dismissed the sheet, denied
/// permission, or no calendar app handled the intent" — all of which are a
/// refusal, not a success, so they surface as
/// [ClientErrorCode.reminderCalendarWriteFailed] rather than being swallowed.
LucentFailure? calendarWriteFailure(bool saved) {
  if (saved) return null;
  return LucentFailure.client(
    clientErrorCode: ClientErrorCode.reminderCalendarWriteFailed,
    message: 'System calendar did not accept the reminder event.',
  );
}
