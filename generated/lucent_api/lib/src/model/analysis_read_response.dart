//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/analysis_read_response_analysis.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analysis_read_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnalysisReadResponse {
  /// Returns a new [AnalysisReadResponse] instance.
  AnalysisReadResponse({
    required this.analysis,

    required this.status,

    required this.sourceVersion,

    required this.computedVersion,

    required this.computedAt,

    required this.retryAfterSeconds,
  });

  @JsonKey(name: r'analysis', required: true, includeIfNull: true)
  final AnalysisReadResponseAnalysis? analysis;

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue: AnalysisReadResponseStatusEnum.unknownDefaultOpenApi,
  )
  final AnalysisReadResponseStatusEnum status;

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
      other is AnalysisReadResponse &&
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

  factory AnalysisReadResponse.fromJson(Map<String, dynamic> json) =>
      _$AnalysisReadResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisReadResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum AnalysisReadResponseStatusEnum {
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

  const AnalysisReadResponseStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
