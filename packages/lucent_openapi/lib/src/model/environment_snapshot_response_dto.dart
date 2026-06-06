//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/environment_snapshot_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'environment_snapshot_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EnvironmentSnapshotResponseDto {
  /// Returns a new [EnvironmentSnapshotResponseDto] instance.
  EnvironmentSnapshotResponseDto({
    required this.code,

    required this.message,

    required this.data,
  });

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final num code;

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final EnvironmentSnapshotDto data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvironmentSnapshotResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory EnvironmentSnapshotResponseDto.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentSnapshotResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EnvironmentSnapshotResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
