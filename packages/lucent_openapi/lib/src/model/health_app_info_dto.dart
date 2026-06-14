//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'health_app_info_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthAppInfoDto {
  /// Returns a new [HealthAppInfoDto] instance.
  HealthAppInfoDto({
    required this.name,

    required this.env,

    required this.pid,

    required this.uptimeSeconds,

    required this.memoryRssBytes,

    required this.memoryHeapUsedBytes,
  });

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @JsonKey(name: r'env', required: true, includeIfNull: false)
  final String env;

  @JsonKey(name: r'pid', required: true, includeIfNull: false)
  final num pid;

  @JsonKey(name: r'uptimeSeconds', required: true, includeIfNull: false)
  final num uptimeSeconds;

  @JsonKey(name: r'memoryRssBytes', required: true, includeIfNull: false)
  final num memoryRssBytes;

  @JsonKey(name: r'memoryHeapUsedBytes', required: true, includeIfNull: false)
  final num memoryHeapUsedBytes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthAppInfoDto &&
          other.name == name &&
          other.env == env &&
          other.pid == pid &&
          other.uptimeSeconds == uptimeSeconds &&
          other.memoryRssBytes == memoryRssBytes &&
          other.memoryHeapUsedBytes == memoryHeapUsedBytes;

  @override
  int get hashCode =>
      name.hashCode +
      env.hashCode +
      pid.hashCode +
      uptimeSeconds.hashCode +
      memoryRssBytes.hashCode +
      memoryHeapUsedBytes.hashCode;

  factory HealthAppInfoDto.fromJson(Map<String, dynamic> json) =>
      _$HealthAppInfoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HealthAppInfoDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
