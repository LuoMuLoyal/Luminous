//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_detail_response_external_identifiers.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineDetailResponseExternalIdentifiers {
  /// Returns a new [MedicineDetailResponseExternalIdentifiers] instance.
  MedicineDetailResponseExternalIdentifiers({
    required this.resource,

    required this.identifier,
  });

  /// Source resource label.
  @JsonKey(name: r'resource', required: true, includeIfNull: false)
  final String resource;

  /// Identifier within that resource.
  @JsonKey(name: r'identifier', required: true, includeIfNull: false)
  final String identifier;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineDetailResponseExternalIdentifiers &&
          other.resource == resource &&
          other.identifier == identifier;

  @override
  int get hashCode => resource.hashCode + identifier.hashCode;

  factory MedicineDetailResponseExternalIdentifiers.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineDetailResponseExternalIdentifiersFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineDetailResponseExternalIdentifiersToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
