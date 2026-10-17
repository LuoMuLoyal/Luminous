//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/health_response_info_value.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthResponse {
  /// Returns a new [HealthResponse] instance.
  HealthResponse({
    required this.status,

    required this.info,

    required this.error,

    required this.details,
  });

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue: HealthResponseStatusEnum.unknownDefaultOpenApi,
  )
  final HealthResponseStatusEnum status;

  @JsonKey(name: r'info', required: true, includeIfNull: false)
  final Map<String, HealthResponseInfoValue> info;

  @JsonKey(name: r'error', required: true, includeIfNull: false)
  final Map<String, HealthResponseInfoValue> error;

  @JsonKey(name: r'details', required: true, includeIfNull: false)
  final Map<String, HealthResponseInfoValue> details;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthResponse &&
          other.status == status &&
          other.info == info &&
          other.error == error &&
          other.details == details;

  @override
  int get hashCode =>
      status.hashCode + info.hashCode + error.hashCode + details.hashCode;

  factory HealthResponse.fromJson(Map<String, dynamic> json) =>
      _$HealthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$HealthResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum HealthResponseStatusEnum {
  @JsonValue(r'ok')
  ok(r'ok'),
  @JsonValue(r'error')
  error(r'error'),
  @JsonValue(r'degraded')
  degraded(r'degraded'),
  @JsonValue(r'shutting_down')
  shuttingDown(r'shutting_down'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const HealthResponseStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
