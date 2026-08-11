//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/suggestion_action_dto.dart';
import 'package:lucent_api/src/model/evidence_item_dto.dart';
import 'package:lucent_api/src/model/suggestion_observed_metric_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'suggestion_item_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SuggestionItemDto {
  /// Returns a new [SuggestionItemDto] instance.
  SuggestionItemDto({
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
    unknownEnumValue: SuggestionItemDtoTypeEnum.unknownDefaultOpenApi,
  )
  final SuggestionItemDtoTypeEnum type;

  /// Visual tone hint
  @JsonKey(
    name: r'cardTone',
    required: true,
    includeIfNull: false,
    unknownEnumValue: SuggestionItemDtoCardToneEnum.unknownDefaultOpenApi,
  )
  final SuggestionItemDtoCardToneEnum cardTone;

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
  final List<EvidenceItemDto> evidence;

  /// Medical disclaimer / boundary text
  @JsonKey(name: r'boundary', required: true, includeIfNull: false)
  final String boundary;

  /// Primary action
  @JsonKey(name: r'primaryAction', required: true, includeIfNull: false)
  final SuggestionActionDto primaryAction;

  /// Secondary actions
  @JsonKey(name: r'secondaryActions', required: false, includeIfNull: false)
  final List<SuggestionActionDto>? secondaryActions;

  /// Confidence level
  @JsonKey(
    name: r'confidence',
    required: true,
    includeIfNull: false,
    unknownEnumValue: SuggestionItemDtoConfidenceEnum.unknownDefaultOpenApi,
  )
  final SuggestionItemDtoConfidenceEnum confidence;

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
    unknownEnumValue: SuggestionItemDtoTriggerTypeEnum.unknownDefaultOpenApi,
  )
  final SuggestionItemDtoTriggerTypeEnum triggerType;

  /// Lifecycle state
  @JsonKey(
    name: r'lifecycleState',
    required: true,
    includeIfNull: false,
    unknownEnumValue: SuggestionItemDtoLifecycleStateEnum.unknownDefaultOpenApi,
  )
  final SuggestionItemDtoLifecycleStateEnum lifecycleState;

  /// Whether this card can trigger a notification
  @JsonKey(name: r'notificationEligible', required: false, includeIfNull: false)
  final Object? notificationEligible;

  /// Available feedback options for this card
  @JsonKey(name: r'feedbackOptions', required: false, includeIfNull: false)
  final List<String>? feedbackOptions;

  /// Sub-type for rendering variety
  @JsonKey(name: r'subtype', required: false, includeIfNull: false)
  final Object? subtype;

  @JsonKey(name: r'observedMetric', required: false, includeIfNull: false)
  final SuggestionObservedMetricDto? observedMetric;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuggestionItemDto &&
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

  factory SuggestionItemDto.fromJson(Map<String, dynamic> json) =>
      _$SuggestionItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SuggestionItemDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Suggestion type
enum SuggestionItemDtoTypeEnum {
  /// Suggestion type
  @JsonValue(r'confirmed_risk')
  confirmedRisk(r'confirmed_risk'),

  /// Suggestion type
  @JsonValue(r'compliance')
  compliance(r'compliance'),

  /// Suggestion type
  @JsonValue(r'trend')
  trend(r'trend'),

  /// Suggestion type
  @JsonValue(r'behavior_advice')
  behaviorAdvice(r'behavior_advice'),

  /// Suggestion type
  @JsonValue(r'coverage')
  coverage(r'coverage'),

  /// Suggestion type
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const SuggestionItemDtoTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Visual tone hint
enum SuggestionItemDtoCardToneEnum {
  /// Visual tone hint
  @JsonValue(r'urgent')
  urgent(r'urgent'),

  /// Visual tone hint
  @JsonValue(r'warning')
  warning(r'warning'),

  /// Visual tone hint
  @JsonValue(r'emphasis')
  emphasis(r'emphasis'),

  /// Visual tone hint
  @JsonValue(r'soft')
  soft(r'soft'),

  /// Visual tone hint
  @JsonValue(r'neutral')
  neutral(r'neutral'),

  /// Visual tone hint
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const SuggestionItemDtoCardToneEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Confidence level
enum SuggestionItemDtoConfidenceEnum {
  /// Confidence level
  @JsonValue(r'high')
  high(r'high'),

  /// Confidence level
  @JsonValue(r'medium')
  medium(r'medium'),

  /// Confidence level
  @JsonValue(r'low')
  low(r'low'),

  /// Confidence level
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const SuggestionItemDtoConfidenceEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Trigger type
enum SuggestionItemDtoTriggerTypeEnum {
  /// Trigger type
  @JsonValue(r'event')
  event(r'event'),

  /// Trigger type
  @JsonValue(r'timer')
  timer(r'timer'),

  /// Trigger type
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const SuggestionItemDtoTriggerTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Lifecycle state
enum SuggestionItemDtoLifecycleStateEnum {
  /// Lifecycle state
  @JsonValue(r'generated')
  generated(r'generated'),

  /// Lifecycle state
  @JsonValue(r'active')
  active(r'active'),

  /// Lifecycle state
  @JsonValue(r'fading')
  fading(r'fading'),

  /// Lifecycle state
  @JsonValue(r'expired')
  expired(r'expired'),

  /// Lifecycle state
  @JsonValue(r'dismissed')
  dismissed(r'dismissed'),

  /// Lifecycle state
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const SuggestionItemDtoLifecycleStateEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
