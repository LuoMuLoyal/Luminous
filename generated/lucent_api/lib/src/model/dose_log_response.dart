//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dose_log_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DoseLogResponse {
  /// Returns a new [DoseLogResponse] instance.
  DoseLogResponse({
    required this.id,

    required this.healthEventId,

    required this.currentMedicineId,

    required this.reminderId,

    required this.status,

    required this.scheduledFor,

    required this.scheduledTime,

    required this.doseText,

    required this.note,

    required this.source_,

    required this.createdAt,

    required this.updatedAt,
  });

  /// Dose log id.
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'healthEventId', required: true, includeIfNull: true)
  final String? healthEventId;

  @JsonKey(name: r'currentMedicineId', required: true, includeIfNull: true)
  final String? currentMedicineId;

  @JsonKey(name: r'reminderId', required: true, includeIfNull: true)
  final String? reminderId;

  /// Dose log status.
  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue: DoseLogResponseStatusEnum.unknownDefaultOpenApi,
  )
  final DoseLogResponseStatusEnum status;

  /// Scheduled date in YYYY-MM-DD format.
  @JsonKey(name: r'scheduledFor', required: true, includeIfNull: false)
  final String scheduledFor;

  @JsonKey(name: r'scheduledTime', required: true, includeIfNull: true)
  final String? scheduledTime;

  @JsonKey(name: r'doseText', required: true, includeIfNull: true)
  final String? doseText;

  @JsonKey(name: r'note', required: true, includeIfNull: true)
  final String? note;

  @JsonKey(name: r'source', required: true, includeIfNull: true)
  final String? source_;

  /// Created at (ISO 8601).
  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final String createdAt;

  /// Updated at (ISO 8601).
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final String updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoseLogResponse &&
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
      (currentMedicineId == null ? 0 : currentMedicineId.hashCode) +
      (reminderId == null ? 0 : reminderId.hashCode) +
      status.hashCode +
      scheduledFor.hashCode +
      (scheduledTime == null ? 0 : scheduledTime.hashCode) +
      (doseText == null ? 0 : doseText.hashCode) +
      (note == null ? 0 : note.hashCode) +
      (source_ == null ? 0 : source_.hashCode) +
      createdAt.hashCode +
      updatedAt.hashCode;

  factory DoseLogResponse.fromJson(Map<String, dynamic> json) =>
      _$DoseLogResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DoseLogResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Dose log status.
enum DoseLogResponseStatusEnum {
  @JsonValue(r'taken')
  taken(r'taken'),
  @JsonValue(r'skipped')
  skipped(r'skipped'),
  @JsonValue(r'missed')
  missed(r'missed'),
  @JsonValue(r'planned')
  planned(r'planned'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const DoseLogResponseStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
