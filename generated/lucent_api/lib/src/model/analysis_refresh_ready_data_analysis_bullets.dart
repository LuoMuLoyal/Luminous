//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analysis_refresh_ready_data_analysis_bullets.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnalysisRefreshReadyDataAnalysisBullets {
  /// Returns a new [AnalysisRefreshReadyDataAnalysisBullets] instance.
  AnalysisRefreshReadyDataAnalysisBullets({
    required this.kind,

    required this.text,
  });

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        AnalysisRefreshReadyDataAnalysisBulletsKindEnum.unknownDefaultOpenApi,
  )
  final AnalysisRefreshReadyDataAnalysisBulletsKindEnum kind;

  @JsonKey(name: r'text', required: true, includeIfNull: false)
  final String text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisRefreshReadyDataAnalysisBullets &&
          other.kind == kind &&
          other.text == text;

  @override
  int get hashCode => kind.hashCode + text.hashCode;

  factory AnalysisRefreshReadyDataAnalysisBullets.fromJson(
    Map<String, dynamic> json,
  ) => _$AnalysisRefreshReadyDataAnalysisBulletsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AnalysisRefreshReadyDataAnalysisBulletsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum AnalysisRefreshReadyDataAnalysisBulletsKindEnum {
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

  const AnalysisRefreshReadyDataAnalysisBulletsKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
