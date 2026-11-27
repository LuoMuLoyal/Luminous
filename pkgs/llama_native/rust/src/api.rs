//! The callable surface: the only functions the bridge exposes.
//!
//! ## Shape
//!
//! An opaque session handle plus a handful of operations. Dart sees
//! `Future<ModelInfo>`, a token stream, and a typed error — never an FFI pointer.
//!
//! ## Why the surface is callback-based rather than `StreamSink`
//!
//! `flutter_rust_bridge` represents a Rust-to-Dart stream with
//! `crate::frb_generated::StreamSink`, which **only exists after the code
//! generator has run**. Referencing it here would make the crate uncompilable
//! until then, which is the wrong order: the llama.cpp integration has to be
//! proven first.
//!
//! So `generate` takes a plain callback, and the generated adapter wraps it in a
//! `StreamSink`. That keeps this crate buildable and unit-testable with no
//! toolchain beyond cargo, and confines the codegen dependency to one adapter
//! file.

use std::sync::Mutex;

use crate::engine::Engine;
use crate::error::{LlamaError, LlamaResult};
use crate::options::{EngineOptions, GenerationOptions, GenerationResult, ModelInfo};

/// A loaded model and its context, as the caller sees it.
///
/// `Mutex` rather than interior mutability on the engine: the bridge may call in
/// from a different task, and serialising through the mutex is exactly the
/// guarantee the KV cache needs. "Released" is a state, not a dangling handle.
pub struct LlamaSession {
    inner: Mutex<Option<Engine>>,
}

impl LlamaSession {
    fn with_engine<T>(&self, body: impl FnOnce(&Engine) -> LlamaResult<T>) -> LlamaResult<T> {
        let guard = self
            .inner
            .lock()
            // A poisoned mutex means a previous call panicked mid-decode; the
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
/// `on_token` receives one piece per decoded token. A piece is **not** a word:
/// it is whatever the tokenizer produced, and a multi-byte character can span
/// pieces, so consumers concatenate rather than parsing individual emissions.
///
/// Returning `false` from `on_token` stops generation; the result then reports
/// `cancelled: true` and keeps the text produced so far.
pub fn generate<F>(
    session: &LlamaSession,
    prompt: String,
    options: GenerationOptions,
    mut on_token: F,
) -> LlamaResult<GenerationResult>
where
    F: FnMut(&str) -> bool,
{
    session.with_engine(|engine| {
        let (text, tokens, cancelled) = engine.generate(&prompt, options, &mut on_token)?;
        Ok(GenerationResult {
            text,
            completion_tokens: tokens,
            cancelled,
        })
    })
}

/// Releases the model and its context.
///
/// Idempotent: a second call finds `None` and succeeds, so the Dart disposal path
/// does not have to track whether it already ran.
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

#[cfg(test)]
mod tests {
    use super::*;

    /// A session with no model, which is the state `release_session` leaves.
    fn released() -> LlamaSession {
        LlamaSession {
            inner: Mutex::new(None),
        }
    }

    #[test]
    fn a_released_session_refuses_work() {
        let session = released();
        let error = session_info(&session).unwrap_err();
        assert_eq!(error.kind(), "invalidState");
    }

    #[test]
    fn releasing_twice_is_not_an_error() {
        // `dispose` must not have to track whether it already ran.
        let session = released();
        assert!(release_session(&session).is_ok());
        assert!(release_session(&session).is_ok());
    }

    #[test]
    fn a_released_session_refuses_generation() {
        let session = released();
        let error = generate(
            &session,
            "hello".to_owned(),
            GenerationOptions::default(),
            |_| true,
        )
        .unwrap_err();
        assert_eq!(error.kind(), "invalidState");
    }

    #[test]
    fn a_released_session_refuses_prompt_formatting() {
        let session = released();
        let error = format_chat_prompt(
            &session,
            vec!["user".to_owned()],
            vec!["hi".to_owned()],
        )
        .unwrap_err();
        assert_eq!(error.kind(), "invalidState");
    }
}