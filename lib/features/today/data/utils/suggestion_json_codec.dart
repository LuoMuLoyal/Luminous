import 'dart:convert';

import 'package:luminous/features/today/domain/entities/suggestion.dart';

/// Manual JSON serialization for [TodaySuggestionBundle] and related types.
///
/// Used by the cache layer to persist/retrieve suggestion cards.
/// AI analysis text (TodaySuggestionExplanation) is NOT cached.
class TodaySuggestionJsonCodec {
  static String bundleToJson(TodaySuggestionBundle bundle) {
    return jsonEncode({
      'generatedAt': bundle.generatedAt,
      'primary': bundle.primary != null ? _cardToJson(bundle.primary!) : null,
      'secondary': bundle.secondary?.map(_cardToJson).toList(),
      'observations': bundle.observations?.map(_cardToJson).toList(),
    });
  }

  static TodaySuggestionBundle bundleFromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return TodaySuggestionBundle(
      generatedAt: map['generatedAt'] as String,
      primary: map['primary'] != null
          ? _cardFromJson(map['primary'] as Map<String, dynamic>)
          : null,
      secondary: (map['secondary'] as List<dynamic>?)
          ?.map((e) => _cardFromJson(e as Map<String, dynamic>))
          .toList(),
      observations: (map['observations'] as List<dynamic>?)
          ?.map((e) => _cardFromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static Map<String, dynamic> _cardToJson(TodaySuggestionCard c) {
    return {
      'id': c.id,
      'type': c.type.toJson(),
      'cardTone': c.cardTone.name,
      'icon': c.icon,
      'title': c.title,
      'reason': c.reason,
      'evidence': c.evidence.map(_evidenceToJson).toList(),
      'boundary': c.boundary,
      'primaryAction': _actionToJson(c.primaryAction),
      'secondaryActions': c.secondaryActions?.map(_actionToJson).toList(),
      'confidence': c.confidence.name,
      'ruleId': c.ruleId,
      'ruleVersion': c.ruleVersion,
      'triggerType': c.triggerType.name,
      'lifecycleState': c.lifecycleState.name,
      'notificationEligible': c.notificationEligible,
      'feedbackOptions': c.feedbackOptions?.map((f) => f.toJson()).toList(),
      'subtype': c.subtype,
    };
  }

  static TodaySuggestionCard _cardFromJson(Map<String, dynamic> m) {
    return TodaySuggestionCard(
      id: m['id'] as String,
      type: TodaySuggestionType.fromJson(m['type'] as String),
      cardTone: TodaySuggestionCardTone.fromJson(m['cardTone'] as String),
      icon: m['icon'] as String,
      title: m['title'] as String,
      reason: m['reason'] as String,
      evidence: (m['evidence'] as List<dynamic>)
          .map((e) => _evidenceFromJson(e as Map<String, dynamic>))
          .toList(),
      boundary: m['boundary'] as String,
      primaryAction: _actionFromJson(
        m['primaryAction'] as Map<String, dynamic>,
      ),
      secondaryActions: (m['secondaryActions'] as List<dynamic>?)
          ?.map((e) => _actionFromJson(e as Map<String, dynamic>))
          .toList(),
      confidence: _confidenceFromString(m['confidence'] as String),
      ruleId: m['ruleId'] as String,
      ruleVersion: m['ruleVersion'] as String,
      triggerType: _triggerFromString(m['triggerType'] as String),
      lifecycleState: TodaySuggestionLifecycleState.fromJson(
        m['lifecycleState'] as String,
      ),
      notificationEligible: m['notificationEligible'] as bool?,
      feedbackOptions: (m['feedbackOptions'] as List<dynamic>?)
          ?.map((f) => _feedbackFromString(f as String))
          .toList(),
      subtype: m['subtype'] as String?,
    );
  }

  static Map<String, dynamic> _evidenceToJson(TodaySuggestionEvidence e) => {
    'kind': e.kind.toJson(),
    'label': e.label,
    'value': e.value,
    'recordId': e.recordId,
    'medicineId': e.medicineId,
  };

  static TodaySuggestionEvidence _evidenceFromJson(Map<String, dynamic> m) =>
      TodaySuggestionEvidence(
        kind: TodaySuggestionEvidenceKind.fromJson(m['kind'] as String),
        label: m['label'] as String,
        value: m['value'] as String,
        recordId: m['recordId'] as String?,
        medicineId: m['medicineId'] as String?,
      );

  static Map<String, dynamic> _actionToJson(TodaySuggestionAction a) => {
    'actionId': a.actionId,
    'label': a.label,
    'route': a.route,
    'authRequired': a.authRequired,
  };

  static TodaySuggestionAction _actionFromJson(Map<String, dynamic> m) =>
      TodaySuggestionAction(
        actionId: m['actionId'] as String,
        label: m['label'] as String,
        route: m['route'] as String,
        authRequired: m['authRequired'] as bool,
      );

  static TodaySuggestionConfidence _confidenceFromString(String value) =>
      switch (value) {
        'high' => TodaySuggestionConfidence.high,
        'medium' => TodaySuggestionConfidence.medium,
        'low' => TodaySuggestionConfidence.low,
        _ => TodaySuggestionConfidence.medium,
      };

  static TodaySuggestionTriggerType _triggerFromString(String value) =>
      switch (value) {
        'event' => TodaySuggestionTriggerType.event,
        'timer' => TodaySuggestionTriggerType.timer,
        _ => TodaySuggestionTriggerType.timer,
      };

  static TodaySuggestionFeedback _feedbackFromString(String value) =>
      switch (value) {
        'accepted' => TodaySuggestionFeedback.accepted,
        'later' => TodaySuggestionFeedback.later,
        'not_applicable' ||
        'notApplicable' => TodaySuggestionFeedback.notApplicable,
        'suppress' => TodaySuggestionFeedback.suppress,
        _ => TodaySuggestionFeedback.later,
      };
}
