import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
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
        FLucideIcons.wifiOff,
      );
    });
    test('null → circleAlert', () {
      expect(sendErrorIcon(null), FLucideIcons.circleAlert);
    });
    test('covers all types', () {
      for (final t in AssistantSendErrorType.values) {
        expect(sendErrorIcon(t), isA<IconData>());
      }
    });
  });
}
