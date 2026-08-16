//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'upsert_reminder_slot_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpsertReminderSlotDto {
  /// Returns a new [UpsertReminderSlotDto] instance.
  UpsertReminderSlotDto({
    this.id,

    required this.scheduledHour,

    required this.scheduledMinute,
  });

  /// Existing reminder id to update. Omit to create a new slot.
  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final String? id;

  /// Scheduled local hour, 0-23.
  @JsonKey(name: r'scheduledHour', required: true, includeIfNull: false)
  final num scheduledHour;

  /// Scheduled local minute, 0-59.
  @JsonKey(name: r'scheduledMinute', required: true, includeIfNull: false)
  final num scheduledMinute;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpsertReminderSlotDto &&
          other.id == id &&
          other.scheduledHour == scheduledHour &&
          other.scheduledMinute == scheduledMinute;

  @override
  int get hashCode =>
      id.hashCode + scheduledHour.hashCode + scheduledMinute.hashCode;

  factory UpsertReminderSlotDto.fromJson(Map<String, dynamic> json) =>
      _$UpsertReminderSlotDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpsertReminderSlotDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
