//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'funnel_response_dto_totals.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FunnelResponseDtoTotals {
  /// Returns a new [FunnelResponseDtoTotals] instance.
  FunnelResponseDtoTotals({
    required this.eventStarted,

    required this.suggestionImpression,

    required this.suggestionActioned,

    required this.eventEndedOrOutcome,

    required this.reviewOpened,
  });

  /// health_event_started count.
  @JsonKey(name: r'eventStarted', required: true, includeIfNull: false)
  final num eventStarted;

  /// suggestion_impression count.
  @JsonKey(name: r'suggestionImpression', required: true, includeIfNull: false)
  final num suggestionImpression;

  /// suggestion_actioned count.
  @JsonKey(name: r'suggestionActioned', required: true, includeIfNull: false)
  final num suggestionActioned;

  /// ended/outcome stage count.
  @JsonKey(name: r'eventEndedOrOutcome', required: true, includeIfNull: false)
  final num eventEndedOrOutcome;

  /// review_opened count.
  @JsonKey(name: r'reviewOpened', required: true, includeIfNull: false)
  final num reviewOpened;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunnelResponseDtoTotals &&
          other.eventStarted == eventStarted &&
          other.suggestionImpression == suggestionImpression &&
          other.suggestionActioned == suggestionActioned &&
          other.eventEndedOrOutcome == eventEndedOrOutcome &&
          other.reviewOpened == reviewOpened;

  @override
  int get hashCode =>
      eventStarted.hashCode +
      suggestionImpression.hashCode +
      suggestionActioned.hashCode +
      eventEndedOrOutcome.hashCode +
      reviewOpened.hashCode;

  factory FunnelResponseDtoTotals.fromJson(Map<String, dynamic> json) =>
      _$FunnelResponseDtoTotalsFromJson(json);

  Map<String, dynamic> toJson() => _$FunnelResponseDtoTotalsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
