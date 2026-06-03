//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/user_condition_status.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_health_context_condition_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateHealthContextConditionDto {
  /// Returns a new [UpdateHealthContextConditionDto] instance.
  UpdateHealthContextConditionDto({
    this.label,

    this.status,

    this.diagnosedAt,

    this.note,
  });

  /// Condition label.
  @JsonKey(name: r'label', required: false, includeIfNull: false)
  final String? label;

  /// Condition status.
  @JsonKey(
    name: r'status',
    required: false,
    includeIfNull: false,
    unknownEnumValue: UserConditionStatus.unknownDefaultOpenApi,
  )
  final UserConditionStatus? status;

  /// Diagnosis date in YYYY-MM-DD format. Use null to clear.
  @JsonKey(name: r'diagnosedAt', required: false, includeIfNull: false)
  final Object? diagnosedAt;

  /// User note for the condition. Use null to clear.
  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final Object? note;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateHealthContextConditionDto &&
          other.label == label &&
          other.status == status &&
          other.diagnosedAt == diagnosedAt &&
          other.note == note;

  @override
  int get hashCode =>
      label.hashCode +
      status.hashCode +
      (diagnosedAt == null ? 0 : diagnosedAt.hashCode) +
      (note == null ? 0 : note.hashCode);

  factory UpdateHealthContextConditionDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateHealthContextConditionDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$UpdateHealthContextConditionDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
