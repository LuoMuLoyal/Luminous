//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/suggestion_item_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_suggestions_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodaySuggestionsResponseDto {
  /// Returns a new [TodaySuggestionsResponseDto] instance.
  TodaySuggestionsResponseDto({
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

  /// Primary suggestion card (highest priority)
  @JsonKey(name: r'primary', required: false, includeIfNull: false)
  final SuggestionItemDto? primary;

  /// Secondary suggestion cards (max 2)
  @JsonKey(name: r'secondary', required: false, includeIfNull: false)
  final List<SuggestionItemDto>? secondary;

  /// Low-confidence observations
  @JsonKey(name: r'observations', required: false, includeIfNull: false)
  final List<SuggestionItemDto>? observations;

  /// When true, one or more suggestion rules threw an error during evaluation — the returned list may be incomplete.
  @JsonKey(name: r'degraded', required: false, includeIfNull: false)
  final Object? degraded;

  /// Current background materialization state
  @JsonKey(
    name: r'materializationStatus',
    required: true,
    includeIfNull: false,
    unknownEnumValue: TodaySuggestionsResponseDtoMaterializationStatusEnum
        .unknownDefaultOpenApi,
  )
  final TodaySuggestionsResponseDtoMaterializationStatusEnum
  materializationStatus;

  /// Latest source version observed for this date
  @JsonKey(name: r'sourceVersion', required: true, includeIfNull: false)
  final num sourceVersion;

  /// When the last successful materialization completed
  @JsonKey(name: r'computedAt', required: true, includeIfNull: true)
  final String? computedAt;

  /// Suggested client polling delay in seconds
  @JsonKey(name: r'retryAfterSeconds', required: true, includeIfNull: true)
  final num? retryAfterSeconds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodaySuggestionsResponseDto &&
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

  factory TodaySuggestionsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TodaySuggestionsResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TodaySuggestionsResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Current background materialization state
enum TodaySuggestionsResponseDtoMaterializationStatusEnum {
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

  const TodaySuggestionsResponseDtoMaterializationStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
