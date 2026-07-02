import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/features/assistant/domain/entities/assistant_models.dart';
import 'package:luminous/features/assistant/presentation/utils/assistant_ui_formatters.dart';

void main() {
  group('AssistantModels', () {
    test('AssistantToolCapability creates with required fields', () {
      final capability = const AssistantToolCapability(
        id: 'get_today_records',
        requiredContextSources: <String>['daily_records'],
        permittedByUser: true,
        enabled: true,
        implemented: true,
        disabledReason: null,
      );
      expect(capability.id, 'get_today_records');
      expect(capability.permittedByUser, isTrue);
      expect(capability.enabled, isTrue);
    });

    test('AssistantConversation creates with required fields', () {
      final now = DateTime(2026, 6, 10);
      final conversation = AssistantConversation(
        id: 'conv-1',
        title: 'Test Conversation',
        status: 'active',
        messages: const <AssistantMessage>[],
        lastMessageAt: now,
        createdAt: now,
        updatedAt: now,
      );
      expect(conversation.id, 'conv-1');
      expect(conversation.title, 'Test Conversation');
      expect(conversation.status, 'active');
      expect(conversation.messages, isEmpty);
    });
  });

  group('proposalIcon', () {
    test('returns squarePlus for createDailyRecord', () {
      expect(
        proposalIcon(AssistantProposedActionType.createDailyRecord),
        FLucideIcons.squarePlus,
      );
    });

    test('returns squarePen for updateDailyRecord', () {
      expect(
        proposalIcon(AssistantProposedActionType.updateDailyRecord),
        FLucideIcons.squarePen,
      );
    });

    test('returns trash2 for deleteDailyRecord', () {
      expect(
        proposalIcon(AssistantProposedActionType.deleteDailyRecord),
        FLucideIcons.trash2,
      );
    });

    test('returns settings2 for updateUserSettings', () {
      expect(
        proposalIcon(AssistantProposedActionType.updateUserSettings),
        FLucideIcons.settings2,
      );
    });
  });

  group('messageIdFor', () {
    test('generates deterministic id from message fields', () {
      final message = AssistantMessage(
        role: AssistantMessageRole.user,
        content: 'Hello',
        createdAt: DateTime(2026, 6, 10),
      );
      final id1 = messageIdFor(message);
      final id2 = messageIdFor(message);
      expect(id1, equals(id2));
    });

    test('different messages produce different ids', () {
      final msg1 = AssistantMessage(
        role: AssistantMessageRole.user,
        content: 'Hello',
        createdAt: DateTime(2026, 6, 10),
      );
      final msg2 = AssistantMessage(
        role: AssistantMessageRole.user,
        content: 'World',
        createdAt: DateTime(2026, 6, 11),
      );
      expect(messageIdFor(msg1), isNot(equals(messageIdFor(msg2))));
    });

    test('includes role name in the id', () {
      final userMsg = AssistantMessage(
        role: AssistantMessageRole.user,
        content: 'Hi',
        createdAt: DateTime(2026, 6, 10),
      );
      final assistantMsg = AssistantMessage(
        role: AssistantMessageRole.assistant,
        content: 'Hello!',
        createdAt: DateTime(2026, 6, 10),
      );
      expect(messageIdFor(userMsg), contains('user'));
      expect(messageIdFor(assistantMsg), contains('assistant'));
    });
  });
}
