//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/daily_record_summary_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'daily_record_summary_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DailyRecordSummaryResponseDto {
  /// Returns a new [DailyRecordSummaryResponseDto] instance.
  DailyRecordSummaryResponseDto({required this.summaries});

  @JsonKey(name: r'summaries', required: true, includeIfNull: false)
  final List<DailyRecordSummaryDto> summaries;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordSummaryResponseDto && other.summaries == summaries;

  @override
  int get hashCode => summaries.hashCode;

  factory DailyRecordSummaryResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DailyRecordSummaryResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DailyRecordSummaryResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
