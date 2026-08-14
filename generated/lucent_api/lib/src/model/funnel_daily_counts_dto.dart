//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'funnel_daily_counts_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FunnelDailyCountsDto {
  /// Returns a new [FunnelDailyCountsDto] instance.
  FunnelDailyCountsDto({
    required this.date,

    required this.eventStarted,

    required this.suggestionImpression,

    required this.suggestionActioned,

    required this.eventEndedOrOutcome,

    required this.reviewOpened,
  });

  /// UTC calendar day (YYYY-MM-DD).
  @JsonKey(name: r'date', required: true, includeIfNull: false)
  final String date;

  /// health_event_started count.
  @JsonKey(name: r'eventStarted', required: true, includeIfNull: false)
  final num eventStarted;

  /// suggestion_impression count.
  @JsonKey(name: r'suggestionImpression', required: true, includeIfNull: false)
  final num suggestionImpression;

  /// suggestion_actioned count.
  @JsonKey(name: r'suggestionActioned', required: true, includeIfNull: false)
  final num suggestionActioned;

  /// health_event_ended + health_event_outcome_confirmed count — the ended/outcome stage (both names are the same user-visible step).
  @JsonKey(name: r'eventEndedOrOutcome', required: true, includeIfNull: false)
  final num eventEndedOrOutcome;

  /// review_opened count.
  @JsonKey(name: r'reviewOpened', required: true, includeIfNull: false)
  final num reviewOpened;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunnelDailyCountsDto &&
          other.date == date &&
          other.eventStarted == eventStarted &&
          other.suggestionImpression == suggestionImpression &&
          other.suggestionActioned == suggestionActioned &&
          other.eventEndedOrOutcome == eventEndedOrOutcome &&
          other.reviewOpened == reviewOpened;

  @override
  int get hashCode =>
      date.hashCode +
      eventStarted.hashCode +
      suggestionImpression.hashCode +
      suggestionActioned.hashCode +
      eventEndedOrOutcome.hashCode +
      reviewOpened.hashCode;

  factory FunnelDailyCountsDto.fromJson(Map<String, dynamic> json) =>
      _$FunnelDailyCountsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FunnelDailyCountsDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
