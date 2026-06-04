//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/daily_record_summary_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'daily_record_summary_data_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DailyRecordSummaryDataDto {
  /// Returns a new [DailyRecordSummaryDataDto] instance.
  DailyRecordSummaryDataDto({required this.summaries});

  @JsonKey(name: r'summaries', required: true, includeIfNull: false)
  final List<DailyRecordSummaryDto> summaries;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordSummaryDataDto && other.summaries == summaries;

  @override
  int get hashCode => summaries.hashCode;

  factory DailyRecordSummaryDataDto.fromJson(Map<String, dynamic> json) =>
      _$DailyRecordSummaryDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DailyRecordSummaryDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
