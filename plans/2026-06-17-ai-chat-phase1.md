# AI Chat Phase 1

Last updated: 2026-06-17

## Goal

Build a lightweight mobile AI chat surface that talks to Lucent first, not directly to a third-party SDK, while preserving:

- server-side tool control
- explicit user context permissions
- streaming markdown output
- clear product/safety boundaries

## Frontend Dependency Decision

Current decision:

- **Do not adopt `flutter_ai_toolkit` as the foundation**
- **Start with a self-owned chat page plus a dedicated streaming markdown renderer**
- **Re-evaluate `flutter_ai_chat_ui` only after the backend streaming contract is stable**

Reasoning:

- `flutter_ai_toolkit` is official, but its current package graph pulls in `firebase_ai` plus camera/file/voice-oriented extras. That is not a clean fit for the current `Lucent -> OpenAPI -> controlled SSE` architecture.
- `flutter_ai_chat_ui` is lighter and backend-agnostic, but it should not become the data/interaction foundation before we confirm it can live comfortably inside our own permissions, retry, tool-state, and product shell.
- `streamdown` is narrow and useful right now because our first hard requirement is stable markdown streaming, not a huge prebuilt chat worldview.

## Scope

Do:

- add a floating chat entry later
- ship one simple chat page
- render assistant output with streaming markdown
- keep user messages / assistant messages / loading / retry / error states explicit
- surface settings that decide what health context the backend may use

Do not:

- add voice capture in the first pass just because a package supports it
- add screenshot input in the first pass
- add RAG in the first pass
- let the client decide permissions without backend enforcement

## Delivery Order

1. backend module + graph skeleton + permission plan
2. backend streaming chat contract
3. simple mobile chat page with markdown streaming
4. settings page expansion for chat-context permissions
5. later RAG tool and richer UI polish

## Likely Files

- `lib/app/router.dart`
- `lib/features/ai_chat/**`
- `lib/features/settings/**`
- `lib/l10n/*.arb`
- `test/features/ai_chat/**`
- `docs/Current_State.md`
- `docs/Next_Plan.md`
- `docs/TODO.md`

## Validation

- `flutter analyze`
- focused widget/provider tests for chat state
- one emulator manual pass for:
  - signed-in chat send
  - streaming assistant markdown
  - denied-context behavior
  - retry/error behavior

## Done Signal For The Foundation Step

- the frontend plan no longer depends on a package making architecture decisions for us
- markdown streaming has a clear owner
- Lucent remains the single enforcement point for tool and context access
