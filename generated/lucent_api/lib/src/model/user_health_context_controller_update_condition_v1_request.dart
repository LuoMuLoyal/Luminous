//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_health_context_controller_update_condition_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UserHealthContextControllerUpdateConditionV1Request {
  /// Returns a new [UserHealthContextControllerUpdateConditionV1Request] instance.
  UserHealthContextControllerUpdateConditionV1Request({
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
    unknownEnumValue:
        UserHealthContextControllerUpdateConditionV1RequestStatusEnum
            .unknownDefaultOpenApi,
  )
  final UserHealthContextControllerUpdateConditionV1RequestStatusEnum? status;

  /// Diagnosis date in YYYY-MM-DD format. Use null to clear.
  @JsonKey(name: r'diagnosedAt', required: false, includeIfNull: false)
  final String? diagnosedAt;

  /// User note for the condition. Use null to clear.
  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserHealthContextControllerUpdateConditionV1Request &&
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

  factory UserHealthContextControllerUpdateConditionV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$UserHealthContextControllerUpdateConditionV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$UserHealthContextControllerUpdateConditionV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Condition status.
enum UserHealthContextControllerUpdateConditionV1RequestStatusEnum {
  @JsonValue(r'active')
  active(r'active'),
  @JsonValue(r'resolved')
  resolved(r'resolved'),
  @JsonValue(r'suspected')
  suspected(r'suspected'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const UserHealthContextControllerUpdateConditionV1RequestStatusEnum(
    this.value,
  );

  final String value;

  @override
  String toString() => value;
}
