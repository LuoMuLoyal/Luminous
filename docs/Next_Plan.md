# Luminous Next Plan

Last updated: 2026-06-20

This file records the next implementation order only. Completed work belongs in `MigrationLog.md`; current facts belong in `Current_State.md`.

## Current Goal

The next active slice is **medicine safety depth**.

## Immediate Work Order

1. **Deepen medicine safety where trust still depends on bounded review**
   - Priority order:
     - expand the reviewed safety rules only where source coverage is explicit
     - keep uncertainty visible when data is missing or unreviewed
     - improve actionability of red-flag outputs without faking broad coverage
   - Success signal:
     - Medicine keeps becoming the strongest trust anchor after Record is now
       fast enough for daily use

2. **Keep assistant evolution bounded to concrete new scenarios**
   - Only extend assistant tools/proposals when a specific missing user task is chosen
   - Do not reopen broad tool refactors without a new capability target
   - Keep memory optional, explicit, and user-controlled when new assistant work resumes

3. **Add RAG later as one extra tool, not as the starting architecture**
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

1. medicine safety depth
2. only then reopen Record if a specific follow-up gap is chosen
3. only then RAG as an extra tool if still needed
4. only then re-open the Web question

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
