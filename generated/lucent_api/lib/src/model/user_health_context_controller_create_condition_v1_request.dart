//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_health_context_controller_create_condition_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UserHealthContextControllerCreateConditionV1Request {
  /// Returns a new [UserHealthContextControllerCreateConditionV1Request] instance.
  UserHealthContextControllerCreateConditionV1Request({
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
    unknownEnumValue:
        UserHealthContextControllerCreateConditionV1RequestStatusEnum
            .unknownDefaultOpenApi,
  )
  final UserHealthContextControllerCreateConditionV1RequestStatusEnum? status;

  /// Diagnosis date in YYYY-MM-DD format.
  @JsonKey(name: r'diagnosedAt', required: false, includeIfNull: false)
  final String? diagnosedAt;

  /// User note for the condition.
  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserHealthContextControllerCreateConditionV1Request &&
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

  factory UserHealthContextControllerCreateConditionV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$UserHealthContextControllerCreateConditionV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$UserHealthContextControllerCreateConditionV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Condition status. Defaults to active.
enum UserHealthContextControllerCreateConditionV1RequestStatusEnum {
  @JsonValue(r'active')
  active(r'active'),
  @JsonValue(r'resolved')
  resolved(r'resolved'),
  @JsonValue(r'suspected')
  suspected(r'suspected'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const UserHealthContextControllerCreateConditionV1RequestStatusEnum(
    this.value,
  );

  final String value;

  @override
  String toString() => value;
}
