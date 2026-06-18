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
    this.isSending = false,
    this.capabilities,
    this.capabilityError,
    this.sendError,
    this.sendErrorType,
    this.lastFailedInput,
    this.messages = const <AiChatMessage>[],
    this.streamingDraft = '',
  });

  final bool isLoadingCapabilities;
  final bool isSending;
  final AiChatCapabilities? capabilities;
  final String? capabilityError;
  final String? sendError;
  final AiChatSendErrorType? sendErrorType;
  final String? lastFailedInput;
  final List<AiChatMessage> messages;
  final String streamingDraft;

  bool get hasConversation => messages.isNotEmpty || streamingDraft.isNotEmpty;

  AiChatState copyWith({
    bool? isLoadingCapabilities,
    bool? isSending,
    Object? capabilities = _sentinel,
    Object? capabilityError = _sentinel,
    Object? sendError = _sentinel,
    Object? sendErrorType = _sentinel,
    Object? lastFailedInput = _sentinel,
    List<AiChatMessage>? messages,
    String? streamingDraft,
  }) {
    return AiChatState(
      isLoadingCapabilities:
          isLoadingCapabilities ?? this.isLoadingCapabilities,
      isSending: isSending ?? this.isSending,
      capabilities: identical(capabilities, _sentinel)
          ? this.capabilities
          : capabilities as AiChatCapabilities?,
      capabilityError: identical(capabilityError, _sentinel)
          ? this.capabilityError
          : capabilityError as String?,
      sendError: identical(sendError, _sentinel)
          ? this.sendError
          : sendError as String?,
      sendErrorType: identical(sendErrorType, _sentinel)
          ? this.sendErrorType
          : sendErrorType as AiChatSendErrorType?,
      lastFailedInput: identical(lastFailedInput, _sentinel)
          ? this.lastFailedInput
          : lastFailedInput as String?,
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

    Future<void>.microtask(loadCapabilities);
    return const AiChatState(isLoadingCapabilities: true);
  }

  Future<void> loadCapabilities() async {
    final session = ref.read(authSessionProvider);
    if (!session.canAccessProtectedData) {
      state = state.copyWith(
        isLoadingCapabilities: false,
        capabilities: null,
        capabilityError: null,
      );
      return;
    }

    state = state.copyWith(
      isLoadingCapabilities: true,
      capabilityError: null,
    );

    try {
      final capabilities = await ref.read(aiChatRepositoryProvider).getCapabilities();
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

  Future<void> sendMessage(String input) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty || state.isSending) {
      return;
    }

    final capabilities = state.capabilities;
    if (capabilities == null || !capabilities.canSendMessages) {
      return;
    }

    final nextMessages = <AiChatMessage>[
      ...state.messages,
      AiChatMessage(
        role: AiChatMessageRole.user,
        content: trimmed,
        createdAt: DateTime.now(),
      ),
    ];

    state = state.copyWith(
      messages: nextMessages,
      isSending: true,
      sendError: null,
      sendErrorType: null,
      lastFailedInput: null,
      streamingDraft: '',
    );

    try {
      await for (final event in ref
          .read(aiChatRepositoryProvider)
          .streamMessages(nextMessages)) {
        switch (event) {
          case AiChatGenerationChunkEvent():
            state = state.copyWith(
              streamingDraft: '${state.streamingDraft}${event.content}',
            );
          case AiChatGenerationResultEvent():
            state = state.copyWith(
              isSending: false,
              streamingDraft: '',
              messages: <AiChatMessage>[
                ...state.messages,
                event.message,
              ],
            );
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
    await sendMessage(input);
  }

  void clearConversation() {
    state = state.copyWith(
      messages: const <AiChatMessage>[],
      streamingDraft: '',
      sendError: null,
      sendErrorType: null,
      lastFailedInput: null,
    );
  }
}

final aiChatControllerProvider =
    NotifierProvider<AiChatController, AiChatState>(AiChatController.new);
