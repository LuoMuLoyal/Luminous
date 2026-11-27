//! Tests for the public value types and the error vocabulary.
//!
//! A model is a multi-gigabyte download, so everything checkable without one is
//! checked here: parameter validation and error classification both run in
//! milliseconds.
//!
//! The generation loop is **not** covered — proving it needs real weights, and
//! that belongs to the integration step. Saying so is better than mocking
//! llama.cpp and calling it verification.

use llama_native_rust::error::LlamaError;
use llama_native_rust::options::{EngineOptions, GenerationOptions};

#[test]
fn engine_options_reject_a_batch_larger_than_the_context() {
    // Upstream would fail the decode instead of reporting a bad parameter, and
    // that failure surfaces mid-generation where it is hard to attribute.
    let options = EngineOptions {
        context_length: 512,
        batch_size: 1024,
        ..EngineOptions::default()
    };
    assert!(options.validate().is_err());
}

#[test]
fn engine_options_reject_a_context_below_the_floor() {
    let options = EngineOptions {
        context_length: 128,
        batch_size: 128,
        ..EngineOptions::default()
    };
    assert!(options.validate().is_err());
}

#[test]
fn engine_options_reject_zero_threads() {
    let options = EngineOptions {
        threads: 0,
        ..EngineOptions::default()
    };
    assert!(options.validate().is_err());
}

#[test]
fn engine_options_accept_the_defaults() {
    assert!(EngineOptions::default().validate().is_ok());
}

#[test]
fn generation_options_reject_out_of_range_sampling() {
    // A top_p of 0 leaves an empty candidate set; llama.cpp degenerates rather
    // than treating it as greedy.
    let bad_top_p = GenerationOptions {
        top_p: 0.0,
        ..GenerationOptions::default()
    };
    assert!(bad_top_p.validate().is_err());

    let bad_temperature = GenerationOptions {
        temperature: 2.5,
        ..GenerationOptions::default()
    };
    assert!(bad_temperature.validate().is_err());

    let bad_max_tokens = GenerationOptions {
        max_tokens: 0,
        ..GenerationOptions::default()
    };
    assert!(bad_max_tokens.validate().is_err());
}

#[test]
fn generation_options_accept_the_defaults() {
    assert!(GenerationOptions::default().validate().is_ok());
}

#[test]
fn error_kinds_are_stable_tags() {
    // Pinned because `bridge_error_mapper.dart` matches on these exact strings:
    // the generated bridge has no typed error channel, so the Dart side recovers
    // the kind from the `Display` prefix. Changing a tag is a breaking change.
    let cases = [
        (
            LlamaError::BackendUnavailable(String::new()),
            "backendUnavailable",
        ),
        (LlamaError::ModelUnreadable(String::new()), "modelUnreadable"),
        (
            LlamaError::ContextUnavailable(String::new()),
            "contextUnavailable",
        ),
        (LlamaError::PromptRejected(String::new()), "promptRejected"),
        (LlamaError::DecodeFailed(String::new()), "decodeFailed"),
        (LlamaError::GrammarInvalid(String::new()), "grammarInvalid"),
        (LlamaError::Cancelled, "cancelled"),
        (LlamaError::InvalidState(String::new()), "invalidState"),
    ];
    for (error, expected) in cases {
        assert_eq!(error.kind(), expected);
        // The Display prefix must carry the same tag, since that is all the Dart
        // side can see through an untyped exception.
        assert!(
            error.to_string().contains(expected),
            "Display for {expected} did not contain the tag: {error}"
        );
    }
}

#[test]
fn only_a_decode_failure_is_retryable() {
    // Everything else is a configuration the caller must change, so offering a
    // retry button would just fail again.
    assert!(LlamaError::DecodeFailed(String::new()).is_retryable());
    assert!(!LlamaError::ModelUnreadable(String::new()).is_retryable());
    assert!(!LlamaError::GrammarInvalid(String::new()).is_retryable());
    assert!(!LlamaError::Cancelled.is_retryable());
}