//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analysis_async_result_data_bullets.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnalysisAsyncResultDataBullets {
  /// Returns a new [AnalysisAsyncResultDataBullets] instance.
  AnalysisAsyncResultDataBullets({required this.kind, required this.text});

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        AnalysisAsyncResultDataBulletsKindEnum.unknownDefaultOpenApi,
  )
  final AnalysisAsyncResultDataBulletsKindEnum kind;

  @JsonKey(name: r'text', required: true, includeIfNull: false)
  final String text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisAsyncResultDataBullets &&
          other.kind == kind &&
          other.text == text;

  @override
  int get hashCode => kind.hashCode + text.hashCode;

  factory AnalysisAsyncResultDataBullets.fromJson(Map<String, dynamic> json) =>
      _$AnalysisAsyncResultDataBulletsFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisAsyncResultDataBulletsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum AnalysisAsyncResultDataBulletsKindEnum {
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

  const AnalysisAsyncResultDataBulletsKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
