//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_reminders_controller_upsert_group_v1_request_slots_inner.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineRemindersControllerUpsertGroupV1RequestSlotsInner {
  /// Returns a new [MedicineRemindersControllerUpsertGroupV1RequestSlotsInner] instance.
  MedicineRemindersControllerUpsertGroupV1RequestSlotsInner({
    this.id,

    required this.scheduledHour,

    required this.scheduledMinute,
  });

  /// Existing reminder id to update. Omit to create a new slot.
  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final String? id;

  /// Scheduled local hour, 0-23.
  // minimum: 0
  // maximum: 23
  @JsonKey(name: r'scheduledHour', required: true, includeIfNull: false)
  final int scheduledHour;

  /// Scheduled local minute, 0-59.
  // minimum: 0
  // maximum: 59
  @JsonKey(name: r'scheduledMinute', required: true, includeIfNull: false)
  final int scheduledMinute;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineRemindersControllerUpsertGroupV1RequestSlotsInner &&
          other.id == id &&
          other.scheduledHour == scheduledHour &&
          other.scheduledMinute == scheduledMinute;

  @override
  int get hashCode =>
      id.hashCode + scheduledHour.hashCode + scheduledMinute.hashCode;

  factory MedicineRemindersControllerUpsertGroupV1RequestSlotsInner.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$MedicineRemindersControllerUpsertGroupV1RequestSlotsInnerFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineRemindersControllerUpsertGroupV1RequestSlotsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
