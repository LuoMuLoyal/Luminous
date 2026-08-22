//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/report_summary_data_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_summary_async_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportSummaryAsyncResponseDto {
  /// Returns a new [ReportSummaryAsyncResponseDto] instance.
  ReportSummaryAsyncResponseDto({this.jobId, this.result});

  /// Queued report summary job identifier.
  @JsonKey(name: r'jobId', required: false, includeIfNull: false)
  final String? jobId;

  /// Inline report summary resource when queue processing is unavailable.
  @JsonKey(name: r'result', required: false, includeIfNull: false)
  final ReportSummaryDataDto? result;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportSummaryAsyncResponseDto &&
          other.jobId == jobId &&
          other.result == result;

  @override
  int get hashCode => jobId.hashCode + result.hashCode;

  factory ReportSummaryAsyncResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ReportSummaryAsyncResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReportSummaryAsyncResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
