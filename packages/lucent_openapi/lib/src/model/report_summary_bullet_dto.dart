//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'report_summary_bullet_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportSummaryBulletDto {
  /// Returns a new [ReportSummaryBulletDto] instance.
  ReportSummaryBulletDto({required this.kind, required this.text});

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue: ReportSummaryBulletDtoKindEnum.unknownDefaultOpenApi,
  )
  final ReportSummaryBulletDtoKindEnum kind;

  @JsonKey(name: r'text', required: true, includeIfNull: false)
  final String text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportSummaryBulletDto &&
          other.kind == kind &&
          other.text == text;

  @override
  int get hashCode => kind.hashCode + text.hashCode;

  factory ReportSummaryBulletDto.fromJson(Map<String, dynamic> json) =>
      _$ReportSummaryBulletDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReportSummaryBulletDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ReportSummaryBulletDtoKindEnum {
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

  const ReportSummaryBulletDtoKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
