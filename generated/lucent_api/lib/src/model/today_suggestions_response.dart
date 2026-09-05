//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/today_suggestions_response_primary.dart';
import 'package:lucent_api/src/model/today_suggestions_response_observations.dart';
import 'package:lucent_api/src/model/today_suggestions_response_secondary.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_suggestions_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodaySuggestionsResponse {
  /// Returns a new [TodaySuggestionsResponse] instance.
  TodaySuggestionsResponse({
    required this.generatedAt,

    this.primary,

    this.secondary,

    this.observations,

    this.degraded,

    required this.materializationStatus,

    required this.sourceVersion,

    required this.computedAt,

    required this.retryAfterSeconds,
  });

  /// When the suggestions were generated
  @JsonKey(name: r'generatedAt', required: true, includeIfNull: false)
  final String generatedAt;

  @JsonKey(name: r'primary', required: false, includeIfNull: false)
  final TodaySuggestionsResponsePrimary? primary;

  /// Secondary suggestion cards (max 2)
  @JsonKey(name: r'secondary', required: false, includeIfNull: false)
  final List<TodaySuggestionsResponseSecondary>? secondary;

  /// Low-confidence observations
  @JsonKey(name: r'observations', required: false, includeIfNull: false)
  final List<TodaySuggestionsResponseObservations>? observations;

  /// When true, one or more suggestion rules threw an error during evaluation — the returned list may be incomplete.
  @JsonKey(name: r'degraded', required: false, includeIfNull: false)
  final bool? degraded;

  /// Current background materialization state
  @JsonKey(
    name: r'materializationStatus',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        TodaySuggestionsResponseMaterializationStatusEnum.unknownDefaultOpenApi,
  )
  final TodaySuggestionsResponseMaterializationStatusEnum materializationStatus;

  /// Latest source version observed for this date
  @JsonKey(name: r'sourceVersion', required: true, includeIfNull: false)
  final num sourceVersion;

  @JsonKey(name: r'computedAt', required: true, includeIfNull: true)
  final String? computedAt;

  @JsonKey(name: r'retryAfterSeconds', required: true, includeIfNull: true)
  final num? retryAfterSeconds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodaySuggestionsResponse &&
          other.generatedAt == generatedAt &&
          other.primary == primary &&
          other.secondary == secondary &&
          other.observations == observations &&
          other.degraded == degraded &&
          other.materializationStatus == materializationStatus &&
          other.sourceVersion == sourceVersion &&
          other.computedAt == computedAt &&
          other.retryAfterSeconds == retryAfterSeconds;

  @override
  int get hashCode =>
      generatedAt.hashCode +
      primary.hashCode +
      secondary.hashCode +
      observations.hashCode +
      degraded.hashCode +
      materializationStatus.hashCode +
      sourceVersion.hashCode +
      (computedAt == null ? 0 : computedAt.hashCode) +
      (retryAfterSeconds == null ? 0 : retryAfterSeconds.hashCode);

  factory TodaySuggestionsResponse.fromJson(Map<String, dynamic> json) =>
      _$TodaySuggestionsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TodaySuggestionsResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Current background materialization state
enum TodaySuggestionsResponseMaterializationStatusEnum {
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

  const TodaySuggestionsResponseMaterializationStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
