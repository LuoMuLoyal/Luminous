//! The bridge surface: the only functions the Dart side can call.
//!
//! ## Shape
//!
//! An opaque session handle plus a handful of operations. `flutter_rust_bridge`
//! turns each into an async Dart function, so the Dart layer sees
//! `Future<ModelInfo>`, a `Stream<String>` for tokens, and a typed error — never
//! an FFI pointer.
//!
//! ## Why the session is opaque
//!
//! `LlamaModel` and the context are `!Send`-adjacent in the sense that a context's
//! KV cache must not be shared; exposing them would let Dart keep a handle across
//! a model switch. `OnceLock`/`Mutex` would make the type `Sync` and invite that
//! misuse, so the handle is a boxed value the bridge owns and Dart can only drop.

use std::sync::Mutex;

use crate::engine::Engine;
use crate::error::{LlamaError, LlamaResult};
use crate::options::{EngineOptions, GenerationOptions, ModelInfo};

/// A loaded model and its context, as Dart sees it.
///
/// `Mutex` rather than interior mutability on the engine: the bridge may call in
/// from a different task, and serialising through the mutex is exactly the
/// guarantee the KV cache needs. Released is a state, not a dangling handle.
pub struct LlamaSession {
    inner: Mutex<Option<Engine>>,
}

impl LlamaSession {
    fn with_engine<T>(&self, body: impl FnOnce(&Engine) -> LlamaResult<T>) -> LlamaResult<T> {
        let guard = self
            .inner
            .lock()
            // A poisoned mutex means a previous call panicked mid-decode. The
            // context state is unknown, so refusing is the only safe answer.
            .map_err(|_| LlamaError::InvalidState("session lock poisoned by a panic".into()))?;
        match guard.as_ref() {
            Some(engine) => body(engine),
            None => Err(LlamaError::InvalidState(
                "the session has been released".into(),
            )),
        }
    }
}

/// Loads a model and returns a session handle.
///
/// Replaces nothing: a caller wanting a new model releases the old session first,
/// because two loaded models is two KV caches and phones do not have the memory.
pub fn load_session(model_path: String, options: EngineOptions) -> LlamaResult<LlamaSession> {
    let engine = Engine::load(&model_path, options)?;
    Ok(LlamaSession {
        inner: Mutex::new(Some(engine)),
    })
}

/// Reads the loaded model's metadata.
pub fn session_info(session: &LlamaSession) -> LlamaResult<ModelInfo> {
    session.with_engine(|engine| Ok(engine.info()))
}

/// Applies the model's chat template; `None` when the GGUF carries none.
pub fn format_chat_prompt(
    session: &LlamaSession,
    roles: Vec<String>,
    contents: Vec<String>,
) -> LlamaResult<Option<String>> {
    session.with_engine(|engine| engine.format_chat_prompt(&roles, &contents))
}

/// Streams a completion.
///
/// `sink` receives one piece per decoded token. A piece is **not** a word: it is
/// whatever the tokenizer produced, and a multi-byte character can span pieces,
/// so consumers concatenate rather than parsing individual emissions.
///
/// The returned value is the full text plus the token count, so a caller can
/// discard the stream and still have the result — that keeps the Dart side able
/// to buffer when it wants to without a second call.
pub fn generate(
    session: &LlamaSession,
    prompt: String,
    options: GenerationOptions,
    sink: &StreamSink<String>,
) -> LlamaResult<GenerationResult> {
    session.with_engine(|engine| {
        let (text, tokens, cancelled) = engine.generate(&prompt, options, |piece| {
            // A send failure means the Dart listener went away. Report it by
            // returning false so the decode loop stops instead of burning CPU
            // producing output nobody receives.
            sink.add(piece.to_owned()).is_ok()
        })?;
        Ok(GenerationResult {
            text,
            completion_tokens: tokens,
            cancelled,
        })
    })
}

/// Releases the model and its context.
///
/// Idempotent: a second call finds `None` and succeeds, so the Dart `dispose`
/// path does not have to track whether it already ran.
pub fn release_session(session: &LlamaSession) -> LlamaResult<()> {
    let mut guard = session
        .inner
        .lock()
        .map_err(|_| LlamaError::InvalidState("session lock poisoned by a panic".into()))?;
    // Dropping the engine frees the context before the model, matching the
    // ordering the C API requires.
    *guard = None;
    Ok(())
}

use flutter_rust_bridge::frb;
use flutter_rust_bridge::StreamSink;

use crate::options::GenerationResult;

/// Keeps the generated bridge from exposing the Rust-internal engine type.
#[frb(ignore)]
pub fn _internal_marker() {}