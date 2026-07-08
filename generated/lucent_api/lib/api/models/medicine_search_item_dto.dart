// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'medicine_search_item_dto_source_source.dart';

part 'medicine_search_item_dto.g.dart';

@JsonSerializable()
class MedicineSearchItemDto {
  const MedicineSearchItemDto({
    required this.id,
    required this.source,
    required this.name,
    required this.subtitle,
    required this.summary,
    required this.tags,
    required this.imageUrl,
    required this.matchedBy,
  });

  factory MedicineSearchItemDto.fromJson(Map<String, Object?> json) =>
      _$MedicineSearchItemDtoFromJson(json);

  /// Stable medicine id.
  final String id;

  /// Knowledge source.
  final MedicineSearchItemDtoSourceSource source;

  /// Display name.
  final String name;

  /// Short supporting subtitle.
  final String? subtitle;

  /// Short preview summary.
  final String? summary;

  /// Compact tags for search cards.
  final List<String> tags;

  /// Optional image URL.
  final String? imageUrl;

  /// Which fields matched the current query.
  final List<String> matchedBy;

  Map<String, Object?> toJson() => _$MedicineSearchItemDtoToJson(this);
}
