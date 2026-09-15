//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/symptom_catalog_response_items.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'symptom_catalog_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SymptomCatalogResponse {
  /// Returns a new [SymptomCatalogResponse] instance.
  SymptomCatalogResponse({required this.items});

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<SymptomCatalogResponseItems> items;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SymptomCatalogResponse && other.items == items;

  @override
  int get hashCode => items.hashCode;

  factory SymptomCatalogResponse.fromJson(Map<String, dynamic> json) =>
      _$SymptomCatalogResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SymptomCatalogResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
