//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/dose_log_status.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mark_dose_log_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MarkDoseLogDto {
  /// Returns a new [MarkDoseLogDto] instance.
  MarkDoseLogDto({
    this.currentMedicineId,

    this.reminderId,

    this.healthEventId,

    required this.status,

    required this.scheduledFor,

    this.scheduledTime,

    this.doseText,

    this.note,
  });

  /// Linked current medicine id.
  @JsonKey(name: r'currentMedicineId', required: false, includeIfNull: false)
  final String? currentMedicineId;

  /// Linked reminder id for slot-aware marks.
  @JsonKey(name: r'reminderId', required: false, includeIfNull: false)
  final String? reminderId;

  /// Linked active health event id.
  @JsonKey(name: r'healthEventId', required: false, includeIfNull: false)
  final Object? healthEventId;

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue: DoseLogStatus.unknownDefaultOpenApi,
  )
  final DoseLogStatus status;

  /// Scheduled date YYYY-MM-DD.
  @JsonKey(name: r'scheduledFor', required: true, includeIfNull: false)
  final String scheduledFor;

  /// Scheduled slot time in HH:mm for slot-aware marks.
  @JsonKey(name: r'scheduledTime', required: false, includeIfNull: false)
  final String? scheduledTime;

  /// Dose text.
  @JsonKey(name: r'doseText', required: false, includeIfNull: false)
  final Object? doseText;

  /// Free-text note.
  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final Object? note;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarkDoseLogDto &&
          other.currentMedicineId == currentMedicineId &&
          other.reminderId == reminderId &&
          other.healthEventId == healthEventId &&
          other.status == status &&
          other.scheduledFor == scheduledFor &&
          other.scheduledTime == scheduledTime &&
          other.doseText == doseText &&
          other.note == note;

  @override
  int get hashCode =>
      currentMedicineId.hashCode +
      reminderId.hashCode +
      (healthEventId == null ? 0 : healthEventId.hashCode) +
      status.hashCode +
      scheduledFor.hashCode +
      scheduledTime.hashCode +
      doseText.hashCode +
      note.hashCode;

  factory MarkDoseLogDto.fromJson(Map<String, dynamic> json) =>
      _$MarkDoseLogDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MarkDoseLogDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
