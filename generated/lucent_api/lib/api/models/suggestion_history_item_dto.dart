// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'suggestion_history_item_dto_confidence_confidence.dart';
import 'suggestion_history_item_dto_feedback_feedback.dart';
import 'suggestion_history_item_dto_lifecycle_state_lifecycle_state.dart';
import 'suggestion_history_item_dto_trigger_type_trigger_type.dart';
import 'suggestion_history_item_dto_type_type.dart';

part 'suggestion_history_item_dto.g.dart';

@JsonSerializable()
class SuggestionHistoryItemDto {
  const SuggestionHistoryItemDto({
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
    required this.generatedAt,
    this.subtype,
    this.feedback,
    this.feedbackAt,
    this.expiredAt,
  });

  factory SuggestionHistoryItemDto.fromJson(Map<String, Object?> json) =>
      _$SuggestionHistoryItemDtoFromJson(json);

  /// Unique suggestion id
  final String id;

  /// Date (YYYY-MM-DD)
  final String date;

  /// Suggestion type
  final SuggestionHistoryItemDtoTypeType type;

  /// Localized short title
  final String title;

  /// Why this suggestion appeared
  final String reason;

  /// Rule identifier
  final String ruleId;

  /// Rule version
  final String ruleVersion;

  /// Trigger type
  final SuggestionHistoryItemDtoTriggerTypeTriggerType triggerType;

  /// Lifecycle state
  final SuggestionHistoryItemDtoLifecycleStateLifecycleState lifecycleState;

  /// Confidence level
  final SuggestionHistoryItemDtoConfidenceConfidence confidence;

  /// Sub-type
  final dynamic subtype;

  /// User feedback, if any
  final SuggestionHistoryItemDtoFeedbackFeedback? feedback;

  /// When feedback was recorded
  final dynamic feedbackAt;

  /// When the suggestion was generated
  final String generatedAt;

  /// When the suggestion was expired
  final dynamic expiredAt;

  Map<String, Object?> toJson() => _$SuggestionHistoryItemDtoToJson(this);
}
