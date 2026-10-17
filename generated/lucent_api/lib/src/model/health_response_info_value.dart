//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_response_info_value.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthResponseInfoValue {
  /// Returns a new [HealthResponseInfoValue] instance.
  HealthResponseInfoValue({
    required this.status,

    this.message,

    this.durationMs,

    this.driver,

    this.probe,

    this.backend,

    this.mode,

    this.name,

    this.env,

    this.pid,

    this.uptimeSeconds,

    this.memoryRssBytes,

    this.memoryHeapUsedBytes,
  });

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue: HealthResponseInfoValueStatusEnum.unknownDefaultOpenApi,
  )
  final HealthResponseInfoValueStatusEnum status;

  @JsonKey(name: r'message', required: false, includeIfNull: false)
  final String? message;

  @JsonKey(name: r'durationMs', required: false, includeIfNull: false)
  final num? durationMs;

  @JsonKey(name: r'driver', required: false, includeIfNull: false)
  final String? driver;

  @JsonKey(name: r'probe', required: false, includeIfNull: false)
  final String? probe;

  @JsonKey(name: r'backend', required: false, includeIfNull: false)
  final String? backend;

  @JsonKey(name: r'mode', required: false, includeIfNull: false)
  final String? mode;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'env', required: false, includeIfNull: false)
  final String? env;

  @JsonKey(name: r'pid', required: false, includeIfNull: false)
  final num? pid;

  @JsonKey(name: r'uptimeSeconds', required: false, includeIfNull: false)
  final num? uptimeSeconds;

  @JsonKey(name: r'memoryRssBytes', required: false, includeIfNull: false)
  final num? memoryRssBytes;

  @JsonKey(name: r'memoryHeapUsedBytes', required: false, includeIfNull: false)
  final num? memoryHeapUsedBytes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthResponseInfoValue &&
          other.status == status &&
          other.message == message &&
          other.durationMs == durationMs &&
          other.driver == driver &&
          other.probe == probe &&
          other.backend == backend &&
          other.mode == mode &&
          other.name == name &&
          other.env == env &&
          other.pid == pid &&
          other.uptimeSeconds == uptimeSeconds &&
          other.memoryRssBytes == memoryRssBytes &&
          other.memoryHeapUsedBytes == memoryHeapUsedBytes;

  @override
  int get hashCode =>
      status.hashCode +
      message.hashCode +
      durationMs.hashCode +
      driver.hashCode +
      probe.hashCode +
      backend.hashCode +
      mode.hashCode +
      name.hashCode +
      env.hashCode +
      pid.hashCode +
      uptimeSeconds.hashCode +
      memoryRssBytes.hashCode +
      memoryHeapUsedBytes.hashCode;

  factory HealthResponseInfoValue.fromJson(Map<String, dynamic> json) =>
      _$HealthResponseInfoValueFromJson(json);

  Map<String, dynamic> toJson() => _$HealthResponseInfoValueToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum HealthResponseInfoValueStatusEnum {
  @JsonValue(r'up')
  up(r'up'),
  @JsonValue(r'degraded')
  degraded(r'degraded'),
  @JsonValue(r'down')
  down(r'down'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const HealthResponseInfoValueStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
