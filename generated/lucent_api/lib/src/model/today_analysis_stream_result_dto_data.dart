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

    this.metrics,

    required this.message,

    this.code,

    this.statusCode,
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

  @JsonKey(name: r'metrics', required: false, includeIfNull: false)
  final List<TodayAnalysisMetricDto>? metrics;

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'code', required: false, includeIfNull: false)
  final num? code;

  @JsonKey(name: r'statusCode', required: false, includeIfNull: false)
  final num? statusCode;

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
          other.metrics == metrics &&
          other.message == message &&
          other.code == code &&
          other.statusCode == statusCode;

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
      metrics.hashCode +
      message.hashCode +
      code.hashCode +
      statusCode.hashCode;

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
