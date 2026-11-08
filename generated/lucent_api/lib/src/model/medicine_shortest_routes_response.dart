//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicine_shortest_routes_response_routes.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_shortest_routes_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineShortestRoutesResponse {
  /// Returns a new [MedicineShortestRoutesResponse] instance.
  MedicineShortestRoutesResponse({required this.status, this.routes});

  /// Whether the graph could answer the query.
  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        MedicineShortestRoutesResponseStatusEnum.unknownDefaultOpenApi,
  )
  final MedicineShortestRoutesResponseStatusEnum status;

  @JsonKey(name: r'routes', required: false, includeIfNull: false)
  final List<MedicineShortestRoutesResponseRoutes>? routes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineShortestRoutesResponse &&
          other.status == status &&
          other.routes == routes;

  @override
  int get hashCode => status.hashCode + routes.hashCode;

  factory MedicineShortestRoutesResponse.fromJson(Map<String, dynamic> json) =>
      _$MedicineShortestRoutesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineShortestRoutesResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Whether the graph could answer the query.
enum MedicineShortestRoutesResponseStatusEnum {
  @JsonValue(r'ok')
  ok(r'ok'),
  @JsonValue(r'notConfigured')
  notConfigured(r'notConfigured'),
  @JsonValue(r'unavailable')
  unavailable(r'unavailable'),
  @JsonValue(r'timeout')
  timeout(r'timeout'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const MedicineShortestRoutesResponseStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
