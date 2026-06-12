//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'report_weekly_summary_bullet_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportWeeklySummaryBulletDto {
  /// Returns a new [ReportWeeklySummaryBulletDto] instance.
  ReportWeeklySummaryBulletDto({required this.kind, required this.text});

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        ReportWeeklySummaryBulletDtoKindEnum.unknownDefaultOpenApi,
  )
  final ReportWeeklySummaryBulletDtoKindEnum kind;

  @JsonKey(name: r'text', required: true, includeIfNull: false)
  final String text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportWeeklySummaryBulletDto &&
          other.kind == kind &&
          other.text == text;

  @override
  int get hashCode => kind.hashCode + text.hashCode;

  factory ReportWeeklySummaryBulletDto.fromJson(Map<String, dynamic> json) =>
      _$ReportWeeklySummaryBulletDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReportWeeklySummaryBulletDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ReportWeeklySummaryBulletDtoKindEnum {
  @JsonValue(r'medication')
  medication(r'medication'),
  @JsonValue(r'hydration')
  hydration(r'hydration'),
  @JsonValue(r'sleep')
  sleep(r'sleep'),
  @JsonValue(r'general')
  general(r'general'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ReportWeeklySummaryBulletDtoKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
