//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/dose_log_status.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dose_log_item_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DoseLogItemDto {
  /// Returns a new [DoseLogItemDto] instance.
  DoseLogItemDto({
    required this.id,
    this.healthEventId,
    this.currentMedicineId,
    this.reminderId,
    required this.status,
    required this.scheduledFor,
    this.scheduledTime,
    this.doseText,
    this.note,
    this.source_,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Dose log id.
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  /// Linked health event id.
  @JsonKey(name: r'healthEventId', required: false, includeIfNull: false)
  final String? healthEventId;

  /// Linked current medicine id.
  @JsonKey(name: r'currentMedicineId', required: false, includeIfNull: false)
  final Object? currentMedicineId;

  /// Linked reminder id for slot-aware logs.
  @JsonKey(name: r'reminderId', required: false, includeIfNull: false)
  final Object? reminderId;

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue: DoseLogStatus.unknownDefaultOpenApi,
  )
  final DoseLogStatus status;

  /// Scheduled date in YYYY-MM-DD format.
  @JsonKey(name: r'scheduledFor', required: true, includeIfNull: false)
  final String scheduledFor;

  /// Scheduled slot time in HH:mm format.
  @JsonKey(name: r'scheduledTime', required: false, includeIfNull: false)
  final Object? scheduledTime;

  /// Dose text.
  @JsonKey(name: r'doseText', required: false, includeIfNull: false)
  final Object? doseText;

  /// Free-text note.
  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final Object? note;

  /// Source.
  @JsonKey(name: r'source', required: false, includeIfNull: false)
  final Object? source_;

  /// Created at (ISO 8601).
  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final String createdAt;

  /// Updated at (ISO 8601).
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final String updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoseLogItemDto &&
          other.id == id &&
          other.healthEventId == healthEventId &&
          other.currentMedicineId == currentMedicineId &&
          other.reminderId == reminderId &&
          other.status == status &&
          other.scheduledFor == scheduledFor &&
          other.scheduledTime == scheduledTime &&
          other.doseText == doseText &&
          other.note == note &&
          other.source_ == source_ &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      id.hashCode +
      (healthEventId == null ? 0 : healthEventId.hashCode) +
      currentMedicineId.hashCode +
      reminderId.hashCode +
      status.hashCode +
      scheduledFor.hashCode +
      scheduledTime.hashCode +
      doseText.hashCode +
      note.hashCode +
      source_.hashCode +
      createdAt.hashCode +
      updatedAt.hashCode;

  factory DoseLogItemDto.fromJson(Map<String, dynamic> json) =>
      _$DoseLogItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DoseLogItemDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
