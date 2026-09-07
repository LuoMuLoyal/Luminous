import 'package:clock/clock.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/core/network/contract/error_mapper.dart';
import 'package:luminous/features/assistant/data/repositories/lucent.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/domain/repositories/assistant.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation_streams.dart';

mixin MessageSending on Notifier<AssistantState>, ConversationStreams {
  Future<void> sendMessage(String input) async {
    await sendMessageInternal(input.trim(), appendUserMessage: true);
  }

  Future<void> sendMessageInternal(
    String trimmed, {
    required bool appendUserMessage,
  }) async {
    if (trimmed.isEmpty || state.isSending || state.isLoadingConversation) {
      return;
    }

    final capabilities = state.capabilities;
    if (capabilities == null || !capabilities.canSendMessages) {
      return;
    }

    final nextMessages = appendUserMessage
        ? <AssistantMessage>[
            ...state.messages,
            AssistantMessage(
              role: AssistantMessageRole.user,
              content: trimmed,
              createdAt: clock.now(),
            ),
          ]
        : List<AssistantMessage>.of(state.messages);

    state = state.copyWith(
      messages: nextMessages,
      isSending: true,
      sendError: null,
      sendErrorType: null,
      lastFailedInput: null,
      streamingDraft: '',
    );

    try {
      await for (final event
          in ref
              .read(assistantRepositoryProvider)
              .streamMessages(
                nextMessages,
                conversationId: state.conversationId,
              )) {
        switch (event) {
          case AssistantGenerationChunkEvent():
            state = state.copyWith(
              streamingDraft: '${state.streamingDraft}${event.content}',
            );
          case AssistantGenerationResultEvent():
            state = state.copyWith(
              isSending: false,
              streamingDraft: '',
              conversationId: event.conversationId.isEmpty
                  ? state.conversationId
                  : event.conversationId,
              messages: <AssistantMessage>[...state.messages, event.message],
            );
            await loadRecentConversations();
            return;
        }
      }

      state = state.copyWith(
        isSending: false,
        sendError: null,
        sendErrorType: AssistantSendErrorType.emptyResult,
        lastFailedInput: trimmed,
      );
    } catch (error) {
      ref
          .read(talkerProvider)
          .error('AssistantController.sendMessageInternal: failed: $error');
      final message = LucentErrorMapper.fromObject(error).message;
      final errorType = classifySendError(error);
      // F-3 断流补偿:当流因网络中断提前结束且已有残句时,把残句保留为
      // 一条失败的助手消息(内容可复制),错误条仍显示,用户可点击「继续生成」
      // 复用 lastFailedInput 重新发起。
      final draft = state.streamingDraft;
      final preserveDraft =
          errorType == AssistantSendErrorType.streamInterrupted &&
          draft.isNotEmpty;
      state = state.copyWith(
        isSending: false,
        sendError: message,
        sendErrorType: errorType,
        lastFailedInput: trimmed,
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

  AssistantSendErrorType classifySendError(Object error) {
    if (error is LucentFailure) {
      // 网络层中断(连接断开/超时/取消)视为流中断,触发 F-3 残句保留。
      if (error.isNetworkConnectivityError ||
          error.networkErrorCode == NetworkErrorCode.cancelled) {
        return AssistantSendErrorType.streamInterrupted;
      }
      return AssistantSendErrorType.server;
    }
    if (error is DioException) {
      // 运行时链上网络失败经 ErrorInterceptor 携带 LucentFailure 重新抛出。
      final embedded = error.error;
      if (embedded is LucentFailure) {
        return classifySendError(embedded);
      }
      return AssistantSendErrorType.unknown;
    }
    if (error is StateError || error is FormatException) {
      return AssistantSendErrorType.streamInterrupted;
    }
    return AssistantSendErrorType.unknown;
  }

  bool hasPendingUserMessage(String input) {
    if (state.messages.isEmpty) {
      return false;
    }
    final last = state.messages.last;
    return last.role == AssistantMessageRole.user && last.content == input;
  }
}
