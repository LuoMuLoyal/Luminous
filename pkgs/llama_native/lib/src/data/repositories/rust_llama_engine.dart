import '../../domain/entities/chat_message.dart';
import '../../domain/entities/engine_options.dart';
import '../../domain/entities/generation_options.dart';
import '../../domain/entities/model_info.dart';
import '../../domain/failures/llama_failure.dart';
import '../../domain/ports/llama_engine.dart';
import '../bridge/bridge_error_mapper.dart';
import '../bridge/llama_bridge.dart';

/// The [LlamaEngine] implementation over the Rust core.
///
/// ## What this class actually does
///
/// Translation and lifetime, nothing else. [LlamaBridge] already gives typed
/// results and a token stream, so there is no FFI, no isolate, and no pointer
/// bookkeeping here — that is what moving the core to Rust removed. What remains
/// Dart's responsibility:
///
/// - mapping bridge errors onto [LlamaFailure];
/// - holding the session handle so a caller cannot use it after release;
/// - refusing calls that would confuse the core (an empty prompt, a conversation
///   with no turns).
///
/// ## Why the bridge is injected
///
/// This class is where the non-trivial logic lives — released-state handling, the
/// empty-input guards, error translation, stream flattening. Taking [LlamaBridge]
/// as a constructor argument lets tests drive all of it with a fake, without a
/// model file, a native library, or a codegen run.
final class RustLlamaEngine implements LlamaEngine {
  RustLlamaEngine._(this._bridge, this._session);

  /// Loads `modelPath` and returns an engine ready to generate.
  static Future<RustLlamaEngine> open(
    LlamaBridge bridge,
    String modelPath, {
    EngineOptions? options,
  }) async {
    try {
      final session = await bridge.loadSession(
        modelPath: modelPath,
        options: options ?? EngineOptions(),
      );
      return RustLlamaEngine._(bridge, session);
    } on LlamaFailure {
      rethrow;
    } on Object catch (error) {
      throw mapBridgeError(error);
    }
  }

  final LlamaBridge _bridge;
  final Object _session;
  bool _released = false;

  @override
  Future<ModelInfo> info() async {
    _requireLive();
    try {
      return await _bridge.sessionInfo(_session);
    } on LlamaFailure {
      rethrow;
    } on Object catch (error) {
      throw mapBridgeError(error);
    }
  }

  @override
  Future<String?> formatChatPrompt(List<ChatMessage> messages) async {
    _requireLive();
    if (messages.isEmpty) {
      throw const LlamaFailure(
        kind: LlamaFailureKind.invalidState,
        message: 'Cannot format an empty conversation.',
      );
    }
    try {
      return await _bridge.formatChatPrompt(
        session: _session,
        messages: messages,
      );
    } on LlamaFailure {
      rethrow;
    } on Object catch (error) {
      throw mapBridgeError(error);
    }
  }

  @override
  Stream<String> generate(String prompt, {GenerationOptions? options}) {
    if (prompt.isEmpty) {
      return Stream.error(
        const LlamaFailure(
          kind: LlamaFailureKind.promptRejected,
          message: 'The prompt is empty.',
        ),
      );
    }
    if (_released) {
      return Stream.error(
        const LlamaFailure(
          kind: LlamaFailureKind.invalidState,
          message: 'This engine has been released.',
        ),
      );
    }

    // Flattening `TokenEvent` into "piece or throw" happens here rather than in
    // the bridge: only the caller knows whether the text produced before a
    // failure should be kept, and a bridge that threw would discard it.
    Stream<String> unfold() async* {
      await for (final event in _bridge.generate(
        session: _session,
        prompt: prompt,
        options: options ?? GenerationOptions(),
      )) {
        final failure = event.failure;
        if (failure != null) {
          throw failure is LlamaFailure ? failure : mapBridgeError(failure);
        }
        final piece = event.piece;
        if (piece != null && piece.isNotEmpty) {
          yield piece;
        }
      }
    }

    return unfold();
  }

  @override
  Future<void> reset() async {
    // The Rust core creates a context per generation, so an empty history is the
    // default and there is nothing to clear. Kept in the interface because a
    // future backend may need it and callers already use it.
    _requireLive();
  }

  @override
  Future<void> release() async {
    if (_released) return;
    _released = true;
    try {
      await _bridge.releaseSession(_session);
    } on Object {
      // Releasing must never throw: it runs from `dispose`.
    }
  }

  void _requireLive() {
    if (_released) {
      throw const LlamaFailure(
        kind: LlamaFailureKind.invalidState,
        message: 'This engine has been released.',
      );
    }
  }
}
