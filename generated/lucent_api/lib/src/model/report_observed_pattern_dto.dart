//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_observed_pattern_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportObservedPatternDto {
  /// Returns a new [ReportObservedPatternDto] instance.
  ReportObservedPatternDto({
    required this.kind,

    required this.text,

    required this.source_,
  });

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue: ReportObservedPatternDtoKindEnum.unknownDefaultOpenApi,
  )
  final ReportObservedPatternDtoKindEnum kind;

  @JsonKey(name: r'text', required: true, includeIfNull: false)
  final String text;

  @JsonKey(name: r'source', required: true, includeIfNull: false)
  final String source_;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportObservedPatternDto &&
          other.kind == kind &&
          other.text == text &&
          other.source_ == source_;

  @override
  int get hashCode => kind.hashCode + text.hashCode + source_.hashCode;

  factory ReportObservedPatternDto.fromJson(Map<String, dynamic> json) =>
      _$ReportObservedPatternDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReportObservedPatternDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ReportObservedPatternDtoKindEnum {
  @JsonValue(r'medication')
  medication(r'medication'),
  @JsonValue(r'hydration')
  hydration(r'hydration'),
  @JsonValue(r'sleep')
  sleep(r'sleep'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ReportObservedPatternDtoKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
