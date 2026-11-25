//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analysis_async_result_data_analysis_bullets.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnalysisAsyncResultDataAnalysisBullets {
  /// Returns a new [AnalysisAsyncResultDataAnalysisBullets] instance.
  AnalysisAsyncResultDataAnalysisBullets({
    required this.kind,

    required this.text,
  });

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        AnalysisAsyncResultDataAnalysisBulletsKindEnum.unknownDefaultOpenApi,
  )
  final AnalysisAsyncResultDataAnalysisBulletsKindEnum kind;

  @JsonKey(name: r'text', required: true, includeIfNull: false)
  final String text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisAsyncResultDataAnalysisBullets &&
          other.kind == kind &&
          other.text == text;

  @override
  int get hashCode => kind.hashCode + text.hashCode;

  factory AnalysisAsyncResultDataAnalysisBullets.fromJson(
    Map<String, dynamic> json,
  ) => _$AnalysisAsyncResultDataAnalysisBulletsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AnalysisAsyncResultDataAnalysisBulletsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum AnalysisAsyncResultDataAnalysisBulletsKindEnum {
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

  const AnalysisAsyncResultDataAnalysisBulletsKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
