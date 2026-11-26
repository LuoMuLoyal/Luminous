//! Public surface of the Rust inference core.
//!
//! Everything the Dart side can call lives under [`api`]. The rest is internal:
//! [`engine`] holds the llama.cpp session, [`error`] maps llama.cpp's failure
//! modes onto values the bridge can carry, and [`options`] mirrors the domain
//! value types.
//!
//! ## Why the bridge surface is tiny
//!
//! Every type that crosses `flutter_rust_bridge` has to be regenerated on both
//! sides, and a signature change silently invalidates the other side until the
//! generator runs again. Keeping the surface to a handful of calls means the
//! generated code stays reviewable and the Dart domain layer does not churn.

mod api;
mod engine;
mod error;
mod options;

pub use api::*;