//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'report_finding_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportFindingDto {
  /// Returns a new [ReportFindingDto] instance.
  ReportFindingDto({
    required this.kind,

    required this.title,

    required this.body,
  });

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue: ReportFindingDtoKindEnum.unknownDefaultOpenApi,
  )
  final ReportFindingDtoKindEnum kind;

  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  @JsonKey(name: r'body', required: true, includeIfNull: false)
  final String body;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportFindingDto &&
          other.kind == kind &&
          other.title == title &&
          other.body == body;

  @override
  int get hashCode => kind.hashCode + title.hashCode + body.hashCode;

  factory ReportFindingDto.fromJson(Map<String, dynamic> json) =>
      _$ReportFindingDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReportFindingDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ReportFindingDtoKindEnum {
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

  const ReportFindingDtoKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
