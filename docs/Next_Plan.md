# Luminous Next Plan

Last updated: 2026-06-18

This file records the next implementation order only. Completed work belongs in `MigrationLog.md`; current facts belong in `Current_State.md`.

## Current Goal

The next active slice is now **Assistant Phase 2: better read tools + write
intent + confirmation**.

Phase 1 is already in place:

- standalone `/assistant`
- latest-session restore
- recent-session list/open
- SSE streaming markdown chat
- bounded server-side tool use
- permission-aware chat context toggles

The next job is not “make the agent autonomous”.
The next job is to make it more useful without losing control:

- answer from more explicit read tools
- propose writes as structured intents
- require explicit user confirmation before any data change

The product baseline still remains:

```text
record -> summarize -> bounded medicine safety check -> export
```

The assistant layer sits on top of that baseline, not instead of it.

## Immediate Work Order

1. **Finish the corrected assistant read-tool boundary first**
   - Priority order:
     - add date-aware record reads: today / single date / date range
     - add profile/settings/current-medicines reads
     - add Today/Report historical AI summary reads from persisted summary history
     - add sleep-by-range reads
   - Rules:
     - keep tool names explicit
     - keep user permission enforcement on the server
     - do not present assistant chat history as historical AI summaries
   - Success signal:
     - the assistant can answer concrete factual questions without falling back
       to vague model-only replies

2. **Keep assistant memory explicit and user-controlled**
   - Priority order:
     - keep conversation persistence for restore/list/open UX
     - keep cross-conversation memory behind its own settings toggle
     - avoid silently reusing old chat context when a user starts a new chat
   - Success signal:
     - “new chat” still means cleared conversation context, while optional memory
       remains understandable and reversible
3. **Add `propose_*` write intents before any AI-triggered writes**
   - Priority order:
     - `propose_create_daily_record`
     - `propose_update_daily_record`
     - `propose_delete_daily_record`
     - `propose_update_user_settings`
   - Rules:
     - no direct AI write path
     - every proposal must render as a visible confirmation card
     - confirmed actions should route into existing product/API write flows first
   - Success signal:
     - users can ask the assistant to help write, but every mutation is still
       explicitly user-approved
   - Current status:
     - backend proposal protocol is now live
     - `/assistant` now renders confirmation cards and can confirm/cancel
       proposal actions
     - next follow-up is polish and expansion, not first-time wiring

4. **Then reshape Record around fast entry**
   - Priority order:
     - tap a record type -> open a lightweight fast-entry surface first
     - common values save quickly with the current time
     - “more” opens the full form
     - present `note` as the user-facing custom record entry
   - Mood:
     - reserve a mood entry point, but do not let mood become the main job of
       this slice
   - Success signal:
     - Record becomes faster to use day to day without needing the assistant
       for every small entry

5. **Add RAG later as one extra tool, not as the starting architecture**
   - Keep this bounded to:
     - medicine leaflet dataset ingestion strategy
     - retrieval-only augmentation over approved medicine knowledge
     - server-side tool integration after the base chat loop is already stable
   - Explicit non-scope:
     - replacing the reviewed medicine safety rule engine
     - pretending retrieval equals safe risk judgment
   - Success signal:
     - RAG improves explanation depth without becoming the first dependency of
       the whole chat feature

6. **Make medicine safety depth the next trust slice after assistant usefulness improves**
   - Keep the recommendation unchanged:
     - stronger medicine safety depth is still the best trust-building slice
       after the current assistant contract becomes genuinely useful
   - Success signal:
     - chat expands product usefulness while medicine safety remains the core
       trust anchor

7. **Keep Web as a deliberate decision, not a stealth requirement**
   - `Luminous-site` is still a competition/marketing surface, not a signed-in product shell
   - Do not quietly turn it into product work while saying the next slice is something else
   - If authenticated Web report preview becomes the chosen next slice later, open a dedicated plan for it and treat it as a separate product surface
   - Success signal:
     - Web is either clearly presentation-only, or clearly a planned product slice, never an accidental in-between

8. **Keep the local validation discipline as a gate, not a suggestion**
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

1. assistant read tools
2. assistant write intents + confirmation cards
3. record fast-entry UX
4. only then RAG as an extra tool if still needed
5. medicine safety depth
6. only then re-open the Web question

## Deferred But Useful

Keep these code paths hidden and annotated until the matching product/API job is ready:

- focused truncation/polish pass for compact CN/EN labels across the five tabs
- agent-assisted support discovery and map-backed nearby-care lookup
- lightweight mood record shapes and a future mood quick-entry/tool hook
- environment signals for contextual Today/Mine use
- medicine scan/OCR/photo/barcode/prescription action shapes
- local-only sleep reminder preferences beyond simple placeholder labeling
- real authenticated Web report preview beyond the competition site
- system health app bridging through Apple Health / Health Connect after AI permission boundaries, local data ownership, and product value are clearer

Leaflet RAG is useful, but only after the bounded chat contract, read tools,
and confirmation flow are stable.

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
