//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'suggestion_history_response_items.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SuggestionHistoryResponseItems {
  /// Returns a new [SuggestionHistoryResponseItems] instance.
  SuggestionHistoryResponseItems({
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
    unknownEnumValue:
        SuggestionHistoryResponseItemsTypeEnum.unknownDefaultOpenApi,
  )
  final SuggestionHistoryResponseItemsTypeEnum type;

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
        SuggestionHistoryResponseItemsTriggerTypeEnum.unknownDefaultOpenApi,
  )
  final SuggestionHistoryResponseItemsTriggerTypeEnum triggerType;

  /// Lifecycle state
  @JsonKey(
    name: r'lifecycleState',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        SuggestionHistoryResponseItemsLifecycleStateEnum.unknownDefaultOpenApi,
  )
  final SuggestionHistoryResponseItemsLifecycleStateEnum lifecycleState;

  /// Confidence level
  @JsonKey(
    name: r'confidence',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        SuggestionHistoryResponseItemsConfidenceEnum.unknownDefaultOpenApi,
  )
  final SuggestionHistoryResponseItemsConfidenceEnum confidence;

  /// Sub-type
  @JsonKey(name: r'subtype', required: false, includeIfNull: false)
  final String? subtype;

  /// User feedback, if any
  @JsonKey(name: r'feedback', required: false, includeIfNull: false)
  final String? feedback;

  /// When feedback was recorded
  @JsonKey(name: r'feedbackAt', required: false, includeIfNull: false)
  final String? feedbackAt;

  /// When the suggestion was generated
  @JsonKey(name: r'generatedAt', required: true, includeIfNull: false)
  final String generatedAt;

  /// When the suggestion was expired
  @JsonKey(name: r'expiredAt', required: false, includeIfNull: false)
  final String? expiredAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuggestionHistoryResponseItems &&
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

  factory SuggestionHistoryResponseItems.fromJson(Map<String, dynamic> json) =>
      _$SuggestionHistoryResponseItemsFromJson(json);

  Map<String, dynamic> toJson() => _$SuggestionHistoryResponseItemsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Suggestion type
enum SuggestionHistoryResponseItemsTypeEnum {
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

  const SuggestionHistoryResponseItemsTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Trigger type
enum SuggestionHistoryResponseItemsTriggerTypeEnum {
  @JsonValue(r'event')
  event(r'event'),
  @JsonValue(r'timer')
  timer(r'timer'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const SuggestionHistoryResponseItemsTriggerTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Lifecycle state
enum SuggestionHistoryResponseItemsLifecycleStateEnum {
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

  const SuggestionHistoryResponseItemsLifecycleStateEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Confidence level
enum SuggestionHistoryResponseItemsConfidenceEnum {
  @JsonValue(r'high')
  high(r'high'),
  @JsonValue(r'medium')
  medium(r'medium'),
  @JsonValue(r'low')
  low(r'low'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const SuggestionHistoryResponseItemsConfidenceEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
