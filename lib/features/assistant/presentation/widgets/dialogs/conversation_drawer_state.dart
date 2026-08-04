import 'package:flutter/foundation.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';

/// Lightweight projection of [AssistantState] used by the conversation drawer.
///
/// Watching only these fields (instead of the full [AssistantState]) keeps the
/// drawer from rebuilding when streaming-related fields (messages,
/// streamingDraft, etc.) change, while still comparing by value thanks to
/// [valueListenable] equality.
@immutable
class AssistantDrawerState {
  const AssistantDrawerState({
    required this.conversationId,
    required this.isOpeningConversation,
    required this.isLoadingRecentConversations,
    required this.recentConversationError,
    required this.recentConversations,
  });

  final String? conversationId;
  final bool isOpeningConversation;
  final bool isLoadingRecentConversations;
  final String? recentConversationError;
  final List<AssistantConversationSummary> recentConversations;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantDrawerState &&
          runtimeType == other.runtimeType &&
          conversationId == other.conversationId &&
          isOpeningConversation == other.isOpeningConversation &&
          isLoadingRecentConversations == other.isLoadingRecentConversations &&
          recentConversationError == other.recentConversationError &&
          listEquals(recentConversations, other.recentConversations);

  @override
  int get hashCode => Object.hash(
    conversationId,
    isOpeningConversation,
    isLoadingRecentConversations,
    recentConversationError,
    recentConversations,
  );
}
