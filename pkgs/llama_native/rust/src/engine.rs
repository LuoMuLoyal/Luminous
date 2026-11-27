//! The llama.cpp session: the only place a model or a context exists.
//!
//! ## Why this is not shared state
//!
//! A context holds a KV cache, so two generations on one context would interleave
//! their tokens. The Dart side therefore keeps one engine per conversation and
//! serialises calls through it; making this type shareable with interior locking
//! would invite exactly the interleaving the cache cannot survive.
//!
//! ## API notes for `llama-cpp-2` 0.1.x
//!
//! Three things differ from what the upstream README shows and are easy to get
//! wrong:
//!
//! - There is no `AddBos` enum; tokenisation takes an `add_special` bool.
//! - `token_to_piece(token, special, lstrip)` returns `Vec<u8>`, not `String` —
//!   a single token can be an incomplete UTF-8 sequence.
//! - Samplers are assembled **before** the chain is built (`chain_simple` takes
//!   the whole list); there is no `with_sampler` builder.

use std::num::NonZeroU32;

use llama_cpp_2::context::params::LlamaContextParams;
use llama_cpp_2::llama_backend::LlamaBackend;
use llama_cpp_2::llama_batch::LlamaBatch;
use llama_cpp_2::model::params::LlamaModelParams;
use llama_cpp_2::model::{LlamaChatMessage, LlamaModel};
use llama_cpp_2::sampling::LlamaSampler;

use crate::error::{LlamaError, LlamaResult};
use crate::options::{EngineOptions, GenerationOptions, ModelInfo};

/// One loaded model plus the backend it came from.
///
/// Declaration order matters for drop: the model borrows the backend, so the
/// model is declared first and released first.
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
            // The usual cause is a missing native library or an unsupported CPU
            // feature, not a bad argument.
            LlamaError::BackendUnavailable(error.to_string())
        })?;

        let mut params = LlamaModelParams::default();
        if options.gpu_layers > 0 {
            params = params.with_n_gpu_layers(options.gpu_layers as u32);
        }
        if !options.use_mmap {
            // Reading the weights into anonymous memory instead of mapping them
            // costs startup time and removes the OS's ability to reclaim pages.
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
        ModelInfo {
            architecture: self.describe("general.architecture"),
            name: self.describe("general.name"),
            trained_context_length: self.model.n_ctx_train(),
            // `n_embd` is a C `int` upstream; the domain type is unsigned because
            // a negative embedding width is not a meaningful value.
            embedding_size: self.model.n_embd().max(0) as u32,
            layer_count: self.model.n_layer(),
            has_chat_template: self.model.chat_template(None).is_ok(),
        }
    }

    fn describe(&self, key: &str) -> String {
        self.model.meta_val_str(key).unwrap_or_default()
    }

    /// Applies the model's embedded chat template.
    ///
    /// `Ok(None)` when the GGUF has no template: the caller then builds a prompt
    /// itself rather than receive a format the model never saw.
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
            .map(|(role, content)| {
                LlamaChatMessage::new(role.clone(), content.clone())
            })
            .collect::<Result<_, _>>()
            .map_err(|error| LlamaError::PromptRejected(error.to_string()))?;

        match self.model.chat_template(None) {
            Ok(template) => self
                .model
                .apply_chat_template(&template, &messages, true)
                .map(Some)
                .map_err(|error| LlamaError::PromptRejected(error.to_string())),
            // No template is an answer, not a failure.
            Err(_) => Ok(None),
        }
    }

    fn context_params(&self) -> LlamaContextParams {
        LlamaContextParams::default()
            .with_n_ctx(NonZeroU32::new(self.options.context_length))
            .with_n_batch(self.options.batch_size)
            .with_n_threads(self.options.threads)
            .with_n_threads_batch(self.options.threads)
    }

    /// Builds the sampler chain.
    ///
    /// Order matters: the grammar goes first so every later sampler filters
    /// inside the set it allows. Reversed, the model can pick a token the grammar
    /// rejects and decoding fails mid-stream.
    fn build_sampler(&self, options: &GenerationOptions) -> LlamaResult<LlamaSampler> {
        let mut samplers = Vec::with_capacity(6);

        if let Some(grammar) = options.grammar.as_deref() {
            let sampler = LlamaSampler::grammar(&self.model, grammar, "root")
                .map_err(|error| LlamaError::GrammarInvalid(error.to_string()))?;
            samplers.push(sampler);
        }

        if options.repeat_last_n > 0 && options.repeat_penalty > 0.0 {
            samplers.push(LlamaSampler::penalties(
                self.model.n_vocab(),
                options.repeat_last_n,
                options.repeat_penalty,
                0.0,
                0.0,
            ));
        }

        if options.temperature <= 0.0 {
            // Greedy: top-k / top-p would be dead weight.
            samplers.push(LlamaSampler::greedy());
        } else {
            if options.top_k > 0 {
                samplers.push(LlamaSampler::top_k(options.top_k));
            }
            if options.top_p < 1.0 {
                samplers.push(LlamaSampler::top_p(options.top_p, 1));
            }
            samplers.push(LlamaSampler::temp(options.temperature));
            samplers.push(LlamaSampler::dist(0));
        }

        Ok(LlamaSampler::chain_simple(samplers))
    }

    /// Streams a completion, calling `on_token` per decoded piece.
    ///
    /// The callback runs synchronously on this thread. Returning `false` stops
    /// generation and the result reports `cancelled: true` while keeping the text
    /// already produced — a user pressing stop should not lose what they read.
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

        let mut context = self
            .model
            .new_context(&self.backend, self.context_params())
            .map_err(|error| LlamaError::ContextUnavailable(error.to_string()))?;

        let vocab = self.model.vocab();

        // `add_special: true` matches what the model expects at the start of a
        // prompt; `parse_special: true` lets a template emit its own markers.
        let tokens = vocab.tokenize(prompt.as_bytes(), true, true);
        if tokens.is_empty() {
            return Err(LlamaError::PromptRejected(
                "prompt produced no tokens".into(),
            ));
        }

        // Decode the prompt in batches: a prompt larger than `n_batch` fails if
        // submitted at once, and a long system prompt regularly is.
        let batch_size = self.options.batch_size.max(1) as usize;
        let mut batch = LlamaBatch::new(batch_size, 1);
        let last_index = tokens.len().saturating_sub(1);

        for (chunk_index, chunk) in tokens.chunks(batch_size).enumerate() {
            batch.clear();
            for (offset, token) in chunk.iter().enumerate() {
                let position = (chunk_index * batch_size + offset) as i32;
                // Only the final prompt token needs logits: they are what the
                // sampler reads, and requesting them all wastes memory.
                batch
                    .add(*token, position, &[0], position as usize == last_index)
                    .map_err(|error| LlamaError::DecodeFailed(error.to_string()))?;
            }
            context
                .decode(&mut batch)
                .map_err(|error| LlamaError::DecodeFailed(error.to_string()))?;
        }

        let mut sampler = self.build_sampler(&options)?;

        let mut text = String::new();
        let mut generated: u32 = 0;
        let mut cancelled = false;
        let mut tail = String::new();

        while generated < options.max_tokens as u32 {
            let token = sampler.sample(&context, -1);

            if vocab.is_eog(token) {
                break;
            }

            // A token can be a partial UTF-8 sequence, so it is collected as bytes
            // and decoded lossily rather than assumed to be a `String`.
            let piece_bytes = vocab.token_to_piece(token, true, None);
            let piece = String::from_utf8_lossy(&piece_bytes).into_owned();

            text.push_str(&piece);
            generated += 1;

            // A stop string can straddle two tokens, so matching runs on a rolling
            // window rather than per piece.
            tail.push_str(&piece);
            if tail.chars().count() > 64 {
                let skip = tail.chars().count() - 64;
                tail = tail.chars().skip(skip).collect();
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
                .add(
                    token,
                    (tokens.len() + generated as usize - 1) as i32,
                    &[0],
                    true,
                )
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