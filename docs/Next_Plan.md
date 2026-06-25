# Luminous Next Plan

Last updated: 2026-06-25

This file records the next implementation order only. Completed work belongs in `migration-log/YYYY-MM-DD.md`; current facts belong in `Current_State.md`.

## Current Goal

The next active slice is **bounded assistant leaflet RAG planning and backend implementation prep** in Lucent.

## Immediate Work Order

1. **Start RAG as one extra assistant tool, not as a new app architecture**
   - Keep this bounded to:
     - medicine leaflet dataset ingestion/index strategy
     - retrieval-only augmentation over approved medicine knowledge
     - server-side tool integration after the base chat loop is already stable
   - Explicit non-scope:
     - replacing the reviewed medicine safety rule engine
     - pretending retrieval equals safe risk judgment
     - making retrieval a mandatory dependency for all assistant replies
   - Current execution source:
     - `../Lucent/plans/2026-06-22-assistant-leaflet-rag-slice.md`

2. **Keep assistant evolution bounded to concrete new scenarios**
   - Only extend assistant tools/proposals when a specific missing user task is chosen
   - Do not reopen broad tool refactors without a new capability target
   - Keep memory optional, explicit, and user-controlled

3. **Keep Web as a deliberate decision**
   - `Luminous-site` is still a competition/marketing surface, not a signed-in product shell
   - If authenticated Web report preview becomes the chosen next slice later, open a dedicated plan

4. **Keep the local validation discipline**
   - Repo-safe daily: `dart run tool/run_daily_checks.dart`
   - Full-stack gate: `dart run tool/run_fullstack_checks.dart` before changes touching auth/session, Today/Report protected loading, daily-records API, generated clients, or E2E helpers

## Deferred But Useful

- focused truncation/polish pass for compact CN/EN labels across the five tabs
- agent-assisted support discovery and map-backed nearby-care lookup
- lightweight mood record shapes and a future mood quick-entry/tool hook
- environment signals for contextual Today/Mine use
- medicine scan/OCR/photo/barcode/prescription action shapes
- local-only sleep reminder preferences beyond simple placeholder labeling
- real authenticated Web report preview beyond the competition site
- system health app bridging through Apple Health / Health Connect

## Medicine Safety Follow-Up Directions

1. **Age threshold debate** (≤18 vs <18, ≥65 vs >65)
2. **Separate lactation field** — currently pregnancy and lactation share the same field
3. **Allergy severity null-handling** — `severity == null` with `reaction == 'anaphylaxis'`
4. **CN medicine interaction gap** — CN-sourced medicines invisible to interaction checker
5. **Avoid-tier escalation policy** — structured `avoid` conclusions stay below red-flag
6. **Duplicate cross-language matching** — "对乙酰氨基酚" vs "paracetamol"
7. **DrugBank synonym over-generalization** — different NSAIDs sharing synonyms

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
