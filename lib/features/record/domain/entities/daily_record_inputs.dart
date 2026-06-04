import 'package:luminous/features/record/domain/entities/daily_record.dart';

/// Sentinel for optional update fields — omit to leave unchanged.
const Object dailyRecordNoChange = Object();

class DailyRecordCreateInput {
  const DailyRecordCreateInput({
    required this.kind,
    required this.occurredAt,
    this.title,
    this.value,
    this.unit,
    this.note,
  });

  final DailyRecordKind kind;
  final String occurredAt;
  final String? title;
  final String? value;
  final String? unit;
  final String? note;
}

class DailyRecordUpdateInput {
  const DailyRecordUpdateInput({
    this.kind = dailyRecordNoChange,
    this.occurredAt = dailyRecordNoChange,
    this.title = dailyRecordNoChange,
    this.value = dailyRecordNoChange,
    this.unit = dailyRecordNoChange,
    this.note = dailyRecordNoChange,
  });

  final Object kind;
  final Object occurredAt;
  final Object title;
  final Object value;
  final Object unit;
  final Object note;
}
