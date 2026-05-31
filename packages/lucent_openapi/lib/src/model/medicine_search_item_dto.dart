//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'medicine_search_item_dto.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineSearchItemDto {
  /// Returns a new [MedicineSearchItemDto] instance.
  MedicineSearchItemDto({

    required  this.id,

    required  this.source_,

    required  this.name,

    required  this.subtitle,

    required  this.summary,

    required  this.tags,

    required  this.imageUrl,

    required  this.matchedBy,
  });

      /// Stable medicine id.
  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



      /// Knowledge source.
  @JsonKey(
    
    name: r'source',
    required: true,
    includeIfNull: false,
  unknownEnumValue: MedicineSearchItemDtoSource_Enum.unknownDefaultOpenApi,
  )


  final MedicineSearchItemDtoSource_Enum source_;



      /// Display name.
  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



      /// Short supporting subtitle.
  @JsonKey(
    
    name: r'subtitle',
    required: true,
    includeIfNull: true,
  )


  final Object? subtitle;



      /// Short preview summary.
  @JsonKey(
    
    name: r'summary',
    required: true,
    includeIfNull: true,
  )


  final Object? summary;



      /// Compact tags for search cards.
  @JsonKey(
    
    name: r'tags',
    required: true,
    includeIfNull: false,
  )


  final List<String> tags;



      /// Optional image URL.
  @JsonKey(
    
    name: r'imageUrl',
    required: true,
    includeIfNull: true,
  )


  final Object? imageUrl;



      /// Which fields matched the current query.
  @JsonKey(
    
    name: r'matchedBy',
    required: true,
    includeIfNull: false,
  )


  final List<String> matchedBy;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MedicineSearchItemDto &&
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

  factory MedicineSearchItemDto.fromJson(Map<String, dynamic> json) => _$MedicineSearchItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineSearchItemDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// Knowledge source.
enum MedicineSearchItemDtoSource_Enum {
    /// Knowledge source.
@JsonValue(r'drugbank')
drugbank(r'drugbank'),
    /// Knowledge source.
@JsonValue(r'cn')
cn(r'cn'),
    /// Knowledge source.
@JsonValue(r'unknown_default_open_api')
unknownDefaultOpenApi(r'unknown_default_open_api');

const MedicineSearchItemDtoSource_Enum(this.value);

final String value;

@override
String toString() => value;
}


