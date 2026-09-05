//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/event_review_response_sections_completed_actions_facts.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_review_response_sections_completed_actions.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventReviewResponseSectionsCompletedActions {
  /// Returns a new [EventReviewResponseSectionsCompletedActions] instance.
  EventReviewResponseSectionsCompletedActions({
    required this.state,

    this.reasonCode,

    this.facts,
  });

  @JsonKey(
    name: r'state',
    required: true,
    includeIfNull: false,
    unknownEnumValue: EventReviewResponseSectionsCompletedActionsStateEnum
        .unknownDefaultOpenApi,
  )
  final EventReviewResponseSectionsCompletedActionsStateEnum state;

  /// Fixed reason code when state is unknown: no_observations (window has no observations), no_completed_actions (no confirmed doses or check-ins), insufficient_coverage (observations exist but no trend is computable).
  @JsonKey(
    name: r'reasonCode',
    required: false,
    includeIfNull: false,
    unknownEnumValue: EventReviewResponseSectionsCompletedActionsReasonCodeEnum
        .unknownDefaultOpenApi,
  )
  final EventReviewResponseSectionsCompletedActionsReasonCodeEnum? reasonCode;

  @JsonKey(name: r'facts', required: false, includeIfNull: false)
  final EventReviewResponseSectionsCompletedActionsFacts? facts;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventReviewResponseSectionsCompletedActions &&
          other.state == state &&
          other.reasonCode == reasonCode &&
          other.facts == facts;

  @override
  int get hashCode => state.hashCode + reasonCode.hashCode + facts.hashCode;

  factory EventReviewResponseSectionsCompletedActions.fromJson(
    Map<String, dynamic> json,
  ) => _$EventReviewResponseSectionsCompletedActionsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$EventReviewResponseSectionsCompletedActionsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum EventReviewResponseSectionsCompletedActionsStateEnum {
  @JsonValue(r'available')
  available(r'available'),
  @JsonValue(r'unknown')
  unknown(r'unknown'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const EventReviewResponseSectionsCompletedActionsStateEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Fixed reason code when state is unknown: no_observations (window has no observations), no_completed_actions (no confirmed doses or check-ins), insufficient_coverage (observations exist but no trend is computable).
enum EventReviewResponseSectionsCompletedActionsReasonCodeEnum {
  @JsonValue(r'no_observations')
  noObservations(r'no_observations'),
  @JsonValue(r'no_completed_actions')
  noCompletedActions(r'no_completed_actions'),
  @JsonValue(r'insufficient_coverage')
  insufficientCoverage(r'insufficient_coverage'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const EventReviewResponseSectionsCompletedActionsReasonCodeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
