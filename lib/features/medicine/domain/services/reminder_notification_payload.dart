import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Payload attached to a scheduled local reminder notification.
///
/// Encodes the reminder's **logical scheduled moment** (`date` from the
/// planning loop and `reminder.scheduledHour/Minute`) — not the
/// advanceMinutes-shifted fire time and not the notification id — so the
/// server can derive a stable `scheduledFor` (truncated to the minute in the
/// user-profile timezone) for the delivery audit trail. The server treats
/// repeated receipts for the same `reminderId|date|time` as a no-op.
@immutable
class ReminderNotificationPayload {
  const ReminderNotificationPayload({
    required this.reminderId,
    required this.date,
    required this.time,
  });

  /// The reminder entity id (stable across reschedules).
  final String reminderId;

  /// The logical scheduled date in `YYYY-MM-DD` form.
  final String date;

  /// The logical scheduled time in `HH:mm` form.
  final String time;

  /// Serializes the payload to the JSON string stored as the notification
  /// payload.
  String encode() => jsonEncode(<String, Object?>{
    'reminderId': reminderId,
    'date': date,
    'time': time,
  });

  /// Parses a notification payload string, returning `null` when the value is
  /// not a valid reminder payload (empty, malformed JSON, missing fields, or
  /// non-conforming `date`/`time` values).
  static ReminderNotificationPayload? tryParse(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(value);
    } on FormatException {
      return null;
    }
    if (decoded is! Map) {
      return null;
    }
    final reminderId = decoded['reminderId'];
    final date = decoded['date'];
    final time = decoded['time'];
    if (reminderId is! String ||
        reminderId.isEmpty ||
        date is! String ||
        !_datePattern.hasMatch(date) ||
        time is! String ||
        !_timePattern.hasMatch(time)) {
      return null;
    }
    return ReminderNotificationPayload(
      reminderId: reminderId,
      date: date,
      time: time,
    );
  }

  static final RegExp _datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  /// Strict `HH:mm` — hours 00-23, minutes 00-59 — so malformed times never
  /// reach the server as a 400.
  static final RegExp _timePattern = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');
}
