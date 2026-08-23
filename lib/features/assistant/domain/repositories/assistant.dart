import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';

sealed class AssistantGenerationEvent {
  const AssistantGenerationEvent();
}

class AssistantGenerationChunkEvent extends AssistantGenerationEvent {
  const AssistantGenerationChunkEvent(this.content);

  final String content;
}

class AssistantGenerationResultEvent extends AssistantGenerationEvent {
  const AssistantGenerationResultEvent({
    required this.conversationId,
    required this.message,
  });

  final String conversationId;
  final AssistantMessage message;
}

abstract interface class AssistantRepository {
  /// Repository boundary: every expected recoverable failure (network, server
  /// business failure) is a `TaskEither` Left produced via
  /// `LucentErrorMapper.fromObject`. A legal empty conversation set stays a
  /// Right.
  TaskEither<LucentFailure, AssistantCapabilities> getCapabilities();

  TaskEither<LucentFailure, List<AssistantConversationSummary>>
  listRecentConversations();

  /// Returns the latest persisted conversation, or null when there is none
  /// (a legal Right, not an error).
  TaskEither<LucentFailure, AssistantConversation?> getLatestConversation();

  TaskEither<LucentFailure, AssistantConversation> openConversation(
    String conversationId,
  );

  TaskEither<LucentFailure, bool> clearLatestConversation();

  /// Renames one persisted conversation (title only) on the backend.
  TaskEither<LucentFailure, void> renameConversation({
    required String conversationId,
    required String title,
  });

  /// Soft-deletes one persisted conversation on the backend.
  TaskEither<LucentFailure, void> deleteConversation(String conversationId);

  /// Streams a chat completion. Keeps stream event semantics — not wrapped in
  /// [TaskEither]. Stream failures (server errors, user cancellation, SSE
  /// interruption) surface as stream errors.
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages, {
    String? conversationId,
  });

  /// Regenerates the last assistant message of a persisted conversation
  /// (F-5b): the backend replays the recorded checkpoint and streams a fresh
  /// answer; the old answer stays in the conversation as a revision.
  ///
  /// Keeps stream event semantics — not wrapped in [TaskEither].
  Stream<AssistantGenerationEvent> regenerateLastMessage(
    String conversationId, {
    required void Function(String content) onChunk,
  });

  /// Confirms or rejects pending assistant write proposals on the backend and
  /// resumes the suspended graph thread. Returns the final assistant content
  /// produced after the decision is applied, or null when unavailable.
  TaskEither<LucentFailure, String?> confirmProposals({
    required String conversationId,
    required List<String> proposalIds,
    required String decision,
    String? note,
  });
}
