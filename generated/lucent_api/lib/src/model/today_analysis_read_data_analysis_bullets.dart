//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_analysis_read_data_analysis_bullets.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayAnalysisReadDataAnalysisBullets {
  /// Returns a new [TodayAnalysisReadDataAnalysisBullets] instance.
  TodayAnalysisReadDataAnalysisBullets({
    required this.kind,

    required this.text,
  });

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        TodayAnalysisReadDataAnalysisBulletsKindEnum.unknownDefaultOpenApi,
  )
  final TodayAnalysisReadDataAnalysisBulletsKindEnum kind;

  @JsonKey(name: r'text', required: true, includeIfNull: false)
  final String text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayAnalysisReadDataAnalysisBullets &&
          other.kind == kind &&
          other.text == text;

  @override
  int get hashCode => kind.hashCode + text.hashCode;

  factory TodayAnalysisReadDataAnalysisBullets.fromJson(
    Map<String, dynamic> json,
  ) => _$TodayAnalysisReadDataAnalysisBulletsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TodayAnalysisReadDataAnalysisBulletsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum TodayAnalysisReadDataAnalysisBulletsKindEnum {
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

  const TodayAnalysisReadDataAnalysisBulletsKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
