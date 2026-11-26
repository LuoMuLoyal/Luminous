/**
 * Stable C ABI over llama.cpp, owned by this package.
 *
 * ## Why a shim instead of binding llama.h directly
 *
 * llama.cpp's C API is **not stable across builds**: upstream renames functions
 * (`llama_load_model_from_file` became `llama_model_load_from_file`), reshapes
 * structs (`llama_context_params` gained and lost fields), and swaps the
 * sampling API wholesale. A dart:ffi binding generated against one build breaks
 * on the next, and the break is a segfault rather than a compile error.
 *
 * This shim is the version-proof seam: ~10 functions whose signatures we
 * control. When upstream moves, only `llama_shim.cpp` changes — no Dart, no
 * platform channel, no app code.
 *
 * ## Calling convention
 *
 * - Every entry point that can fail takes `(char* err, int32_t err_len)` and
 *   returns 0 on success or a negative en error code, writing a message into
 *   `err` when it does. Returning pointers instead and checking null would lose
 *   the reason.
 * - Strings are UTF-8, never NUL-terminated assumptions on length.
 * - Token callbacks are invoked on the generation thread, synchronously, so the
 *   caller can forward a token and return immediately.
 */
#ifndef LLAMA_SHIM_H
#define LLAMA_SHIM_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Platform visibility: the Dart side loads this dylib by path. */
#if defined(_WIN32)
#define LLAMA_SHIM_EXPORT __declspec(dllexport)
#else
#define LLAMA_SHIM_EXPORT __attribute__((visibility("default")))
#endif

/* Error codes. Negative so 0 stays "success". */
#define LLAMA_SHIM_OK 0
#define LLAMA_SHIM_ERR_LOAD (-1)
#define LLAMA_SHIM_ERR_CONTEXT (-2)
#define LLAMA_SHIM_ERR_TOKENIZE (-3)
#define LLAMA_SHIM_ERR_DECODE (-4)
#define LLAMA_SHIM_ERR_GRAMMAR (-5)
#define LLAMA_SHIM_ERR_CANCELLED (-6)
#define LLAMA_SHIM_ERR_INVALID (-7)

/** Opaque handles; the caller never dereferences these. */
typedef void* llama_shim_model;
typedef void* llama_shim_context;

/**
 * Called once per decoded token, on the generation thread.
 *
 * `piece` is UTF-8 and NOT NUL-terminated (a single token can contain a partial
 * multi-byte sequence). Return non-zero to cancel generation.
 */
typedef int32_t (*llama_shim_token_cb)(const char* piece, int32_t len,
                                       void* user_data);

/** Loads the ggml backends. Call once per process before any model. */
LLAMA_SHIM_EXPORT int32_t llama_shim_backend_init(char* err, int32_t err_len);

/** Releases the backends. No model or context may outlive this. */
LLAMA_SHIM_EXPORT void llama_shim_backend_free(void);

/**
 * Loads a GGUF model.
 *
 * `n_gpu_layers` follows llama.cpp semantics: 0 is CPU only, a large positive
 * value offloads as much as the backend supports.
 */
LLAMA_SHIM_EXPORT llama_shim_model llama_shim_model_load(
    const char* path, int32_t n_gpu_layers, int32_t use_mmap, char* err,
    int32_t err_len);

LLAMA_SHIM_EXPORT void llama_shim_model_free(llama_shim_model model);

/**
 * Reads model metadata as a JSON object, for display and for choosing a chat
 * template. Returns the byte count written, or negative on failure.
 */
LLAMA_SHIM_EXPORT int32_t llama_shim_model_meta(llama_shim_model model,
                                                char* buf, int32_t len);

/**
 * Creates a context. `n_ctx` is the KV-cache window: memory scales with it, so
 * this is the main lever on residency.
 */
LLAMA_SHIM_EXPORT llama_shim_context llama_shim_ctx_new(
    llama_shim_model model, int32_t n_ctx, int32_t n_threads, int32_t n_batch,
    char* err, int32_t err_len);

LLAMA_SHIM_EXPORT void llama_shim_ctx_free(llama_shim_context ctx);

/**
 * Clears the KV cache so the next generate starts from an empty history.
 *
 * Needed because a finished generation leaves its tokens in the cache; reusing
 * the context without this makes the next turn think it is mid-conversation.
 */
LLAMA_SHIM_EXPORT void llama_shim_ctx_reset(llama_shim_context ctx);

/**
 * Tokenises `text` into `out`. Returns the token count, or negative on error.
 *
 * Called with `out == NULL` to measure: returns the count needed.
 */
LLAMA_SHIM_EXPORT int32_t llama_shim_tokenize(llama_shim_context ctx,
                                              const char* text, int32_t text_len,
                                              int32_t* out, int32_t out_cap,
                                              int32_t add_special);

/**
 * Runs one generation, streaming each token to `cb`.
 *
 * `grammar` is a GBNF grammar constraining decoding, or NULL for none. This is
 * how a caller guarantees parseable output instead of hoping: the sampler
 * cannot emit a token the grammar rejects.
 *
 * `stop_json` is a JSON array of stop strings, or NULL.
 *
 * Returns the number of tokens generated, or a negative error code. A
 * cancellation requested through `cb` is reported as LLAMA_SHIM_ERR_CANCELLED.
 */
LLAMA_SHIM_EXPORT int32_t llama_shim_generate(
    llama_shim_context ctx, llama_shim_model model, const char* prompt,
    int32_t prompt_len, int32_t max_tokens, float temperature, float top_p,
    int32_t top_k, float repeat_penalty, float repeat_last_n,
    const char* grammar, const char* stop_json, llama_shim_token_cb cb,
    void* user_data, char* err, int32_t err_len);

/**
 * Applies a chat template to `messages_json` (`[{role, content}, ...]`).
 *
 * Uses the template embedded in the GGUF, which is why the model file is the
 * source of truth for prompt format rather than app code.
 *
 * Returns the byte count written to `buf`, or negative.
 */
LLAMA_SHIM_EXPORT int32_t llama_shim_apply_chat_template(
    llama_shim_model model, const char* messages_json, int32_t add_assistant,
    char* buf, int32_t len);

#ifdef __cplusplus
}
#endif

#endif /* LLAMA_SHIM_H */