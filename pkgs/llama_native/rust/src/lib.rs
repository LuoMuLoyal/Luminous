//! Public surface of the Rust inference core.
//!
//! ## Module layout
//!
//! - [`api`] — the callable surface: session handle plus operations.
//! - [`engine`] — internal; holds the llama.cpp model and context.
//! - [`error`] — the failure vocabulary, shared with the Dart side.
//! - [`options`] — value types crossing the bridge.
//!
//! Everything the Dart side can reach lives in [`api`]. `engine` stays private
//! because exposing it would let a caller hold a model across a session swap,
//! which is exactly the KV-cache aliasing this design prevents.
//!
//! ## Why the bridge surface is tiny
//!
//! Every type that crosses `flutter_rust_bridge` has to be regenerated on both
//! sides, and a signature change silently invalidates the other side until the
//! generator runs. Keeping the surface to a handful of calls keeps the generated
//! code reviewable and the Dart domain layer stable.

pub mod api;
pub mod error;
pub mod options;

mod engine;

pub use api::*;
pub use error::{LlamaError, LlamaResult};
pub use options::{
    EngineOptions, GenerationOptions, GenerationResult, ModelInfo,
};