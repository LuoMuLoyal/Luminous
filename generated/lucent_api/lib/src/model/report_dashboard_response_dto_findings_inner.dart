//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_dashboard_response_dto_findings_inner.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportDashboardResponseDtoFindingsInner {
  /// Returns a new [ReportDashboardResponseDtoFindingsInner] instance.
  ReportDashboardResponseDtoFindingsInner({
    required this.kind,

    required this.title,

    required this.body,
  });

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        ReportDashboardResponseDtoFindingsInnerKindEnum.unknownDefaultOpenApi,
  )
  final ReportDashboardResponseDtoFindingsInnerKindEnum kind;

  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  @JsonKey(name: r'body', required: true, includeIfNull: false)
  final String body;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportDashboardResponseDtoFindingsInner &&
          other.kind == kind &&
          other.title == title &&
          other.body == body;

  @override
  int get hashCode => kind.hashCode + title.hashCode + body.hashCode;

  factory ReportDashboardResponseDtoFindingsInner.fromJson(
    Map<String, dynamic> json,
  ) => _$ReportDashboardResponseDtoFindingsInnerFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ReportDashboardResponseDtoFindingsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ReportDashboardResponseDtoFindingsInnerKindEnum {
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

  const ReportDashboardResponseDtoFindingsInnerKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
