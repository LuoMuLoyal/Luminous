//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicine_network_response_center.dart';
import 'package:lucent_api/src/model/medicine_network_response_edges.dart';
import 'package:lucent_api/src/model/medicine_network_response_neighbours.dart';
import 'package:lucent_api/src/model/medicine_network_response_degree.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_network_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineNetworkResponse {
  /// Returns a new [MedicineNetworkResponse] instance.
  MedicineNetworkResponse({
    required this.center,

    required this.degree,

    required this.neighbours,

    required this.edges,

    required this.truncated,

    required this.ordering,
  });

  @JsonKey(name: r'center', required: true, includeIfNull: false)
  final MedicineNetworkResponseCenter center;

  @JsonKey(name: r'degree', required: true, includeIfNull: false)
  final MedicineNetworkResponseDegree degree;

  /// At most `limit` neighbours; complete only when `truncated` is 0.
  @JsonKey(name: r'neighbours', required: true, includeIfNull: false)
  final List<MedicineNetworkResponseNeighbours> neighbours;

  /// One edge per neighbour, always from the centre outward. Facts only.
  @JsonKey(name: r'edges', required: true, includeIfNull: false)
  final List<MedicineNetworkResponseEdges> edges;

  /// Neighbours omitted by the limit. Non-zero means the UI must say \"and N more\"; treating the list as complete would misstate the drug’s degree.
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'truncated', required: true, includeIfNull: false)
  final int truncated;

  /// How the shown neighbours were chosen. drugbank_id_asc means deterministic index order, NOT ranked by importance.
  @JsonKey(
    name: r'ordering',
    required: true,
    includeIfNull: false,
    unknownEnumValue: MedicineNetworkResponseOrderingEnum.unknownDefaultOpenApi,
  )
  final MedicineNetworkResponseOrderingEnum ordering;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineNetworkResponse &&
          other.center == center &&
          other.degree == degree &&
          other.neighbours == neighbours &&
          other.edges == edges &&
          other.truncated == truncated &&
          other.ordering == ordering;

  @override
  int get hashCode =>
      center.hashCode +
      degree.hashCode +
      neighbours.hashCode +
      edges.hashCode +
      truncated.hashCode +
      ordering.hashCode;

  factory MedicineNetworkResponse.fromJson(Map<String, dynamic> json) =>
      _$MedicineNetworkResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineNetworkResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// How the shown neighbours were chosen. drugbank_id_asc means deterministic index order, NOT ranked by importance.
enum MedicineNetworkResponseOrderingEnum {
  @JsonValue(r'drugbank_id_asc')
  drugbankIdAsc(r'drugbank_id_asc'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const MedicineNetworkResponseOrderingEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
