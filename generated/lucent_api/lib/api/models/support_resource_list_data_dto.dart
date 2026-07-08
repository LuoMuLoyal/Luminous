// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'support_resource_dto.dart';

part 'support_resource_list_data_dto.g.dart';

@JsonSerializable()
class SupportResourceListDataDto {
  const SupportResourceListDataDto({
    required this.items,
    required this.updatedAt,
  });

  factory SupportResourceListDataDto.fromJson(Map<String, Object?> json) =>
      _$SupportResourceListDataDtoFromJson(json);

  final List<SupportResourceDto> items;

  /// ISO-8601 timestamp of last reference data revision.
  final String updatedAt;

  Map<String, Object?> toJson() => _$SupportResourceListDataDtoToJson(this);
}
