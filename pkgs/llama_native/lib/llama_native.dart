/// On-device LLM inference via llama.cpp, with the core in Rust.
///
/// ## Layout
///
/// Clean architecture with one-way dependencies; the backend language is an
/// implementation detail of the innermost layer:
///
/// ```text
/// domain/          pure Dart: entities, ports, rules. No native code at all.
///   entities/      GenerationOptions, EngineOptions, ModelInfo, ChatMessage …
///   failures/      LlamaFailure and its stable kinds
///   ports/         LlamaEngine — what the app depends on
///   services/      CollectGeneration, fallbackChatPrompt
///
/// data/            the llama.cpp implementation (Rust core + bridge).
///   bridge/        the only file that names generated `flutter_rust_bridge` symbols
///   repositories/  RustLlamaEngine — implements the port
///
/// rust/            the Rust crate: llama-cpp-2 session, options, error mapping.
/// ```
///
/// The app imports [`LlamaEngine`][LlamaEngine] and the value types; it never
/// imports `data/`. A fake engine satisfies the port in tests without a model
/// file, and a future backend is a new folder rather than a rewrite.
///
/// ## Why Rust rather than a hand-written C shim
///
/// `llama-cpp-2` generates its bindings from the vendored llama.cpp source, so an
/// upstream rename becomes a compile error instead of a runtime segfault — the
/// reason the earlier C shim existed at all. The model and context also live
/// behind Rust's ownership rules, which removes the manual pending-call bookkeeping
/// a Dart-only FFI layer needed.
///
/// ## Why inference still runs off the UI thread
///
/// `llama_decode` blocks for hundreds of milliseconds per token. The bridge
/// marshals each call onto a Rust worker, so the Flutter isolate keeps painting
/// between tokens. This is a correctness requirement, not an optimisation.
///
/// ## What this package deliberately does not do
///
/// - **Model download.** The app decides where models come from and verifies
///   them; this package opens a path.
/// - **Chat templates.** They come from the GGUF, via llama.cpp. Guessing a
///   format the model was not trained on produces plausible garbage.
/// - **Prompt construction from app data.** Callers assemble the conversation.
library;

export 'src/data/bridge/bridge_error_mapper.dart'
    show mapBridgeError, mapBridgeErrorKind;
export 'src/data/bridge/llama_bridge.dart' show LlamaBridge, TokenEvent;
export 'src/data/repositories/rust_llama_engine.dart' show RustLlamaEngine;
export 'src/domain/entities/chat_message.dart' show ChatMessage;
export 'src/domain/entities/engine_options.dart' show EngineOptions;
export 'src/domain/entities/generation_options.dart' show GenerationOptions;
export 'src/domain/entities/generation_result.dart' show GenerationResult;
export 'src/domain/entities/model_info.dart' show ModelInfo;
export 'src/domain/failures/llama_failure.dart'
    show LlamaFailure, LlamaFailureKind;
export 'src/domain/ports/llama_engine.dart' show LlamaEngine;
export 'src/domain/services/collect_generation.dart'
    show CollectGeneration, fallbackChatPrompt, requireLoaded;
