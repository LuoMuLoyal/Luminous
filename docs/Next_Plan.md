# Luminous Next Plan

Last updated: 2026-07-01

This file records the next implementation order only. Current facts belong in `Current_State.md`; change history belongs in `migration-log/YYYY-MM-DD.md`.

## Current Goal

**Shipping Luminous v4.0.0**. The A-class placeholder interactions are wired; remaining B/C-class items require backend/API work or product decisions.

## Immediate Next

1. **Run full v4.0.0 validation gate**
   - `dart run tool/run_daily_checks.dart` (repo-safe)
   - `dart run tool/run_fullstack_checks.dart` (Android emulator + Lucent test runtime)

2. **Tag v4.0.0** after gate passes

3. **Keep assistant evolution bounded to concrete scenarios**
   - Only extend tools/proposals when a specific missing user task is chosen.
   - Memory stays optional, explicit, and user-controlled.

4. **Keep Web as a deliberate decision**
   - `Luminous-site` is a competition/marketing surface, not a signed-in product shell.
   - If authenticated Web report preview is needed later, open a dedicated plan.

## Deferred But Useful

- agent-assisted support discovery and map-backed nearby-care lookup
- environment signals for contextual Today/Mine use
- Report score/finding/pattern/trend/AI action card drill-down (needs product decision: detail page vs filter Record tab)
- medicine-side scan/OCR/barcode/prescription action shapes (need product scope + backend contracts)
- real authenticated Web report preview beyond the competition site
- system health app bridging through Apple Health / Health Connect

## Medicine Safety Follow-Up

1. **Allergy severity null-handling** — `severity == null` with `reaction == 'anaphylaxis'`
2. **CN medicine interaction gap** — CN-sourced medicines invisible to interaction checker
3. **Avoid-tier escalation policy** — structured `avoid` conclusions stay below red-flag
4. **Duplicate cross-language matching** — "对乙酰氨基酚" vs "paracetamol"
5. **DrugBank synonym over-generalization** — different NSAIDs sharing synonyms

## Do Not Start Yet

- standalone More tab or generic utility hub
- women-health or period management
- sport recovery
- specialist health packs
- smart devices or family profiles
- skin recognition or report photo import
- medicine-side OCR/barcode/photo/prescription recognition UI or contracts
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
