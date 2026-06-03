//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/user_condition_status.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_health_context_condition_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateHealthContextConditionDto {
  /// Returns a new [CreateHealthContextConditionDto] instance.
  CreateHealthContextConditionDto({
    required this.label,

    this.status,

    this.diagnosedAt,

    this.note,
  });

  /// Condition label.
  @JsonKey(name: r'label', required: true, includeIfNull: false)
  final String label;

  /// Condition status. Defaults to active.
  @JsonKey(
    name: r'status',
    required: false,
    includeIfNull: false,
    unknownEnumValue: UserConditionStatus.unknownDefaultOpenApi,
  )
  final UserConditionStatus? status;

  /// Diagnosis date in YYYY-MM-DD format.
  @JsonKey(name: r'diagnosedAt', required: false, includeIfNull: false)
  final Object? diagnosedAt;

  /// User note for the condition.
  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateHealthContextConditionDto &&
          other.label == label &&
          other.status == status &&
          other.diagnosedAt == diagnosedAt &&
          other.note == note;

  @override
  int get hashCode =>
      label.hashCode +
      status.hashCode +
      (diagnosedAt == null ? 0 : diagnosedAt.hashCode) +
      note.hashCode;

  factory CreateHealthContextConditionDto.fromJson(Map<String, dynamic> json) =>
      _$CreateHealthContextConditionDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CreateHealthContextConditionDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
