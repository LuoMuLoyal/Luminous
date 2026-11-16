//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_network_response_degree.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineNetworkResponseDegree {
  /// Returns a new [MedicineNetworkResponseDegree] instance.
  MedicineNetworkResponseDegree({
    required this.interactions,

    required this.targets,
  });

  /// Total interacting drugs, from count(*), not the truncated list length.
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'interactions', required: true, includeIfNull: false)
  final int interactions;

  /// Total drug-target edges of the centre drug.
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'targets', required: true, includeIfNull: false)
  final int targets;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineNetworkResponseDegree &&
          other.interactions == interactions &&
          other.targets == targets;

  @override
  int get hashCode => interactions.hashCode + targets.hashCode;

  factory MedicineNetworkResponseDegree.fromJson(Map<String, dynamic> json) =>
      _$MedicineNetworkResponseDegreeFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineNetworkResponseDegreeToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
