//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/today_analysis_read_data_dto.dart';
import 'package:lucent_api/src/model/today_analysis_bullet_dto.dart';
import 'package:lucent_api/src/model/today_analysis_data_dto.dart';
import 'package:lucent_api/src/model/today_analysis_metric_dto.dart';
import 'package:lucent_api/src/model/today_analysis_refresh_pending_data_dto.dart';
import 'package:lucent_api/src/model/today_analysis_refresh_ready_data_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_analysis_controller_refresh_v1201_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayAnalysisControllerRefreshV1201Response {
  /// Returns a new [TodayAnalysisControllerRefreshV1201Response] instance.
  TodayAnalysisControllerRefreshV1201Response({
    required this.date,

    required this.generatedAt,

    required this.sourceVersion,

    required this.summary,

    required this.bullets,

    required this.actionLabel,

    required this.action,

    required this.confidenceNote,

    required this.aiGenerated,

    this.metrics,

    required this.analysis,

    required this.status,

    required this.computedVersion,

    required this.computedAt,

    required this.retryAfterSeconds,

    required this.jobId,
  });

  @JsonKey(name: r'date', required: true, includeIfNull: false)
  final String date;

  @JsonKey(name: r'generatedAt', required: true, includeIfNull: false)
  final String generatedAt;

  @JsonKey(name: r'sourceVersion', required: true, includeIfNull: false)
  final num sourceVersion;

  @JsonKey(name: r'summary', required: true, includeIfNull: false)
  final String summary;

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

  @JsonKey(name: r'analysis', required: true, includeIfNull: false)
  final TodayAnalysisDataDto analysis;

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue: TodayAnalysisControllerRefreshV1201ResponseStatusEnum
        .unknownDefaultOpenApi,
  )
  final TodayAnalysisControllerRefreshV1201ResponseStatusEnum status;

  @JsonKey(name: r'computedVersion', required: true, includeIfNull: false)
  final num computedVersion;

  @JsonKey(name: r'computedAt', required: true, includeIfNull: true)
  final String? computedAt;

  @JsonKey(name: r'retryAfterSeconds', required: true, includeIfNull: true)
  final num? retryAfterSeconds;

  @JsonKey(name: r'jobId', required: true, includeIfNull: false)
  final String jobId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayAnalysisControllerRefreshV1201Response &&
          other.date == date &&
          other.generatedAt == generatedAt &&
          other.sourceVersion == sourceVersion &&
          other.summary == summary &&
          other.bullets == bullets &&
          other.actionLabel == actionLabel &&
          other.action == action &&
          other.confidenceNote == confidenceNote &&
          other.aiGenerated == aiGenerated &&
          other.metrics == metrics &&
          other.analysis == analysis &&
          other.status == status &&
          other.computedVersion == computedVersion &&
          other.computedAt == computedAt &&
          other.retryAfterSeconds == retryAfterSeconds &&
          other.jobId == jobId;

  @override
  int get hashCode =>
      date.hashCode +
      generatedAt.hashCode +
      sourceVersion.hashCode +
      summary.hashCode +
      bullets.hashCode +
      actionLabel.hashCode +
      action.hashCode +
      confidenceNote.hashCode +
      aiGenerated.hashCode +
      metrics.hashCode +
      analysis.hashCode +
      status.hashCode +
      computedVersion.hashCode +
      (computedAt == null ? 0 : computedAt.hashCode) +
      (retryAfterSeconds == null ? 0 : retryAfterSeconds.hashCode) +
      jobId.hashCode;

  factory TodayAnalysisControllerRefreshV1201Response.fromJson(
    Map<String, dynamic> json,
  ) => _$TodayAnalysisControllerRefreshV1201ResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TodayAnalysisControllerRefreshV1201ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum TodayAnalysisControllerRefreshV1201ResponseStatusEnum {
  @JsonValue(r'ready')
  ready(r'ready'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const TodayAnalysisControllerRefreshV1201ResponseStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
