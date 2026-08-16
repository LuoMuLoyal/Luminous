import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/utils/string_utils.dart';
import 'package:luminous/features/medicine/data/datasources/reminder_remote.dart';
import 'package:luminous/features/medicine/domain/entities/reminder_sound_preference.dart';

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
    required this.enableVibration,
    required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final bool playSound;
  final bool enableVibration;
  final String payload;
}

class MedicineReminderNotificationPlanner {
  const MedicineReminderNotificationPlanner({
    this.horizonDays = 7,
    this.maxNotifications = 60,
    int Function(String value)? hashValue,
    this._clock = const Clock(),
  }) : _hashValue = hashValue ?? _defaultFfnv1a32;

  static int _defaultFfnv1a32(String value) {
    // FNV-1a 32-bit hash: http://www.isthe.com/chongo/tech/comp/fnv/index.html
    // 0x811c9dc5 is the 32-bit FNV offset basis.
    // 0x01000193 is the 32-bit FNV prime.
    // 0xffffffff masks the result to 32 bits.
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
  final Clock _clock;

  List<PlannedNotification> plan({
    required List<MedicineReminderItem> reminders,
    required bool remindersEnabled,
    required MedicineReminderSoundPreference sound,
    required MedicineReminderNotificationTexts texts,
    DateTime? now,
    int advanceMinutes = 0,
    bool dndEnabled = false,
    int dndStartHour = 22,
    int dndStartMinute = 0,
    int dndEndHour = 7,
    int dndEndMinute = 0,
    bool enableVibration = true,
    bool soundEnabled = true,
  }) {
    if (!remindersEnabled || reminders.isEmpty) {
      return const <PlannedNotification>[];
    }

    final referenceNow = now ?? _clock.now();
    final startDate = DateTime(
      referenceNow.year,
      referenceNow.month,
      referenceNow.day,
    );
    final usedIds = <int>{};
    final playSound =
        soundEnabled && sound != MedicineReminderSoundPreference.silent;
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

        var scheduledAt = DateTime(
          date.year,
          date.month,
          date.day,
          reminder.scheduledHour,
          reminder.scheduledMinute,
        );

        // Apply advance reminder offset.
        if (advanceMinutes > 0) {
          scheduledAt = scheduledAt.subtract(Duration(minutes: advanceMinutes));
        }

        if (!scheduledAt.isAfter(referenceNow)) {
          continue;
        }

        // Skip notifications that fall within the DND window.
        if (dndEnabled &&
            _isInDndWindow(
              scheduledAt,
              dndStartHour,
              dndStartMinute,
              dndEndHour,
              dndEndMinute,
            )) {
          continue;
        }

        try {
          planned.add(
            PlannedNotification(
              id: _allocateNotificationId(reminder.id, scheduledAt, usedIds),
              title:
                  normalizeNullableText(reminder.label) ?? texts.defaultTitle,
              body: normalizeNullableText(reminder.note) ?? texts.defaultBody,
              scheduledAt: scheduledAt,
              playSound: playSound,
              enableVibration: enableVibration && playSound,
              payload: reminder.id,
            ),
          );
        } on StateError catch (e) {
          // 通知 ID 线性探测耗尽(极端饱和输入):跳过该条提醒并记录日志,
          // 返回已分配的通知,保证上层调度不会因单条异常而整体崩溃。
          appTalker.error('MedicineReminderNotificationPlanner: $e');
          continue;
        }
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
    // Android notification IDs must be positive 32-bit ints. Masking with
    // 0x7fffffff clears the sign bit while keeping 31 bits of hash entropy.
    var candidate =
        _hashValue('$reminderId@${_notificationMomentKey(scheduledAt)}') &
        0x7fffffff;
    if (candidate == 0) {
      candidate = 1;
    }

    // Linear probing over the 31-bit space practically never saturates;
    // the attempt cap only guards against degenerate inputs that would
    // otherwise loop forever.
    var attempts = 0;
    while (usedIds.contains(candidate)) {
      candidate = (candidate + 1) & 0x7fffffff;
      if (candidate == 0) {
        candidate = 1;
      }
      attempts += 1;
      if (attempts > _maxIdProbeAttempts) {
        throw StateError(
          'Unable to allocate a unique notification id after '
          '$_maxIdProbeAttempts probes (usedIds=${usedIds.length})',
        );
      }
    }

    usedIds.add(candidate);
    return candidate;
  }

  /// Upper bound on linear probing before giving up (see
  /// [_allocateNotificationId]).
  static const _maxIdProbeAttempts = 1000;

  /// Checks whether [scheduledAt] falls inside a DND window.
  ///
  /// The window may cross midnight, e.g. 22:00 → 07:00.
  bool _isInDndWindow(
    DateTime scheduledAt,
    int startHour,
    int startMinute,
    int endHour,
    int endMinute,
  ) {
    final startMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;
    final scheduledMinutes = scheduledAt.hour * 60 + scheduledAt.minute;

    if (startMinutes == endMinutes) {
      // Zero-length window — nothing is blocked.
      return false;
    }

    if (startMinutes < endMinutes) {
      // Same-day window, e.g. 14:00 → 18:00.
      return scheduledMinutes >= startMinutes && scheduledMinutes < endMinutes;
    }

    // Cross-midnight window, e.g. 22:00 → 07:00.
    return scheduledMinutes >= startMinutes || scheduledMinutes < endMinutes;
  }

  String _notificationMomentKey(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$year-$month-${day}T$hour:$minute';
  }
}
