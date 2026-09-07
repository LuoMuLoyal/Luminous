import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/features/assistant/data/repositories/lucent.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';

mixin ConversationStreams on Notifier<AssistantState> {
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
}
