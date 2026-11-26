import '../entities/chat_message.dart';
import '../entities/engine_options.dart';
import '../entities/generation_options.dart';
import '../entities/model_info.dart';
import '../failures/llama_failure.dart';

/// What an on-device LLM engine must be able to do.
///
/// ## Why a port at all
///
/// The app depends on this, never on a llama.cpp-specific class. That buys three
/// things that matter for a device-local model:
///
/// - **Testability**: a fake engine runs the app's streaming UI and cancellation
///   paths without a 2 GB model or a native build.
/// - **Swappability**: a platform whose build is not ready (or a future
///   LiteRT-LM backend) implements this instead of rewriting call sites.
/// - **Discipline about failure**: every method reports [LlamaFailure] through
///   the returned future or stream, so no call site can pretend loading always
///   succeeds.
///
/// ## Threading contract
///
/// Implementations run inference **off the platform thread**. The interface says
/// nothing about isolates because that is an implementation decision, but a
/// synchronous implementation that blocks the UI would violate the intent of
/// [generate]: the whole point of a stream is that the app can paint between
/// tokens.
abstract interface class LlamaEngine {
  /// Loads a GGUF model and allocates its context.
  ///
  /// Replaces any previously loaded model. Throws [LlamaFailure] when the file is
  /// unreadable or the context cannot be allocated.
  Future<ModelInfo> load(String modelPath, {EngineOptions options});

  /// Applies the model's own chat template to [messages].
  ///
  /// Returns `null` when the GGUF carries no template: the caller then supplies
  /// a prompt itself rather than receive a format the model was never trained
  /// on. Guessing a template here would produce plausible-looking but incorrect
  /// output, which is worse than a clear "not available".
  Future<String?> formatChatPrompt(List<ChatMessage> messages);

  /// Streams a completion for [prompt].
  ///
  /// Each event is a piece of decoded UTF-8 text. **A piece is not a word or a
  /// character** — it is whatever the tokenizer produced, and a multi-byte
  /// character can span pieces. Consumers concatenate; nothing should assume a
  /// piece is a complete unit.
  ///
  /// Errors surface as [LlamaFailure] on the stream, not as a thrown exception
  /// before the stream exists: a failure can arrive mid-generation, and the app
  /// needs to keep what was already shown.
  Stream<String> generate(String prompt, {GenerationOptions? options});

  /// Clears the KV cache so the next [generate] starts from an empty history.
  ///
  /// Required between conversations: a finished generation leaves its tokens in
  /// the cache, and without this reset the next turn behaves as though it is
  /// continuing the previous one.
  Future<void> reset();

  /// Releases the model, the context, and any worker.
  ///
  /// Safe to call twice; callers use it in `dispose`.
  Future<void> release();
}
