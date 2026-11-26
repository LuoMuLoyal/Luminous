//! Value types crossing the bridge.
//!
//! Plain structs with owned fields: `flutter_rust_bridge` can serialise borrowed
//! data, but a `&str` tied to a stack frame is a lifetime bug waiting to happen
//! once the generated code is in the loop.

use crate::error::LlamaError;

/// How a model is loaded.
#[derive(Debug, Clone)]
pub struct EngineOptions {
    /// KV-cache window. Memory scales linearly with this — not with
    /// `max_tokens` — so it is what decides whether a device can hold the model.
    pub context_length: u32,
    /// Prompt tokens decoded per step; must not exceed `context_length`.
    pub batch_size: u32,
    /// Compute threads. Deliberately a parameter rather than "all cores": on a
    /// phone, pinning every core hits the thermal limit before it saves time.
    pub threads: i32,
    /// Layers offloaded to the GPU. 0 is CPU-only.
    pub gpu_layers: i32,
    /// Memory-map the weights instead of copying them, so the OS can evict clean
    /// pages under pressure rather than killing the app.
    pub use_mmap: bool,
}

impl Default for EngineOptions {
    fn default() -> Self {
        Self {
            context_length: 4096,
            batch_size: 512,
            threads: 4,
            gpu_layers: 0,
            use_mmap: true,
        }
    }
}

impl EngineOptions {
    /// Rejects a configuration llama.cpp would only fail on mid-decode.
    pub fn validate(&self) -> Result<(), LlamaError> {
        if self.context_length < 512 {
            return Err(LlamaError::ContextUnavailable(
                "context_length must be at least 512".into(),
            ));
        }
        if self.batch_size == 0 || self.batch_size > self.context_length {
            return Err(LlamaError::ContextUnavailable(format!(
                "batch_size must be in [1, context_length]; got {} with context_length {}",
                self.batch_size, self.context_length
            )));
        }
        if self.threads < 1 {
            return Err(LlamaError::InvalidState(
                "threads must be at least 1".into(),
            ));
        }
        if self.gpu_layers < 0 {
            return Err(LlamaError::InvalidState(
                "gpu_layers must be >= 0".into(),
            ));
        }
        Ok(())
    }
}

/// Sampling and decoding settings for one generation.
#[derive(Debug, Clone)]
pub struct GenerationOptions {
    pub max_tokens: i32,
    /// 0 means greedy; `top_p` / `top_k` are then ignored.
    pub temperature: f32,
    pub top_p: f32,
    pub top_k: i32,
    pub repeat_penalty: f32,
    /// Recent tokens the repetition penalty inspects; 0 disables it.
    pub repeat_last_n: i32,
    pub stop_sequences: Vec<String>,
    /// GBNF grammar constraining every sampled token.
    ///
    /// This is why a small local model can be trusted with machine-readable
    /// output: the sampler cannot emit a token the grammar rejects.
    pub grammar: Option<String>,
}

impl Default for GenerationOptions {
    fn default() -> Self {
        Self {
            max_tokens: 512,
            temperature: 0.7,
            top_p: 0.95,
            top_k: 40,
            repeat_penalty: 1.1,
            repeat_last_n: 64,
            stop_sequences: Vec::new(),
            grammar: None,
        }
    }
}

impl GenerationOptions {
    pub fn validate(&self) -> Result<(), LlamaError> {
        if self.max_tokens < 1 {
            return Err(LlamaError::InvalidState(
                "max_tokens must be at least 1".into(),
            ));
        }
        if !(0.0..=2.0).contains(&self.temperature) {
            return Err(LlamaError::InvalidState(
                "temperature must be in [0, 2]".into(),
            ));
        }
        if self.top_p <= 0.0 || self.top_p > 1.0 {
            return Err(LlamaError::InvalidState("top_p must be in (0, 1]".into()));
        }
        Ok(())
    }
}

/// What the GGUF reports about itself.
#[derive(Debug, Clone)]
pub struct ModelInfo {
    pub architecture: String,
    pub name: String,
    /// The context length the model was **trained** for — an upper bound, not a
    /// recommendation; KV memory is why the runtime usually uses less.
    pub trained_context_length: u32,
    pub embedding_size: u32,
    pub layer_count: u32,
    /// Whether the file carries its own chat template, which is what makes
    /// prompt format the model's responsibility rather than the app's.
    pub has_chat_template: bool,
}

/// One completion's outcome.
#[derive(Debug, Clone)]
pub struct GenerationResult {
    pub text: String,
    pub completion_tokens: u32,
    /// True when the caller stopped it; `text` then holds what was produced.
    pub cancelled: bool,
}