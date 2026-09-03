//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'environment_snapshot_response_dto_humidity.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EnvironmentSnapshotResponseDtoHumidity {
  /// Returns a new [EnvironmentSnapshotResponseDtoHumidity] instance.
  EnvironmentSnapshotResponseDtoHumidity({required this.percent});

  @JsonKey(name: r'percent', required: true, includeIfNull: false)
  final num percent;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvironmentSnapshotResponseDtoHumidity &&
          other.percent == percent;

  @override
  int get hashCode => percent.hashCode;

  factory EnvironmentSnapshotResponseDtoHumidity.fromJson(
    Map<String, dynamic> json,
  ) => _$EnvironmentSnapshotResponseDtoHumidityFromJson(json);

  Map<String, dynamic> toJson() =>
      _$EnvironmentSnapshotResponseDtoHumidityToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
