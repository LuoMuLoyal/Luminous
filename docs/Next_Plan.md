# Luminous Next Plan

Last updated: 2026-06-17

This file records the next implementation order only. Completed work belongs in `MigrationLog.md`; current facts belong in `Current_State.md`.

## Current Goal

The next active slice is now **AI Chat Phase 1**.

This is not a broad “AI everywhere” expansion and it is not a RAG-first job.
The target is a lightweight, controllable chat surface that can answer through
explicit server-side tools and only user-authorized health context.

The current product baseline still remains:

```text
record -> summarize -> bounded medicine safety check -> export
```

The next slice sits on top of that baseline, not instead of it.

## Immediate Work Order

1. **Build the backend-first AI chat foundation**
   - Priority order:
     - add a dedicated Lucent `ai-chat` module
     - keep the orchestrator as a restricted LangGraph tool graph
     - define the first tool inventory explicitly in code
     - expand user settings so chat-context permissions are real before exposing a public chat flow
   - Explicit non-scope:
     - pgvector
     - leaflet RAG
     - broad memory
     - uncontrolled agent behavior
   - Success signal:
     - Lucent has a real AI chat module and a bounded orchestration foundation instead of vague future notes

2. **Continue the simple mobile chat surface after Phase 1**
   - Priority order:
     - refine the current lightweight entry point and chat page
     - keep streaming assistant output with markdown
     - keep retry/error/loading states visible and testable
     - expand permission messaging and settings polish around health context
   - Current package direction:
     - do not make `flutter_ai_toolkit` the foundation
     - prefer a self-owned page plus a dedicated markdown streaming renderer
     - only re-evaluate `flutter_ai_chat_ui` after the backend contract is stable
   - Success signal:
     - the mobile chat can stream, render, fail clearly, and remain product-rule-controlled without depending on a framework UI shell

3. **Add RAG later as one extra tool, not as the starting architecture**
   - Keep this bounded to:
     - medicine leaflet dataset ingestion strategy
     - retrieval-only augmentation over approved medicine knowledge
     - server-side tool integration after the base chat loop is already stable
   - Explicit non-scope:
     - replacing the reviewed medicine safety rule engine
     - pretending retrieval equals safe risk judgment
   - Success signal:
     - RAG improves explanation depth without becoming the first dependency of the whole chat feature

4. **Make medicine safety depth the next trust slice after AI chat foundation**
   - Keep the recommendation unchanged:
     - stronger medicine safety depth is still the best trust-building slice after the chat foundation is in place
   - Success signal:
     - chat expands product usefulness while medicine safety remains the core trust anchor

5. **Keep Web as a deliberate decision, not a stealth requirement**
   - `Luminous-site` is still a competition/marketing surface, not a signed-in product shell
   - Do not quietly turn it into product work while saying the next slice is something else
   - If authenticated Web report preview becomes the chosen next slice later, open a dedicated plan for it and treat it as a separate product surface
   - Success signal:
     - Web is either clearly presentation-only, or clearly a planned product slice, never an accidental in-between

6. **Keep the local validation discipline as a gate, not a suggestion**
   - Repo-safe daily entry:
     - `powershell -ExecutionPolicy Bypass -File tool/run_daily_checks.ps1`
   - Full-stack gate entry:
     - `powershell -ExecutionPolicy Bypass -File tool/run_fullstack_checks.ps1`
   - Use the full-stack gate before merging changes that touch:
     - auth/session restore
     - Today/Report protected loading
     - `/api/v1/user/daily-records*`
     - generated auth/record client surface
     - E2E helper scripts
   - Success signal:
     - “looks fine locally” stops being the reason something breaks after deploy

## Recommended Sequence

If the team wants the shortest path with the highest payoff, use this order:

1. backend AI chat foundation
2. mobile chat surface with streaming markdown
3. only then RAG as an extra tool if still needed
4. medicine safety depth
5. only then re-open the Web question

## Deferred But Useful

Keep these code paths hidden and annotated until the matching product/API job is ready:

- focused truncation/polish pass for compact CN/EN labels across the five tabs
- agent-assisted support discovery and map-backed nearby-care lookup
- lightweight mood record shapes
- environment signals for contextual Today/Mine use
- medicine scan/OCR/photo/barcode/prescription action shapes
- local-only sleep reminder preferences beyond simple placeholder labeling
- real authenticated Web report preview beyond the competition site

Leaflet RAG is useful, but only after the bounded chat contract and permissions are stable.

Pregnancy/lactation/special-group medication safety remains active only inside Medicine safety boundaries.

## Do Not Start Yet

- standalone More tab or generic utility hub
- women-health or period management
- sport recovery
- specialist health packs
- smart devices or family profiles
- skin recognition or report photo import
- OCR/barcode/photo/prescription recognition UI or contracts
- real push delivery through FCM/APNs
- real SMS delivery
- backend reminder delivery workers
- paid or credentialed external services without explicit approval
- environment frontend wiring until the target Today/Mine job is explicit

## Contract References

- `Lucent/docs/public/reminder-contract.md`: reminder boundary
- `Lucent/docs/public/environment-contract.md`: environment snapshot boundary
- `Lucent/docs/public/data-sources.md`: medicine data-source/import strategy
- `Lucent/docs/public/mine-settings-contract.md`: export/status/support-resource boundary
