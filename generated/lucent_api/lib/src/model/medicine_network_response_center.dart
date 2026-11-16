//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_network_response_center.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineNetworkResponseCenter {
  /// Returns a new [MedicineNetworkResponseCenter] instance.
  MedicineNetworkResponseCenter({required this.id, required this.name});

  /// DrugBank id of the centre drug.
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  /// Display name of the centre drug.
  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineNetworkResponseCenter &&
          other.id == id &&
          other.name == name;

  @override
  int get hashCode => id.hashCode + name.hashCode;

  factory MedicineNetworkResponseCenter.fromJson(Map<String, dynamic> json) =>
      _$MedicineNetworkResponseCenterFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineNetworkResponseCenterToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
