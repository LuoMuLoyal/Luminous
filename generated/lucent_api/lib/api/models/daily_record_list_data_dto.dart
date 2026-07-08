// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'daily_record_item_dto.dart';

part 'daily_record_list_data_dto.g.dart';

@JsonSerializable()
class DailyRecordListDataDto {
  const DailyRecordListDataDto({required this.items, required this.total});

  factory DailyRecordListDataDto.fromJson(Map<String, Object?> json) =>
      _$DailyRecordListDataDtoFromJson(json);

  final List<DailyRecordItemDto> items;

  /// Total records for the date (before pagination).
  final num total;

  Map<String, Object?> toJson() => _$DailyRecordListDataDtoToJson(this);
}
