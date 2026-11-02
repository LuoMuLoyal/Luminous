//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_shortest_routes_response_routes.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineShortestRoutesResponseRoutes {
  /// Returns a new [MedicineShortestRoutesResponseRoutes] instance.
  MedicineShortestRoutesResponseRoutes({
    required this.stepCount,

    required this.pathNodes,

    required this.pathRelations,
  });

  /// Number of hops in the path.
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'stepCount', required: true, includeIfNull: false)
  final int stepCount;

  /// Node display names, in path order.
  @JsonKey(name: r'pathNodes', required: true, includeIfNull: false)
  final List<String> pathNodes;

  /// Edge types, aligned with pathNodes.
  @JsonKey(name: r'pathRelations', required: true, includeIfNull: false)
  final List<String> pathRelations;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineShortestRoutesResponseRoutes &&
          other.stepCount == stepCount &&
          other.pathNodes == pathNodes &&
          other.pathRelations == pathRelations;

  @override
  int get hashCode =>
      stepCount.hashCode + pathNodes.hashCode + pathRelations.hashCode;

  factory MedicineShortestRoutesResponseRoutes.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineShortestRoutesResponseRoutesFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineShortestRoutesResponseRoutesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
