//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/today_suggestions_response_dto_primary_evidence_inner.dart';
import 'package:lucent_api/src/model/today_suggestions_response_dto_primary_observed_metric.dart';
import 'package:lucent_api/src/model/today_suggestions_response_dto_primary_secondary_actions_inner.dart';
import 'package:lucent_api/src/model/today_suggestions_response_dto_primary_primary_action.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_suggestions_response_dto_primary.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodaySuggestionsResponseDtoPrimary {
  /// Returns a new [TodaySuggestionsResponseDtoPrimary] instance.
  TodaySuggestionsResponseDtoPrimary({
    required this.id,

    required this.type,

    required this.cardTone,

    required this.icon,

    required this.title,

    required this.reason,

    required this.evidence,

    required this.boundary,

    required this.primaryAction,

    this.secondaryActions,

    required this.confidence,

    required this.ruleId,

    required this.ruleVersion,

    required this.triggerType,

    required this.lifecycleState,

    this.notificationEligible,

    this.feedbackOptions,

    this.subtype,

    this.observedMetric,
  });

  /// Unique suggestion id
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  /// Suggestion type
  @JsonKey(
    name: r'type',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        TodaySuggestionsResponseDtoPrimaryTypeEnum.unknownDefaultOpenApi,
  )
  final TodaySuggestionsResponseDtoPrimaryTypeEnum type;

  /// Visual tone hint
  @JsonKey(
    name: r'cardTone',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        TodaySuggestionsResponseDtoPrimaryCardToneEnum.unknownDefaultOpenApi,
  )
  final TodaySuggestionsResponseDtoPrimaryCardToneEnum cardTone;

  /// Icon identifier for the frontend
  @JsonKey(name: r'icon', required: true, includeIfNull: false)
  final String icon;

  /// Localized short title
  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  /// Why this suggestion appeared
  @JsonKey(name: r'reason', required: true, includeIfNull: false)
  final String reason;

  /// Evidence items
  @JsonKey(name: r'evidence', required: true, includeIfNull: false)
  final List<TodaySuggestionsResponseDtoPrimaryEvidenceInner> evidence;

  /// Medical disclaimer / boundary text
  @JsonKey(name: r'boundary', required: true, includeIfNull: false)
  final String boundary;

  @JsonKey(name: r'primaryAction', required: true, includeIfNull: false)
  final TodaySuggestionsResponseDtoPrimaryPrimaryAction primaryAction;

  /// Secondary actions
  @JsonKey(name: r'secondaryActions', required: false, includeIfNull: false)
  final List<TodaySuggestionsResponseDtoPrimarySecondaryActionsInner>?
  secondaryActions;

  /// Confidence level
  @JsonKey(
    name: r'confidence',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        TodaySuggestionsResponseDtoPrimaryConfidenceEnum.unknownDefaultOpenApi,
  )
  final TodaySuggestionsResponseDtoPrimaryConfidenceEnum confidence;

  /// Rule identifier for auditability
  @JsonKey(name: r'ruleId', required: true, includeIfNull: false)
  final String ruleId;

  /// Rule version
  @JsonKey(name: r'ruleVersion', required: true, includeIfNull: false)
  final String ruleVersion;

  /// Trigger type
  @JsonKey(
    name: r'triggerType',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        TodaySuggestionsResponseDtoPrimaryTriggerTypeEnum.unknownDefaultOpenApi,
  )
  final TodaySuggestionsResponseDtoPrimaryTriggerTypeEnum triggerType;

  /// Lifecycle state
  @JsonKey(
    name: r'lifecycleState',
    required: true,
    includeIfNull: false,
    unknownEnumValue: TodaySuggestionsResponseDtoPrimaryLifecycleStateEnum
        .unknownDefaultOpenApi,
  )
  final TodaySuggestionsResponseDtoPrimaryLifecycleStateEnum lifecycleState;

  /// Whether this card can trigger a notification
  @JsonKey(name: r'notificationEligible', required: false, includeIfNull: false)
  final bool? notificationEligible;

  /// Available feedback options for this card
  @JsonKey(name: r'feedbackOptions', required: false, includeIfNull: false)
  final List<TodaySuggestionsResponseDtoPrimaryFeedbackOptionsEnum>?
  feedbackOptions;

  /// Sub-type for rendering variety
  @JsonKey(name: r'subtype', required: false, includeIfNull: false)
  final String? subtype;

  @JsonKey(name: r'observedMetric', required: false, includeIfNull: false)
  final TodaySuggestionsResponseDtoPrimaryObservedMetric? observedMetric;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodaySuggestionsResponseDtoPrimary &&
          other.id == id &&
          other.type == type &&
          other.cardTone == cardTone &&
          other.icon == icon &&
          other.title == title &&
          other.reason == reason &&
          other.evidence == evidence &&
          other.boundary == boundary &&
          other.primaryAction == primaryAction &&
          other.secondaryActions == secondaryActions &&
          other.confidence == confidence &&
          other.ruleId == ruleId &&
          other.ruleVersion == ruleVersion &&
          other.triggerType == triggerType &&
          other.lifecycleState == lifecycleState &&
          other.notificationEligible == notificationEligible &&
          other.feedbackOptions == feedbackOptions &&
          other.subtype == subtype &&
          other.observedMetric == observedMetric;

  @override
  int get hashCode =>
      id.hashCode +
      type.hashCode +
      cardTone.hashCode +
      icon.hashCode +
      title.hashCode +
      reason.hashCode +
      evidence.hashCode +
      boundary.hashCode +
      primaryAction.hashCode +
      secondaryActions.hashCode +
      confidence.hashCode +
      ruleId.hashCode +
      ruleVersion.hashCode +
      triggerType.hashCode +
      lifecycleState.hashCode +
      notificationEligible.hashCode +
      feedbackOptions.hashCode +
      subtype.hashCode +
      observedMetric.hashCode;

  factory TodaySuggestionsResponseDtoPrimary.fromJson(
    Map<String, dynamic> json,
  ) => _$TodaySuggestionsResponseDtoPrimaryFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TodaySuggestionsResponseDtoPrimaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Suggestion type
enum TodaySuggestionsResponseDtoPrimaryTypeEnum {
  @JsonValue(r'confirmed_risk')
  confirmedRisk(r'confirmed_risk'),
  @JsonValue(r'compliance')
  compliance(r'compliance'),
  @JsonValue(r'trend')
  trend(r'trend'),
  @JsonValue(r'behavior_advice')
  behaviorAdvice(r'behavior_advice'),
  @JsonValue(r'coverage')
  coverage(r'coverage'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const TodaySuggestionsResponseDtoPrimaryTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Visual tone hint
enum TodaySuggestionsResponseDtoPrimaryCardToneEnum {
  @JsonValue(r'urgent')
  urgent(r'urgent'),
  @JsonValue(r'warning')
  warning(r'warning'),
  @JsonValue(r'emphasis')
  emphasis(r'emphasis'),
  @JsonValue(r'soft')
  soft(r'soft'),
  @JsonValue(r'neutral')
  neutral(r'neutral'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const TodaySuggestionsResponseDtoPrimaryCardToneEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Confidence level
enum TodaySuggestionsResponseDtoPrimaryConfidenceEnum {
  @JsonValue(r'high')
  high(r'high'),
  @JsonValue(r'medium')
  medium(r'medium'),
  @JsonValue(r'low')
  low(r'low'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const TodaySuggestionsResponseDtoPrimaryConfidenceEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Trigger type
enum TodaySuggestionsResponseDtoPrimaryTriggerTypeEnum {
  @JsonValue(r'event')
  event(r'event'),
  @JsonValue(r'timer')
  timer(r'timer'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const TodaySuggestionsResponseDtoPrimaryTriggerTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Lifecycle state
enum TodaySuggestionsResponseDtoPrimaryLifecycleStateEnum {
  @JsonValue(r'generated')
  generated(r'generated'),
  @JsonValue(r'active')
  active(r'active'),
  @JsonValue(r'fading')
  fading(r'fading'),
  @JsonValue(r'expired')
  expired(r'expired'),
  @JsonValue(r'dismissed')
  dismissed(r'dismissed'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const TodaySuggestionsResponseDtoPrimaryLifecycleStateEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum TodaySuggestionsResponseDtoPrimaryFeedbackOptionsEnum {
  @JsonValue(r'accepted')
  accepted(r'accepted'),
  @JsonValue(r'later')
  later(r'later'),
  @JsonValue(r'not_applicable')
  notApplicable(r'not_applicable'),
  @JsonValue(r'suppress')
  suppress(r'suppress'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const TodaySuggestionsResponseDtoPrimaryFeedbackOptionsEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
