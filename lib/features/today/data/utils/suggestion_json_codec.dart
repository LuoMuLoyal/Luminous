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
      'materializationStatus': bundle.materializationStatus.toJson(),
      'sourceVersion': bundle.sourceVersion,
      'computedAt': bundle.computedAt?.toUtc().toIso8601String(),
      'retryAfterSeconds': bundle.retryAfterSeconds,
      'primary': bundle.primary != null ? _cardToJson(bundle.primary!) : null,
      'secondary': bundle.secondary?.map(_cardToJson).toList(),
      'observations': bundle.observations?.map(_cardToJson).toList(),
    });
  }

  static TodaySuggestionBundle bundleFromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return TodaySuggestionBundle(
      generatedAt: _asString(map['generatedAt']) ?? '',
      materializationStatus: TodaySuggestionMaterializationStatus.fromJson(
        _asString(map['materializationStatus']) ?? 'ready',
      ),
      sourceVersion: _safeInt(map['sourceVersion']) ?? 0,
      computedAt: _parseDateTime(map['computedAt']),
      retryAfterSeconds: _safeInt(map['retryAfterSeconds']),
      primary: _cardFromJsonOrNull(map['primary']),
      secondary: _asList(
        map['secondary'],
      )?.map(_cardFromJsonOrNull).whereType<TodaySuggestionCard>().toList(),
      observations: _asList(
        map['observations'],
      )?.map(_cardFromJsonOrNull).whereType<TodaySuggestionCard>().toList(),
    );
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value is! String) return null;
    return DateTime.tryParse(value);
  }

  static int? _safeInt(Object? value) {
    if (value is int) return value;
    if (value is num && value.isFinite && value == value.truncate()) {
      return value.toInt();
    }
    return null;
  }

  /// Type-guarded accessors: an unexpected cache shape (e.g. `id` decoded
  /// as an int) yields a default instead of a raw `TypeError` crash.
  /// Callers additionally treat a malformed bundle as stale cache and clear
  /// it, so these fallbacks only soften recoverable cases.
  static String? _asString(Object? value) => value is String ? value : null;

  static Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, dynamic val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  static List<dynamic>? _asList(Object? value) => value is List ? value : null;

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
      id: _asString(m['id']) ?? '',
      type: TodaySuggestionType.fromJson(_asString(m['type']) ?? ''),
      cardTone: TodaySuggestionCardTone.fromJson(
        _asString(m['cardTone']) ?? '',
      ),
      icon: _asString(m['icon']) ?? '',
      title: _asString(m['title']) ?? '',
      reason: _asString(m['reason']) ?? '',
      evidence:
          _asList(
            m['evidence'],
          )?.map((e) => _evidenceFromJson(_asMap(e) ?? const {})).toList() ??
          const [],
      boundary: _asString(m['boundary']) ?? '',
      primaryAction: _actionFromJson(_asMap(m['primaryAction']) ?? const {}),
      secondaryActions: _asList(
        m['secondaryActions'],
      )?.map((e) => _actionFromJson(_asMap(e) ?? const {})).toList(),
      confidence: _confidenceFromString(_asString(m['confidence']) ?? ''),
      ruleId: _asString(m['ruleId']) ?? '',
      ruleVersion: _asString(m['ruleVersion']) ?? '',
      triggerType: _triggerFromString(_asString(m['triggerType']) ?? ''),
      lifecycleState: TodaySuggestionLifecycleState.fromJson(
        _asString(m['lifecycleState']) ?? '',
      ),
      notificationEligible: m['notificationEligible'] is bool
          ? m['notificationEligible'] as bool
          : null,
      feedbackOptions: _asList(
        m['feedbackOptions'],
      )?.map((f) => _feedbackFromString(_asString(f) ?? '')).toList(),
      subtype: _asString(m['subtype']),
    );
  }

  /// Null-safe card decode for optional card slots.
  static TodaySuggestionCard? _cardFromJsonOrNull(Object? value) {
    final map = _asMap(value);
    return map == null ? null : _cardFromJson(map);
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
        kind: TodaySuggestionEvidenceKind.fromJson(_asString(m['kind']) ?? ''),
        label: _asString(m['label']) ?? '',
        value: _asString(m['value']) ?? '',
        recordId: _asString(m['recordId']),
        medicineId: _asString(m['medicineId']),
      );

  static Map<String, dynamic> _actionToJson(TodaySuggestionAction a) => {
    'actionId': a.actionId,
    'label': a.label,
    'route': a.route,
    'authRequired': a.authRequired,
  };

  static TodaySuggestionAction _actionFromJson(Map<String, dynamic> m) =>
      TodaySuggestionAction(
        actionId: _asString(m['actionId']) ?? '',
        label: _asString(m['label']) ?? '',
        route: _asString(m['route']) ?? '',
        authRequired: m['authRequired'] is bool
            ? m['authRequired'] as bool
            : false,
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
        'not_applicable' => TodaySuggestionFeedback.notApplicable,
        'suppress' => TodaySuggestionFeedback.suppress,
        _ => TodaySuggestionFeedback.later,
      };
}
