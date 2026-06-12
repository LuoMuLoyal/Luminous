//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/today_analysis_bullet_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_analysis_data_dto.g.dart';

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

    required this.summary,

    required this.bullets,

    required this.actionLabel,

    required this.confidenceNote,
  });

  @JsonKey(name: r'date', required: true, includeIfNull: false)
  final String date;

  @JsonKey(name: r'generatedAt', required: true, includeIfNull: false)
  final String generatedAt;

  @JsonKey(name: r'summary', required: true, includeIfNull: false)
  final String summary;

  @JsonKey(name: r'bullets', required: true, includeIfNull: false)
  final List<TodayAnalysisBulletDto> bullets;

  @JsonKey(name: r'actionLabel', required: true, includeIfNull: false)
  final String actionLabel;

  @JsonKey(name: r'confidenceNote', required: true, includeIfNull: false)
  final String confidenceNote;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayAnalysisDataDto &&
          other.date == date &&
          other.generatedAt == generatedAt &&
          other.summary == summary &&
          other.bullets == bullets &&
          other.actionLabel == actionLabel &&
          other.confidenceNote == confidenceNote;

  @override
  int get hashCode =>
      date.hashCode +
      generatedAt.hashCode +
      summary.hashCode +
      bullets.hashCode +
      actionLabel.hashCode +
      confidenceNote.hashCode;

  factory TodayAnalysisDataDto.fromJson(Map<String, dynamic> json) =>
      _$TodayAnalysisDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TodayAnalysisDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
