import 'dart:async';

import 'package:clock/clock.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/core/network/contract/error_mapper.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/assistant/data/repositories/lucent.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/domain/repositories/assistant.dart';
import 'package:luminous/features/assistant/presentation/utils/message_id.dart';

part 'conversation.freezed.dart';

enum AssistantSendErrorType { server, streamInterrupted, emptyResult, unknown }

@freezed
abstract class AssistantState with _$AssistantState {
  const AssistantState._();

  const factory AssistantState({
    @Default(false) bool isLoadingCapabilities,
    @Default(false) bool isLoadingConversation,
    @Default(false) bool isLoadingRecentConversations,
    @Default(false) bool isOpeningConversation,
    @Default(false) bool isClearingConversation,
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
  final Set<String> _renamingConversationIds = <String>{};

  @override
  AssistantState build() {
    final session = ref.watch(authSessionProvider);
    if (!session.canAccessProtectedData) {
      return const AssistantState();
    }

    unawaited(Future<void>.microtask(_bootstrap));
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

    final result = await ref
        .read(assistantRepositoryProvider)
        .getCapabilities()
        .run();
    switch (result) {
      case Left(:final value):
        ref
            .read(talkerProvider)
            .error('AssistantController.loadCapabilities: failed: $value');
        state = state.copyWith(
          isLoadingCapabilities: false,
          capabilityError: value.message,
        );
      case Right(:final value):
        state = state.copyWith(
          isLoadingCapabilities: false,
          capabilities: value,
          capabilityError: null,
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

    final result = await ref
        .read(assistantRepositoryProvider)
        .getLatestConversation()
        .run();
    switch (result) {
      case Left(:final value):
        ref
            .read(talkerProvider)
            .error(
              'AssistantController.loadLatestConversation: failed: $value',
            );
        state = state.copyWith(
          isLoadingConversation: false,
          conversationError: value.message,
        );
      case Right(:final value):
        state = state.copyWith(
          isLoadingConversation: false,
          conversationId: value?.id,
          messages: value?.messages ?? const <AssistantMessage>[],
          streamingDraft: '',
          conversationError: null,
          sendError: null,
          sendErrorType: null,
          lastFailedInput: null,
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

    final result = await ref
        .read(assistantRepositoryProvider)
        .listRecentConversations()
        .run();
    switch (result) {
      case Left(:final value):
        ref
            .read(talkerProvider)
            .error(
              'AssistantController.loadRecentConversations: failed: $value',
            );
        state = state.copyWith(
          isLoadingRecentConversations: false,
          recentConversationError: value.message,
        );
      case Right(:final value):
        state = state.copyWith(
          isLoadingRecentConversations: false,
          recentConversations: value,
          recentConversationError: null,
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

    final result = await ref
        .read(assistantRepositoryProvider)
        .openConversation(conversationId)
        .run();
    switch (result) {
      case Left(:final value):
        ref
            .read(talkerProvider)
            .error('AssistantController.openConversation: failed: $value');
        state = state.copyWith(
          isOpeningConversation: false,
          conversationError: value.message,
        );
      case Right(:final value):
        state = state.copyWith(
          isOpeningConversation: false,
          conversationId: value.id,
          messages: value.messages,
          streamingDraft: '',
          conversationError: null,
        );
        await loadRecentConversations();
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
          .error('AssistantController._sendMessageInternal: failed: $error');
      final message = LucentErrorMapper.fromObject(error).message;
      final errorType = _classifySendError(error);
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

  AssistantSendErrorType _classifySendError(Object error) {
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
        return _classifySendError(embedded);
      }
      return AssistantSendErrorType.unknown;
    }
    if (error is StateError || error is FormatException) {
      return AssistantSendErrorType.streamInterrupted;
    }
    return AssistantSendErrorType.unknown;
  }

  /// F-5b 灰态辅助:把 [messages] 中最后一条 assistant 消息标记为
  /// `replaced: true`(已是 replaced 或没有 assistant 消息时原样返回)。
  List<AssistantMessage> _markLastAssistantReplaced(
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
            final replacedMessages = _markLastAssistantReplaced(state.messages);
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
      final errorType = _classifySendError(error);
      // 与 _sendMessageInternal 相同的 F-3 补偿:断流残句保留为失败消息。
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
    await _sendMessageInternal(trimmed, appendUserMessage: false);
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

    state = state.copyWith(isClearingConversation: true);

    final result = await ref
        .read(assistantRepositoryProvider)
        .clearLatestConversation()
        .run();
    switch (result) {
      case Left(:final value):
        ref
            .read(talkerProvider)
            .error('AssistantController.clearConversation: failed: $value');
        state = state.copyWith(
          isClearingConversation: false,
          conversationError: value.message,
        );
        return;
      case Right():
        break;
    }

    state = state.copyWith(
      isClearingConversation: false,
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

  /// Renames one persisted conversation with an optimistic local update.
  ///
  /// The list entry title is replaced immediately (trimmed; empty becomes
  /// null), then the backend is called. On failure the previous title is
  /// restored and the error is rethrown so the page can toast it.
  Future<void> renameConversation({
    required String conversationId,
    required String title,
  }) async {
    final trimmed = title.trim();
    final newTitle = trimmed.isEmpty ? null : trimmed;

    final current = state.recentConversations;
    final index = current.indexWhere((item) => item.id == conversationId);
    if (index < 0) {
      return;
    }
    if (newTitle != null && !_renamingConversationIds.add(conversationId)) {
      ref
          .read(talkerProvider)
          .debug(
            'AssistantController.renameConversation: ignored concurrent rename '
            'for conversation $conversationId',
          );
      return;
    }
    final oldTitle = current[index].title;
    final updated = List<AssistantConversationSummary>.of(current);
    updated[index] = _summaryWithTitle(current[index], newTitle);
    state = state.copyWith(recentConversations: updated);

    // The backend rejects empty titles (`@IsNotEmpty`); an empty input only
    // clears the name locally and is never persisted.
    if (newTitle == null) {
      return;
    }

    try {
      final result = await ref
          .read(assistantRepositoryProvider)
          .renameConversation(conversationId: conversationId, title: newTitle)
          .run();
      switch (result) {
        case Left(:final value):
          ref
              .read(talkerProvider)
              .error('AssistantController.renameConversation: failed: $value');
          state = state.copyWith(
            recentConversations: state.recentConversations
                .map(
                  (item) => item.id == conversationId
                      ? _summaryWithTitle(item, oldTitle)
                      : item,
                )
                .toList(growable: false),
          );
          throw value;
        case Right():
          break;
      }
    } finally {
      _renamingConversationIds.remove(conversationId);
    }

    // Re-fetch the list so server-derived ordering/title stays authoritative.
    // Refresh failures are non-fatal; the optimistic title is kept.
    await loadRecentConversations();
    if (state.recentConversationError != null) {
      ref
          .read(talkerProvider)
          .debug(
            'AssistantController.renameConversation: refresh failed '
            'after rename for conversation $conversationId',
          );
    }
  }

  /// Soft-deletes one persisted conversation and closes the local state when
  /// it was the currently active conversation.
  ///
  /// Deleting the active conversation clears the local messages and falls back
  /// to [loadLatestConversation] so the drawer/page never shows a stale or
  /// blank conversation; [loadLatestConversation] already handles the
  /// no-conversation case (returns an empty state, not a white screen).
  Future<void> deleteConversation(String conversationId) async {
    final result = await ref
        .read(assistantRepositoryProvider)
        .deleteConversation(conversationId)
        .run();
    switch (result) {
      case Left(:final value):
        ref
            .read(talkerProvider)
            .error('AssistantController.deleteConversation: failed: $value');
        throw value;
      case Right():
        break;
    }

    final isCurrent = state.conversationId == conversationId;
    if (isCurrent) {
      state = state.copyWith(
        conversationId: null,
        messages: const <AssistantMessage>[],
        streamingDraft: '',
        conversationError: null,
        sendError: null,
        sendErrorType: null,
        lastFailedInput: null,
      );
      await loadLatestConversation();
    }
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

    // The real write is applied server-side by the confirm endpoint (F-11):
    // approved proposals are executed atomically from the thread state before
    // the graph thread is resumed. A persisted conversation is therefore
    // required — without one the graph never suspends and there is no pending
    // proposal to confirm.
    final conversationId = state.conversationId;
    if (conversationId == null || conversationId.isEmpty) {
      throw StateError('No persisted conversation for proposal confirmation.');
    }

    _updateProposalState(
      messageId: messageId,
      proposalId: proposalId,
      executionState: AssistantProposalExecutionState.executing,
      executionError: null,
    );

    final result = await ref
        .read(assistantRepositoryProvider)
        .confirmProposals(
          conversationId: conversationId,
          proposalIds: <String>[proposal.id],
          decision: 'approved',
        )
        .run();
    switch (result) {
      case Left(:final value):
        ref
            .read(talkerProvider)
            .error('AssistantController.confirmProposedAction: failed: $value');
        _updateProposalState(
          messageId: messageId,
          proposalId: proposal.id,
          executionState: AssistantProposalExecutionState.failed,
          executionError: value.message,
        );
        throw value;
      case Right(:final value):
        _appendFinalContent(value);
    }
    _updateProposalState(
      messageId: messageId,
      proposalId: proposal.id,
      executionState: AssistantProposalExecutionState.confirmed,
      executionError: null,
    );
    ref
        .read(dataChangeBusProvider.notifier)
        .emit(_dataChangeTopicFor(proposal.type));
    await loadRecentConversations();
  }

  /// Maps a confirmed proposal type to the cross-feature data invalidation
  /// topic so dashboards refresh after the server-side write (F-11).
  String _dataChangeTopicFor(AssistantProposedActionType type) {
    return switch (type) {
      AssistantProposedActionType.createDailyRecord ||
      AssistantProposedActionType.updateDailyRecord ||
      AssistantProposedActionType.deleteDailyRecord =>
        DataChangeTopic.dailyRecords,
      AssistantProposedActionType.updateUserSettings =>
        DataChangeTopic.userSettings,
    };
  }

  /// Re-triggers the streaming pipeline with the user message that originally
  /// produced an expired proposal, so the assistant generates a fresh one.
  ///
  /// Finds the last `user` message preceding the assistant message that
  /// carries the proposal. When a send is already in flight the call is a
  /// no-op (the incoming reply would race with the running stream).
  Future<void> regenerateExpiredProposal({
    required String messageId,
    required String proposalId,
  }) async {
    if (state.isSending || state.isLoadingConversation) {
      return;
    }

    final userMessage = _precedingUserMessage(messageId);
    if (userMessage == null) {
      throw StateError(
        'Could not find the message that produced this proposal.',
      );
    }

    await _sendMessageInternal(userMessage.content, appendUserMessage: false);
  }

  /// Returns the last `user` message before the assistant message with the
  /// given id, or null when there is none.
  AssistantMessage? _precedingUserMessage(String messageId) {
    final index = state.messages.indexWhere(
      (message) => messageIdFor(message) == messageId,
    );
    if (index < 0) {
      return null;
    }
    for (var i = index - 1; i >= 0; i--) {
      final message = state.messages[i];
      if (message.role == AssistantMessageRole.user) {
        return message;
      }
    }
    return null;
  }

  Future<void> dismissProposedAction({
    required String messageId,
    required String proposalId,
  }) async {
    final conversationId = state.conversationId;
    if (conversationId == null || conversationId.isEmpty) {
      _updateProposalState(
        messageId: messageId,
        proposalId: proposalId,
        executionState: AssistantProposalExecutionState.dismissed,
        executionError: null,
      );
      return;
    }

    // In a persisted conversation dismissing a proposal rejects it on the
    // backend so the suspended graph thread resumes and the user can keep
    // chatting with the same conversation.
    final result = await ref
        .read(assistantRepositoryProvider)
        .confirmProposals(
          conversationId: conversationId,
          proposalIds: <String>[proposalId],
          decision: 'rejected',
        )
        .run();
    switch (result) {
      case Left(:final value):
        ref
            .read(talkerProvider)
            .error('AssistantController.dismissProposedAction: failed: $value');
        _updateProposalState(
          messageId: messageId,
          proposalId: proposalId,
          executionState: AssistantProposalExecutionState.failed,
          executionError: value.message,
        );
        throw value;
      case Right(:final value):
        _appendFinalContent(value);
    }

    _updateProposalState(
      messageId: messageId,
      proposalId: proposalId,
      executionState: AssistantProposalExecutionState.dismissed,
      executionError: null,
    );
  }

  /// Appends the assistant confirmation reply produced after a proposal
  /// decision is applied on the backend, when one is available.
  void _appendFinalContent(String? finalContent) {
    final content = finalContent?.trim();
    if (content == null || content.isEmpty) {
      return;
    }
    state = state.copyWith(
      messages: <AssistantMessage>[
        ...state.messages,
        AssistantMessage(
          role: AssistantMessageRole.assistant,
          content: content,
          createdAt: clock.now(),
        ),
      ],
    );
  }

  (AssistantMessage, AssistantProposedAction)? _findProposalTarget({
    required String messageId,
    required String proposalId,
  }) {
    for (final message in state.messages) {
      if (messageIdFor(message) != messageId) {
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
            if (messageIdFor(message) != messageId) {
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
}

final assistantControllerProvider =
    NotifierProvider<AssistantController, AssistantState>(
      AssistantController.new,
    );

/// Returns a copy of [summary] with its title replaced.
AssistantConversationSummary _summaryWithTitle(
  AssistantConversationSummary summary,
  String? title,
) {
  return AssistantConversationSummary(
    id: summary.id,
    title: title,
    status: summary.status,
    lastMessageAt: summary.lastMessageAt,
    createdAt: summary.createdAt,
    updatedAt: summary.updatedAt,
  );
}
