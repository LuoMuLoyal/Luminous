//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/today_analysis_stream_summary_dto.dart';
import 'package:lucent_api/src/model/today_analysis_bullet_dto.dart';
import 'package:lucent_api/src/model/today_analysis_data_dto.dart';
import 'package:lucent_api/src/model/today_analysis_metric_dto.dart';
import 'package:lucent_api/src/model/today_analysis_stream_error_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_analysis_stream_result_dto_data.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayAnalysisStreamResultDtoData {
  /// Returns a new [TodayAnalysisStreamResultDtoData] instance.
  TodayAnalysisStreamResultDtoData({
    required this.summary,

    required this.date,

    required this.generatedAt,

    this.sourceVersion,

    required this.bullets,

    required this.actionLabel,

    required this.action,

    required this.confidenceNote,

    required this.aiGenerated,

    this.metrics,

    required this.type,

    required this.title,

    required this.detail,

    required this.code,

    this.errors,

    this.retryable,

    this.retryAfter,

    this.traceId,

    required this.status,
  });

  @JsonKey(name: r'summary', required: true, includeIfNull: false)
  final String summary;

  @JsonKey(name: r'date', required: true, includeIfNull: false)
  final String date;

  @JsonKey(name: r'generatedAt', required: true, includeIfNull: false)
  final String generatedAt;

  @JsonKey(name: r'sourceVersion', required: false, includeIfNull: false)
  final num? sourceVersion;

  @JsonKey(name: r'bullets', required: true, includeIfNull: false)
  final List<TodayAnalysisBulletDto> bullets;

  @JsonKey(name: r'actionLabel', required: true, includeIfNull: false)
  final String actionLabel;

  @JsonKey(name: r'action', required: true, includeIfNull: false)
  final String action;

  @JsonKey(name: r'confidenceNote', required: true, includeIfNull: false)
  final String confidenceNote;

  @JsonKey(name: r'aiGenerated', required: true, includeIfNull: false)
  final bool aiGenerated;

  @JsonKey(name: r'metrics', required: false, includeIfNull: false)
  final List<TodayAnalysisMetricDto>? metrics;

  /// Stable URI identifying the problem type.
  @JsonKey(name: r'type', required: true, includeIfNull: false)
  final String type;

  /// Localized short summary of the problem.
  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  /// Localized, actionable description for this request.
  @JsonKey(name: r'detail', required: true, includeIfNull: false)
  final String detail;

  /// Stable machine-readable business code.
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  /// Safe structured validation errors keyed by field or general.
  @JsonKey(name: r'errors', required: false, includeIfNull: false)
  final Map<String, Object>? errors;

  /// Whether retrying may succeed, subject to client policy.
  @JsonKey(name: r'retryable', required: false, includeIfNull: false)
  final bool? retryable;

  /// Minimum delay before retrying, in seconds.
  // minimum: 0
  @JsonKey(name: r'retryAfter', required: false, includeIfNull: false)
  final num? retryAfter;

  /// Trace correlation identifier; never a business key.
  @JsonKey(name: r'traceId', required: false, includeIfNull: false)
  final String? traceId;

  /// Why the stream ended; this is not an HTTP status code.
  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        TodayAnalysisStreamResultDtoDataStatusEnum.unknownDefaultOpenApi,
  )
  final TodayAnalysisStreamResultDtoDataStatusEnum status;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayAnalysisStreamResultDtoData &&
          other.summary == summary &&
          other.date == date &&
          other.generatedAt == generatedAt &&
          other.sourceVersion == sourceVersion &&
          other.bullets == bullets &&
          other.actionLabel == actionLabel &&
          other.action == action &&
          other.confidenceNote == confidenceNote &&
          other.aiGenerated == aiGenerated &&
          other.metrics == metrics &&
          other.type == type &&
          other.title == title &&
          other.detail == detail &&
          other.code == code &&
          other.errors == errors &&
          other.retryable == retryable &&
          other.retryAfter == retryAfter &&
          other.traceId == traceId &&
          other.status == status;

  @override
  int get hashCode =>
      summary.hashCode +
      date.hashCode +
      generatedAt.hashCode +
      sourceVersion.hashCode +
      bullets.hashCode +
      actionLabel.hashCode +
      action.hashCode +
      confidenceNote.hashCode +
      aiGenerated.hashCode +
      metrics.hashCode +
      type.hashCode +
      title.hashCode +
      detail.hashCode +
      code.hashCode +
      errors.hashCode +
      retryable.hashCode +
      retryAfter.hashCode +
      traceId.hashCode +
      status.hashCode;

  factory TodayAnalysisStreamResultDtoData.fromJson(
    Map<String, dynamic> json,
  ) => _$TodayAnalysisStreamResultDtoDataFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TodayAnalysisStreamResultDtoDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Why the stream ended; this is not an HTTP status code.
enum TodayAnalysisStreamResultDtoDataStatusEnum {
  /// Why the stream ended; this is not an HTTP status code.
  @JsonValue(r'client_error')
  clientError(r'client_error'),

  /// Why the stream ended; this is not an HTTP status code.
  @JsonValue(r'server_error')
  serverError(r'server_error'),

  /// Why the stream ended; this is not an HTTP status code.
  @JsonValue(r'cancelled')
  cancelled(r'cancelled'),

  /// Why the stream ended; this is not an HTTP status code.
  @JsonValue(r'server_shutdown')
  serverShutdown(r'server_shutdown'),

  /// Why the stream ended; this is not an HTTP status code.
  @JsonValue(r'unknown')
  unknown(r'unknown'),

  /// Why the stream ended; this is not an HTTP status code.
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const TodayAnalysisStreamResultDtoDataStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
