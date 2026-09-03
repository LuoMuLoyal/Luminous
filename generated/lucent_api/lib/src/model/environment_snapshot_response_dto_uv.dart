//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'environment_snapshot_response_dto_uv.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EnvironmentSnapshotResponseDtoUv {
  /// Returns a new [EnvironmentSnapshotResponseDtoUv] instance.
  EnvironmentSnapshotResponseDtoUv({required this.index, required this.level});

  @JsonKey(name: r'index', required: true, includeIfNull: false)
  final num index;

  @JsonKey(
    name: r'level',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        EnvironmentSnapshotResponseDtoUvLevelEnum.unknownDefaultOpenApi,
  )
  final EnvironmentSnapshotResponseDtoUvLevelEnum level;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvironmentSnapshotResponseDtoUv &&
          other.index == index &&
          other.level == level;

  @override
  int get hashCode => index.hashCode + level.hashCode;

  factory EnvironmentSnapshotResponseDtoUv.fromJson(
    Map<String, dynamic> json,
  ) => _$EnvironmentSnapshotResponseDtoUvFromJson(json);

  Map<String, dynamic> toJson() =>
      _$EnvironmentSnapshotResponseDtoUvToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum EnvironmentSnapshotResponseDtoUvLevelEnum {
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

  const EnvironmentSnapshotResponseDtoUvLevelEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
