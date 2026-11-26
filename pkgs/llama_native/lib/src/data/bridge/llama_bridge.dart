import '../../domain/entities/chat_message.dart';
import '../../domain/entities/engine_options.dart';
import '../../domain/entities/generation_options.dart';
import '../../domain/entities/model_info.dart';

/// The seam between this package and the generated Rust bridge.
///
/// ## Why an interface rather than calling generated code directly
///
/// `flutter_rust_bridge_codegen` emits free functions with mechanical names into
/// `lib/src/data/ffi/`. Calling them from the engine would mean that (a) the
/// engine cannot be tested without a native library, and (b) every regeneration
/// ripples through the repository layer.
///
/// This interface is the contract the generated code will satisfy. One
/// implementation (`RustBridgeBindings`, written once codegen has run) adapts the
/// generated functions; `RustLlamaEngine` depends only on this. A fake
/// implementation then covers the engine's own logic in tests.
///
/// ## Why the DTOs are not in `domain/`
///
/// They are the *wire* shape — deliberately dumber than the domain entities, with
/// primitives only. If `flutter_rust_bridge` changes how it mirrors a Rust struct,
/// only the binding implementation deals with it; the domain does not move.
abstract interface class LlamaBridge {
  /// Loads a model and returns an opaque session handle.
  ///
  /// The handle is `Object` rather than a typed class so that swapping the
  /// generated type does not change this contract.
  Future<Object> loadSession({
    required String modelPath,
    required EngineOptions options,
  });

  /// Reads the loaded model's metadata.
  Future<ModelInfo> sessionInfo(Object session);

  /// Applies the chat template; null when the GGUF carries none.
  Future<String?> formatChatPrompt({
    required Object session,
    required List<ChatMessage> messages,
  });

  /// Streams a completion as token pieces.
  ///
  /// Each event carries either a piece or a failure — never both. A failure can
  /// arrive after the first piece, which is why it is a stream event rather than
  /// a thrown exception: the caller must keep the text already produced.
  Stream<TokenEvent> generate({
    required Object session,
    required String prompt,
    required GenerationOptions options,
  });

  /// Releases the session's native resources.
  Future<void> releaseSession(Object session);
}

/// One emission from [LlamaBridge.generate].
final class TokenEvent {
  const TokenEvent.piece(String this.piece) : failure = null;
  const TokenEvent.failure(Object this.failure) : piece = null;

  /// The decoded text, when this event carries output.
  final String? piece;

  /// The failure, when this event ends generation abnormally.
  final Object? failure;

  bool get isFailure => failure != null;
}
