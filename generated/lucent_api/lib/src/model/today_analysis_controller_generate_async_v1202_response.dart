//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/today_analysis_controller_generate_v1200_response.dart';
import 'package:lucent_api/src/model/today_analysis_async_status_data_dto.dart';
import 'package:lucent_api/src/model/today_analysis_async_result_data_dto.dart';
import 'package:lucent_api/src/model/today_analysis_async_job_data_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_analysis_controller_generate_async_v1202_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayAnalysisControllerGenerateAsyncV1202Response {
  /// Returns a new [TodayAnalysisControllerGenerateAsyncV1202Response] instance.
  TodayAnalysisControllerGenerateAsyncV1202Response({
    required this.jobId,

    required this.result,

    required this.status,
  });

  @JsonKey(name: r'jobId', required: true, includeIfNull: false)
  final String jobId;

  @JsonKey(name: r'result', required: true, includeIfNull: false)
  final TodayAnalysisControllerGenerateV1200Response result;

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        TodayAnalysisControllerGenerateAsyncV1202ResponseStatusEnum
            .unknownDefaultOpenApi,
  )
  final TodayAnalysisControllerGenerateAsyncV1202ResponseStatusEnum status;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayAnalysisControllerGenerateAsyncV1202Response &&
          other.jobId == jobId &&
          other.result == result &&
          other.status == status;

  @override
  int get hashCode => jobId.hashCode + result.hashCode + status.hashCode;

  factory TodayAnalysisControllerGenerateAsyncV1202Response.fromJson(
    Map<String, dynamic> json,
  ) => _$TodayAnalysisControllerGenerateAsyncV1202ResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TodayAnalysisControllerGenerateAsyncV1202ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum TodayAnalysisControllerGenerateAsyncV1202ResponseStatusEnum {
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

  const TodayAnalysisControllerGenerateAsyncV1202ResponseStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
