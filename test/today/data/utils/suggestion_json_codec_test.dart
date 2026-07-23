import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/today/data/utils/suggestion_json_codec.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';

void main() {
  group('TodaySuggestionJsonCodec', () {
    TodaySuggestionCard createCard({
      String id = 'card-001',
      TodaySuggestionType type = TodaySuggestionType.confirmedRisk,
      TodaySuggestionCardTone cardTone = TodaySuggestionCardTone.urgent,
      String icon = 'warning',
      String title = '测试建议卡片',
      String reason = '检测到潜在风险',
      String boundary = '仅限当前用药场景',
      TodaySuggestionConfidence confidence = TodaySuggestionConfidence.high,
      String ruleId = 'rule-001',
      String ruleVersion = 'v1.0',
      TodaySuggestionTriggerType triggerType = TodaySuggestionTriggerType.event,
      TodaySuggestionLifecycleState lifecycleState =
          TodaySuggestionLifecycleState.active,
      bool? notificationEligible = true,
      String? subtype,
      List<TodaySuggestionAction>? secondaryActions,
      List<TodaySuggestionFeedback>? feedbackOptions,
    }) {
      return TodaySuggestionCard(
        id: id,
        type: type,
        cardTone: cardTone,
        icon: icon,
        title: title,
        reason: reason,
        evidence: [
          const TodaySuggestionEvidence(
            kind: TodaySuggestionEvidenceKind.record,
            label: '最近血压',
            value: '150/95 mmHg',
            recordId: 'rec-001',
            medicineId: null,
          ),
        ],
        boundary: boundary,
        primaryAction: const TodaySuggestionAction(
          actionId: 'act-001',
          label: '查看详情',
          route: '/record/rec-001',
          authRequired: true,
        ),
        secondaryActions: secondaryActions,
        confidence: confidence,
        ruleId: ruleId,
        ruleVersion: ruleVersion,
        triggerType: triggerType,
        lifecycleState: lifecycleState,
        notificationEligible: notificationEligible,
        feedbackOptions: feedbackOptions,
        subtype: subtype,
      );
    }

    group('bundleToJson / bundleFromJson round-trip', () {
      test('round-trips a bundle with primary card only', () {
        final bundle = TodaySuggestionBundle(
          generatedAt: '2026-07-10T08:00:00Z',
          primary: createCard(),
        );

        final json = TodaySuggestionJsonCodec.bundleToJson(bundle);
        final restored = TodaySuggestionJsonCodec.bundleFromJson(json);

        expect(restored.generatedAt, '2026-07-10T08:00:00Z');
        expect(restored.primary, isNotNull);
        expect(restored.primary!.id, 'card-001');
        expect(restored.secondary, isNull);
        expect(restored.observations, isNull);
      });

      test('round-trips a bundle with all sections populated', () {
        final bundle = TodaySuggestionBundle(
          generatedAt: '2026-07-10T08:00:00Z',
          primary: createCard(id: 'primary-001'),
          secondary: [
            createCard(id: 'secondary-001', title: '次要建议'),
            createCard(id: 'secondary-002', title: '另一条建议'),
          ],
          observations: [
            createCard(
              id: 'obs-001',
              type: TodaySuggestionType.trend,
              title: '趋势观察',
            ),
          ],
        );

        final json = TodaySuggestionJsonCodec.bundleToJson(bundle);
        final restored = TodaySuggestionJsonCodec.bundleFromJson(json);

        expect(restored.generatedAt, '2026-07-10T08:00:00Z');
        expect(restored.primary!.id, 'primary-001');
        expect(restored.secondary, hasLength(2));
        expect(restored.secondary![0].id, 'secondary-001');
        expect(restored.secondary![1].id, 'secondary-002');
        expect(restored.observations, hasLength(1));
        expect(restored.observations![0].id, 'obs-001');
        expect(restored.observations![0].type, TodaySuggestionType.trend);
      });

      test('round-trips a bundle with null primary and empty lists', () {
        const bundle = TodaySuggestionBundle(
          generatedAt: '2026-07-10T08:00:00Z',
          primary: null,
          secondary: [],
          observations: [],
        );

        final json = TodaySuggestionJsonCodec.bundleToJson(bundle);
        final restored = TodaySuggestionJsonCodec.bundleFromJson(json);

        expect(restored.generatedAt, '2026-07-10T08:00:00Z');
        expect(restored.primary, isNull);
        expect(restored.secondary, isEmpty);
        expect(restored.observations, isEmpty);
      });
    });

    group('card serialization', () {
      test('round-trips all card fields correctly', () {
        final card = createCard(
          id: 'full-card',
          type: TodaySuggestionType.compliance,
          cardTone: TodaySuggestionCardTone.warning,
          icon: 'pill',
          title: '服药提醒',
          reason: '今日尚未服药',
          boundary: '仅限当前处方',
          confidence: TodaySuggestionConfidence.medium,
          ruleId: 'rule-002',
          ruleVersion: 'v2.1',
          triggerType: TodaySuggestionTriggerType.timer,
          lifecycleState: TodaySuggestionLifecycleState.fading,
          notificationEligible: false,
          subtype: 'medication',
          secondaryActions: [
            const TodaySuggestionAction(
              actionId: 'act-002',
              label: '稍后提醒',
              route: '/snooze',
              authRequired: false,
            ),
          ],
          feedbackOptions: [
            TodaySuggestionFeedback.accepted,
            TodaySuggestionFeedback.later,
            TodaySuggestionFeedback.notApplicable,
            TodaySuggestionFeedback.suppress,
          ],
        );

        final bundle = TodaySuggestionBundle(
          generatedAt: '2026-07-10T08:00:00Z',
          primary: card,
        );

        final json = TodaySuggestionJsonCodec.bundleToJson(bundle);
        final restored = TodaySuggestionJsonCodec.bundleFromJson(json);
        final restoredCard = restored.primary!;

        expect(restoredCard.id, 'full-card');
        expect(restoredCard.type, TodaySuggestionType.compliance);
        expect(restoredCard.cardTone, TodaySuggestionCardTone.warning);
        expect(restoredCard.icon, 'pill');
        expect(restoredCard.title, '服药提醒');
        expect(restoredCard.reason, '今日尚未服药');
        expect(restoredCard.boundary, '仅限当前处方');
        expect(restoredCard.confidence, TodaySuggestionConfidence.medium);
        expect(restoredCard.ruleId, 'rule-002');
        expect(restoredCard.ruleVersion, 'v2.1');
        expect(restoredCard.triggerType, TodaySuggestionTriggerType.timer);
        expect(
          restoredCard.lifecycleState,
          TodaySuggestionLifecycleState.fading,
        );
        expect(restoredCard.notificationEligible, false);
        expect(restoredCard.subtype, 'medication');
        expect(restoredCard.secondaryActions, hasLength(1));
        expect(restoredCard.secondaryActions![0].actionId, 'act-002');
        expect(restoredCard.secondaryActions![0].label, '稍后提醒');
        expect(restoredCard.secondaryActions![0].route, '/snooze');
        expect(restoredCard.secondaryActions![0].authRequired, false);
        expect(restoredCard.feedbackOptions, hasLength(4));
        expect(
          restoredCard.feedbackOptions![0],
          TodaySuggestionFeedback.accepted,
        );
        expect(restoredCard.feedbackOptions![1], TodaySuggestionFeedback.later);
        expect(
          restoredCard.feedbackOptions![2],
          TodaySuggestionFeedback.notApplicable,
        );
        expect(
          restoredCard.feedbackOptions![3],
          TodaySuggestionFeedback.suppress,
        );
      });

      test('round-trips evidence with all optional fields', () {
        const card = TodaySuggestionCard(
          id: 'evidence-card',
          type: TodaySuggestionType.behaviorAdvice,
          cardTone: TodaySuggestionCardTone.soft,
          icon: 'lightbulb',
          title: '建议',
          reason: 'reason',
          evidence: [
            TodaySuggestionEvidence(
              kind: TodaySuggestionEvidenceKind.riskCheck,
              label: '风险检查',
              value: '高风险',
              recordId: 'rec-123',
              medicineId: 'med-456',
            ),
            TodaySuggestionEvidence(
              kind: TodaySuggestionEvidenceKind.baseline,
              label: '基线',
              value: '正常',
              recordId: null,
              medicineId: null,
            ),
          ],
          boundary: 'boundary',
          primaryAction: TodaySuggestionAction(
            actionId: 'act',
            label: 'label',
            route: '/route',
            authRequired: false,
          ),
          confidence: TodaySuggestionConfidence.low,
          ruleId: 'rule',
          ruleVersion: 'v1',
          triggerType: TodaySuggestionTriggerType.event,
          lifecycleState: TodaySuggestionLifecycleState.generated,
        );

        const bundle = TodaySuggestionBundle(
          generatedAt: '2026-07-10T00:00:00Z',
          primary: card,
        );

        final json = TodaySuggestionJsonCodec.bundleToJson(bundle);
        final restored = TodaySuggestionJsonCodec.bundleFromJson(json);

        expect(restored.primary!.evidence, hasLength(2));
        expect(
          restored.primary!.evidence[0].kind,
          TodaySuggestionEvidenceKind.riskCheck,
        );
        expect(restored.primary!.evidence[0].recordId, 'rec-123');
        expect(restored.primary!.evidence[0].medicineId, 'med-456');
        expect(
          restored.primary!.evidence[1].kind,
          TodaySuggestionEvidenceKind.baseline,
        );
        expect(restored.primary!.evidence[1].recordId, isNull);
        expect(restored.primary!.evidence[1].medicineId, isNull);
      });

      test('round-trips card with null optional fields', () {
        const card = TodaySuggestionCard(
          id: 'minimal',
          type: TodaySuggestionType.coverage,
          cardTone: TodaySuggestionCardTone.neutral,
          icon: 'info',
          title: 'title',
          reason: 'reason',
          evidence: [],
          boundary: 'boundary',
          primaryAction: TodaySuggestionAction(
            actionId: 'act',
            label: 'label',
            route: '/route',
            authRequired: false,
          ),
          confidence: TodaySuggestionConfidence.medium,
          ruleId: 'rule',
          ruleVersion: 'v1',
          triggerType: TodaySuggestionTriggerType.timer,
          lifecycleState: TodaySuggestionLifecycleState.active,
          secondaryActions: null,
          notificationEligible: null,
          feedbackOptions: null,
          subtype: null,
        );

        const bundle = TodaySuggestionBundle(
          generatedAt: '2026-07-10T00:00:00Z',
          primary: card,
        );

        final json = TodaySuggestionJsonCodec.bundleToJson(bundle);
        final restored = TodaySuggestionJsonCodec.bundleFromJson(json);

        expect(restored.primary!.secondaryActions, isNull);
        expect(restored.primary!.notificationEligible, isNull);
        expect(restored.primary!.feedbackOptions, isNull);
        expect(restored.primary!.subtype, isNull);
        expect(restored.primary!.evidence, isEmpty);
      });
    });

    group('enum serialization fallbacks', () {
      test('unknown confidence string falls back to medium', () {
        final card = createCard();
        final bundle = TodaySuggestionBundle(
          generatedAt: '2026-07-10T00:00:00Z',
          primary: card,
        );

        final json = TodaySuggestionJsonCodec.bundleToJson(bundle);
        final jsonMap = jsonDecode(json) as Map<String, dynamic>;
        (jsonMap['primary']! as Map<String, dynamic>)['confidence'] =
            'unknown_value';
        final modifiedJson = jsonEncode(jsonMap);

        final restored = TodaySuggestionJsonCodec.bundleFromJson(modifiedJson);

        expect(restored.primary!.confidence, TodaySuggestionConfidence.medium);
      });

      test('unknown trigger type string falls back to timer', () {
        final card = createCard();
        final bundle = TodaySuggestionBundle(
          generatedAt: '2026-07-10T00:00:00Z',
          primary: card,
        );

        final json = TodaySuggestionJsonCodec.bundleToJson(bundle);
        final jsonMap = jsonDecode(json) as Map<String, dynamic>;
        (jsonMap['primary']! as Map<String, dynamic>)['triggerType'] =
            'unknown_trigger';
        final modifiedJson = jsonEncode(jsonMap);

        final restored = TodaySuggestionJsonCodec.bundleFromJson(modifiedJson);

        expect(restored.primary!.triggerType, TodaySuggestionTriggerType.timer);
      });

      test('unknown feedback string falls back to later', () {
        final card = createCard(
          feedbackOptions: [TodaySuggestionFeedback.accepted],
        );
        final bundle = TodaySuggestionBundle(
          generatedAt: '2026-07-10T00:00:00Z',
          primary: card,
        );

        final json = TodaySuggestionJsonCodec.bundleToJson(bundle);
        final jsonMap = jsonDecode(json) as Map<String, dynamic>;
        ((jsonMap['primary']! as Map<String, dynamic>)['feedbackOptions']
                as List)[0] =
            'mystery';
        final modifiedJson = jsonEncode(jsonMap);

        final restored = TodaySuggestionJsonCodec.bundleFromJson(modifiedJson);

        expect(
          restored.primary!.feedbackOptions![0],
          TodaySuggestionFeedback.later,
        );
      });
    });

    group('JSON structure verification', () {
      test('produces valid JSON with expected top-level keys', () {
        const bundle = TodaySuggestionBundle(
          generatedAt: '2026-07-10T00:00:00Z',
        );

        final json = TodaySuggestionJsonCodec.bundleToJson(bundle);
        final map = jsonDecode(json) as Map<String, dynamic>;

        expect(map, containsPair('generatedAt', '2026-07-10T00:00:00Z'));
        expect(map, containsPair('primary', isNull));
        expect(map, containsPair('secondary', isNull));
        expect(map, containsPair('observations', isNull));
      });

      test('card JSON includes all expected keys', () {
        final card = createCard();
        final bundle = TodaySuggestionBundle(
          generatedAt: '2026-07-10T00:00:00Z',
          primary: card,
        );

        final json = TodaySuggestionJsonCodec.bundleToJson(bundle);
        final map = jsonDecode(json) as Map<String, dynamic>;
        final cardMap = map['primary'] as Map<String, dynamic>;

        expect(cardMap, containsPair('id', 'card-001'));
        expect(cardMap, containsPair('type', 'confirmed_risk'));
        expect(cardMap, containsPair('cardTone', 'urgent'));
        expect(cardMap, containsPair('icon', 'warning'));
        expect(cardMap, containsPair('confidence', 'high'));
        expect(cardMap, containsPair('triggerType', 'event'));
        expect(cardMap, containsPair('lifecycleState', 'active'));
        expect(cardMap, containsPair('notificationEligible', true));
        expect(cardMap, containsPair('ruleId', 'rule-001'));
        expect(cardMap, containsPair('ruleVersion', 'v1.0'));
      });
    });
  });
}
