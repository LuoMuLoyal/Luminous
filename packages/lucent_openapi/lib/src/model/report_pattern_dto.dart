//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'report_pattern_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportPatternDto {
  /// Returns a new [ReportPatternDto] instance.
  ReportPatternDto({
    required this.kind,

    required this.title,

    required this.status,

    required this.body,

    required this.sparkline,
  });

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue: ReportPatternDtoKindEnum.unknownDefaultOpenApi,
  )
  final ReportPatternDtoKindEnum kind;

  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue: ReportPatternDtoStatusEnum.unknownDefaultOpenApi,
  )
  final ReportPatternDtoStatusEnum status;

  @JsonKey(name: r'body', required: true, includeIfNull: false)
  final String body;

  @JsonKey(name: r'sparkline', required: true, includeIfNull: false)
  final List<num> sparkline;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportPatternDto &&
          other.kind == kind &&
          other.title == title &&
          other.status == status &&
          other.body == body &&
          other.sparkline == sparkline;

  @override
  int get hashCode =>
      kind.hashCode +
      title.hashCode +
      status.hashCode +
      body.hashCode +
      sparkline.hashCode;

  factory ReportPatternDto.fromJson(Map<String, dynamic> json) =>
      _$ReportPatternDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReportPatternDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ReportPatternDtoKindEnum {
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

  const ReportPatternDtoKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum ReportPatternDtoStatusEnum {
  @JsonValue(r'good')
  good(r'good'),
  @JsonValue(r'stable')
  stable(r'stable'),
  @JsonValue(r'needs_attention')
  needsAttention(r'needs_attention'),
  @JsonValue(r'insufficient_data')
  insufficientData(r'insufficient_data'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ReportPatternDtoStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
