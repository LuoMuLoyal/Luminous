//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analysis_data_bullets.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnalysisDataBullets {
  /// Returns a new [AnalysisDataBullets] instance.
  AnalysisDataBullets({required this.kind, required this.text});

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue: AnalysisDataBulletsKindEnum.unknownDefaultOpenApi,
  )
  final AnalysisDataBulletsKindEnum kind;

  @JsonKey(name: r'text', required: true, includeIfNull: false)
  final String text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisDataBullets && other.kind == kind && other.text == text;

  @override
  int get hashCode => kind.hashCode + text.hashCode;

  factory AnalysisDataBullets.fromJson(Map<String, dynamic> json) =>
      _$AnalysisDataBulletsFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisDataBulletsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum AnalysisDataBulletsKindEnum {
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

  const AnalysisDataBulletsKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
