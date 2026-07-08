// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'daily_record_item_dto.dart';
import 'daily_record_kind.dart';

part 'daily_record_summary_dto.g.dart';

@JsonSerializable()
class DailyRecordSummaryDto {
  const DailyRecordSummaryDto({
    required this.kind,
    required this.count,
    this.latest,
  });

  factory DailyRecordSummaryDto.fromJson(Map<String, Object?> json) =>
      _$DailyRecordSummaryDtoFromJson(json);

  final DailyRecordKind kind;

  /// Count of records for this kind on the given date.
  final num count;

  /// Most recent record of this kind.
  final DailyRecordItemDto? latest;

  Map<String, Object?> toJson() => _$DailyRecordSummaryDtoToJson(this);
}
