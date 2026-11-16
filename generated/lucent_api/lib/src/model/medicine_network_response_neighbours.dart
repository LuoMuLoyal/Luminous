//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_network_response_neighbours.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineNetworkResponseNeighbours {
  /// Returns a new [MedicineNetworkResponseNeighbours] instance.
  MedicineNetworkResponseNeighbours({
    required this.id,

    required this.name,

    required this.nodeKind,

    required this.inCatalogue,
  });

  /// Entity id: DrugBank id for drugs, target id for proteins.
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  /// Display name.
  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  /// Node type, used for shape and legend grouping.
  @JsonKey(
    name: r'nodeKind',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        MedicineNetworkResponseNeighboursNodeKindEnum.unknownDefaultOpenApi,
  )
  final MedicineNetworkResponseNeighboursNodeKindEnum nodeKind;

  /// Whether the neighbour exists in the local catalogue. Interaction partners may have been retired upstream, so out-of-catalogue nodes are name-only and must not be linked.
  @JsonKey(name: r'inCatalogue', required: true, includeIfNull: false)
  final bool inCatalogue;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineNetworkResponseNeighbours &&
          other.id == id &&
          other.name == name &&
          other.nodeKind == nodeKind &&
          other.inCatalogue == inCatalogue;

  @override
  int get hashCode =>
      id.hashCode + name.hashCode + nodeKind.hashCode + inCatalogue.hashCode;

  factory MedicineNetworkResponseNeighbours.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineNetworkResponseNeighboursFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineNetworkResponseNeighboursToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Node type, used for shape and legend grouping.
enum MedicineNetworkResponseNeighboursNodeKindEnum {
  @JsonValue(r'drug')
  drug(r'drug'),
  @JsonValue(r'protein')
  protein(r'protein'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const MedicineNetworkResponseNeighboursNodeKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
