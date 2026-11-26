//! Failure vocabulary shared with the Dart side.
//!
//! ## Why not `anyhow` (which is what most llama-cpp-2 examples use)
//!
//! The bridge serialises error values, so a type-erased `Box<dyn Error>` would
//! arrive in Dart as a string and the app would have to match on message text to
//! decide whether to offer a model download or a smaller context. A closed enum
//! crosses the boundary as a real value and keeps that decision a type-level one.

use thiserror::Error;

/// What went wrong, in terms the app can act on.
#[derive(Debug, Error)]
pub enum LlamaError {
    /// The shared library or its backend failed to initialise.
    #[error("llama.cpp backend unavailable: {0}")]
    BackendUnavailable(String),

    /// The GGUF could not be opened or parsed.
    #[error("model could not be loaded: {0}")]
    ModelUnreadable(String),

    /// The context could not be created — usually the requested window exceeds
    /// available memory.
    #[error("context could not be created: {0}")]
    ContextUnavailable(String),

    /// The prompt could not be tokenised.
    #[error("prompt rejected: {0}")]
    PromptRejected(String),

    /// A decode step failed mid-generation.
    #[error("decode failed: {0}")]
    DecodeFailed(String),

    /// The caller's grammar is invalid, or the sampler produced nothing for it.
    #[error("grammar invalid: {0}")]
    GrammarInvalid(String),

    /// Generation was stopped by the caller.
    #[error("generation cancelled")]
    Cancelled,

    /// The session was used after release, or two calls raced on one context.
    #[error("invalid state: {0}")]
    InvalidState(String),
}

impl LlamaError {
    /// Stable tag carried across the bridge.
    ///
    /// A string rather than an integer: the Dart enum is generated from this,
    /// and a numeric tag makes a reorder look harmless in a diff.
    pub fn kind(&self) -> &'static str {
        match self {
            Self::BackendUnavailable(_) => "backendUnavailable",
            Self::ModelUnreadable(_) => "modelUnreadable",
            Self::ContextUnavailable(_) => "contextUnavailable",
            Self::PromptRejected(_) => "promptRejected",
            Self::DecodeFailed(_) => "decodeFailed",
            Self::GrammarInvalid(_) => "grammarInvalid",
            Self::Cancelled => "cancelled",
            Self::InvalidState(_) => "invalidState",
        }
    }
}

/// Whether retrying the same call could plausibly succeed.
///
/// Only a decode failure qualifies: every other variant describes a
/// configuration the caller would have to change, so a retry button there just
/// fails again.
impl LlamaError {
    pub fn is_retryable(&self) -> bool {
        matches!(self, Self::DecodeFailed(_))
    }
}

pub type LlamaResult<T> = Result<T, LlamaError>;