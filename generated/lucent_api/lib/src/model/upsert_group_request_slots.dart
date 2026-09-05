//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'upsert_group_request_slots.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpsertGroupRequestSlots {
  /// Returns a new [UpsertGroupRequestSlots] instance.
  UpsertGroupRequestSlots({
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
      other is UpsertGroupRequestSlots &&
          other.id == id &&
          other.scheduledHour == scheduledHour &&
          other.scheduledMinute == scheduledMinute;

  @override
  int get hashCode =>
      id.hashCode + scheduledHour.hashCode + scheduledMinute.hashCode;

  factory UpsertGroupRequestSlots.fromJson(Map<String, dynamic> json) =>
      _$UpsertGroupRequestSlotsFromJson(json);

  Map<String, dynamic> toJson() => _$UpsertGroupRequestSlotsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
