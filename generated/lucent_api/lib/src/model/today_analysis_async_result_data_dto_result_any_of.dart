//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/today_analysis_read_response_dto_analysis.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_analysis_async_result_data_dto_result_any_of.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayAnalysisAsyncResultDataDtoResultAnyOf {
  /// Returns a new [TodayAnalysisAsyncResultDataDtoResultAnyOf] instance.
  TodayAnalysisAsyncResultDataDtoResultAnyOf({
    required this.analysis,

    required this.status,

    required this.sourceVersion,

    required this.computedVersion,

    required this.computedAt,

    required this.retryAfterSeconds,
  });

  @JsonKey(name: r'analysis', required: true, includeIfNull: true)
  final TodayAnalysisReadResponseDtoAnalysis? analysis;

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue: TodayAnalysisAsyncResultDataDtoResultAnyOfStatusEnum
        .unknownDefaultOpenApi,
  )
  final TodayAnalysisAsyncResultDataDtoResultAnyOfStatusEnum status;

  @JsonKey(name: r'sourceVersion', required: true, includeIfNull: false)
  final num sourceVersion;

  @JsonKey(name: r'computedVersion', required: true, includeIfNull: false)
  final num computedVersion;

  @JsonKey(name: r'computedAt', required: true, includeIfNull: true)
  final String? computedAt;

  @JsonKey(name: r'retryAfterSeconds', required: true, includeIfNull: true)
  final num? retryAfterSeconds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayAnalysisAsyncResultDataDtoResultAnyOf &&
          other.analysis == analysis &&
          other.status == status &&
          other.sourceVersion == sourceVersion &&
          other.computedVersion == computedVersion &&
          other.computedAt == computedAt &&
          other.retryAfterSeconds == retryAfterSeconds;

  @override
  int get hashCode =>
      (analysis == null ? 0 : analysis.hashCode) +
      status.hashCode +
      sourceVersion.hashCode +
      computedVersion.hashCode +
      (computedAt == null ? 0 : computedAt.hashCode) +
      (retryAfterSeconds == null ? 0 : retryAfterSeconds.hashCode);

  factory TodayAnalysisAsyncResultDataDtoResultAnyOf.fromJson(
    Map<String, dynamic> json,
  ) => _$TodayAnalysisAsyncResultDataDtoResultAnyOfFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TodayAnalysisAsyncResultDataDtoResultAnyOfToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum TodayAnalysisAsyncResultDataDtoResultAnyOfStatusEnum {
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

  const TodayAnalysisAsyncResultDataDtoResultAnyOfStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
