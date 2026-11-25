//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/analysis_async_result_data_analysis.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analysis_async_result_data_result_any_of1.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnalysisAsyncResultDataResultAnyOf1 {
  /// Returns a new [AnalysisAsyncResultDataResultAnyOf1] instance.
  AnalysisAsyncResultDataResultAnyOf1({
    required this.analysis,

    required this.status,

    required this.sourceVersion,

    required this.computedVersion,

    required this.computedAt,

    required this.retryAfterSeconds,
  });

  @JsonKey(name: r'analysis', required: true, includeIfNull: true)
  final AnalysisAsyncResultDataAnalysis? analysis;

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        AnalysisAsyncResultDataResultAnyOf1StatusEnum.unknownDefaultOpenApi,
  )
  final AnalysisAsyncResultDataResultAnyOf1StatusEnum status;

  @JsonKey(name: r'sourceVersion', required: true, includeIfNull: false)
  final num sourceVersion;

  @JsonKey(name: r'computedVersion', required: true, includeIfNull: false)
  final num computedVersion;

  @JsonKey(name: r'computedAt', required: true, includeIfNull: true)
  final String? computedAt;

  @JsonKey(name: r'retryAfterSeconds', required: true, includeIfNull: true)
  final num? retryAfterSeconds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisAsyncResultDataResultAnyOf1 &&
          other.analysis == analysis &&
          other.status == status &&
          other.sourceVersion == sourceVersion &&
          other.computedVersion == computedVersion &&
          other.computedAt == computedAt &&
          other.retryAfterSeconds == retryAfterSeconds;

  @override
  int get hashCode =>
      (analysis == null ? 0 : analysis.hashCode) +
      status.hashCode +
      sourceVersion.hashCode +
      computedVersion.hashCode +
      (computedAt == null ? 0 : computedAt.hashCode) +
      (retryAfterSeconds == null ? 0 : retryAfterSeconds.hashCode);

  factory AnalysisAsyncResultDataResultAnyOf1.fromJson(
    Map<String, dynamic> json,
  ) => _$AnalysisAsyncResultDataResultAnyOf1FromJson(json);

  Map<String, dynamic> toJson() =>
      _$AnalysisAsyncResultDataResultAnyOf1ToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum AnalysisAsyncResultDataResultAnyOf1StatusEnum {
  @JsonValue(r'empty')
  empty(r'empty'),
  @JsonValue(r'pending')
  pending(r'pending'),
  @JsonValue(r'ready')
  ready(r'ready'),
  @JsonValue(r'stale')
  stale(r'stale'),
  @JsonValue(r'failed')
  failed(r'failed'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AnalysisAsyncResultDataResultAnyOf1StatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
