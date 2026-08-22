import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/domain/repositories/assistant.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';
import 'package:luminous/features/assistant/presentation/utils/message_id.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controller_test_helpers.dart';

void main() {
  group('AssistantController', () {
    test(
      'regenerateExpiredProposal resends the preceding user message',
      () async {
        SharedPreferences.setMockInitialValues(const <String, Object>{});
        final userMessage = AssistantMessage(
          role: AssistantMessageRole.user,
          content: '帮我记一杯水',
          createdAt: DateTime(2026, 6, 1, 11),
        );
        final assistantMessage = buildAssistantMessage(
          content: '建议已过期。',
          proposedActions: <AssistantProposedAction>[
            createDailyRecordProposal(
              id: 'proposal-expired',
              expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
            ),
          ],
        );
        final fake = FakeAssistantRepository(
          latestConversation: conversationWith(
            id: 'persisted-1',
            messages: <AssistantMessage>[userMessage, assistantMessage],
          ),
          streamOverride: Stream<AssistantGenerationEvent>.fromIterable([
            AssistantGenerationResultEvent(
              conversationId: 'persisted-1',
              message: buildAssistantMessage(content: '这是重新生成的建议。'),
            ),
          ]),
        );
        final container = buildContainer(fake);
        addTearDown(container.dispose);

        final controller = container.read(assistantControllerProvider.notifier);
        await controller.loadCapabilities();
        await controller.loadLatestConversation();

        final before = container
            .read(assistantControllerProvider)
            .messages
            .length;
        await controller.regenerateExpiredProposal(
          messageId: messageIdFor(assistantMessage),
          proposalId: 'proposal-expired',
        );

        expect(fake.streamMessagesCallCount, 1);
        expect(fake.lastStreamConversationId, 'persisted-1');
        // The pipeline reuses the persisted messages without appending a new
        // user message; the user message that produced the proposal is in there.
        expect(fake.lastStreamMessages?.length, 2);
        expect(fake.lastStreamMessages?.first.content, '帮我记一杯水');
        // The pipeline reuses persisted messages without appending a new user
        // message; a fresh assistant reply is appended on the result event.
        expect(
          container.read(assistantControllerProvider).messages.length,
          before + 1,
        );
      },
    );

    test(
      'regenerateExpiredProposal throws when no user message precedes it',
      () async {
        SharedPreferences.setMockInitialValues(const <String, Object>{});
        final assistantMessage = buildAssistantMessage(
          content: '建议已过期。',
          proposedActions: <AssistantProposedAction>[
            createDailyRecordProposal(
              id: 'proposal-expired',
              expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
            ),
          ],
        );
        final fake = FakeAssistantRepository(
          latestConversation: conversationWith(
            id: 'persisted-1',
            messages: <AssistantMessage>[assistantMessage],
          ),
        );
        final container = buildContainer(fake);
        addTearDown(container.dispose);

        final controller = container.read(assistantControllerProvider.notifier);
        await controller.loadCapabilities();
        await controller.loadLatestConversation();

        await expectLater(
          controller.regenerateExpiredProposal(
            messageId: messageIdFor(assistantMessage),
            proposalId: 'proposal-expired',
          ),
          throwsA(isA<StateError>()),
        );
      },
    );

    test(
      'regenerateExpiredProposal is skipped while a send is in flight',
      () async {
        SharedPreferences.setMockInitialValues(const <String, Object>{});
        final streamController = StreamController<AssistantGenerationEvent>();
        addTearDown(streamController.close);
        final userMessage = AssistantMessage(
          role: AssistantMessageRole.user,
          content: '帮我记一杯水',
          createdAt: DateTime(2026, 6, 1, 11),
        );
        final assistantMessage = buildAssistantMessage(
          content: '建议已过期。',
          proposedActions: <AssistantProposedAction>[
            createDailyRecordProposal(
              id: 'proposal-expired',
              expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
            ),
          ],
        );
        final fake = FakeAssistantRepository(
          latestConversation: conversationWith(
            id: 'persisted-1',
            messages: <AssistantMessage>[userMessage, assistantMessage],
          ),
          streamOverride: streamController.stream,
        );
        final container = buildContainer(fake);
        addTearDown(container.dispose);

        final controller = container.read(assistantControllerProvider.notifier);
        await controller.loadCapabilities();
        await controller.loadLatestConversation();

        final sendFuture = controller.sendMessage('第一条消息');
        expect(container.read(assistantControllerProvider).isSending, isTrue);

        await controller.regenerateExpiredProposal(
          messageId: messageIdFor(assistantMessage),
          proposalId: 'proposal-expired',
        );

        // Only the in-flight send hit the pipeline; the regenerate call was a
        // no-op. Complete the stream and await the send to clean up.
        expect(fake.streamMessagesCallCount, 1);
        streamController.add(
          AssistantGenerationResultEvent(
            conversationId: 'persisted-1',
            message: buildAssistantMessage(content: 'ok'),
          ),
        );
        await sendFuture;
      },
    );

    test(
      'regenerateLastMessage appends the new answer and keeps the old one',
      () async {
        SharedPreferences.setMockInitialValues(const <String, Object>{});
        final oldAnswer = buildAssistantMessage(content: '旧回答');
        final fake = FakeAssistantRepository(
          latestConversation: conversationWith(
            id: 'persisted-1',
            messages: <AssistantMessage>[
              AssistantMessage(
                role: AssistantMessageRole.user,
                content: '帮我查一下睡眠',
                createdAt: DateTime(2026, 6, 1, 11),
              ),
              oldAnswer,
            ],
          ),
          regenerateStream: Stream<AssistantGenerationEvent>.fromIterable([
            const AssistantGenerationChunkEvent('新的'),
            AssistantGenerationResultEvent(
              conversationId: 'persisted-1',
              message: buildAssistantMessage(content: '新的回答'),
            ),
          ]),
        );
        final container = buildContainer(fake);
        addTearDown(container.dispose);

        final controller = container.read(assistantControllerProvider.notifier);
        await controller.loadCapabilities();
        await controller.loadLatestConversation();

        final before = container
            .read(assistantControllerProvider)
            .messages
            .length;
        await controller.regenerateLastMessage();

        expect(fake.regenerateCallCount, 1);
        expect(fake.lastRegenerateConversationId, 'persisted-1');
        final state = container.read(assistantControllerProvider);
        expect(state.messages.length, before + 1);
        // 旧答案保留为修订,新回答追加在末尾。
        expect(state.messages[before - 1].content, '旧回答');
        expect(state.messages.last.content, '新的回答');
        expect(state.isSending, isFalse);
        expect(state.sendError, isNull);
      },
    );

    test(
      'F-5b: regenerateLastMessage marks the old answer as replaced',
      () async {
        SharedPreferences.setMockInitialValues(const <String, Object>{});
        final oldAnswer = buildAssistantMessage(content: '旧回答');
        final fake = FakeAssistantRepository(
          latestConversation: conversationWith(
            id: 'persisted-1',
            messages: <AssistantMessage>[
              AssistantMessage(
                role: AssistantMessageRole.user,
                content: '帮我查一下睡眠',
                createdAt: DateTime(2026, 6, 1, 11),
              ),
              oldAnswer,
            ],
          ),
          regenerateStream: Stream<AssistantGenerationEvent>.fromIterable([
            AssistantGenerationResultEvent(
              conversationId: 'persisted-1',
              message: buildAssistantMessage(content: '新的回答'),
            ),
          ]),
        );
        final container = buildContainer(fake);
        addTearDown(container.dispose);

        final controller = container.read(assistantControllerProvider.notifier);
        await controller.loadCapabilities();
        await controller.loadLatestConversation();

        // 重生成成功前旧回答未被标记。
        expect(
          container.read(assistantControllerProvider).messages.last.replaced,
          isFalse,
        );

        await controller.regenerateLastMessage();

        final state = container.read(assistantControllerProvider);
        final old = state.messages[state.messages.length - 2];
        final fresh = state.messages.last;
        // 旧回答被标记为「已替换」,新回答保持正常态。
        expect(old.role, AssistantMessageRole.assistant);
        expect(old.content, '旧回答');
        expect(old.replaced, isTrue);
        expect(fresh.content, '新的回答');
        expect(fresh.replaced, isFalse);
      },
    );

    test('F-5b: failed regenerate keeps the old answer normal', () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final fake = FakeAssistantRepository(
        latestConversation: conversationWith(
          id: 'persisted-1',
          messages: <AssistantMessage>[
            AssistantMessage(
              role: AssistantMessageRole.user,
              content: '帮我查一下睡眠',
              createdAt: DateTime(2026, 6, 1, 11),
            ),
            buildAssistantMessage(content: '旧回答'),
          ],
        ),
        regenerateStream: Stream<AssistantGenerationEvent>.error(
          StateError('stream closed'),
        ),
      );
      final container = buildContainer(fake);
      addTearDown(container.dispose);

      final controller = container.read(assistantControllerProvider.notifier);
      await controller.loadCapabilities();
      await controller.loadLatestConversation();

      await controller.regenerateLastMessage();

      final state = container.read(assistantControllerProvider);
      expect(state.sendError, isNotNull);
      // 失败不标记:旧回答仍为正常态,也没有新增消息。
      expect(
        state.messages.where(
          (message) => message.role == AssistantMessageRole.assistant,
        ),
        hasLength(1),
      );
      expect(
        state.messages
            .where((message) => message.role == AssistantMessageRole.assistant)
            .single
            .replaced,
        isFalse,
      );
    });

    test(
      'regenerateLastMessage throws without a persisted conversation',
      () async {
        SharedPreferences.setMockInitialValues(const <String, Object>{});
        final fake = FakeAssistantRepository();
        final container = buildContainer(fake);
        addTearDown(container.dispose);

        final controller = container.read(assistantControllerProvider.notifier);
        await controller.loadCapabilities();
        await controller.loadLatestConversation();

        await expectLater(
          controller.regenerateLastMessage(),
          throwsA(isA<StateError>()),
        );
        expect(fake.regenerateCallCount, 0);
      },
    );

    test('regenerateLastMessage surfaces streaming errors', () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final fake = FakeAssistantRepository(
        latestConversation: conversationWith(
          id: 'persisted-1',
          messages: <AssistantMessage>[buildAssistantMessage(content: '旧回答')],
        ),
        regenerateStream: Stream<AssistantGenerationEvent>.error(
          StateError('stream closed'),
        ),
      );
      final container = buildContainer(fake);
      addTearDown(container.dispose);

      final controller = container.read(assistantControllerProvider.notifier);
      await controller.loadCapabilities();
      await controller.loadLatestConversation();

      await controller.regenerateLastMessage();

      final state = container.read(assistantControllerProvider);
      expect(state.isSending, isFalse);
      expect(state.sendErrorType, AssistantSendErrorType.streamInterrupted);
      expect(state.sendError, isNotNull);
    });
  });
}
