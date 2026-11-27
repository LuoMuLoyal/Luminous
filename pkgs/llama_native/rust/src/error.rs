//! Failure vocabulary shared with the Dart side.
//!
//! ## Why not `anyhow` (which most llama-cpp-2 examples use)
//!
//! The bridge serialises error values, so a type-erased `Box<dyn Error>` would
//! arrive in Dart as a string and the app would have to match on message text to
//! decide whether to offer a model download or a smaller context. A closed enum
//! crosses the boundary as a real value and keeps that decision type-level.
//!
//! ## Why `Display` is hand-written
//!
//! `thiserror` would save eight impl lines and cost a dependency in the build
//! graph of a crate that already compiles llama.cpp. The derive is not worth it
//! here; `fmt::Display` is four lines.

use std::fmt;

/// What went wrong, in terms the app can act on.
#[derive(Debug)]
pub enum LlamaError {
    /// The shared library or its backend failed to initialise.
    BackendUnavailable(String),

    /// The GGUF could not be opened or parsed.
    ModelUnreadable(String),

    /// The context could not be created — usually the requested window exceeds
    /// available memory.
    ContextUnavailable(String),

    /// The prompt could not be tokenised.
    PromptRejected(String),

    /// A decode step failed mid-generation.
    DecodeFailed(String),

    /// The caller's grammar is invalid.
    GrammarInvalid(String),

    /// Generation was stopped by the caller.
    Cancelled,

    /// The session was used after release, or two calls raced on one context.
    InvalidState(String),
}

impl LlamaError {
    /// Stable tag carried across the bridge.
    ///
    /// A string rather than an integer: the Dart enum is derived from this, and a
    /// numeric tag makes a reorder look harmless in a diff.
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

    /// Whether retrying the same call could plausibly succeed.
    ///
    /// Only a decode failure qualifies: every other variant describes a
    /// configuration the caller must change, so a retry button there just fails
    /// again.
    pub fn is_retryable(&self) -> bool {
        matches!(self, Self::DecodeFailed(_))
    }
}

impl fmt::Display for LlamaError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        // The variant tag is part of the message on purpose: the generated bridge
        // has no typed error channel yet, so the Dart side recovers the kind from
        // this text (see `bridge_error_mapper.dart`). Changing these words is a
        // breaking change for that mapper.
        // Built from `kind()` so the prefix is literally the tag the Dart mapper
        // matches on. Spelling the names twice is how the two drift apart.
        let tag = self.kind();
        match self {
            Self::Cancelled => write!(f, "{tag}"),
            Self::BackendUnavailable(detail)
            | Self::ModelUnreadable(detail)
            | Self::ContextUnavailable(detail)
            | Self::PromptRejected(detail)
            | Self::DecodeFailed(detail)
            | Self::GrammarInvalid(detail)
            | Self::InvalidState(detail) => write!(f, "{tag}: {detail}"),
        }
    }
}

impl std::error::Error for LlamaError {}

pub type LlamaResult<T> = Result<T, LlamaError>;