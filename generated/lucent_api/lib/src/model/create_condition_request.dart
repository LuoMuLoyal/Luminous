//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_condition_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateConditionRequest {
  /// Returns a new [CreateConditionRequest] instance.
  CreateConditionRequest({
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
    unknownEnumValue: CreateConditionRequestStatusEnum.unknownDefaultOpenApi,
  )
  final CreateConditionRequestStatusEnum? status;

  /// Diagnosis date in YYYY-MM-DD format.
  @JsonKey(name: r'diagnosedAt', required: false, includeIfNull: false)
  final String? diagnosedAt;

  /// User note for the condition.
  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateConditionRequest &&
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

  factory CreateConditionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateConditionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateConditionRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Condition status. Defaults to active.
enum CreateConditionRequestStatusEnum {
  @JsonValue(r'active')
  active(r'active'),
  @JsonValue(r'resolved')
  resolved(r'resolved'),
  @JsonValue(r'suspected')
  suspected(r'suspected'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const CreateConditionRequestStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
