import '../entities/chat_message.dart';
import '../entities/generation_result.dart';
import '../entities/model_info.dart';
import '../failures/llama_failure.dart';

/// Collects a streamed generation into a single result.
///
/// ## Why this is a domain concern and not a helper on the engine
///
/// Deciding when a stream is "done", and what to do with the text produced
/// before a cancellation, is a rule the app cares about — not an implementation
/// detail of llama.cpp. Keeping it here means every backend (and every fake in
/// tests) behaves identically on cancel, and the app does not re-implement the
/// rule at each call site.
///
/// ## Cancellation
///
/// [shouldCancel] is polled after each piece with the text accumulated so far,
/// so a caller can stop on a phrase rather than only by elapsed time. The result
/// keeps the partial text and reports `cancelled: true` — a stop is a normal
/// end, so it does not throw.
final class CollectGeneration {
  const CollectGeneration();

  Future<GenerationResult> call({
    required Stream<String> stream,
    bool Function(String soFar)? shouldCancel,
  }) async {
    final buffer = StringBuffer();
    var pieces = 0;
    var cancelled = false;

    await for (final piece in stream) {
      buffer.write(piece);
      pieces += 1;
      if (shouldCancel?.call(buffer.toString()) ?? false) {
        cancelled = true;
        // Break rather than await cancellation from the engine: the caller has
        // already shown this text, and waiting for the native loop to unwind
        // would freeze that half-finished state on screen.
        break;
      }
    }

    return GenerationResult(
      text: buffer.toString(),
      completionTokens: pieces,
      cancelled: cancelled,
    );
  }
}

/// Shared guard for the operations that require a loaded model.
///
/// Throws [LlamaFailure] rather than returning null: a call made before [load]
/// is a programming error in the caller, and failing where it happens beats a
/// null dereference three frames later.
ModelInfo requireLoaded(ModelInfo? info) {
  if (info == null) {
    throw const LlamaFailure(
      kind: LlamaFailureKind.invalidState,
      message: 'No model is loaded: call load() first.',
    );
  }
  return info;
}

/// Formats [messages] for a model with no embedded template.
///
/// Used only when [formatChatPrompt][LlamaEngine.formatChatPrompt] returns null.
/// Kept as a domain rule so the fallback is visible and testable rather than
/// buried in a backend adapter.
///
/// The format is the plain `Role: content` transcript — deliberately the least
/// presumptuous option. It is what most instruction-tuned models accept when
/// their own template is unavailable, and it is honest about being a fallback.
String fallbackChatPrompt(List<ChatMessage> messages) {
  final buffer = StringBuffer();
  for (final message in messages) {
    buffer.writeln('${_label(message.role)}: ${message.content}');
  }
  buffer.write('Assistant:');
  return buffer.toString();
}

String _label(String role) => switch (role) {
  'system' => 'System',
  'user' => 'User',
  'assistant' => 'Assistant',
  _ => role,
};
