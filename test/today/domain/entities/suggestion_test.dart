import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';

void main() {
  group('TodaySuggestionType', () {
    test('toJson returns correct snake_case for all values', () {
      expect(TodaySuggestionType.confirmedRisk.toJson(), 'confirmed_risk');
      expect(TodaySuggestionType.compliance.toJson(), 'compliance');
      expect(TodaySuggestionType.trend.toJson(), 'trend');
      expect(TodaySuggestionType.behaviorAdvice.toJson(), 'behavior_advice');
      expect(TodaySuggestionType.coverage.toJson(), 'coverage');
    });

    test('fromJson maps known strings to correct enum values', () {
      expect(
        TodaySuggestionType.fromJson('confirmed_risk'),
        TodaySuggestionType.confirmedRisk,
      );
      expect(
        TodaySuggestionType.fromJson('compliance'),
        TodaySuggestionType.compliance,
      );
      expect(TodaySuggestionType.fromJson('trend'), TodaySuggestionType.trend);
      expect(
        TodaySuggestionType.fromJson('behavior_advice'),
        TodaySuggestionType.behaviorAdvice,
      );
      expect(
        TodaySuggestionType.fromJson('coverage'),
        TodaySuggestionType.coverage,
      );
    });

    test('fromJson falls back to behaviorAdvice for unknown string', () {
      expect(
        TodaySuggestionType.fromJson('unknown'),
        TodaySuggestionType.behaviorAdvice,
      );
      expect(
        TodaySuggestionType.fromJson(''),
        TodaySuggestionType.behaviorAdvice,
      );
    });

    test('toJson/fromJson round-trip preserves identity', () {
      for (final value in TodaySuggestionType.values) {
        expect(TodaySuggestionType.fromJson(value.toJson()), value);
      }
    });
  });

  group('TodaySuggestionCardTone', () {
    test('fromJson maps known strings to correct enum values', () {
      expect(
        TodaySuggestionCardTone.fromJson('urgent'),
        TodaySuggestionCardTone.urgent,
      );
      expect(
        TodaySuggestionCardTone.fromJson('warning'),
        TodaySuggestionCardTone.warning,
      );
      expect(
        TodaySuggestionCardTone.fromJson('emphasis'),
        TodaySuggestionCardTone.emphasis,
      );
      expect(
        TodaySuggestionCardTone.fromJson('soft'),
        TodaySuggestionCardTone.soft,
      );
      expect(
        TodaySuggestionCardTone.fromJson('neutral'),
        TodaySuggestionCardTone.neutral,
      );
    });

    test('fromJson falls back to soft for unknown string', () {
      expect(
        TodaySuggestionCardTone.fromJson('unknown'),
        TodaySuggestionCardTone.soft,
      );
      expect(
        TodaySuggestionCardTone.fromJson(''),
        TodaySuggestionCardTone.soft,
      );
    });
  });

  group('TodaySuggestionLifecycleState', () {
    test('fromJson maps known strings to correct enum values', () {
      expect(
        TodaySuggestionLifecycleState.fromJson('generated'),
        TodaySuggestionLifecycleState.generated,
      );
      expect(
        TodaySuggestionLifecycleState.fromJson('active'),
        TodaySuggestionLifecycleState.active,
      );
      expect(
        TodaySuggestionLifecycleState.fromJson('fading'),
        TodaySuggestionLifecycleState.fading,
      );
      expect(
        TodaySuggestionLifecycleState.fromJson('expired'),
        TodaySuggestionLifecycleState.expired,
      );
      expect(
        TodaySuggestionLifecycleState.fromJson('dismissed'),
        TodaySuggestionLifecycleState.dismissed,
      );
    });

    test('fromJson falls back to active for unknown string', () {
      expect(
        TodaySuggestionLifecycleState.fromJson('unknown'),
        TodaySuggestionLifecycleState.active,
      );
      expect(
        TodaySuggestionLifecycleState.fromJson(''),
        TodaySuggestionLifecycleState.active,
      );
    });
  });

  group('TodaySuggestionFeedback', () {
    test('toJson returns correct strings for all values', () {
      expect(TodaySuggestionFeedback.accepted.toJson(), 'accepted');
      expect(TodaySuggestionFeedback.later.toJson(), 'later');
      expect(TodaySuggestionFeedback.notApplicable.toJson(), 'not_applicable');
      expect(TodaySuggestionFeedback.suppress.toJson(), 'suppress');
    });
  });

  group('TodaySuggestionFeedbackEffect', () {
    test('fromJson maps known strings to correct enum values', () {
      expect(
        TodaySuggestionFeedbackEffect.fromJson('boosted_type'),
        TodaySuggestionFeedbackEffect.boostedType,
      );
      expect(
        TodaySuggestionFeedbackEffect.fromJson('delayed_until'),
        TodaySuggestionFeedbackEffect.delayedUntil,
      );
      expect(
        TodaySuggestionFeedbackEffect.fromJson('suppressed_type'),
        TodaySuggestionFeedbackEffect.suppressedType,
      );
      expect(
        TodaySuggestionFeedbackEffect.fromJson('noted'),
        TodaySuggestionFeedbackEffect.noted,
      );
    });

    test('fromJson falls back to noted for unknown string', () {
      expect(
        TodaySuggestionFeedbackEffect.fromJson('unknown'),
        TodaySuggestionFeedbackEffect.noted,
      );
      expect(
        TodaySuggestionFeedbackEffect.fromJson(''),
        TodaySuggestionFeedbackEffect.noted,
      );
    });
  });

  group('TodaySuggestionEvidenceKind', () {
    test('toJson returns correct strings for all values', () {
      expect(TodaySuggestionEvidenceKind.record.toJson(), 'record');
      expect(TodaySuggestionEvidenceKind.reminder.toJson(), 'reminder');
      expect(TodaySuggestionEvidenceKind.riskCheck.toJson(), 'risk_check');
      expect(TodaySuggestionEvidenceKind.trend.toJson(), 'trend');
      expect(TodaySuggestionEvidenceKind.profile.toJson(), 'profile');
      expect(TodaySuggestionEvidenceKind.baseline.toJson(), 'baseline');
    });

    test('fromJson maps known strings to correct enum values', () {
      expect(
        TodaySuggestionEvidenceKind.fromJson('record'),
        TodaySuggestionEvidenceKind.record,
      );
      expect(
        TodaySuggestionEvidenceKind.fromJson('reminder'),
        TodaySuggestionEvidenceKind.reminder,
      );
      expect(
        TodaySuggestionEvidenceKind.fromJson('risk_check'),
        TodaySuggestionEvidenceKind.riskCheck,
      );
      expect(
        TodaySuggestionEvidenceKind.fromJson('trend'),
        TodaySuggestionEvidenceKind.trend,
      );
      expect(
        TodaySuggestionEvidenceKind.fromJson('profile'),
        TodaySuggestionEvidenceKind.profile,
      );
      expect(
        TodaySuggestionEvidenceKind.fromJson('baseline'),
        TodaySuggestionEvidenceKind.baseline,
      );
    });

    test('fromJson falls back to record for unknown string', () {
      expect(
        TodaySuggestionEvidenceKind.fromJson('unknown'),
        TodaySuggestionEvidenceKind.record,
      );
      expect(
        TodaySuggestionEvidenceKind.fromJson(''),
        TodaySuggestionEvidenceKind.record,
      );
    });

    test('toJson/fromJson round-trip preserves identity', () {
      for (final value in TodaySuggestionEvidenceKind.values) {
        expect(TodaySuggestionEvidenceKind.fromJson(value.toJson()), value);
      }
    });
  });

  group('TodaySuggestionConfidence', () {
    test('contains expected values', () {
      expect(
        TodaySuggestionConfidence.values,
        containsAll([
          TodaySuggestionConfidence.high,
          TodaySuggestionConfidence.medium,
          TodaySuggestionConfidence.low,
        ]),
      );
    });
  });

  group('TodaySuggestionTriggerType', () {
    test('contains expected values', () {
      expect(
        TodaySuggestionTriggerType.values,
        containsAll([
          TodaySuggestionTriggerType.event,
          TodaySuggestionTriggerType.timer,
        ]),
      );
    });
  });

  group('Entity construction', () {
    test('TodaySuggestionCard can be constructed with required fields', () {
      const card = TodaySuggestionCard(
        id: 's1',
        type: TodaySuggestionType.compliance,
        cardTone: TodaySuggestionCardTone.soft,
        icon: 'pill',
        title: 'Take your medicine',
        reason: 'You missed a dose',
        evidence: [],
        boundary: 'Only applies to morning doses',
        primaryAction: TodaySuggestionAction(
          actionId: 'a1',
          label: 'View',
          route: '/record',
          authRequired: true,
        ),
        confidence: TodaySuggestionConfidence.high,
        ruleId: 'rule-1',
        ruleVersion: 'v1',
        triggerType: TodaySuggestionTriggerType.timer,
        lifecycleState: TodaySuggestionLifecycleState.active,
      );

      expect(card.id, 's1');
      expect(card.type, TodaySuggestionType.compliance);
      expect(card.confidence, TodaySuggestionConfidence.high);
      expect(card.secondaryActions, isNull);
      expect(card.notificationEligible, isNull);
      expect(card.feedbackOptions, isNull);
      expect(card.subtype, isNull);
    });

    test('TodaySuggestionBundle can be constructed with null optionals', () {
      const bundle = TodaySuggestionBundle(generatedAt: '2026-07-12T10:00:00Z');

      expect(bundle.generatedAt, '2026-07-12T10:00:00Z');
      expect(bundle.primary, isNull);
      expect(bundle.secondary, isNull);
      expect(bundle.observations, isNull);
    });

    test('TodaySuggestionExplanation can be constructed', () {
      const explanation = TodaySuggestionExplanation(
        suggestionId: 's1',
        reason: 'Because...',
        boundary: 'Only when...',
        aiGenerated: true,
      );

      expect(explanation.suggestionId, 's1');
      expect(explanation.aiGenerated, isTrue);
      expect(explanation.locale, isNull);
    });

    test('TodaySuggestionFeedbackResult can be constructed', () {
      const result = TodaySuggestionFeedbackResult(
        suggestionId: 's1',
        feedback: TodaySuggestionFeedback.accepted,
        appliedEffect: TodaySuggestionFeedbackEffect.boostedType,
      );

      expect(result.suggestionId, 's1');
      expect(result.feedback, TodaySuggestionFeedback.accepted);
      expect(result.appliedEffect, TodaySuggestionFeedbackEffect.boostedType);
      expect(result.expiresAt, isNull);
    });

    test('TodaySuggestionHistoryItem can be constructed', () {
      const item = TodaySuggestionHistoryItem(
        id: 'h1',
        date: '2026-07-12',
        type: TodaySuggestionType.trend,
        title: 'Blood sugar trending up',
        reason: 'Consistently above target',
        ruleId: 'rule-2',
        ruleVersion: 'v1',
        triggerType: TodaySuggestionTriggerType.event,
        lifecycleState: TodaySuggestionLifecycleState.expired,
        confidence: TodaySuggestionConfidence.medium,
        generatedAt: '2026-07-12T08:00:00Z',
      );

      expect(item.id, 'h1');
      expect(item.type, TodaySuggestionType.trend);
      expect(item.feedback, isNull);
      expect(item.expiredAt, isNull);
    });

    test('TodaySuggestionHistory can be constructed', () {
      const history = TodaySuggestionHistory(
        items: [],
        total: 0,
        startDate: '2026-07-01',
        endDate: '2026-07-12',
      );

      expect(history.items, isEmpty);
      expect(history.total, 0);
      expect(history.startDate, '2026-07-01');
      expect(history.endDate, '2026-07-12');
    });
  });
}
