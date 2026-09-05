//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_search_response_items.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineSearchResponseItems {
  /// Returns a new [MedicineSearchResponseItems] instance.
  MedicineSearchResponseItems({
    required this.id,

    required this.source_,

    required this.name,

    required this.subtitle,

    required this.summary,

    required this.tags,

    required this.imageUrl,

    required this.matchedBy,
  });

  /// Stable medicine id.
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  /// Knowledge source.
  @JsonKey(
    name: r'source',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        MedicineSearchResponseItemsSource_Enum.unknownDefaultOpenApi,
  )
  final MedicineSearchResponseItemsSource_Enum source_;

  /// Display name.
  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @JsonKey(name: r'subtitle', required: true, includeIfNull: true)
  final String? subtitle;

  @JsonKey(name: r'summary', required: true, includeIfNull: true)
  final String? summary;

  /// Compact tags for search cards.
  @JsonKey(name: r'tags', required: true, includeIfNull: false)
  final List<String> tags;

  @JsonKey(name: r'imageUrl', required: true, includeIfNull: true)
  final String? imageUrl;

  /// Which fields matched the current query.
  @JsonKey(name: r'matchedBy', required: true, includeIfNull: false)
  final List<String> matchedBy;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineSearchResponseItems &&
          other.id == id &&
          other.source_ == source_ &&
          other.name == name &&
          other.subtitle == subtitle &&
          other.summary == summary &&
          other.tags == tags &&
          other.imageUrl == imageUrl &&
          other.matchedBy == matchedBy;

  @override
  int get hashCode =>
      id.hashCode +
      source_.hashCode +
      name.hashCode +
      (subtitle == null ? 0 : subtitle.hashCode) +
      (summary == null ? 0 : summary.hashCode) +
      tags.hashCode +
      (imageUrl == null ? 0 : imageUrl.hashCode) +
      matchedBy.hashCode;

  factory MedicineSearchResponseItems.fromJson(Map<String, dynamic> json) =>
      _$MedicineSearchResponseItemsFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineSearchResponseItemsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Knowledge source.
enum MedicineSearchResponseItemsSource_Enum {
  @JsonValue(r'drugbank')
  drugbank(r'drugbank'),
  @JsonValue(r'cn')
  cn(r'cn'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const MedicineSearchResponseItemsSource_Enum(this.value);

  final String value;

  @override
  String toString() => value;
}
