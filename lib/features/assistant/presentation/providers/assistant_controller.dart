import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_openapi/lucent_openapi.dart'
    show UpdateAssistantContextSettingsDto, UpdateUserSettingsDto;
import 'package:luminous/core/network/lucent_api_exception.dart';
import 'package:luminous/core/network/lucent_error_mapper.dart';
import 'package:luminous/features/assistant/data/repositories/lucent_assistant_repository.dart';
import 'package:luminous/features/assistant/domain/entities/assistant_models.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/record/data/providers/daily_record_providers.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/domain/entities/daily_record_inputs.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings_controller.dart';

enum AssistantSendErrorType { server, streamInterrupted, emptyResult, unknown }

class AssistantState {
  const AssistantState({
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
    this.recentConversations = const <AssistantConversationSummary>[],
    this.messages = const <AssistantMessage>[],
    this.streamingDraft = '',
  });

  final bool isLoadingCapabilities;
  final bool isLoadingConversation;
  final bool isLoadingRecentConversations;
  final bool isOpeningConversation;
  final bool isSending;
  final AssistantCapabilities? capabilities;
  final String? capabilityError;
  final String? conversationError;
  final String? recentConversationError;
  final String? sendError;
  final AssistantSendErrorType? sendErrorType;
  final String? lastFailedInput;
  final String? conversationId;
  final List<AssistantConversationSummary> recentConversations;
  final List<AssistantMessage> messages;
  final String streamingDraft;

  bool get hasConversation => messages.isNotEmpty || streamingDraft.isNotEmpty;

  AssistantState copyWith({
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
    List<AssistantConversationSummary>? recentConversations,
    List<AssistantMessage>? messages,
    String? streamingDraft,
  }) {
    return AssistantState(
      isLoadingCapabilities:
          isLoadingCapabilities ?? this.isLoadingCapabilities,
      isLoadingConversation:
          isLoadingConversation ?? this.isLoadingConversation,
      isLoadingRecentConversations:
          isLoadingRecentConversations ?? this.isLoadingRecentConversations,
      isOpeningConversation:
          isOpeningConversation ?? this.isOpeningConversation,
      isSending: isSending ?? this.isSending,
      capabilities: identical(capabilities, _sentinel)
          ? this.capabilities
          : capabilities as AssistantCapabilities?,
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
          : sendErrorType as AssistantSendErrorType?,
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

class AssistantController extends Notifier<AssistantState> {
  @override
  AssistantState build() {
    final session = ref.watch(authSessionProvider);
    if (!session.canAccessProtectedData) {
      return const AssistantState();
    }

    Future<void>.microtask(_bootstrap);
    return const AssistantState(
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
        recentConversations: const <AssistantConversationSummary>[],
        messages: const <AssistantMessage>[],
        streamingDraft: '',
        conversationError: null,
        recentConversationError: null,
      );
      return;
    }

    state = state.copyWith(isLoadingCapabilities: true, capabilityError: null);

    try {
      final capabilities = await ref
          .read(assistantRepositoryProvider)
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
        messages: const <AssistantMessage>[],
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
          .read(assistantRepositoryProvider)
          .getLatestConversation();
      state = state.copyWith(
        isLoadingConversation: false,
        conversationId: conversation?.id,
        messages: conversation?.messages ?? const <AssistantMessage>[],
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
        recentConversations: const <AssistantConversationSummary>[],
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
          .read(assistantRepositoryProvider)
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
    if (state.isSending ||
        state.isLoadingConversation ||
        state.isOpeningConversation) {
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
          .read(assistantRepositoryProvider)
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
        ? <AssistantMessage>[
            ...state.messages,
            AssistantMessage(
              role: AssistantMessageRole.user,
              content: trimmed,
              createdAt: DateTime.now(),
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
          in ref.read(assistantRepositoryProvider).streamMessages(nextMessages)) {
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
        sendError: 'AI 流式响应已结束，但没有返回最终结果。',
        sendErrorType: AssistantSendErrorType.emptyResult,
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

  AssistantSendErrorType _classifySendError(Object error) {
    if (error is LucentApiException) {
      final statusCode = error.statusCode;
      if (statusCode != null && statusCode >= 500) {
        return AssistantSendErrorType.server;
      }
      return AssistantSendErrorType.server;
    }
    if (error is StateError || error is FormatException) {
      return AssistantSendErrorType.streamInterrupted;
    }
    return AssistantSendErrorType.unknown;
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
      await ref.read(assistantRepositoryProvider).clearLatestConversation();
    } catch (error) {
      final message = LucentErrorMapper.fromObject(error).message;
      state = state.copyWith(conversationError: message);
      return;
    }

    state = state.copyWith(
      conversationId: null,
      messages: const <AssistantMessage>[],
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
    return last.role == AssistantMessageRole.user && last.content == input;
  }

  Future<void> confirmProposedAction({
    required String messageId,
    required String proposalId,
  }) async {
    final target = _findProposalTarget(
      messageId: messageId,
      proposalId: proposalId,
    );
    if (target == null) {
      return;
    }

    final proposal = target.$2;
    if (!proposal.isActionable) {
      return;
    }

    _updateProposalState(
      messageId: messageId,
      proposalId: proposalId,
      executionState: AssistantProposalExecutionState.executing,
      executionError: null,
    );

    try {
      await _executeProposal(proposal);
      _updateProposalState(
        messageId: messageId,
        proposalId: proposalId,
        executionState: AssistantProposalExecutionState.confirmed,
        executionError: null,
      );
    } catch (error) {
      final messageText = LucentErrorMapper.fromObject(error).message;
      _updateProposalState(
        messageId: messageId,
        proposalId: proposal.id,
        executionState: AssistantProposalExecutionState.failed,
        executionError: messageText,
      );
      rethrow;
    }
  }

  void dismissProposedAction({
    required String messageId,
    required String proposalId,
  }) {
    _updateProposalState(
      messageId: messageId,
      proposalId: proposalId,
      executionState: AssistantProposalExecutionState.dismissed,
      executionError: null,
    );
  }

  Future<void> _executeProposal(AssistantProposedAction proposal) async {
    switch (proposal.payload) {
      case AssistantCreateDailyRecordProposalPayload():
        final payload =
            proposal.payload as AssistantCreateDailyRecordProposalPayload;
        await ref
            .read(dailyRecordRepositoryProvider)
            .create(
              DailyRecordCreateInput(
                kind: _mapDailyRecordKind(payload.draft.kind),
                occurredAt: payload.draft.occurredAt,
                title: payload.draft.title,
                value: payload.draft.value,
                unit: payload.draft.unit,
                note: payload.draft.note,
                payload: payload.draft.payload,
              ),
            );
      case AssistantUpdateDailyRecordProposalPayload():
        final payload =
            proposal.payload as AssistantUpdateDailyRecordProposalPayload;
        await ref
            .read(dailyRecordRepositoryProvider)
            .update(
              payload.recordId,
              DailyRecordUpdateInput(
                occurredAt: payload.hasOccurredAt
                    ? payload.occurredAt
                    : dailyRecordNoChange,
                title: payload.hasTitle ? payload.title : dailyRecordNoChange,
                value: payload.hasValue ? payload.value : dailyRecordNoChange,
                unit: payload.hasUnit ? payload.unit : dailyRecordNoChange,
                note: payload.hasNote ? payload.note : dailyRecordNoChange,
                payload: payload.hasPayload
                    ? payload.payload
                    : dailyRecordNoChange,
              ),
            );
      case AssistantDeleteDailyRecordProposalPayload():
        final payload =
            proposal.payload as AssistantDeleteDailyRecordProposalPayload;
        await ref.read(dailyRecordRepositoryProvider).delete(payload.recordId);
      case AssistantUpdateUserSettingsProposalPayload():
        final payload =
            proposal.payload as AssistantUpdateUserSettingsProposalPayload;
        await ref
            .read(userSettingsControllerProvider.notifier)
            .applySettingsPatch(
              UpdateUserSettingsDto(
                assistantEnabled: payload.draft.assistantEnabled,
                assistantMemoryEnabled: payload.draft.assistantMemoryEnabled,
                assistantContext: payload.draft.assistantContext == null
                    ? null
                    : UpdateAssistantContextSettingsDto(
                        healthProfile:
                            payload.draft.assistantContext!.healthProfile,
                        dailyRecords: payload.draft.assistantContext!.dailyRecords,
                        sleepRecords: payload.draft.assistantContext!.sleepRecords,
                        currentMedicines:
                            payload.draft.assistantContext!.currentMedicines,
                      ),
              ),
            );
        await loadCapabilities();
    }
  }

  (AssistantMessage, AssistantProposedAction)? _findProposalTarget({
    required String messageId,
    required String proposalId,
  }) {
    for (final message in state.messages) {
      if (_messageIdOf(message) != messageId) {
        continue;
      }
      for (final proposal in message.proposedActions) {
        if (proposal.id == proposalId) {
          return (message, proposal);
        }
      }
    }
    return null;
  }

  void _updateProposalState({
    required String messageId,
    required String proposalId,
    required AssistantProposalExecutionState executionState,
    required String? executionError,
  }) {
    state = state.copyWith(
      messages: state.messages
          .map((message) {
            if (_messageIdOf(message) != messageId) {
              return message;
            }
            return message.copyWith(
              proposedActions: message.proposedActions
                  .map(
                    (proposal) => proposal.id == proposalId
                        ? proposal.copyWith(
                            executionState: executionState,
                            executionError: executionError,
                          )
                        : proposal,
                  )
                  .toList(growable: false),
            );
          })
          .toList(growable: false),
    );
  }

  DailyRecordKind _mapDailyRecordKind(String raw) {
    return switch (raw) {
      'water' => DailyRecordKind.water,
      'meal' => DailyRecordKind.meal,
      'symptom' => DailyRecordKind.symptom,
      'note' => DailyRecordKind.note,
      'sleep' => DailyRecordKind.sleep,
      _ => DailyRecordKind.note,
    };
  }

  String messageIdOf(AssistantMessage message) => _messageIdOf(message);

  String _messageIdOf(AssistantMessage message) {
    return '${message.role.name}-${message.createdAt.toIso8601String()}-${message.content.hashCode}';
  }
}

final assistantControllerProvider =
    NotifierProvider<AssistantController, AssistantState>(AssistantController.new);
