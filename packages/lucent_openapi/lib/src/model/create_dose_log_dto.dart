//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/dose_log_status.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_dose_log_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateDoseLogDto {
  /// Returns a new [CreateDoseLogDto] instance.
  CreateDoseLogDto({
    this.currentMedicineId,

    required this.status,

    required this.scheduledFor,

    this.doseText,

    this.note,
  });

  /// Linked current medicine id.
  @JsonKey(name: r'currentMedicineId', required: false, includeIfNull: false)
  final String? currentMedicineId;

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

  /// Dose text.
  @JsonKey(name: r'doseText', required: false, includeIfNull: false)
  final String? doseText;

  /// Free-text note.
  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateDoseLogDto &&
          other.currentMedicineId == currentMedicineId &&
          other.status == status &&
          other.scheduledFor == scheduledFor &&
          other.doseText == doseText &&
          other.note == note;

  @override
  int get hashCode =>
      currentMedicineId.hashCode +
      status.hashCode +
      scheduledFor.hashCode +
      doseText.hashCode +
      note.hashCode;

  factory CreateDoseLogDto.fromJson(Map<String, dynamic> json) =>
      _$CreateDoseLogDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateDoseLogDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
