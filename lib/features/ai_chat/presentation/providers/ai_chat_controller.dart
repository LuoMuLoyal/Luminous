import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/network/lucent_api_exception.dart';
import 'package:luminous/core/network/lucent_error_mapper.dart';
import 'package:luminous/features/ai_chat/data/repositories/lucent_ai_chat_repository.dart';
import 'package:luminous/features/ai_chat/domain/entities/ai_chat_models.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';

enum AiChatSendErrorType { server, streamInterrupted, emptyResult, unknown }

class AiChatState {
  const AiChatState({
    this.isLoadingCapabilities = false,
    this.isLoadingConversation = false,
    this.isLoadingRecentConversations = false,
    this.isOpeningConversation = false,
    this.isSending = false,
    this.capabilities,
    this.capabilityError,
    this.conversationError,
    this.recentConversationError,
    this.sendError,
    this.sendErrorType,
    this.lastFailedInput,
    this.conversationId,
    this.recentConversations = const <AiChatConversationSummary>[],
    this.messages = const <AiChatMessage>[],
    this.streamingDraft = '',
  });

  final bool isLoadingCapabilities;
  final bool isLoadingConversation;
  final bool isLoadingRecentConversations;
  final bool isOpeningConversation;
  final bool isSending;
  final AiChatCapabilities? capabilities;
  final String? capabilityError;
  final String? conversationError;
  final String? recentConversationError;
  final String? sendError;
  final AiChatSendErrorType? sendErrorType;
  final String? lastFailedInput;
  final String? conversationId;
  final List<AiChatConversationSummary> recentConversations;
  final List<AiChatMessage> messages;
  final String streamingDraft;

  bool get hasConversation => messages.isNotEmpty || streamingDraft.isNotEmpty;

  AiChatState copyWith({
    bool? isLoadingCapabilities,
    bool? isLoadingConversation,
    bool? isLoadingRecentConversations,
    bool? isOpeningConversation,
    bool? isSending,
    Object? capabilities = _sentinel,
    Object? capabilityError = _sentinel,
    Object? conversationError = _sentinel,
    Object? recentConversationError = _sentinel,
    Object? sendError = _sentinel,
    Object? sendErrorType = _sentinel,
    Object? lastFailedInput = _sentinel,
    Object? conversationId = _sentinel,
    List<AiChatConversationSummary>? recentConversations,
    List<AiChatMessage>? messages,
    String? streamingDraft,
  }) {
    return AiChatState(
      isLoadingCapabilities:
          isLoadingCapabilities ?? this.isLoadingCapabilities,
      isLoadingConversation:
          isLoadingConversation ?? this.isLoadingConversation,
      isLoadingRecentConversations:
          isLoadingRecentConversations ?? this.isLoadingRecentConversations,
      isOpeningConversation: isOpeningConversation ?? this.isOpeningConversation,
      isSending: isSending ?? this.isSending,
      capabilities: identical(capabilities, _sentinel)
          ? this.capabilities
          : capabilities as AiChatCapabilities?,
      capabilityError: identical(capabilityError, _sentinel)
          ? this.capabilityError
          : capabilityError as String?,
      conversationError: identical(conversationError, _sentinel)
          ? this.conversationError
          : conversationError as String?,
      recentConversationError: identical(recentConversationError, _sentinel)
          ? this.recentConversationError
          : recentConversationError as String?,
      sendError: identical(sendError, _sentinel)
          ? this.sendError
          : sendError as String?,
      sendErrorType: identical(sendErrorType, _sentinel)
          ? this.sendErrorType
          : sendErrorType as AiChatSendErrorType?,
      lastFailedInput: identical(lastFailedInput, _sentinel)
          ? this.lastFailedInput
          : lastFailedInput as String?,
      conversationId: identical(conversationId, _sentinel)
          ? this.conversationId
          : conversationId as String?,
      recentConversations: recentConversations ?? this.recentConversations,
      messages: messages ?? this.messages,
      streamingDraft: streamingDraft ?? this.streamingDraft,
    );
  }
}

const Object _sentinel = Object();

class AiChatController extends Notifier<AiChatState> {
  @override
  AiChatState build() {
    final session = ref.watch(authSessionProvider);
    if (!session.canAccessProtectedData) {
      return const AiChatState();
    }

    Future<void>.microtask(_bootstrap);
    return const AiChatState(
      isLoadingCapabilities: true,
      isLoadingConversation: true,
      isLoadingRecentConversations: true,
    );
  }

  Future<void> _bootstrap() async {
    await Future.wait<void>([
      loadCapabilities(),
      loadLatestConversation(),
      loadRecentConversations(),
    ]);
  }

  Future<void> loadCapabilities() async {
    final session = ref.read(authSessionProvider);
    if (!session.canAccessProtectedData) {
      state = state.copyWith(
        isLoadingCapabilities: false,
        capabilities: null,
        capabilityError: null,
        conversationId: null,
        recentConversations: const <AiChatConversationSummary>[],
        messages: const <AiChatMessage>[],
        streamingDraft: '',
        conversationError: null,
        recentConversationError: null,
      );
      return;
    }

    state = state.copyWith(isLoadingCapabilities: true, capabilityError: null);

    try {
      final capabilities = await ref
          .read(aiChatRepositoryProvider)
          .getCapabilities();
      state = state.copyWith(
        isLoadingCapabilities: false,
        capabilities: capabilities,
        capabilityError: null,
      );
    } catch (error) {
      final message = LucentErrorMapper.fromObject(error).message;
      state = state.copyWith(
        isLoadingCapabilities: false,
        capabilityError: message,
      );
    }
  }

  Future<void> loadLatestConversation() async {
    final session = ref.read(authSessionProvider);
    if (!session.canAccessProtectedData) {
      state = state.copyWith(
        isLoadingConversation: false,
        conversationId: null,
        messages: const <AiChatMessage>[],
        streamingDraft: '',
        conversationError: null,
      );
      return;
    }

    state = state.copyWith(
      isLoadingConversation: true,
      conversationError: null,
    );

    try {
      final conversation = await ref
          .read(aiChatRepositoryProvider)
          .getLatestConversation();
      state = state.copyWith(
        isLoadingConversation: false,
        conversationId: conversation?.id,
        messages: conversation?.messages ?? const <AiChatMessage>[],
        streamingDraft: '',
        conversationError: null,
        sendError: null,
        sendErrorType: null,
        lastFailedInput: null,
      );
    } catch (error) {
      final message = LucentErrorMapper.fromObject(error).message;
      state = state.copyWith(
        isLoadingConversation: false,
        conversationError: message,
      );
    }
  }

  Future<void> loadRecentConversations() async {
    final session = ref.read(authSessionProvider);
    if (!session.canAccessProtectedData) {
      state = state.copyWith(
        isLoadingRecentConversations: false,
        recentConversations: const <AiChatConversationSummary>[],
        recentConversationError: null,
      );
      return;
    }

    state = state.copyWith(
      isLoadingRecentConversations: true,
      recentConversationError: null,
    );

    try {
      final items = await ref
          .read(aiChatRepositoryProvider)
          .listRecentConversations();
      state = state.copyWith(
        isLoadingRecentConversations: false,
        recentConversations: items,
        recentConversationError: null,
      );
    } catch (error) {
      final message = LucentErrorMapper.fromObject(error).message;
      state = state.copyWith(
        isLoadingRecentConversations: false,
        recentConversationError: message,
      );
    }
  }

  Future<void> openConversation(String conversationId) async {
    if (state.isSending || state.isLoadingConversation || state.isOpeningConversation) {
      return;
    }

    state = state.copyWith(
      isOpeningConversation: true,
      conversationError: null,
      sendError: null,
      sendErrorType: null,
      lastFailedInput: null,
      streamingDraft: '',
    );

    try {
      final conversation = await ref
          .read(aiChatRepositoryProvider)
          .openConversation(conversationId);
      state = state.copyWith(
        isOpeningConversation: false,
        conversationId: conversation.id,
        messages: conversation.messages,
        streamingDraft: '',
        conversationError: null,
      );
      await loadRecentConversations();
    } catch (error) {
      final message = LucentErrorMapper.fromObject(error).message;
      state = state.copyWith(
        isOpeningConversation: false,
        conversationError: message,
      );
    }
  }

  Future<void> sendMessage(String input) async {
    await _sendMessageInternal(input.trim(), appendUserMessage: true);
  }

  Future<void> _sendMessageInternal(
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
        ? <AiChatMessage>[
            ...state.messages,
            AiChatMessage(
              role: AiChatMessageRole.user,
              content: trimmed,
              createdAt: DateTime.now(),
            ),
          ]
        : List<AiChatMessage>.of(state.messages);

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
          in ref.read(aiChatRepositoryProvider).streamMessages(nextMessages)) {
        switch (event) {
          case AiChatGenerationChunkEvent():
            state = state.copyWith(
              streamingDraft: '${state.streamingDraft}${event.content}',
            );
          case AiChatGenerationResultEvent():
            state = state.copyWith(
              isSending: false,
              streamingDraft: '',
              conversationId: event.conversationId.isEmpty
                  ? state.conversationId
                  : event.conversationId,
              messages: <AiChatMessage>[...state.messages, event.message],
            );
            await loadRecentConversations();
            return;
        }
      }

      state = state.copyWith(
        isSending: false,
        sendError: 'AI 流式响应已结束，但没有返回最终结果。',
        sendErrorType: AiChatSendErrorType.emptyResult,
        lastFailedInput: trimmed,
      );
    } catch (error) {
      final message = LucentErrorMapper.fromObject(error).message;
      final errorType = _classifySendError(error);
      state = state.copyWith(
        isSending: false,
        sendError: message,
        sendErrorType: errorType,
        lastFailedInput: trimmed,
        streamingDraft: '',
      );
    }
  }

  AiChatSendErrorType _classifySendError(Object error) {
    if (error is LucentApiException) {
      final statusCode = error.statusCode;
      if (statusCode != null && statusCode >= 500) {
        return AiChatSendErrorType.server;
      }
      return AiChatSendErrorType.server;
    }
    if (error is StateError || error is FormatException) {
      return AiChatSendErrorType.streamInterrupted;
    }
    return AiChatSendErrorType.unknown;
  }

  Future<void> retryLastMessage() async {
    final input = state.lastFailedInput;
    if (input == null || input.isEmpty) {
      return;
    }
    await _sendMessageInternal(
      input,
      appendUserMessage: !_hasPendingUserMessage(input),
    );
  }

  Future<void> clearConversation() async {
    if (state.isSending || state.isLoadingConversation) {
      return;
    }

    try {
      await ref.read(aiChatRepositoryProvider).clearLatestConversation();
    } catch (error) {
      final message = LucentErrorMapper.fromObject(error).message;
      state = state.copyWith(conversationError: message);
      return;
    }

    state = state.copyWith(
      conversationId: null,
      messages: const <AiChatMessage>[],
      streamingDraft: '',
      conversationError: null,
      sendError: null,
      sendErrorType: null,
      lastFailedInput: null,
    );
    await loadRecentConversations();
  }

  bool _hasPendingUserMessage(String input) {
    if (state.messages.isEmpty) {
      return false;
    }
    final last = state.messages.last;
    return last.role == AiChatMessageRole.user && last.content == input;
  }
}

final aiChatControllerProvider =
    NotifierProvider<AiChatController, AiChatState>(AiChatController.new);
