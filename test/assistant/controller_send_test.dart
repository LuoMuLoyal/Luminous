import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/features/assistant/data/repositories/lucent.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/domain/repositories/assistant.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/test_helpers.dart';
import 'controller_test_helpers.dart';

void main() {
  group('AssistantController', () {
    test('build returns loading state when authenticated', () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final session = SignedInAuthSessionNotifier();
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => session),
          assistantRepositoryProvider.overrideWithValue(
            FakeAssistantRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(assistantControllerProvider);
      expect(state.isLoadingCapabilities, isTrue);
    });

    test('loadCapabilities populates capabilities on success', () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final session = SignedInAuthSessionNotifier();
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => session),
          assistantRepositoryProvider.overrideWithValue(
            FakeAssistantRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(assistantControllerProvider.notifier);
      await controller.loadCapabilities();

      final state = container.read(assistantControllerProvider);
      expect(state.isLoadingCapabilities, isFalse);
      expect(state.capabilities, isNotNull);
      expect(state.capabilities!.chatModelConfigured, isTrue);
    });

    test('loadCapabilities handles error gracefully', () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final session = SignedInAuthSessionNotifier();
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => session),
          assistantRepositoryProvider.overrideWithValue(
            ErrorThrowingRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(assistantControllerProvider.notifier);
      await controller.loadCapabilities();

      final state = container.read(assistantControllerProvider);
      expect(state.isLoadingCapabilities, isFalse);
      expect(state.capabilityError, isNotNull);
    });

    test('sendMessage forwards the persisted conversation id', () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final session = SignedInAuthSessionNotifier();
      final fake = FakeAssistantRepository(
        latestConversation: AssistantConversation(
          id: 'persisted-1',
          title: null,
          status: 'active',
          messages: const <AssistantMessage>[],
          lastMessageAt: null,
          createdAt: DateTime(2026, 6, 1),
          updatedAt: DateTime(2026, 6, 1),
        ),
        streamOverride: Stream.fromIterable([
          AssistantGenerationResultEvent(
            conversationId: 'persisted-1',
            message: AssistantMessage(
              role: AssistantMessageRole.assistant,
              content: 'ok',
              createdAt: DateTime(2026, 6, 1),
            ),
          ),
        ]),
      );
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => session),
          assistantRepositoryProvider.overrideWithValue(fake),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(assistantControllerProvider.notifier);
      await controller.loadCapabilities();
      await controller.loadLatestConversation();
      await controller.sendMessage('hello');

      expect(fake.lastStreamConversationId, 'persisted-1');
    });

    test(
      'resendMessage reuses the pipeline without appending the user message',
      () async {
        SharedPreferences.setMockInitialValues(const <String, Object>{});
        final fake = FakeAssistantRepository(
          latestConversation: conversationWith(
            id: 'persisted-1',
            messages: <AssistantMessage>[
              AssistantMessage(
                role: AssistantMessageRole.user,
                content: '帮我记一杯水',
                createdAt: DateTime(2026, 6, 1, 11),
              ),
              buildAssistantMessage(content: '好的,已记录。'),
            ],
          ),
          streamOverride: Stream<AssistantGenerationEvent>.fromIterable([
            AssistantGenerationResultEvent(
              conversationId: 'persisted-1',
              message: buildAssistantMessage(content: '再次回答。'),
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
        await controller.resendMessage('帮我记一杯水');

        expect(fake.streamMessagesCallCount, 1);
        // 用户消息已在历史中,不重复 append。
        expect(fake.lastStreamMessages?.length, 2);
        expect(fake.lastStreamMessages?.first.content, '帮我记一杯水');
        expect(fake.lastStreamMessages?.last.content, '好的,已记录。');
        final state = container.read(assistantControllerProvider);
        // 仅新增一条助手回答(重新让助手回答)。
        expect(state.messages.length, before + 1);
        expect(state.messages.last.content, '再次回答。');
      },
    );

    test(
      'F-3: streamInterrupted preserves the partial draft as a copyable message',
      () async {
        SharedPreferences.setMockInitialValues(const <String, Object>{});
        final fake = FakeAssistantRepository(
          streamOverride: Stream<AssistantGenerationEvent>.multi((controller) {
            controller.add(const AssistantGenerationChunkEvent('部分内容'));
            controller.addError(StateError('stream closed'));
          }),
        );
        final container = buildContainer(fake);
        addTearDown(container.dispose);

        final controller = container.read(assistantControllerProvider.notifier);
        await controller.loadCapabilities();
        await controller.loadLatestConversation();
        await controller.sendMessage('hello');

        final state = container.read(assistantControllerProvider);
        expect(state.sendErrorType, AssistantSendErrorType.streamInterrupted);
        // 错误条仍显示,但残句已保留为可复制的失败消息。
        expect(state.sendError, isNotNull);
        expect(state.streamingDraft, isEmpty);
        expect(state.messages.last.role, AssistantMessageRole.assistant);
        expect(state.messages.last.content, '部分内容');
        // 「继续生成」按钮语义 = retry,复用 lastFailedInput。
        expect(state.lastFailedInput, 'hello');

        fake.streamOverride = Stream<AssistantGenerationEvent>.fromIterable([
          AssistantGenerationResultEvent(
            conversationId: 'persisted-1',
            message: buildAssistantMessage(content: '完整回答。'),
          ),
        ]);
        await controller.retryLastMessage();
        final retried = container.read(assistantControllerProvider);
        expect(retried.sendError, isNull);
        expect(retried.messages.last.content, '完整回答。');
      },
    );

    test('F-3: non-interrupted errors drop the partial draft', () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final fake = FakeAssistantRepository(
        streamOverride: Stream<AssistantGenerationEvent>.multi((controller) {
          controller.add(const AssistantGenerationChunkEvent('残句'));
          controller.addError(Exception('generic failure'));
        }),
      );
      final container = buildContainer(fake);
      addTearDown(container.dispose);

      final controller = container.read(assistantControllerProvider.notifier);
      await controller.loadCapabilities();
      await controller.loadLatestConversation();
      await controller.sendMessage('hello');

      final state = container.read(assistantControllerProvider);
      expect(state.sendErrorType, AssistantSendErrorType.unknown);
      // 非断流错误不保留残句。
      expect(
        state.messages.where((message) => message.content == '残句'),
        isEmpty,
      );
    });
  });
}
