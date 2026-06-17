# Luminous Next Plan

Last updated: 2026-06-16

This file records the next implementation order only. Completed work belongs in `MigrationLog.md`; current facts belong in `Current_State.md`.

## Current Goal

The mobile MVP is now closed enough to stop treating “MVP completion” itself as the task. The next phase should do two things in order:

1. turn the shipped MVP into a stable, repeatable, production-demoable baseline
2. productize the weakest still-rough real slice before opening any broader post-MVP work

The current real path remains:

```text
record -> summarize -> bounded medicine safety check -> export
```

## Immediate Work Order

1. **Freeze the deployed MVP into a clean demo baseline**
   - Priority order:
     - write and follow one production smoke checklist after each deploy
     - prepare one stable demo account / demo data reset routine
     - turn any remaining half-real UI wording into explicit boundary wording instead of relying on oral explanation
     - keep campus discovery, map lookup, and agent-assisted support search outside the MVP promise
   - Success signal:
     - someone else can deploy and demo the full mobile path without ad-hoc debugging

2. **Productize report/export, because it is already the weakest “real but still rough” slice**
   - Priority order:
     - keep `hospital` / `monthly` / `print` as the current real PDF set, and stop revisiting that decision unless the backend contract changes
     - tighten export lifecycle wording: requesting, processing, completed, failed, expired-download-link
     - align Report and Mine so they expose the same export-status model instead of one side feeling more “real” than the other
     - improve PDF polish only where it changes user trust: pagination, header/footer consistency, and doctor-facing readability
     - keep privacy, sharing, and hospital-summary boundaries explicit instead of implying a full collaboration workflow
   - Success signal:
     - export feels like a finished user feature, not a technical proof that PDF generation works

3. **Pick one next real slice after export, not three**
   - Recommended choice:
     - stronger medicine safety depth
   - Why this is the best next slice:
     - it matches the product’s trust anchor
     - it improves real user value more than cosmetic Web expansion
     - it is easier to defend in competition/demo than “more AI”
   - Concrete scope if chosen:
     - reviewed ingredient normalization groundwork for CN + DrugBank overlap
     - broader duplicate-ingredient coverage
     - carefully reviewed interaction-rule expansion
     - better unknown / unsupported-state wording when confidence is limited
   - Explicit non-scope:
     - speculative AI risk judgment
     - broad unreviewed interaction expansion
     - map/agent support discovery
   - Success signal:
     - medicine safety meaningfully covers more common real cases without weakening the current safety boundary

4. **Keep Web as a deliberate decision, not a stealth requirement**
   - `Luminous-site` is still a competition/marketing surface, not a signed-in product shell
   - Do not quietly turn it into product work while saying the next slice is something else
   - If authenticated Web report preview becomes the chosen next slice later, open a dedicated plan for it and treat it as a separate product surface
   - Success signal:
     - Web is either clearly presentation-only, or clearly a planned product slice, never an accidental in-between

5. **Keep AI in maintenance mode**
   - Today and Report AI streaming already exists and is good enough for the current MVP path
   - Only revisit AI when one of these is true:
     - streaming stability regresses
     - cancellation / retry UX is visibly bad
     - safety wording misses a real edge case
   - Do not expand into “AI everywhere” before report/export and medicine-trust work are cleaner

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

1. production smoke checklist + demo/reset discipline
2. export/report productization
3. medicine safety depth
4. only then re-open the Web question

## Deferred But Useful

Keep these code paths hidden and annotated until the matching product/API job is ready:

- focused truncation/polish pass for compact CN/EN labels across the five tabs
- agent-assisted support discovery and map-backed nearby-care lookup
- lightweight mood record shapes
- environment signals for contextual Today/Mine use
- medicine scan/OCR/photo/barcode/prescription action shapes
- local-only sleep reminder preferences beyond simple placeholder labeling
- real authenticated Web report preview beyond the competition site

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
