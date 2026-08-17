//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/today_analysis_bullet_dto.dart';
import 'package:lucent_api/src/model/today_analysis_metric_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_analysis_data_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayAnalysisDataDto {
  /// Returns a new [TodayAnalysisDataDto] instance.
  TodayAnalysisDataDto({
    required this.date,

    required this.generatedAt,

    this.sourceVersion,

    required this.summary,

    required this.bullets,

    required this.actionLabel,

    required this.action,

    required this.confidenceNote,

    required this.aiGenerated,

    this.metrics,
  });

  @JsonKey(name: r'date', required: true, includeIfNull: false)
  final String date;

  @JsonKey(name: r'generatedAt', required: true, includeIfNull: false)
  final String generatedAt;

  @JsonKey(name: r'sourceVersion', required: false, includeIfNull: false)
  final num? sourceVersion;

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayAnalysisDataDto &&
          other.date == date &&
          other.generatedAt == generatedAt &&
          other.sourceVersion == sourceVersion &&
          other.summary == summary &&
          other.bullets == bullets &&
          other.actionLabel == actionLabel &&
          other.action == action &&
          other.confidenceNote == confidenceNote &&
          other.aiGenerated == aiGenerated &&
          other.metrics == metrics;

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
      metrics.hashCode;

  factory TodayAnalysisDataDto.fromJson(Map<String, dynamic> json) =>
      _$TodayAnalysisDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TodayAnalysisDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
