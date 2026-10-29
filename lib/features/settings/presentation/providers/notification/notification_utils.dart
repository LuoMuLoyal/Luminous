import 'package:flutter/material.dart';

/// Utility functions for notification time handling.
///
/// These are extracted from [NotificationSettingsController] to keep the
/// controller focused on business logic.
class NotificationUtils {
  NotificationUtils._();

  /// Formats a [TimeOfDay] to a 24-hour string "HH:mm".
  static String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Converts a [TimeOfDay] to minutes since midnight.
  /// Returns `null` if the input is `null`.
  static int? toMinutes(TimeOfDay? time) =>
      time == null ? null : time.hour * 60 + time.minute;

  /// Converts minutes since midnight to a [TimeOfDay].
  /// Returns `null` if the input is `null` or out of range [0, 1439].
  static TimeOfDay? fromMinutes(int? minutes) {
    if (minutes == null || minutes < 0 || minutes > 1439) return null;
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }

  /// Parses a time string "HH:mm" to a [TimeOfDay].
  /// Returns `null` if the input is `null`, empty, or malformed.
  static TimeOfDay? parseTime(String? value) {
    if (value == null || value.isEmpty) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }
}
