import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/features/assistant/data/repositories/lucent.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation_streams.dart';

mixin ConversationManagement on Notifier<AssistantState>, ConversationStreams {
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
    updated[index] = summaryWithTitle(current[index], newTitle);
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
                      ? summaryWithTitle(item, oldTitle)
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

  final Set<String> _renamingConversationIds = <String>{};

  /// Returns a copy of [summary] with its title replaced.
  static AssistantConversationSummary summaryWithTitle(
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
}
