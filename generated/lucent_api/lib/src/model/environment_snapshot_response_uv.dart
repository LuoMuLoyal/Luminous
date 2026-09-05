//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'environment_snapshot_response_uv.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EnvironmentSnapshotResponseUv {
  /// Returns a new [EnvironmentSnapshotResponseUv] instance.
  EnvironmentSnapshotResponseUv({required this.index, required this.level});

  @JsonKey(name: r'index', required: true, includeIfNull: false)
  final num index;

  @JsonKey(
    name: r'level',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        EnvironmentSnapshotResponseUvLevelEnum.unknownDefaultOpenApi,
  )
  final EnvironmentSnapshotResponseUvLevelEnum level;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvironmentSnapshotResponseUv &&
          other.index == index &&
          other.level == level;

  @override
  int get hashCode => index.hashCode + level.hashCode;

  factory EnvironmentSnapshotResponseUv.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentSnapshotResponseUvFromJson(json);

  Map<String, dynamic> toJson() => _$EnvironmentSnapshotResponseUvToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum EnvironmentSnapshotResponseUvLevelEnum {
  @JsonValue(r'low')
  low(r'low'),
  @JsonValue(r'moderate')
  moderate(r'moderate'),
  @JsonValue(r'high')
  high(r'high'),
  @JsonValue(r'very_high')
  veryHigh(r'very_high'),
  @JsonValue(r'extreme')
  extreme(r'extreme'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const EnvironmentSnapshotResponseUvLevelEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
