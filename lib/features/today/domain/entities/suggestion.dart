import 'package:freezed_annotation/freezed_annotation.dart';

part 'suggestion.freezed.dart';

// ── Enums ─────────────────────────────────────────────────────────────────

/// Suggestion card type from the backend rule engine.
enum TodaySuggestionType {
  confirmedRisk,
  compliance,
  trend,
  behaviorAdvice,
  coverage;

  String toJson() => switch (this) {
        TodaySuggestionType.confirmedRisk => 'confirmed_risk',
        TodaySuggestionType.compliance => 'compliance',
        TodaySuggestionType.trend => 'trend',
        TodaySuggestionType.behaviorAdvice => 'behavior_advice',
        TodaySuggestionType.coverage => 'coverage',
      };

  static TodaySuggestionType fromJson(String value) {
    return switch (value) {
      'confirmed_risk' => TodaySuggestionType.confirmedRisk,
      'compliance' => TodaySuggestionType.compliance,
      'trend' => TodaySuggestionType.trend,
      'behavior_advice' => TodaySuggestionType.behaviorAdvice,
      'coverage' => TodaySuggestionType.coverage,
      _ => TodaySuggestionType.behaviorAdvice,
    };
  }
}

/// Visual tone hint for card styling.
enum TodaySuggestionCardTone {
  urgent,
  warning,
  emphasis,
  soft,
  neutral;

  static TodaySuggestionCardTone fromJson(String value) {
    return switch (value) {
      'urgent' => TodaySuggestionCardTone.urgent,
      'warning' => TodaySuggestionCardTone.warning,
      'emphasis' => TodaySuggestionCardTone.emphasis,
      'soft' => TodaySuggestionCardTone.soft,
      'neutral' => TodaySuggestionCardTone.neutral,
      _ => TodaySuggestionCardTone.soft,
    };
  }
}

/// Confidence level of the suggestion.
enum TodaySuggestionConfidence { high, medium, low }

/// Lifecycle state of the suggestion.
enum TodaySuggestionLifecycleState {
  generated,
  active,
  fading,
  expired,
  dismissed;

  static TodaySuggestionLifecycleState fromJson(String value) {
    return switch (value) {
      'generated' => TodaySuggestionLifecycleState.generated,
      'active' => TodaySuggestionLifecycleState.active,
      'fading' => TodaySuggestionLifecycleState.fading,
      'expired' => TodaySuggestionLifecycleState.expired,
      'dismissed' => TodaySuggestionLifecycleState.dismissed,
      _ => TodaySuggestionLifecycleState.active,
    };
  }
}

/// What triggered the suggestion.
enum TodaySuggestionTriggerType { event, timer }

/// User feedback on a suggestion.
enum TodaySuggestionFeedback {
  accepted,
  later,
  notApplicable,
  suppress;

  String toJson() => switch (this) {
    TodaySuggestionFeedback.accepted => 'accepted',
    TodaySuggestionFeedback.later => 'later',
    TodaySuggestionFeedback.notApplicable => 'not_applicable',
    TodaySuggestionFeedback.suppress => 'suppress',
  };
}

/// Effect applied by the feedback engine.
enum TodaySuggestionFeedbackEffect {
  boostedType,
  delayedUntil,
  suppressedType,
  noted;

  static TodaySuggestionFeedbackEffect fromJson(String value) {
    return switch (value) {
      'boosted_type' => TodaySuggestionFeedbackEffect.boostedType,
      'delayed_until' => TodaySuggestionFeedbackEffect.delayedUntil,
      'suppressed_type' => TodaySuggestionFeedbackEffect.suppressedType,
      'noted' => TodaySuggestionFeedbackEffect.noted,
      _ => TodaySuggestionFeedbackEffect.noted,
    };
  }
}

/// Evidence item kind.
enum TodaySuggestionEvidenceKind {
  record,
  reminder,
  riskCheck,
  trend,
  profile,
  baseline;

  String toJson() => switch (this) {
        TodaySuggestionEvidenceKind.record => 'record',
        TodaySuggestionEvidenceKind.reminder => 'reminder',
        TodaySuggestionEvidenceKind.riskCheck => 'risk_check',
        TodaySuggestionEvidenceKind.trend => 'trend',
        TodaySuggestionEvidenceKind.profile => 'profile',
        TodaySuggestionEvidenceKind.baseline => 'baseline',
      };

  static TodaySuggestionEvidenceKind fromJson(String value) {
    return switch (value) {
      'record' => TodaySuggestionEvidenceKind.record,
      'reminder' => TodaySuggestionEvidenceKind.reminder,
      'risk_check' => TodaySuggestionEvidenceKind.riskCheck,
      'trend' => TodaySuggestionEvidenceKind.trend,
      'profile' => TodaySuggestionEvidenceKind.profile,
      'baseline' => TodaySuggestionEvidenceKind.baseline,
      _ => TodaySuggestionEvidenceKind.record,
    };
  }
}

// ── Entities ──────────────────────────────────────────────────────────────

/// Evidence item shown on a suggestion card.
@freezed
abstract class TodaySuggestionEvidence with _$TodaySuggestionEvidence {
  const factory TodaySuggestionEvidence({
    required TodaySuggestionEvidenceKind kind,
    required String label,
    required String value,
    String? recordId,
    String? medicineId,
  }) = _TodaySuggestionEvidence;
}

/// Action that the user can take from a suggestion card.
@freezed
abstract class TodaySuggestionAction with _$TodaySuggestionAction {
  const factory TodaySuggestionAction({
    required String actionId,
    required String label,
    required String route,
    required bool authRequired,
  }) = _TodaySuggestionAction;
}

/// A single suggestion card.
@freezed
abstract class TodaySuggestionCard with _$TodaySuggestionCard {
  const factory TodaySuggestionCard({
    required String id,
    required TodaySuggestionType type,
    required TodaySuggestionCardTone cardTone,
    required String icon,
    required String title,
    required String reason,
    required List<TodaySuggestionEvidence> evidence,
    required String boundary,
    required TodaySuggestionAction primaryAction,
    required TodaySuggestionConfidence confidence,
    required String ruleId,
    required String ruleVersion,
    required TodaySuggestionTriggerType triggerType,
    required TodaySuggestionLifecycleState lifecycleState,
    List<TodaySuggestionAction>? secondaryActions,
    bool? notificationEligible,
    List<TodaySuggestionFeedback>? feedbackOptions,
    String? subtype,
  }) = _TodaySuggestionCard;
}

/// Top-level suggestion bundle returned by GET /today/suggestions.
@freezed
abstract class TodaySuggestionBundle with _$TodaySuggestionBundle {
  const factory TodaySuggestionBundle({
    required String generatedAt,
    TodaySuggestionCard? primary,
    List<TodaySuggestionCard>? secondary,
    List<TodaySuggestionCard>? observations,
  }) = _TodaySuggestionBundle;
}

/// AI explanation for a suggestion card.
@freezed
abstract class TodaySuggestionExplanation with _$TodaySuggestionExplanation {
  const factory TodaySuggestionExplanation({
    required String suggestionId,
    required String reason,
    required String boundary,
    required bool aiGenerated,
    String? locale,
  }) = _TodaySuggestionExplanation;
}

/// Result of submitting feedback for a suggestion.
@freezed
abstract class TodaySuggestionFeedbackResult
    with _$TodaySuggestionFeedbackResult {
  const factory TodaySuggestionFeedbackResult({
    required String suggestionId,
    required TodaySuggestionFeedback feedback,
    required TodaySuggestionFeedbackEffect appliedEffect,
    String? expiresAt,
  }) = _TodaySuggestionFeedbackResult;
}

/// A single suggestion history item for the Report page.
@freezed
abstract class TodaySuggestionHistoryItem with _$TodaySuggestionHistoryItem {
  const factory TodaySuggestionHistoryItem({
    required String id,
    required String date,
    required TodaySuggestionType type,
    required String title,
    required String reason,
    required String ruleId,
    required String ruleVersion,
    required TodaySuggestionTriggerType triggerType,
    required TodaySuggestionLifecycleState lifecycleState,
    required TodaySuggestionConfidence confidence,
    required String generatedAt,
    String? subtype,
    TodaySuggestionFeedback? feedback,
    String? feedbackAt,
    String? expiredAt,
  }) = _TodaySuggestionHistoryItem;
}

/// Suggestion history response.
@freezed
abstract class TodaySuggestionHistory with _$TodaySuggestionHistory {
  const factory TodaySuggestionHistory({
    required List<TodaySuggestionHistoryItem> items,
    required int total,
    required String startDate,
    required String endDate,
  }) = _TodaySuggestionHistory;
}
