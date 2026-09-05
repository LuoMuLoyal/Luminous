//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'environment_snapshot_response_humidity.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EnvironmentSnapshotResponseHumidity {
  /// Returns a new [EnvironmentSnapshotResponseHumidity] instance.
  EnvironmentSnapshotResponseHumidity({required this.percent});

  @JsonKey(name: r'percent', required: true, includeIfNull: false)
  final num percent;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvironmentSnapshotResponseHumidity && other.percent == percent;

  @override
  int get hashCode => percent.hashCode;

  factory EnvironmentSnapshotResponseHumidity.fromJson(
    Map<String, dynamic> json,
  ) => _$EnvironmentSnapshotResponseHumidityFromJson(json);

  Map<String, dynamic> toJson() =>
      _$EnvironmentSnapshotResponseHumidityToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
