String formatRecordDate(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

String formatRecordTimeLabel(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return '--:--';
  }
  return trimmed;
}

String formatRecordDateTimeLabel(String occurredAt, {String? occurredTime}) {
  final parsed = DateTime.tryParse(occurredAt);
  final timeText = occurredTime?.trim();
  if (parsed == null) {
    if (timeText != null && timeText.isNotEmpty) {
      return '$occurredAt $timeText';
    }
    return occurredAt;
  }

  final local = parsed.toLocal();
  final dateText = formatRecordDate(local);
  if (timeText != null && timeText.isNotEmpty) {
    return '$dateText $timeText';
  }

  return '$dateText '
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}

String formatRecordTimeValue(DateTime value) {
  return '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';
}

DateTime? parseRecordDate(String? value) {
  if (value == null) return null;
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return null;
  return DateTime(parsed.year, parsed.month, parsed.day);
}

DateTime? applyRecordTimeToDate(DateTime date, String? occurredTime) {
  final time = parseRecordTime(occurredTime);
  if (time == null) return null;
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

DateTime? parseRecordDateTime(String occurredAt, {String? occurredTime}) {
  final date = parseRecordDate(occurredAt);
  if (date == null) return null;
  return applyRecordTimeToDate(date, occurredTime) ?? date;
}

({int hour, int minute})? parseRecordTime(String? value) {
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
