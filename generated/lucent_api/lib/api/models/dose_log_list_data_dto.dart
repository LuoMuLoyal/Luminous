// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'dose_log_item_dto.dart';

part 'dose_log_list_data_dto.g.dart';

@JsonSerializable()
class DoseLogListDataDto {
  const DoseLogListDataDto({required this.items, required this.total});

  factory DoseLogListDataDto.fromJson(Map<String, Object?> json) =>
      _$DoseLogListDataDtoFromJson(json);

  final List<DoseLogItemDto> items;

  /// Total count of dose logs for the date.
  final num total;

  Map<String, Object?> toJson() => _$DoseLogListDataDtoToJson(this);
}
