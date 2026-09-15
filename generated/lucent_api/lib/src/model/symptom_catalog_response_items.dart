//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'symptom_catalog_response_items.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SymptomCatalogResponseItems {
  /// Returns a new [SymptomCatalogResponseItems] instance.
  SymptomCatalogResponseItems({required this.code, required this.label});

  /// Stable symptom code; the value stored in payload `symptom`.
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  /// Localized display label.
  @JsonKey(name: r'label', required: true, includeIfNull: false)
  final String label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SymptomCatalogResponseItems &&
          other.code == code &&
          other.label == label;

  @override
  int get hashCode => code.hashCode + label.hashCode;

  factory SymptomCatalogResponseItems.fromJson(Map<String, dynamic> json) =>
      _$SymptomCatalogResponseItemsFromJson(json);

  Map<String, dynamic> toJson() => _$SymptomCatalogResponseItemsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
