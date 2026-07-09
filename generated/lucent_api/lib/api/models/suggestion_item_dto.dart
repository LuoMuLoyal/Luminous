// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'evidence_item_dto.dart';
import 'suggestion_action_dto.dart';
import 'suggestion_item_dto_card_tone_card_tone.dart';
import 'suggestion_item_dto_confidence_confidence.dart';
import 'suggestion_item_dto_lifecycle_state_lifecycle_state.dart';
import 'suggestion_item_dto_trigger_type_trigger_type.dart';
import 'suggestion_item_dto_type_type.dart';

part 'suggestion_item_dto.g.dart';

@JsonSerializable()
class SuggestionItemDto {
  const SuggestionItemDto({
    required this.id,
    required this.type,
    required this.cardTone,
    required this.icon,
    required this.title,
    required this.reason,
    required this.evidence,
    required this.boundary,
    required this.primaryAction,
    required this.confidence,
    required this.ruleId,
    required this.ruleVersion,
    required this.triggerType,
    required this.lifecycleState,
    this.secondaryActions,
    this.notificationEligible,
    this.feedbackOptions,
    this.subtype,
  });

  factory SuggestionItemDto.fromJson(Map<String, Object?> json) =>
      _$SuggestionItemDtoFromJson(json);

  /// Unique suggestion id
  final String id;

  /// Suggestion type
  final SuggestionItemDtoTypeType type;

  /// Visual tone hint
  final SuggestionItemDtoCardToneCardTone cardTone;

  /// Icon identifier for the frontend
  final String icon;

  /// Localized short title
  final String title;

  /// Why this suggestion appeared
  final String reason;

  /// Evidence items
  final List<EvidenceItemDto> evidence;

  /// Medical disclaimer / boundary text
  final String boundary;

  /// Primary action
  final SuggestionActionDto primaryAction;

  /// Secondary actions
  final List<SuggestionActionDto>? secondaryActions;

  /// Confidence level
  final SuggestionItemDtoConfidenceConfidence confidence;

  /// Rule identifier for auditability
  final String ruleId;

  /// Rule version
  final String ruleVersion;

  /// Trigger type
  final SuggestionItemDtoTriggerTypeTriggerType triggerType;

  /// Lifecycle state
  final SuggestionItemDtoLifecycleStateLifecycleState lifecycleState;

  /// Whether this card can trigger a notification
  final dynamic notificationEligible;

  /// Available feedback options for this card
  final List<String>? feedbackOptions;

  /// Sub-type for rendering variety
  final dynamic subtype;

  Map<String, Object?> toJson() => _$SuggestionItemDtoToJson(this);
}
