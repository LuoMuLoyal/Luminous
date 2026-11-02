//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_transport_routes_response_routes.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineTransportRoutesResponseRoutes {
  /// Returns a new [MedicineTransportRoutesResponseRoutes] instance.
  MedicineTransportRoutesResponseRoutes({
    required this.transporterGene,

    required this.transporterName,

    required this.inverted,
  });

  /// Transporter gene symbol.
  @JsonKey(name: r'transporterGene', required: true, includeIfNull: false)
  final String transporterGene;

  /// Transporter display name.
  @JsonKey(name: r'transporterName', required: true, includeIfNull: false)
  final String transporterName;

  /// True when the edge points transporter -> drug (do not draw a same-direction arrow).
  @JsonKey(name: r'inverted', required: true, includeIfNull: false)
  final bool inverted;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineTransportRoutesResponseRoutes &&
          other.transporterGene == transporterGene &&
          other.transporterName == transporterName &&
          other.inverted == inverted;

  @override
  int get hashCode =>
      transporterGene.hashCode + transporterName.hashCode + inverted.hashCode;

  factory MedicineTransportRoutesResponseRoutes.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineTransportRoutesResponseRoutesFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineTransportRoutesResponseRoutesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
