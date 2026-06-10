import 'package:flutter/foundation.dart';
import 'package:luminous/features/medicine/data/datasources/medicine_reminder_remote_data_source.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_reminder_sound_preference.dart';

@immutable
class MedicineReminderNotificationTexts {
  const MedicineReminderNotificationTexts({
    required this.defaultTitle,
    required this.defaultBody,
    required this.channelName,
    required this.channelDescription,
  });

  final String defaultTitle;
  final String defaultBody;
  final String channelName;
  final String channelDescription;
}

@immutable
class PlannedNotification {
  const PlannedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.playSound,
    required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final bool playSound;
  final String payload;
}

class MedicineReminderNotificationPlanner {
  const MedicineReminderNotificationPlanner({
    this.horizonDays = 7,
    this.maxNotifications = 60,
    int Function(String value)? hashValue,
  }) : _hashValue = hashValue ?? _defaultFfnv1a32;

  static int _defaultFfnv1a32(String value) {
    var hash = 0x811c9dc5;
    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash;
  }

  final int horizonDays;
  final int maxNotifications;
  final int Function(String value) _hashValue;

  List<PlannedNotification> plan({
    required List<MedicineReminderItem> reminders,
    required bool remindersEnabled,
    required MedicineReminderSoundPreference sound,
    required MedicineReminderNotificationTexts texts,
    DateTime? now,
  }) {
    if (!remindersEnabled || reminders.isEmpty) {
      return const <PlannedNotification>[];
    }

    final referenceNow = now ?? DateTime.now();
    final startDate = DateTime(
      referenceNow.year,
      referenceNow.month,
      referenceNow.day,
    );
    final usedIds = <int>{};
    final playSound = sound != MedicineReminderSoundPreference.silent;
    final planned = <PlannedNotification>[];

    for (var dayOffset = 0; dayOffset < horizonDays; dayOffset += 1) {
      final date = DateTime(
        startDate.year,
        startDate.month,
        startDate.day + dayOffset,
      );

      for (final reminder in reminders) {
        if (!reminder.isActive || !reminder.matchesDate(date)) {
          continue;
        }

        final scheduledAt = DateTime(
          date.year,
          date.month,
          date.day,
          reminder.scheduledHour,
          reminder.scheduledMinute,
        );
        if (!scheduledAt.isAfter(referenceNow)) {
          continue;
        }

        final notificationId = _allocateNotificationId(
          reminder.id,
          scheduledAt,
          usedIds,
        );
        planned.add(
          PlannedNotification(
            id: notificationId,
            title: _nonEmptyOrNull(reminder.label) ?? texts.defaultTitle,
            body: _nonEmptyOrNull(reminder.note) ?? texts.defaultBody,
            scheduledAt: scheduledAt,
            playSound: playSound,
            payload: reminder.id,
          ),
        );
      }
    }

    planned.sort((left, right) {
      final scheduledAt = left.scheduledAt.compareTo(right.scheduledAt);
      if (scheduledAt != 0) {
        return scheduledAt;
      }
      return left.id.compareTo(right.id);
    });

    if (planned.length <= maxNotifications) {
      return planned.toList(growable: false);
    }
    return planned.take(maxNotifications).toList(growable: false);
  }

  int _allocateNotificationId(
    String reminderId,
    DateTime scheduledAt,
    Set<int> usedIds,
  ) {
    var candidate =
        _hashValue('$reminderId@${_notificationMomentKey(scheduledAt)}') &
        0x7fffffff;
    if (candidate == 0) {
      candidate = 1;
    }

    while (usedIds.contains(candidate)) {
      candidate = (candidate + 1) & 0x7fffffff;
      if (candidate == 0) {
        candidate = 1;
      }
    }

    usedIds.add(candidate);
    return candidate;
  }

  String _notificationMomentKey(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$year-$month-${day}T$hour:$minute';
  }

  String? _nonEmptyOrNull(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}
