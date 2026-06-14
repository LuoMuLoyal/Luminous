//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/health_component_status.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_component_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthComponentDto {
  /// Returns a new [HealthComponentDto] instance.
  HealthComponentDto({
    required this.name,

    required this.status,

    required this.critical,

    required this.durationMs,

    required this.error,

    required this.details,
  });

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue: HealthComponentStatus.unknownDefaultOpenApi,
  )
  final HealthComponentStatus status;

  @JsonKey(name: r'critical', required: true, includeIfNull: false)
  final bool critical;

  @JsonKey(name: r'durationMs', required: true, includeIfNull: false)
  final num durationMs;

  @JsonKey(name: r'error', required: true, includeIfNull: true)
  final String? error;

  @JsonKey(name: r'details', required: true, includeIfNull: true)
  final Map<String, Object>? details;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthComponentDto &&
          other.name == name &&
          other.status == status &&
          other.critical == critical &&
          other.durationMs == durationMs &&
          other.error == error &&
          other.details == details;

  @override
  int get hashCode =>
      name.hashCode +
      status.hashCode +
      critical.hashCode +
      durationMs.hashCode +
      (error == null ? 0 : error.hashCode) +
      (details == null ? 0 : details.hashCode);

  factory HealthComponentDto.fromJson(Map<String, dynamic> json) =>
      _$HealthComponentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HealthComponentDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
