import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/assistant/data/repositories/lucent.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation_sending.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation_streams.dart';
import 'package:luminous/features/assistant/presentation/utils/message_id.dart';

mixin ProposalHandling
    on Notifier<AssistantState>, MessageSending, ConversationStreams {
  Future<void> confirmProposedAction({
    required String messageId,
    required String proposalId,
  }) async {
    final target = findProposalTarget(
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

    updateProposalState(
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
        updateProposalState(
          messageId: messageId,
          proposalId: proposal.id,
          executionState: AssistantProposalExecutionState.failed,
          executionError: value.message,
        );
        throw value;
      case Right(:final value):
        appendFinalContent(value);
    }
    updateProposalState(
      messageId: messageId,
      proposalId: proposal.id,
      executionState: AssistantProposalExecutionState.confirmed,
      executionError: null,
    );
    ref
        .read(dataChangeBusProvider.notifier)
        .emit(dataChangeTopicFor(proposal.type));
    await loadRecentConversations();
  }

  /// Maps a confirmed proposal type to the cross-feature data invalidation
  /// topic so dashboards refresh after the server-side write (F-11).
  String dataChangeTopicFor(AssistantProposedActionType type) {
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

    final userMessage = precedingUserMessage(messageId);
    if (userMessage == null) {
      throw StateError(
        'Could not find the message that produced this proposal.',
      );
    }

    await sendMessageInternal(userMessage.content, appendUserMessage: false);
  }

  /// Returns the last `user` message before the assistant message with the
  /// given id, or null when there is none.
  AssistantMessage? precedingUserMessage(String messageId) {
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
      updateProposalState(
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
        updateProposalState(
          messageId: messageId,
          proposalId: proposalId,
          executionState: AssistantProposalExecutionState.failed,
          executionError: value.message,
        );
        throw value;
      case Right(:final value):
        appendFinalContent(value);
    }

    updateProposalState(
      messageId: messageId,
      proposalId: proposalId,
      executionState: AssistantProposalExecutionState.dismissed,
      executionError: null,
    );
  }

  /// Appends the assistant confirmation reply produced after a proposal
  /// decision is applied on the backend, when one is available.
  void appendFinalContent(String? finalContent) {
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

  (AssistantMessage, AssistantProposedAction)? findProposalTarget({
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

  void updateProposalState({
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
