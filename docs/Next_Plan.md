# Luminous Next Plan

Last updated: 2026-06-22

This file records the next implementation order only. Completed work belongs in `MigrationLog.md`; current facts belong in `Current_State.md`.

## Current Goal

**Medicine safety depth** is complete.

The next active slice is **bounded assistant leaflet RAG planning and backend implementation prep**.

Immediate collaboration note:

- The user plans to do a UI/UX pass first.
- Backend-side next work should therefore be limited to locking the Lucent RAG
  slice boundary and execution plan, not starting a second broad frontend track
  in parallel.

## Completed: Medicine Safety Depth

- Rule matrix: 9 reviewed rules were locked in code and condensed into the follow-up directions below.
- Boundary tests: 30 original domain tests plus 3 context-leak guards and 1 structured red-flag compatibility case; age thresholds (17/18/64/65/66/null), pregnancy/lactation/pediatric/geriatric missing-field cases, allergy near-match guards, duplicate disjoint guards, findings+coverage coexistence invariants, classifier tier tests.
- Special-population classification: 5-level `SpecialPopulationConclusion` (contraindicated → avoid → caution → consultClinician → insufficientInformation) with bilingual keyword classifier, severity derived from conclusion tier.
- Two-layer UI: conclusion label + evidence text, context-enhanced body.
- Red-flag action layering: L1 急救 / L2 咨询 / L3 观察（无假资源链接）.
- Total medicine tests: 53 (39 domain + 6 red-flag + 8 page).

## Remaining Medicine Safety Follow-Up Directions

From the completed rule-matrix review, the following remain as explicit follow-up candidates:

1. **Age threshold debate** (≤18 vs <18, ≥65 vs >65) — 18-year-olds and 65-year-olds are currently excluded from pediatric/geriatric checks.
2. **Separate lactation field** — currently pregnancy and lactation share the same `pregnancyLactation` detail field; no independent lactation data source exists.
3. **Allergy severity null-handling** — `severity == null` with `reaction == 'anaphylaxis'` does not escalate to red flag.
4. **CN medicine interaction gap** — CN-sourced medicines are completely invisible to the interaction checker and report no coverage issue.
5. **Avoid-tier escalation policy** — structured `avoid` conclusions still stay below red-flag level; whether that should escalate for pregnancy/lactation remains an explicit product/risk decision.
6. **Duplicate cross-language matching** — "对乙酰氨基酚" vs "paracetamol" do not match as duplicate due to different normalized strings.
7. **DrugBank synonym over-generalization** — different NSAIDs sharing "ibuprofen" as a synonym could falsely trigger duplicate warnings (data-quality dependent).

These are not urgent blockers — they represent the next depth increment when medicine safety is revisited.

## Immediate Work Order

1. **Do the UI/UX pass separately from backend RAG**
   - Let the upcoming UI/UX work focus on presentation and interaction quality
   - Do not make the UI pass block the RAG boundary decision
   - Do not start a second large frontend product slice under the name of RAG

2. **Start RAG as one extra assistant tool, not as a new app architecture**
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
   - Success signal:
     - RAG improves explanation depth without becoming the first dependency of
       the whole chat feature

3. **Keep assistant evolution bounded to concrete new scenarios**
   - Only extend assistant tools/proposals when a specific missing user task is chosen
   - Do not reopen broad tool refactors without a new capability target
   - Keep memory optional, explicit, and user-controlled when new assistant work resumes

4. **Keep Record follow-up work bounded after the finished fast-entry slice**
   - Record fast entry, quick-choice save, editable date/time fields, and
     concrete `occurredTime` persistence are done.
   - Only reopen Record when a specific follow-up gap is chosen, such as:
     - broader full-stack E2E around the new time-of-day contract
     - more nuanced quick-choice sets per kind
     - additional timeline/detail polish backed by real product need
   - Success signal:
     - Record stays stable instead of becoming an open-ended polish sink

5. **Keep Web as a deliberate decision, not a stealth requirement**
   - `Luminous-site` is still a competition/marketing surface, not a signed-in product shell
   - Do not quietly turn it into product work while saying the next slice is something else
   - If authenticated Web report preview becomes the chosen next slice later, open a dedicated plan for it and treat it as a separate product surface
   - Success signal:
     - Web is either clearly presentation-only, or clearly a planned product slice, never an accidental in-between

6. **Keep the local validation discipline as a gate, not a suggestion**
   - Repo-safe daily entry:
     - `dart run tool/run_daily_checks.dart`
   - Full-stack gate entry:
     - `dart run tool/run_fullstack_checks.dart`
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

1. finish the planned UI/UX pass
2. execute the bounded Lucent assistant leaflet-RAG slice
3. reopen Record only if a specific follow-up gap is chosen
4. re-open the Web question if desired
5. revisit medicine safety depth follow-ups from the 7 candidates above

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

Leaflet RAG is useful, but only after the current Record and assistant product
baseline are stable.

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
