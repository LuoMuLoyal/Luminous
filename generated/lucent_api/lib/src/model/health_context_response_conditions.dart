//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_context_response_conditions.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthContextResponseConditions {
  /// Returns a new [HealthContextResponseConditions] instance.
  HealthContextResponseConditions({
    required this.id,

    required this.label,

    required this.status,

    required this.diagnosedAt,

    required this.resolvedAt,

    required this.note,

    required this.extras,

    required this.createdAt,

    required this.updatedAt,
  });

  /// Condition id.
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  /// Condition label.
  @JsonKey(name: r'label', required: true, includeIfNull: false)
  final String label;

  /// Condition status.
  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        HealthContextResponseConditionsStatusEnum.unknownDefaultOpenApi,
  )
  final HealthContextResponseConditionsStatusEnum status;

  @JsonKey(name: r'diagnosedAt', required: true, includeIfNull: true)
  final String? diagnosedAt;

  @JsonKey(name: r'resolvedAt', required: true, includeIfNull: true)
  final String? resolvedAt;

  @JsonKey(name: r'note', required: true, includeIfNull: true)
  final String? note;

  /// Sparse condition extensions stored in jsonb.
  @JsonKey(name: r'extras', required: true, includeIfNull: true)
  final Object? extras;

  /// Created time in ISO 8601 format.
  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final String createdAt;

  /// Updated time in ISO 8601 format.
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final String updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthContextResponseConditions &&
          other.id == id &&
          other.label == label &&
          other.status == status &&
          other.diagnosedAt == diagnosedAt &&
          other.resolvedAt == resolvedAt &&
          other.note == note &&
          other.extras == extras &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      id.hashCode +
      label.hashCode +
      status.hashCode +
      (diagnosedAt == null ? 0 : diagnosedAt.hashCode) +
      (resolvedAt == null ? 0 : resolvedAt.hashCode) +
      (note == null ? 0 : note.hashCode) +
      (extras == null ? 0 : extras.hashCode) +
      createdAt.hashCode +
      updatedAt.hashCode;

  factory HealthContextResponseConditions.fromJson(Map<String, dynamic> json) =>
      _$HealthContextResponseConditionsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$HealthContextResponseConditionsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Condition status.
enum HealthContextResponseConditionsStatusEnum {
  @JsonValue(r'active')
  active(r'active'),
  @JsonValue(r'resolved')
  resolved(r'resolved'),
  @JsonValue(r'suspected')
  suspected(r'suspected'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const HealthContextResponseConditionsStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
