//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/report_weekly_summary_bullet_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_weekly_summary_data_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportWeeklySummaryDataDto {
  /// Returns a new [ReportWeeklySummaryDataDto] instance.
  ReportWeeklySummaryDataDto({
    required this.range,

    required this.startDate,

    required this.endDate,

    required this.generatedAt,

    required this.summary,

    required this.bullets,

    required this.actionLabel,

    required this.confidenceNote,
  });

  @JsonKey(
    name: r'range',
    required: true,
    includeIfNull: false,
    unknownEnumValue: ReportWeeklySummaryDataDtoRangeEnum.unknownDefaultOpenApi,
  )
  final ReportWeeklySummaryDataDtoRangeEnum range;

  @JsonKey(name: r'startDate', required: true, includeIfNull: false)
  final String startDate;

  @JsonKey(name: r'endDate', required: true, includeIfNull: false)
  final String endDate;

  @JsonKey(name: r'generatedAt', required: true, includeIfNull: false)
  final String generatedAt;

  @JsonKey(name: r'summary', required: true, includeIfNull: false)
  final String summary;

  @JsonKey(name: r'bullets', required: true, includeIfNull: false)
  final List<ReportWeeklySummaryBulletDto> bullets;

  @JsonKey(name: r'actionLabel', required: true, includeIfNull: false)
  final String actionLabel;

  @JsonKey(name: r'confidenceNote', required: true, includeIfNull: false)
  final String confidenceNote;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportWeeklySummaryDataDto &&
          other.range == range &&
          other.startDate == startDate &&
          other.endDate == endDate &&
          other.generatedAt == generatedAt &&
          other.summary == summary &&
          other.bullets == bullets &&
          other.actionLabel == actionLabel &&
          other.confidenceNote == confidenceNote;

  @override
  int get hashCode =>
      range.hashCode +
      startDate.hashCode +
      endDate.hashCode +
      generatedAt.hashCode +
      summary.hashCode +
      bullets.hashCode +
      actionLabel.hashCode +
      confidenceNote.hashCode;

  factory ReportWeeklySummaryDataDto.fromJson(Map<String, dynamic> json) =>
      _$ReportWeeklySummaryDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReportWeeklySummaryDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ReportWeeklySummaryDataDtoRangeEnum {
  @JsonValue(r'last_7_days')
  last7Days(r'last_7_days'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ReportWeeklySummaryDataDtoRangeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
