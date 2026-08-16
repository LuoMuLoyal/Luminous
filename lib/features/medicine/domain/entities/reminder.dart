/// Write input for creating or updating a medicine reminder.
class MedicineReminderWriteInput {
  const MedicineReminderWriteInput({
    this.currentMedicineId,
    this.label,
    required this.scheduledHour,
    required this.scheduledMinute,
    this.daysOfWeek,
    this.startDate,
    this.endDate,
    this.isActive = true,
    this.note,
  });

  final String? currentMedicineId;
  final String? label;
  final int scheduledHour;
  final int scheduledMinute;
  final List<int>? daysOfWeek;
  final String? startDate;
  final String? endDate;
  final bool isActive;
  final String? note;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'currentMedicineId': currentMedicineId,
      'label': label,
      'scheduledHour': scheduledHour,
      'scheduledMinute': scheduledMinute,
      'daysOfWeek': daysOfWeek,
      'startDate': startDate,
      'endDate': endDate,
      'isActive': isActive,
      'note': note,
    };
  }
}

/// Write input for a single slot inside a whole-group reminder upsert.
class MedicineReminderSlotUpsertInput {
  const MedicineReminderSlotUpsertInput({
    this.id,
    required this.scheduledHour,
    required this.scheduledMinute,
  });

  final String? id;
  final int scheduledHour;
  final int scheduledMinute;
}

/// Write input for upserting a whole medicine reminder group in a single
/// transaction. Slots carrying an [id] are updated, slots without one are
/// created, and existing group slots missing from [slots] are soft-deleted
/// server-side. Serialization happens in the datasource, which maps this
/// input onto the generated `UpsertMedicineReminderGroupDto` (null and
/// empty-string optional fields are omitted from the wire payload).
class MedicineReminderGroupUpsertInput {
  const MedicineReminderGroupUpsertInput({
    required this.currentMedicineId,
    this.label,
    this.daysOfWeek,
    this.startDate,
    this.endDate,
    this.isActive,
    this.note,
    required this.slots,
  });

  final String currentMedicineId;
  final String? label;
  final List<int>? daysOfWeek;
  final String? startDate;
  final String? endDate;
  final bool? isActive;
  final String? note;
  final List<MedicineReminderSlotUpsertInput> slots;
}

/// A single medicine reminder item.
class MedicineReminderItem {
  const MedicineReminderItem({
    required this.id,
    this.currentMedicineId,
    this.label,
    required this.scheduledHour,
    required this.scheduledMinute,
    this.daysOfWeek,
    this.startDate,
    this.endDate,
    required this.isActive,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? currentMedicineId;
  final String? label;
  final int scheduledHour;
  final int scheduledMinute;
  final List<int>? daysOfWeek;
  final String? startDate;
  final String? endDate;
  final bool isActive;
  final String? note;
  final String createdAt;
  final String updatedAt;

  String get timeLabel {
    final hour = scheduledHour.toString().padLeft(2, '0');
    final minute = scheduledMinute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool matchesDate(DateTime date) {
    final currentDate = _dateOnly(date);
    final start = _parseDateOnly(startDate);
    if (start != null && currentDate.isBefore(start)) return false;
    final end = _parseDateOnly(endDate);
    if (end != null && currentDate.isAfter(end)) return false;

    final days = daysOfWeek;
    if (days == null) return true;
    final weekday = date.weekday % 7;
    return days.contains(weekday);
  }
}

/// A reminder delivery log entry.
class ReminderDeliveryItem {
  const ReminderDeliveryItem({
    required this.id,
    this.reminderId,
    this.deviceId,
    required this.channel,
    required this.status,
    required this.scheduledFor,
    this.deliveredAt,
    this.errorMessage,
    required this.createdAt,
  });

  final String id;
  final String? reminderId;
  final String? deviceId;
  final String channel;
  final String status;
  final String scheduledFor;
  final String? deliveredAt;
  final String? errorMessage;
  final String createdAt;
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

DateTime? _parseDateOnly(String? value) {
  if (value == null || value.isEmpty) return null;
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return null;
  return _dateOnly(parsed);
}
