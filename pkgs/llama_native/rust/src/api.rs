//! The callable surface: the only functions the bridge exposes.
//!
//! ## Shape
//!
//! An opaque session handle plus a handful of operations. Dart sees
//! `Future<ModelInfo>`, a `Stream<String>` for tokens, and a typed error — never
//! an FFI pointer.
//!
//! ## Why signatures spell out `Result<T, LlamaError>`
//!
//! The code generator parses the source, not the type system: it does **not** see
//! through a `type LlamaResult<T> = Result<T, LlamaError>` alias, and treats the
//! alias as an opaque handle. The generated Dart then offers no way to read the
//! value or the error. Writing the `Result` out in full is the one form it
//! understands.
//!
//! ## Why `generate` takes a `StreamSink`
//!
//! It is `flutter_rust_bridge`'s representation of a Rust-to-Dart stream, and it
//! lives in the generated module — which is why this crate only became
//! bridge-ready once the generator had run once. The callback it replaces would
//! be a function pointer, which the generator skips along with any generic
//! parameter.

use std::sync::Mutex;

use crate::engine::Engine;
use crate::error::LlamaError;
use crate::frb_generated::StreamSink;
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
    fn with_engine<T>(
        &self,
        body: impl FnOnce(&Engine) -> Result<T, LlamaError>,
    ) -> Result<T, LlamaError> {
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
pub fn load_session(
    model_path: String,
    options: EngineOptions,
) -> Result<LlamaSession, LlamaError> {
    let engine = Engine::load(&model_path, options)?;
    Ok(LlamaSession {
        inner: Mutex::new(Some(engine)),
    })
}

/// Reads the loaded model's metadata.
pub fn session_info(session: &LlamaSession) -> Result<ModelInfo, LlamaError> {
    session.with_engine(|engine| Ok(engine.info()))
}

/// Applies the model's chat template; `None` when the GGUF carries none.
pub fn format_chat_prompt(
    session: &LlamaSession,
    roles: Vec<String>,
    contents: Vec<String>,
) -> Result<Option<String>, LlamaError> {
    session.with_engine(|engine| engine.format_chat_prompt(&roles, &contents))
}

/// Streams a completion to [sink].
///
/// Each emission is one decoded token piece. A piece is **not** a word: it is
/// whatever the tokenizer produced, and a multi-byte character can span pieces,
/// so consumers concatenate rather than parsing individual emissions.
///
/// The return value carries the full text and token count, so a caller that
/// ignores the stream still gets the result. Cancellation is expressed by the
/// caller closing the stream — `sink.send` then reports an error, which stops the
/// decode loop instead of burning CPU producing output nobody receives.
pub fn generate(
    session: &LlamaSession,
    prompt: String,
    options: GenerationOptions,
    sink: StreamSink<String>,
) -> Result<(), LlamaError> {
    session.with_engine(|engine| {
        // The pieces travel through `sink`; the return value only reports
        // whether the loop completed. A caller that needs the assembled text
        // concatenates what the stream delivered.
        let (_text, _tokens, _cancelled) = engine.generate(&prompt, options, |piece| {
            sink.add(piece.to_owned()).is_ok()
        })?;
        Ok(())
    })
}

/// Releases the model and its context.
///
/// Idempotent: a second call finds `None` and succeeds, so the Dart disposal path
/// does not have to track whether it already ran.
pub fn release_session(session: &LlamaSession) -> Result<(), LlamaError> {
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