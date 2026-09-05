//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'environment_snapshot_response_temperature.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EnvironmentSnapshotResponseTemperature {
  /// Returns a new [EnvironmentSnapshotResponseTemperature] instance.
  EnvironmentSnapshotResponseTemperature({
    required this.celsius,

    required this.feelsLike,
  });

  @JsonKey(name: r'celsius', required: true, includeIfNull: false)
  final num celsius;

  @JsonKey(name: r'feelsLike', required: true, includeIfNull: false)
  final num feelsLike;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvironmentSnapshotResponseTemperature &&
          other.celsius == celsius &&
          other.feelsLike == feelsLike;

  @override
  int get hashCode => celsius.hashCode + feelsLike.hashCode;

  factory EnvironmentSnapshotResponseTemperature.fromJson(
    Map<String, dynamic> json,
  ) => _$EnvironmentSnapshotResponseTemperatureFromJson(json);

  Map<String, dynamic> toJson() =>
      _$EnvironmentSnapshotResponseTemperatureToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
