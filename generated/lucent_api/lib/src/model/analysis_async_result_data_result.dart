//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/analysis_async_result_data_metrics.dart';
import 'package:lucent_api/src/model/analysis_async_result_data_result_any_of1.dart';
import 'package:lucent_api/src/model/analysis_async_result_data_result_any_of.dart';
import 'package:lucent_api/src/model/analysis_async_result_data_analysis.dart';
import 'package:lucent_api/src/model/analysis_async_result_data_bullets.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analysis_async_result_data_result.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnalysisAsyncResultDataResult {
  /// Returns a new [AnalysisAsyncResultDataResult] instance.
  AnalysisAsyncResultDataResult({
    required this.date,

    required this.generatedAt,

    required this.sourceVersion,

    required this.summary,

    required this.bullets,

    required this.actionLabel,

    required this.action,

    required this.confidenceNote,

    required this.briefingGenerated,

    this.metrics,

    required this.analysis,

    required this.status,

    required this.computedVersion,

    required this.computedAt,

    required this.retryAfterSeconds,
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
  final List<AnalysisAsyncResultDataBullets> bullets;

  @JsonKey(name: r'actionLabel', required: true, includeIfNull: false)
  final String actionLabel;

  @JsonKey(name: r'action', required: true, includeIfNull: false)
  final String action;

  @JsonKey(name: r'confidenceNote', required: true, includeIfNull: false)
  final String confidenceNote;

  @JsonKey(name: r'briefingGenerated', required: true, includeIfNull: false)
  final bool briefingGenerated;

  @JsonKey(name: r'metrics', required: false, includeIfNull: false)
  final List<AnalysisAsyncResultDataMetrics>? metrics;

  @JsonKey(name: r'analysis', required: true, includeIfNull: true)
  final AnalysisAsyncResultDataAnalysis? analysis;

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        AnalysisAsyncResultDataResultStatusEnum.unknownDefaultOpenApi,
  )
  final AnalysisAsyncResultDataResultStatusEnum status;

  @JsonKey(name: r'computedVersion', required: true, includeIfNull: false)
  final num computedVersion;

  @JsonKey(name: r'computedAt', required: true, includeIfNull: true)
  final String? computedAt;

  @JsonKey(name: r'retryAfterSeconds', required: true, includeIfNull: true)
  final num? retryAfterSeconds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisAsyncResultDataResult &&
          other.date == date &&
          other.generatedAt == generatedAt &&
          other.sourceVersion == sourceVersion &&
          other.summary == summary &&
          other.bullets == bullets &&
          other.actionLabel == actionLabel &&
          other.action == action &&
          other.confidenceNote == confidenceNote &&
          other.briefingGenerated == briefingGenerated &&
          other.metrics == metrics &&
          other.analysis == analysis &&
          other.status == status &&
          other.computedVersion == computedVersion &&
          other.computedAt == computedAt &&
          other.retryAfterSeconds == retryAfterSeconds;

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
      briefingGenerated.hashCode +
      metrics.hashCode +
      (analysis == null ? 0 : analysis.hashCode) +
      status.hashCode +
      computedVersion.hashCode +
      (computedAt == null ? 0 : computedAt.hashCode) +
      (retryAfterSeconds == null ? 0 : retryAfterSeconds.hashCode);

  factory AnalysisAsyncResultDataResult.fromJson(Map<String, dynamic> json) =>
      _$AnalysisAsyncResultDataResultFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisAsyncResultDataResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum AnalysisAsyncResultDataResultStatusEnum {
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

  const AnalysisAsyncResultDataResultStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
