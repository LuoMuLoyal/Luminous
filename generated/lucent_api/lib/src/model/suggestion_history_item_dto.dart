//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'suggestion_history_item_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SuggestionHistoryItemDto {
  /// Returns a new [SuggestionHistoryItemDto] instance.
  SuggestionHistoryItemDto({
    required this.id,

    required this.date,

    required this.type,

    required this.title,

    required this.reason,

    required this.ruleId,

    required this.ruleVersion,

    required this.triggerType,

    required this.lifecycleState,

    required this.confidence,

    this.subtype,

    this.feedback,

    this.feedbackAt,

    required this.generatedAt,

    this.expiredAt,
  });

  /// Unique suggestion id
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  /// Date (YYYY-MM-DD)
  @JsonKey(name: r'date', required: true, includeIfNull: false)
  final String date;

  /// Suggestion type
  @JsonKey(
    name: r'type',
    required: true,
    includeIfNull: false,
    unknownEnumValue: SuggestionHistoryItemDtoTypeEnum.unknownDefaultOpenApi,
  )
  final SuggestionHistoryItemDtoTypeEnum type;

  /// Localized short title
  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  /// Why this suggestion appeared
  @JsonKey(name: r'reason', required: true, includeIfNull: false)
  final String reason;

  /// Rule identifier
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
        SuggestionHistoryItemDtoTriggerTypeEnum.unknownDefaultOpenApi,
  )
  final SuggestionHistoryItemDtoTriggerTypeEnum triggerType;

  /// Lifecycle state
  @JsonKey(
    name: r'lifecycleState',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        SuggestionHistoryItemDtoLifecycleStateEnum.unknownDefaultOpenApi,
  )
  final SuggestionHistoryItemDtoLifecycleStateEnum lifecycleState;

  /// Confidence level
  @JsonKey(
    name: r'confidence',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        SuggestionHistoryItemDtoConfidenceEnum.unknownDefaultOpenApi,
  )
  final SuggestionHistoryItemDtoConfidenceEnum confidence;

  /// Sub-type
  @JsonKey(name: r'subtype', required: false, includeIfNull: false)
  final Object? subtype;

  /// User feedback, if any
  @JsonKey(
    name: r'feedback',
    required: false,
    includeIfNull: false,
    unknownEnumValue:
        SuggestionHistoryItemDtoFeedbackEnum.unknownDefaultOpenApi,
  )
  final SuggestionHistoryItemDtoFeedbackEnum? feedback;

  /// When feedback was recorded
  @JsonKey(name: r'feedbackAt', required: false, includeIfNull: false)
  final Object? feedbackAt;

  /// When the suggestion was generated
  @JsonKey(name: r'generatedAt', required: true, includeIfNull: false)
  final String generatedAt;

  /// When the suggestion was expired
  @JsonKey(name: r'expiredAt', required: false, includeIfNull: false)
  final Object? expiredAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuggestionHistoryItemDto &&
          other.id == id &&
          other.date == date &&
          other.type == type &&
          other.title == title &&
          other.reason == reason &&
          other.ruleId == ruleId &&
          other.ruleVersion == ruleVersion &&
          other.triggerType == triggerType &&
          other.lifecycleState == lifecycleState &&
          other.confidence == confidence &&
          other.subtype == subtype &&
          other.feedback == feedback &&
          other.feedbackAt == feedbackAt &&
          other.generatedAt == generatedAt &&
          other.expiredAt == expiredAt;

  @override
  int get hashCode =>
      id.hashCode +
      date.hashCode +
      type.hashCode +
      title.hashCode +
      reason.hashCode +
      ruleId.hashCode +
      ruleVersion.hashCode +
      triggerType.hashCode +
      lifecycleState.hashCode +
      confidence.hashCode +
      subtype.hashCode +
      feedback.hashCode +
      feedbackAt.hashCode +
      generatedAt.hashCode +
      expiredAt.hashCode;

  factory SuggestionHistoryItemDto.fromJson(Map<String, dynamic> json) =>
      _$SuggestionHistoryItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SuggestionHistoryItemDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Suggestion type
enum SuggestionHistoryItemDtoTypeEnum {
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

  const SuggestionHistoryItemDtoTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Trigger type
enum SuggestionHistoryItemDtoTriggerTypeEnum {
  /// Trigger type
  @JsonValue(r'event')
  event(r'event'),

  /// Trigger type
  @JsonValue(r'timer')
  timer(r'timer'),

  /// Trigger type
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const SuggestionHistoryItemDtoTriggerTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Lifecycle state
enum SuggestionHistoryItemDtoLifecycleStateEnum {
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

  const SuggestionHistoryItemDtoLifecycleStateEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Confidence level
enum SuggestionHistoryItemDtoConfidenceEnum {
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

  const SuggestionHistoryItemDtoConfidenceEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// User feedback, if any
enum SuggestionHistoryItemDtoFeedbackEnum {
  /// User feedback, if any
  @JsonValue(r'accepted')
  accepted(r'accepted'),

  /// User feedback, if any
  @JsonValue(r'later')
  later(r'later'),

  /// User feedback, if any
  @JsonValue(r'not_applicable')
  notApplicable(r'not_applicable'),

  /// User feedback, if any
  @JsonValue(r'suppress')
  suppress(r'suppress'),

  /// User feedback, if any
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const SuggestionHistoryItemDtoFeedbackEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
