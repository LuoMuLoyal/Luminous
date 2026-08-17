//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/today_analysis_async_status_data_dto.dart';
import 'package:lucent_api/src/model/today_analysis_async_result_data_dto_result.dart';
import 'package:lucent_api/src/model/today_analysis_async_result_data_dto.dart';
import 'package:lucent_api/src/model/today_analysis_async_job_data_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_analysis_async_response_dto_data.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayAnalysisAsyncResponseDtoData {
  /// Returns a new [TodayAnalysisAsyncResponseDtoData] instance.
  TodayAnalysisAsyncResponseDtoData({
    required this.jobId,

    required this.result,

    required this.status,
  });

  @JsonKey(name: r'jobId', required: true, includeIfNull: false)
  final String jobId;

  @JsonKey(name: r'result', required: true, includeIfNull: false)
  final TodayAnalysisAsyncResultDataDtoResult result;

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        TodayAnalysisAsyncResponseDtoDataStatusEnum.unknownDefaultOpenApi,
  )
  final TodayAnalysisAsyncResponseDtoDataStatusEnum status;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayAnalysisAsyncResponseDtoData &&
          other.jobId == jobId &&
          other.result == result &&
          other.status == status;

  @override
  int get hashCode => jobId.hashCode + result.hashCode + status.hashCode;

  factory TodayAnalysisAsyncResponseDtoData.fromJson(
    Map<String, dynamic> json,
  ) => _$TodayAnalysisAsyncResponseDtoDataFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TodayAnalysisAsyncResponseDtoDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum TodayAnalysisAsyncResponseDtoDataStatusEnum {
  @JsonValue(r'empty')
  empty(r'empty'),
  @JsonValue(r'pending')
  pending(r'pending'),
  @JsonValue(r'ready')
  ready(r'ready'),
  @JsonValue(r'stale')
  stale(r'stale'),
  @JsonValue(r'failed')
  failed(r'failed'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const TodayAnalysisAsyncResponseDtoDataStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
