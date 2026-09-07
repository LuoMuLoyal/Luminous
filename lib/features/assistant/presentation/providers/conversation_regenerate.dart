import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/network/contract/error_mapper.dart';
import 'package:luminous/features/assistant/data/repositories/lucent.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/domain/repositories/assistant.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation_sending.dart';

mixin MessageRegeneration on Notifier<AssistantState>, MessageSending {
  /// Regenerates the last assistant message of the current conversation
  /// (F-5b). Requires a persisted conversation; the backend only allows the
  /// last message to be regenerated and rejects anything else with 400,
  /// surfaced as a toast by the page.
  Future<void> regenerateLastMessage() async {
    final conversationId = state.conversationId;
    if (conversationId == null || conversationId.isEmpty) {
      throw StateError('No persisted conversation to regenerate.');
    }
    if (state.isSending || state.isLoadingConversation) {
      return;
    }

    state = state.copyWith(
      isSending: true,
      sendError: null,
      sendErrorType: null,
      streamingDraft: '',
    );

    try {
      await for (final event
          in ref
              .read(assistantRepositoryProvider)
              .regenerateLastMessage(
                conversationId,
                onChunk: (content) {
                  state = state.copyWith(
                    streamingDraft: '${state.streamingDraft}$content',
                  );
                },
              )) {
        switch (event) {
          case AssistantGenerationChunkEvent():
            break; // 已由 onChunk 更新 streamingDraft。
          case AssistantGenerationResultEvent():
            // F-5b 灰态:重生成成功(result 事件)时,把本次重生成之前的最后一条
            // assistant 消息标记为「已替换」,再追加新回答。失败/断流不标记,
            // 旧回答保持正常态。
            final replacedMessages = markLastAssistantReplaced(state.messages);
            state = state.copyWith(
              isSending: false,
              streamingDraft: '',
              conversationId: event.conversationId.isEmpty
                  ? state.conversationId
                  : event.conversationId,
              messages: <AssistantMessage>[...replacedMessages, event.message],
            );
            await loadRecentConversations();
            return;
        }
      }

      state = state.copyWith(
        isSending: false,
        sendError: null,
        sendErrorType: AssistantSendErrorType.emptyResult,
        lastFailedInput: null,
      );
    } catch (error) {
      ref
          .read(talkerProvider)
          .error('AssistantController.regenerateLastMessage: failed: $error');
      final message = LucentErrorMapper.fromObject(error).message;
      final errorType = classifySendError(error);
      // 与 sendMessageInternal 相同的 F-3 补偿:断流残句保留为失败消息。
      final draft = state.streamingDraft;
      final preserveDraft =
          errorType == AssistantSendErrorType.streamInterrupted &&
          draft.isNotEmpty;
      state = state.copyWith(
        isSending: false,
        sendError: message,
        sendErrorType: errorType,
        lastFailedInput: null,
        streamingDraft: '',
        messages: preserveDraft
            ? <AssistantMessage>[
                ...state.messages,
                AssistantMessage(
                  role: AssistantMessageRole.assistant,
                  content: draft,
                  createdAt: clock.now(),
                ),
              ]
            : state.messages,
      );
    }
  }

  /// F-5b 灰态辅助:把 [messages] 中最后一条 assistant 消息标记为
  /// `replaced: true`(已是 replaced 或没有 assistant 消息时原样返回)。
  List<AssistantMessage> markLastAssistantReplaced(
    List<AssistantMessage> messages,
  ) {
    final index = messages.lastIndexWhere(
      (message) => message.role == AssistantMessageRole.assistant,
    );
    if (index < 0 || messages[index].replaced) {
      return messages;
    }
    return <AssistantMessage>[
      for (var i = 0; i < messages.length; i++)
        i == index ? messages[i].copyWith(replaced: true) : messages[i],
    ];
  }

  /// Re-sends an existing user message (「重新发送」): the content is already
  /// in the conversation history, so it is not appended again — the backend
  /// dedupes via its findAppendStartIndex. If an assistant reply already
  /// follows the message, a new reply is appended, matching the "ask again"
  /// semantics.
  Future<void> resendMessage(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      return;
    }
    await sendMessageInternal(trimmed, appendUserMessage: false);
  }

  Future<void> retryLastMessage() async {
    final input = state.lastFailedInput;
    if (input == null || input.isEmpty) {
      return;
    }
    await sendMessageInternal(
      input,
      appendUserMessage: !hasPendingUserMessage(input),
    );
  }
}
