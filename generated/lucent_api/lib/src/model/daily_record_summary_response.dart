//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/daily_record_summary_response_summaries.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'daily_record_summary_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DailyRecordSummaryResponse {
  /// Returns a new [DailyRecordSummaryResponse] instance.
  DailyRecordSummaryResponse({required this.summaries});

  @JsonKey(name: r'summaries', required: true, includeIfNull: false)
  final List<DailyRecordSummaryResponseSummaries> summaries;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordSummaryResponse && other.summaries == summaries;

  @override
  int get hashCode => summaries.hashCode;

  factory DailyRecordSummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$DailyRecordSummaryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DailyRecordSummaryResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
