import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/features/assistant/data/repositories/lucent.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';

mixin CapabilitiesLoader on Notifier<AssistantState> {
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
}
