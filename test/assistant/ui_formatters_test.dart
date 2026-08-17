import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';
import 'package:luminous/features/assistant/presentation/utils/ui_formatters.dart';

AssistantProposedAction _p(AssistantProposalExecutionState s) {
  return AssistantProposedAction(
    id: 'p1',
    type: AssistantProposedActionType.createDailyRecord,
    title: 'T',
    summary: 'S',
    reason: null,
    previewFields: const [],
    target: const AssistantProposalTarget(kind: 'record', label: 'test'),
    constraints: const [],
    expiresAt: null,
    payloadVersion: 1,
    payload: const AssistantCreateDailyRecordProposalPayload(
      draft: AssistantCreateDailyRecordDraft(
        kind: 'meal',
        occurredAt: '2026-06-15',
        title: null,
        value: null,
        unit: null,
        note: null,
        payload: null,
      ),
    ),
    executionState: s,
  );
}

void main() {
  group('proposalStateColor', () {
    final colors = FTheme.neutral.light.touch.colors;
    test('pending → primary', () {
      expect(
        proposalStateColor(colors, _p(AssistantProposalExecutionState.pending)),
        colors.primary,
      );
    });
    test('confirmed → secondary', () {
      expect(
        proposalStateColor(
          colors,
          _p(AssistantProposalExecutionState.confirmed),
        ),
        colors.secondary,
      );
    });
    test('dismissed → mutedForeground', () {
      expect(
        proposalStateColor(
          colors,
          _p(AssistantProposalExecutionState.dismissed),
        ),
        colors.mutedForeground,
      );
    });
    test('failed → destructive', () {
      expect(
        proposalStateColor(colors, _p(AssistantProposalExecutionState.failed)),
        colors.destructive,
      );
    });
    test('covers all states', () {
      for (final s in AssistantProposalExecutionState.values) {
        expect(proposalStateColor(colors, _p(s)), isA<Color>());
      }
    });
  });

  group('sendErrorIcon', () {
    test('streamInterrupted → wifiOff', () {
      expect(
        sendErrorIcon(AssistantSendErrorType.streamInterrupted),
        SemanticIcons.statusUnavailable,
      );
    });
    test('null → circleAlert', () {
      expect(sendErrorIcon(null), SemanticIcons.statusError);
    });
    test('covers all types', () {
      for (final t in AssistantSendErrorType.values) {
        expect(sendErrorIcon(t), isA<IconData>());
      }
    });
  });

  group('knowledgeSourceTypeOf', () {
    test('leaflet tool → leaflet tier', () {
      expect(
        knowledgeSourceTypeOf('search_medicine_leaflets'),
        AssistantKnowledgeSourceType.leaflet,
      );
    });
    test('drugbank tools → drugbank tier', () {
      expect(
        knowledgeSourceTypeOf('resolve_drugbank_entity'),
        AssistantKnowledgeSourceType.drugbank,
      );
      expect(
        knowledgeSourceTypeOf('search_drugbank_passages'),
        AssistantKnowledgeSourceType.drugbank,
      );
    });
    test('medical QA tool → medicalQa tier', () {
      expect(
        knowledgeSourceTypeOf('search_medical_qa_corpus'),
        AssistantKnowledgeSourceType.medicalQa,
      );
    });
    test('non-knowledge tools → null', () {
      expect(knowledgeSourceTypeOf('get_user_profile'), isNull);
      expect(knowledgeSourceTypeOf('propose_create_daily_record'), isNull);
      expect(knowledgeSourceTypeOf('unknown_tool'), isNull);
    });
  });
}
