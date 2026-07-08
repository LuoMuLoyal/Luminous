// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'pollen_level.dart';

part 'pollen_indicator_dto.g.dart';

@JsonSerializable()
class PollenIndicatorDto {
  const PollenIndicatorDto({
    required this.level,
    required this.primaryType,
    required this.value,
    required this.unit,
  });

  factory PollenIndicatorDto.fromJson(Map<String, Object?> json) =>
      _$PollenIndicatorDtoFromJson(json);

  final PollenLevel level;
  final String? primaryType;
  final num? value;
  final String? unit;

  Map<String, Object?> toJson() => _$PollenIndicatorDtoToJson(this);
}
