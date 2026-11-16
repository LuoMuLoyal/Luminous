//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_network_response_edges.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineNetworkResponseEdges {
  /// Returns a new [MedicineNetworkResponseEdges] instance.
  MedicineNetworkResponseEdges({
    required this.kind,

    required this.neighbourId,

    required this.relationKind,

    required this.actions,
  });

  /// Which fact this edge states.
  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        MedicineNetworkResponseEdgesKindEnum.unknownDefaultOpenApi,
  )
  final MedicineNetworkResponseEdgesKindEnum kind;

  /// Matches the neighbour id this edge ends at.
  @JsonKey(name: r'neighbourId', required: true, includeIfNull: false)
  final String neighbourId;

  /// Target-edge relation kind (target / enzyme / carrier / transporter).
  @JsonKey(name: r'relationKind', required: true, includeIfNull: true)
  final String? relationKind;

  /// Target-edge action labels (inhibitor, agonist, ...).
  @JsonKey(name: r'actions', required: true, includeIfNull: false)
  final List<String> actions;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineNetworkResponseEdges &&
          other.kind == kind &&
          other.neighbourId == neighbourId &&
          other.relationKind == relationKind &&
          other.actions == actions;

  @override
  int get hashCode =>
      kind.hashCode +
      neighbourId.hashCode +
      (relationKind == null ? 0 : relationKind.hashCode) +
      actions.hashCode;

  factory MedicineNetworkResponseEdges.fromJson(Map<String, dynamic> json) =>
      _$MedicineNetworkResponseEdgesFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineNetworkResponseEdgesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Which fact this edge states.
enum MedicineNetworkResponseEdgesKindEnum {
  @JsonValue(r'interaction')
  interaction(r'interaction'),
  @JsonValue(r'target')
  target(r'target'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const MedicineNetworkResponseEdgesKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
