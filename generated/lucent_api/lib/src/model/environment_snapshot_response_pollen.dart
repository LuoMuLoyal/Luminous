//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'environment_snapshot_response_pollen.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EnvironmentSnapshotResponsePollen {
  /// Returns a new [EnvironmentSnapshotResponsePollen] instance.
  EnvironmentSnapshotResponsePollen({
    required this.level,

    required this.primaryType,

    required this.value,

    required this.unit,
  });

  @JsonKey(
    name: r'level',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        EnvironmentSnapshotResponsePollenLevelEnum.unknownDefaultOpenApi,
  )
  final EnvironmentSnapshotResponsePollenLevelEnum level;

  @JsonKey(name: r'primaryType', required: true, includeIfNull: true)
  final String? primaryType;

  @JsonKey(name: r'value', required: true, includeIfNull: true)
  final num? value;

  @JsonKey(name: r'unit', required: true, includeIfNull: true)
  final String? unit;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvironmentSnapshotResponsePollen &&
          other.level == level &&
          other.primaryType == primaryType &&
          other.value == value &&
          other.unit == unit;

  @override
  int get hashCode =>
      level.hashCode +
      (primaryType == null ? 0 : primaryType.hashCode) +
      (value == null ? 0 : value.hashCode) +
      (unit == null ? 0 : unit.hashCode);

  factory EnvironmentSnapshotResponsePollen.fromJson(
    Map<String, dynamic> json,
  ) => _$EnvironmentSnapshotResponsePollenFromJson(json);

  Map<String, dynamic> toJson() =>
      _$EnvironmentSnapshotResponsePollenToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum EnvironmentSnapshotResponsePollenLevelEnum {
  @JsonValue(r'low')
  low(r'low'),
  @JsonValue(r'medium')
  medium(r'medium'),
  @JsonValue(r'high')
  high(r'high'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const EnvironmentSnapshotResponsePollenLevelEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
