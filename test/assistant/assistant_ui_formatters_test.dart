import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/features/assistant/domain/entities/assistant_models.dart';
import 'package:luminous/features/assistant/presentation/providers/assistant_controller.dart';
import 'package:luminous/features/assistant/presentation/utils/assistant_ui_formatters.dart';

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
    final theme = ThemeData.light();
    test('pending → primary', () {
      expect(
        proposalStateColor(theme, _p(AssistantProposalExecutionState.pending)),
        theme.colorScheme.primary,
      );
    });
    test('confirmed → tertiary', () {
      expect(
        proposalStateColor(
          theme,
          _p(AssistantProposalExecutionState.confirmed),
        ),
        theme.colorScheme.tertiary,
      );
    });
    test('dismissed → outline', () {
      expect(
        proposalStateColor(
          theme,
          _p(AssistantProposalExecutionState.dismissed),
        ),
        theme.colorScheme.outline,
      );
    });
    test('failed → error', () {
      expect(
        proposalStateColor(theme, _p(AssistantProposalExecutionState.failed)),
        theme.colorScheme.error,
      );
    });
    test('covers all states', () {
      for (final s in AssistantProposalExecutionState.values) {
        expect(proposalStateColor(theme, _p(s)), isA<Color>());
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
