//! The llama.cpp session: the only place a model or a context exists.
//!
//! ## Why this is a plain struct and not shared state
//!
//! A `llama_context` holds a KV cache, so two generations on one context would
//! interleave their tokens. The Dart side therefore creates one engine per
//! conversation and serialises calls through it; making the Rust type `Sync`
//! with interior locking would invite exactly the interleaving the KV cache
//! cannot survive. `flutter_rust_bridge` handles the async wrapping.

use llama_cpp_2::context::params::LlamaContextParams;
use llama_cpp_2::llama_backend::LlamaBackend;
use llama_cpp_2::llama_batch::LlamaBatch;
use llama_cpp_2::model::params::LlamaModelParams;
use llama_cpp_2::model::{AddBos, LlamaChatMessage, LlamaModel};
use llama_cpp_2::sampling::LlamaSampler;

use crate::error::{LlamaError, LlamaResult};
use crate::options::{EngineOptions, GenerationOptions, ModelInfo};

/// One loaded model plus its context.
///
/// Field order matters for drop: Rust drops in declaration order, and the
/// context borrows the model. Declaring the model first means it outlives the
/// context, which is the same ordering constraint the C API has.
pub struct Engine {
    model: LlamaModel,
    backend: LlamaBackend,
    options: EngineOptions,
}

impl Engine {
    /// Initialises the backend and loads `model_path`.
    pub fn load(model_path: &str, options: EngineOptions) -> LlamaResult<Self> {
        options.validate()?;

        let backend = LlamaBackend::init().map_err(|error| {
            // The common cause here is a missing native library or an
            // unsupported CPU feature, not a bad argument.
            LlamaError::BackendUnavailable(error.to_string())
        })?;

        let mut params = LlamaModelParams::default();
        if options.gpu_layers > 0 {
            params = params.with_n_gpu_layers(options.gpu_layers as u32);
        }
        if !options.use_mmap {
            // `with_use_mmap(false)` reads the weights into anonymous memory.
            // Left on by default so the OS can reclaim clean pages.
            params = params.with_use_mmap(false);
        }

        let model = LlamaModel::load_from_file(&backend, model_path, &params)
            .map_err(|error| LlamaError::ModelUnreadable(error.to_string()))?;

        Ok(Self {
            model,
            backend,
            options,
        })
    }

    /// Reads the model's own description of itself.
    pub fn info(&self) -> ModelInfo {
        let trained_context_length = self.model.n_ctx_train();
        ModelInfo {
            architecture: self.describe("general.architecture"),
            name: self.describe("general.name"),
            trained_context_length,
            embedding_size: self.model.n_embd(),
            layer_count: self.model.n_layer(),
            has_chat_template: self.model.chat_template(None).is_ok(),
        }
    }

    fn describe(&self, key: &str) -> String {
        self.model
            .meta_val_str(key)
            .unwrap_or_default()
    }

    /// Applies the model's embedded chat template.
    ///
    /// Returns `Ok(None)` when the GGUF has no template: the caller then builds
    /// a prompt itself rather than receive a format the model never saw.
    pub fn format_chat_prompt(
        &self,
        roles: &[String],
        contents: &[String],
    ) -> LlamaResult<Option<String>> {
        if roles.len() != contents.len() {
            return Err(LlamaError::InvalidState(
                "roles and contents must have the same length".into(),
            ));
        }
        let messages: Vec<LlamaChatMessage> = roles
            .iter()
            .zip(contents.iter())
            .map(|(role, content)| LlamaChatMessage::new(role.clone(), content.clone()))
            .collect::<Result<_, _>>()
            .map_err(|error| LlamaError::PromptRejected(error.to_string()))?;

        match self.model.chat_template(None) {
            Ok(template) => self
                .model
                .apply_chat_template(&template, &messages, true)
                .map(Some)
                .map_err(|error| LlamaError::PromptRejected(error.to_string())),
            // No template is not a failure: it is an answer the caller acts on.
            Err(_) => Ok(None),
        }
    }

    /// The context parameters for this engine's options.
    fn context_params(&self) -> LlamaContextParams {
        LlamaContextParams::default()
            .with_n_ctx(Some(
                std::num::NonZeroU32::new(self.options.context_length)
                    .unwrap_or(std::num::NonZeroU32::MIN),
            ))
            .with_n_batch(self.options.batch_size)
    }

    /// Streams a completion, calling `on_token` for each decoded piece.
    ///
    /// The callback is synchronous and runs on this thread: the Dart side
    /// forwards each piece into a `StreamSink`, so the UI paints between tokens
    /// while the decode loop keeps running.
    ///
    /// Returning `false` from the callback stops generation; the result then
    /// reports `cancelled: true` and keeps the text produced so far — a user
    /// pressing stop should not lose what they already read.
    pub fn generate<F>(
        &self,
        prompt: &str,
        options: GenerationOptions,
        mut on_token: F,
    ) -> LlamaResult<(String, u32, bool)>
    where
        F: FnMut(&str) -> bool,
    {
        options.validate()?;

        let context = self
            .model
            .new_context(&self.backend, self.context_params())
            .map_err(|error| LlamaError::ContextUnavailable(error.to_string()))?;

        // Tokenise the prompt. `AddBos` follows the model: adding a BOS the model
        // does not expect degrades output subtly rather than failing.
        let tokens = self
            .model
            .str_to_token(prompt, AddBos::Always)
            .map_err(|error| LlamaError::PromptRejected(error.to_string()))?;
        if tokens.is_empty() {
            return Err(LlamaError::PromptRejected("prompt produced no tokens".into()));
        }

        // Decode the prompt in batches: a prompt longer than `n_batch` fails if
        // submitted at once, and a catalog-heavy system prompt routinely is.
        let batch_size = self.options.batch_size.max(1) as usize;
        let mut batch = LlamaBatch::new(batch_size, 1);
        let last = tokens.len().saturating_sub(1);
        for (offset, chunk) in tokens.chunks(batch_size).enumerate() {
            batch.clear();
            for (index, token) in chunk.iter().enumerate() {
                let position = (offset * batch_size + index) as i32;
                // Only the final prompt token needs its logits: they are what
                // the sampler reads. Requesting them all wastes memory.
                batch
                    .add(*token, position, &[0], position as usize == last)
                    .map_err(|error| LlamaError::DecodeFailed(error.to_string()))?;
            }
            context
                .decode(&mut batch)
                .map_err(|error| LlamaError::DecodeFailed(error.to_string()))?;
        }

        // Build the sampler chain. The grammar goes first so every other sampler
        // filters inside the set it allows; reversed, the model can pick a token
        // the grammar rejects and decoding fails mid-stream.
        let mut chain = LlamaSampler::chain_simple([
            LlamaSampler::penalties(
                options.repeat_last_n,
                options.repeat_penalty,
                0.0,
                0.0,
            ),
        ]);

        if let Some(grammar) = options.grammar.as_deref() {
            match LlamaSampler::grammar(&self.model, grammar, "root") {
                Ok(sampler) => chain = chain.with_sampler(sampler),
                Err(error) => {
                    return Err(LlamaError::GrammarInvalid(error.to_string()));
                }
            }
        }

        if options.temperature <= 0.0 {
            chain = chain.with_sampler(LlamaSampler::greedy());
        } else {
            if options.top_k > 0 {
                chain = chain.with_sampler(LlamaSampler::top_k(options.top_k));
            }
            if options.top_p < 1.0 {
                chain = chain.with_sampler(LlamaSampler::top_p(options.top_p, 1));
            }
            chain = chain
                .with_sampler(LlamaSampler::temp(options.temperature))
                .with_sampler(LlamaSampler::dist(0));
        }

        let mut text = String::new();
        let mut generated: u32 = 0;
        let mut cancelled = false;
        let mut tail = String::new();

        while generated < options.max_tokens as u32 {
            let token = chain.sample(&context, -1);

            if self.model.is_eog_token(token) {
                break;
            }

            let piece = match self.model.token_to_piece(token, &mut |_| {}) {
                Ok(piece) => piece,
                Err(error) => {
                    return Err(LlamaError::DecodeFailed(error.to_string()));
                }
            };

            text.push_str(&piece);
            generated += 1;

            // A stop string can straddle two tokens, so matching runs on a
            // rolling window rather than per piece.
            tail.push_str(&piece);
            if tail.len() > 64 {
                let cut = tail.len() - 64;
                // Borrowed boundary: `truncate` is safe on a char boundary, and
                // cutting mid-codepoint would panic.
                tail = tail.chars().skip(cut.min(tail.chars().count())).collect();
            }
            let hit_stop = options
                .stop_sequences
                .iter()
                .any(|stop| !stop.is_empty() && tail.ends_with(stop));

            if !on_token(&piece) {
                cancelled = true;
                break;
            }
            if hit_stop {
                break;
            }

            // Feed the token back for the next step.
            batch.clear();
            batch
                .add(token, (tokens.len() + generated as usize - 1) as i32, &[0], true)
                .map_err(|error| LlamaError::DecodeFailed(error.to_string()))?;
            context
                .decode(&mut batch)
                .map_err(|error| LlamaError::DecodeFailed(error.to_string()))?;
        }

        Ok((text, generated, cancelled))
    }

    /// The options this engine was loaded with, for diagnostics.
    pub fn options(&self) -> &EngineOptions {
        &self.options
    }
}