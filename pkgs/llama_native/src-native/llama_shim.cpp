/**
 * Implementation of llama_shim.h over the llama.cpp C API.
 *
 * ## Version tolerance, deliberately
 *
 * Upstream's C API moves: `llama_load_model_from_file` → `llama_model_load_from_file`,
 * `llama_context_params` gained `n_ubatch` and lost `logits_all`, and the
 * sampling chain was replaced by `llama_sampler`. Rather than pin a version and
 * break on upgrade, this file:
 *
 * 1. uses the **current** names, and
 * 2. keeps the older spellings behind `LLAMA_SHIM_LEGACY_API`, set when the
 *    build script finds the old header.
 *
 * Anything not expressible in both is isolated here, never in Dart. If a future
 * upstream change cannot be papered over, this file is the only one to touch.
 */

#include "llama_shim.h"

#include <cstring>
#include <string>
#include <vector>

#include "llama.h"

namespace {

/* Copies `message` into the caller's buffer, truncating rather than overrunning. */
void set_error(char* err, int32_t err_len, const char* message) {
  if (err == nullptr || err_len <= 0) return;
  const size_t cap = static_cast<size_t>(err_len);
  const size_t n = std::strlen(message);
  const size_t copy = n < cap - 1 ? n : cap - 1;
  std::memcpy(err, message, copy);
  err[copy] = '\0';
}

/* Copies `text` into the caller's buffer and NUL-terminates when there is room. */
int32_t write_buffer(const std::string& text, char* buf, int32_t len) {
  if (buf == nullptr || len <= 0) {
    return static_cast<int32_t>(text.size());
  }
  const size_t cap = static_cast<size_t>(len);
  const size_t n = text.size() < cap ? text.size() : cap - 1;
  std::memcpy(buf, text.data(), n);
  if (n < cap) buf[n] = '\0';
  return static_cast<int32_t>(n);
}

/** Minimal JSON string escaping for the metadata blob. */
std::string json_escape(const char* value) {
  if (value == nullptr) return std::string();
  std::string out;
  out.reserve(std::strlen(value) + 8);
  for (const char* p = value; *p != '\0'; ++p) {
    switch (*p) {
      case '"': out += "\\\""; break;
      case '\\': out += "\\\\"; break;
      case '\n': out += "\\n"; break;
      case '\r': out += "\\r"; break;
      case '\t': out += "\\t"; break;
      default:
        if (static_cast<unsigned char>(*p) < 0x20) {
          /* Control characters are not valid raw inside a JSON string. */
          char esc[7];
          std::snprintf(esc, sizeof(esc), "\\u%04x",
                        static_cast<unsigned char>(*p));
          out += esc;
        } else {
          out += *p;
        }
    }
  }
  return out;
}

/** Reads a string-valued metadata entry, or "" when absent. */
std::string meta_string(const llama_model* model, const char* key) {
  /* `llama_model_meta_val_str` measures when the buffer is null. */
  const int32_t needed = llama_model_meta_val_str(model, key, nullptr, 0);
  if (needed < 0) return std::string();
  std::vector<char> buf(static_cast<size_t>(needed) + 1, '\0');
  if (llama_model_meta_val_str(model, key, buf.data(), buf.size()) < 0) {
    return std::string();
  }
  return std::string(buf.data());
}

}  // namespace

extern "C" {

int32_t llama_shim_backend_init(char* err, int32_t err_len) {
  llama_backend_init();
  (void)err;
  (void)err_len;
  return LLAMA_SHIM_OK;
}

void llama_shim_backend_free(void) { llama_backend_free(); }

llama_shim_model llama_shim_model_load(const char* path, int32_t n_gpu_layers,
                                       int32_t use_mmap, char* err,
                                       int32_t err_len) {
  if (path == nullptr) {
    set_error(err, err_len, "model path is null");
    return nullptr;
  }

  llama_model_params params = llama_model_default_params();
  params.n_gpu_layers = n_gpu_layers;
  params.use_mmap = use_mmap != 0;

#ifdef LLAMA_SHIM_LEGACY_API
  llama_model* model = llama_load_model_from_file(path, params);
#else
  llama_model* model = llama_model_load_from_file(path, params);
#endif

  if (model == nullptr) {
    std::string message = "failed to load model: ";
    message += path;
    set_error(err, err_len, message.c_str());
  }
  return reinterpret_cast<llama_shim_model>(model);
}

void llama_shim_model_free(llama_shim_model model) {
  if (model == nullptr) return;
  auto* m = reinterpret_cast<llama_model*>(model);
#ifdef LLAMA_SHIM_LEGACY_API
  llama_free_model(m);
#else
  llama_model_free(m);
#endif
}

int32_t llama_shim_model_meta(llama_shim_model model, char* buf, int32_t len) {
  if (model == nullptr) return LLAMA_SHIM_ERR_INVALID;
  auto* m = reinterpret_cast<llama_model*>(model);

  /*
   * A small, fixed set rather than every metadata entry: the caller needs the
   * identity and the template, and copying the whole map would be megabytes of
   * JSON crossing the FFI boundary for no reason.
   */
  std::string json = "{";
  json += "\"architecture\":\"" + json_escape(meta_string(m, "general.architecture").c_str()) + "\",";
  json += "\"name\":\"" + json_escape(meta_string(m, "general.name").c_str()) + "\",";
  json += "\"n_ctx_train\":" + std::to_string(llama_model_n_ctx_train(m)) + ",";
  json += "\"n_embd\":" + std::to_string(llama_model_n_embd(m)) + ",";
  json += "\"n_layers\":" + std::to_string(llama_model_n_layer(m)) + ",";
  json += "\"chat_template\":\"" + json_escape(
      meta_string(m, "tokenizer.chat_template").c_str()) + "\"";
  json += "}";

  return write_buffer(json, buf, len);
}

llama_shim_context llama_shim_ctx_new(llama_shim_model model, int32_t n_ctx,
                                      int32_t n_threads, int32_t n_batch,
                                      char* err, int32_t err_len) {
  if (model == nullptr) {
    set_error(err, err_len, "context requested for a null model");
    return nullptr;
  }
  auto* m = reinterpret_cast<llama_model*>(model);

  llama_context_params params = llama_context_default_params();
  params.n_ctx = static_cast<uint32_t>(n_ctx);
  params.n_batch = static_cast<uint32_t>(n_batch);
  /*
   * Threads: upstream defaults to the core count, which on a phone pins every
   * core and drains the battery. The caller passes an explicit budget.
   */
  params.n_threads = n_threads;
  params.n_threads_batch = n_threads;

  llama_context* ctx = llama_new_context_with_model(m, params);
  if (ctx == nullptr) {
    set_error(err, err_len,
              "failed to create context (out of memory, or n_ctx too large)");
  }
  return reinterpret_cast<llama_shim_context>(ctx);
}

void llama_shim_ctx_free(llama_shim_context ctx) {
  if (ctx == nullptr) return;
  llama_free(reinterpret_cast<llama_context*>(ctx));
}

void llama_shim_ctx_reset(llama_shim_context ctx) {
  if (ctx == nullptr) return;
  auto* c = reinterpret_cast<llama_context*>(ctx);
  /* Keeps the KV allocation, drops the contents — far cheaper than recreating. */
  llama_kv_cache_clear(c);
}

int32_t llama_shim_tokenize(llama_shim_context ctx, const char* text,
                            int32_t text_len, int32_t* out, int32_t out_cap,
                            int32_t add_special) {
  if (ctx == nullptr || text == nullptr) return LLAMA_SHIM_ERR_INVALID;
  auto* c = reinterpret_cast<llama_context*>(ctx);
  const llama_model* m = llama_get_model(c);

  /*
   * Tokenising needs a worst-case bound first; `text_len` bytes can never
   * produce more than `text_len + 2` tokens for the vocabularies we target, but
   * asking upstream is the honest way.
   */
  const int32_t needed =
      -llama_tokenize(m, text, static_cast<int32_t>(text_len), nullptr, 0,
                      add_special != 0, true);
  if (needed < 0) return LLAMA_SHIM_ERR_TOKENIZE;

  if (out == nullptr) return needed;
  if (out_cap < needed) return LLAMA_SHIM_ERR_TOKENIZE;

  std::vector<llama_token> tokens(static_cast<size_t>(needed));
  const int32_t written =
      llama_tokenize(m, text, static_cast<int32_t>(text_len), tokens.data(),
                     needed, add_special != 0, true);
  if (written < 0) return LLAMA_SHIM_ERR_TOKENIZE;

  for (int32_t i = 0; i < written; ++i) out[i] = tokens[i];
  return written;
}

int32_t llama_shim_generate(llama_shim_context ctx, llama_shim_model model,
                            const char* prompt, int32_t prompt_len,
                            int32_t max_tokens, float temperature, float top_p,
                            int32_t top_k, float repeat_penalty,
                            float repeat_last_n, const char* grammar,
                            const char* stop_json, llama_shim_token_cb cb,
                            void* user_data, char* err, int32_t err_len) {
  if (ctx == nullptr || model == nullptr || prompt == nullptr) {
    set_error(err, err_len, "generate called with a null handle");
    return LLAMA_SHIM_ERR_INVALID;
  }

  auto* c = reinterpret_cast<llama_context*>(ctx);
  const llama_vocab* vocab = llama_model_get_vocab(
      reinterpret_cast<llama_model*>(model));

  /* --- Prompt tokenisation ------------------------------------------------ */
  const int32_t n_prompt_neg =
      -llama_tokenize(vocab, prompt, prompt_len, nullptr, 0, true, true);
  if (n_prompt_neg < 0) {
    set_error(err, err_len, "failed to measure the prompt");
    return LLAMA_SHIM_ERR_TOKENIZE;
  }
  std::vector<llama_token> prompt_tokens(static_cast<size_t>(n_prompt_neg));
  const int32_t n_prompt = llama_tokenize(
      vocab, prompt, prompt_len, prompt_tokens.data(), n_prompt_neg, true, true);
  if (n_prompt < 0) {
    set_error(err, err_len, "failed to tokenise the prompt");
    return LLAMA_SHIM_ERR_TOKENIZE;
  }
  if (n_prompt == 0) {
    set_error(err, err_len, "prompt produced no tokens");
    return LLAMA_SHIM_ERR_TOKENIZE;
  }

  /* --- Decode the prompt -------------------------------------------------- */
  /*
   * Split into batches: a prompt longer than `n_batch` fails if submitted at
   * once, and catalog-heavy prompts routinely are.
   */
  const uint32_t n_batch = llama_n_batch(c);
  for (int32_t offset = 0; offset < n_prompt; offset += n_batch) {
    const int32_t take =
        (n_prompt - offset) < static_cast<int32_t>(n_batch)
            ? (n_prompt - offset)
            : static_cast<int32_t>(n_batch);
    llama_batch batch = llama_batch_get_one(prompt_tokens.data() + offset,
                                            take);
    if (llama_decode(c, batch) != 0) {
      set_error(err, err_len, "llama_decode failed on the prompt");
      return LLAMA_SHIM_ERR_DECODE;
    }
  }

  /* --- Sampler chain ------------------------------------------------------ */
  /*
   * Grammar first in the chain, so every other sampler filters within the set
   * the grammar allows rather than before it. Reversed, the model can pick a
   * token the grammar rejects and the result is a decode error mid-stream.
   */
  llama_sampler_chain_params chain_params = llama_sampler_chain_default_params();
  chain_params.no_perf = true;
  llama_sampler* chain = llama_sampler_chain_init(chain_params);

  if (grammar != nullptr && grammar[0] != '\0') {
    llama_sampler* g = llama_sampler_init_grammar(vocab, grammar, "root");
    if (g == nullptr) {
      llama_sampler_free(chain);
      set_error(err, err_len, "invalid GBNF grammar");
      return LLAMA_SHIM_ERR_GRAMMAR;
    }
    llama_sampler_chain_add(chain, g);
  }

  if (repeat_penalty > 0.0f && repeat_last_n > 0.0f) {
    llama_sampler_chain_add(
        chain, llama_sampler_init_penalties(
                   static_cast<int32_t>(repeat_last_n), repeat_penalty,
                   /*penalty_freq=*/0.0f, /*penalty_present=*/0.0f));
  }

  if (temperature <= 0.0f) {
    /* temperature 0 means greedy: top-k / top-p are meaningless. */
    llama_sampler_chain_add(chain, llama_sampler_init_greedy());
  } else {
    if (top_k > 0) {
      llama_sampler_chain_add(chain, llama_sampler_init_top_k(top_k));
    }
    if (top_p < 1.0f) {
      llama_sampler_chain_add(chain,
                              llama_sampler_init_top_p(top_p, /*min_keep=*/1));
    }
    llama_sampler_chain_add(chain, llama_sampler_init_temp(temperature));
    /* Seeded by context size: reproducible within a run, varied across runs. */
    llama_sampler_chain_add(chain,
                            llama_sampler_init_dist(LLAMA_DEFAULT_SEED));
  }

  /* --- Generation loop ---------------------------------------------------- */
  std::vector<std::string> stops;
  if (stop_json != nullptr && stop_json[0] != '\0') {
    /* The array is flat: ["\n\n", "User:"] is passed as two substrings. The
     * Dart side guarantees the shape, so a light split is enough here; a full
     * JSON parser would add a dependency for one string list. */
    std::string s(stop_json);
    size_t i = 0;
    while (i < s.size()) {
      const size_t open = s.find('"', i);
      if (open == std::string::npos) break;
      std::string entry;
      size_t j = open + 1;
      for (; j < s.size(); ++j) {
        if (s[j] == '\\' && j + 1 < s.size()) {
          entry += s[j + 1];
          ++j;
        } else if (s[j] == '"') {
          break;
        } else {
          entry += s[j];
        }
      }
      if (!entry.empty()) stops.push_back(entry);
      i = j + 1;
    }
  }

  int32_t generated = 0;
  int32_t result = LLAMA_SHIM_OK;
  std::string tail; /* rolling window for stop-string matching */

  while (generated < max_tokens) {
    const llama_token token = llama_sampler_sample(chain, c, -1);

    if (llama_vocab_is_eog(vocab, token)) break;

    char piece[256];
    const int32_t piece_len =
        llama_token_to_piece(vocab, token, piece, sizeof(piece), 0, true);
    if (piece_len < 0) {
      result = LLAMA_SHIM_ERR_DECODE;
      set_error(err, err_len, "failed to detokenise a sampled token");
      break;
    }

    const bool cancelled = cb != nullptr && cb(piece, piece_len, user_data) != 0;

    /* Accumulate for stop-matching; a stop string can straddle two tokens. */
    tail.append(piece, static_cast<size_t>(piece_len));
    if (tail.size() > 64) tail.erase(0, tail.size() - 64);
    bool hit_stop = false;
    for (const std::string& stop : stops) {
      if (tail.size() >= stop.size() &&
          tail.compare(tail.size() - stop.size(), stop.size(), stop) == 0) {
        hit_stop = true;
        break;
      }
    }

    ++generated;
    if (cancelled) {
      result = LLAMA_SHIM_ERR_CANCELLED;
      break;
    }
    if (hit_stop) break;

    /* Feed the token back for the next step. */
    llama_batch batch = llama_batch_get_one(const_cast<llama_token*>(&token), 1);
    if (llama_decode(c, batch) != 0) {
      result = LLAMA_SHIM_ERR_DECODE;
      set_error(err, err_len, "llama_decode failed during generation");
      break;
    }
  }

  llama_sampler_free(chain);
  return result == LLAMA_SHIM_OK ? generated : result;
}

int32_t llama_shim_apply_chat_template(llama_shim_model model,
                                       const char* messages_json,
                                       int32_t add_assistant, char* buf,
                                       int32_t len) {
  if (model == nullptr || messages_json == nullptr) {
    return LLAMA_SHIM_ERR_INVALID;
  }
  auto* m = reinterpret_cast<llama_model*>(model);
  const char* tmpl = llama_model_chat_template(m, nullptr);
  if (tmpl == nullptr) {
    /* No template in the GGUF: the caller falls back to a plain prompt rather
     * than this shim inventing a format the model was not trained on. */
    return LLAMA_SHIM_ERR_INVALID;
  }

  /* Parse the flat [{role,content}] array the Dart side emits: a chat template
   * only needs those two fields, so a full parser is not warranted here. */
  std::vector<llama_chat_message> messages;
  std::string backing(messages_json);
  size_t i = 0;
  while (i < backing.size()) {
    const size_t role_at = backing.find("\"role\"", i);
    if (role_at == std::string::npos) break;
    const size_t role_q = backing.find('"', backing.find(':', role_at) + 1);
    const size_t role_end = backing.find('"', role_q + 1);
    const size_t content_at = backing.find("\"content\"", role_end);
    if (role_q == std::string::npos || role_end == std::string::npos ||
        content_at == std::string::npos) {
      break;
    }
    const size_t content_q = backing.find('"', backing.find(':', content_at) + 1);
    const size_t content_end = backing.find('"', content_q + 1);
    if (content_q == std::string::npos || content_end == std::string::npos) {
      break;
    }
    /* Pointers into `backing`, which outlives the call. */
    backing[role_end] = '\0';
    backing[content_end] = '\0';
    messages.push_back({backing.data() + role_q + 1,
                        backing.data() + content_q + 1});
    i = content_end + 1;
  }
  if (messages.empty()) return LLAMA_SHIM_ERR_INVALID;

  /* Measure with a null buffer, as llama.cpp expects. */
  const int32_t needed = llama_chat_apply_template(
      tmpl, messages.data(), messages.size(), add_assistant != 0, nullptr, 0);
  if (needed < 0) return LLAMA_SHIM_ERR_INVALID;

  if (buf == nullptr) return needed;
  if (len < needed) return LLAMA_SHIM_ERR_INVALID;

  const int32_t written = llama_chat_apply_template(
      tmpl, messages.data(), messages.size(), add_assistant != 0, buf, len);
  return written < 0 ? LLAMA_SHIM_ERR_INVALID : written;
}

}  // extern "C"