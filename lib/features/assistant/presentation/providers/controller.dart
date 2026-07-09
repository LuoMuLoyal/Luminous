import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lucent_api/api/export.dart'
    show UpdateAssistantContextSettingsDto, UpdateUserSettingsDto;
import 'package:luminous/core/logger/app_logger.dart';
import 'package:luminous/core/network/api_exception.dart';
import 'package:luminous/core/network/error_mapper.dart';
import 'package:luminous/features/assistant/data/repositories/lucent_repository.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/auth/presentation/providers/session/session_provider.dart';
import 'package:luminous/features/record/data/providers/providers.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings_controller.dart';

part 'controller.freezed.dart';

enum AssistantSendErrorType { server, streamInterrupted, emptyResult, unknown }

@freezed
abstract class AssistantState with _$AssistantState {
  const AssistantState._();

  const factory AssistantState({
    @Default(false) bool isLoadingCapabilities,
    @Default(false) bool isLoadingConversation,
    @Default(false) bool isLoadingRecentConversations,
    @Default(false) bool isOpeningConversation,
    @Default(false) bool isSending,
    AssistantCapabilities? capabilities,
    String? capabilityError,
    String? conversationError,
    String? recentConversationError,
    String? sendError,
    AssistantSendErrorType? sendErrorType,
    String? lastFailedInput,
    String? conversationId,
    @Default([]) List<AssistantConversationSummary> recentConversations,
    @Default([]) List<AssistantMessage> messages,
    @Default('') String streamingDraft,
  }) = _AssistantState;

  bool get hasConversation => messages.isNotEmpty || streamingDraft.isNotEmpty;
}

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
      ref
          .read(talkerProvider)
          .error('AssistantController.loadCapabilities: failed: $error');
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
      ref
          .read(talkerProvider)
          .error('AssistantController.loadLatestConversation: failed: $error');
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
      ref
          .read(talkerProvider)
          .error('AssistantController.loadRecentConversations: failed: $error');
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
      ref
          .read(talkerProvider)
          .error('AssistantController.openConversation: failed: $error');
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
              .streamMessages(nextMessages)) {
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
      ref
          .read(talkerProvider)
          .error('AssistantController._sendMessageInternal: failed: $error');
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
      ref
          .read(talkerProvider)
          .error('AssistantController.clearConversation: failed: $error');
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
      ref
          .read(talkerProvider)
          .error('AssistantController.confirmProposedAction: failed: $error');
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
    if (proposal.isExpired) {
      throw const LucentApiException(message: '这条建议已过期，请重新生成。');
    }
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
        final ctx = payload.draft.assistantContext;
        final current = ref.read(userSettingsControllerProvider).value;
        await ref
            .read(userSettingsControllerProvider.notifier)
            .applySettingsPatch(
              UpdateUserSettingsDto(
                aiSummariesEnabled: current?.aiSummariesEnabled ?? false,
                dataSharingConsent: current?.dataSharingConsent ?? false,
                assistantEnabled:
                    payload.draft.assistantEnabled ??
                    current?.assistantEnabled ??
                    false,
                assistantMemoryEnabled:
                    payload.draft.assistantMemoryEnabled ??
                    current?.assistantMemoryEnabled ??
                    false,
                assistantContext: ctx != null
                    ? UpdateAssistantContextSettingsDto(
                        healthProfile: ctx.healthProfile,
                        dailyRecords: ctx.dailyRecords,
                        sleepRecords: ctx.sleepRecords,
                        currentMedicines: ctx.currentMedicines,
                      )
                    : UpdateAssistantContextSettingsDto(
                        healthProfile: current?.assistantContext.healthProfile,
                        dailyRecords: current?.assistantContext.dailyRecords,
                        sleepRecords: current?.assistantContext.sleepRecords,
                        currentMedicines:
                            current?.assistantContext.currentMedicines,
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
    NotifierProvider<AssistantController, AssistantState>(
      AssistantController.new,
    );
