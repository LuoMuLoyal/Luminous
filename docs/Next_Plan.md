# Luminous Next Plan

Last updated: 2026-06-28

This file records the next implementation order only. Completed work belongs in `migration-log/YYYY-MM-DD.md`; current facts belong in `Current_State.md`.

## Current Goal

The next active slice is **shipping Luminous v4.0.0**. The A-class placeholder interactions (reachable with existing routes/providers) are wired; the remaining B/C-class items are recorded below and require backend/API work or product decisions before implementation.

## Immediate Work Order

1. **Finish v4.0.0 release prep**
   - Resolve or defer the B/C-class placeholder items listed below.
   - Run the full validation gate before tagging 4.0.0.
   - Consider unifying `AuthBackButton` with `AppBackButton` as the final back-button cleanup.

2. **Keep assistant evolution bounded to concrete new scenarios**
   - Only extend assistant tools/proposals when a specific missing user task is chosen.
   - Do not reopen broad tool refactors without a new capability target.
   - Keep memory optional, explicit, and user-controlled.

3. **Keep Web as a deliberate decision**
   - `Luminous-site` is still a competition/marketing surface, not a signed-in product shell.
   - If authenticated Web report preview becomes the chosen next slice later, open a dedicated plan.

4. **Keep the local validation discipline**
   - Repo-safe daily: `dart run tool/run_daily_checks.dart`.
   - Full-stack gate: `dart run tool/run_fullstack_checks.dart` before changes touching auth/session, Today/Report protected loading, daily-records API, generated clients, or E2E helpers.

## Recently Completed

- **Backend notification module + Luminous notification inbox** (`Lucent`/`Luminous` commits around 2026-06-26): `UserNotification` Prisma model and enum, NestJS CRUD API with unread count and batch read, inline notification generation after AI summary, report export, and password change events; Flutter notification list/detail pages, unread red-dot badge driven by real backend unread count, grouped list with paginated load-more, swipe-to-delete and batch mark-all-read, action routing from detail page, and full ARB localization.
- **Backend assistant leaflet RAG** (`Lucent` commit `6f165e3`): `get_medicine_leaflet_context` tool, leaflet index rebuild script, dynamic `ragEnabled` capabilities truth, and updated assistant contract.
- **Luminous Record/Report responsive pass** (`Luminous` commit `0a57312`): removed Record "Today overview", widened Report finding cards, added `AppResponsiveSizing`, and replaced the highest-impact fixed layout dimensions.
- **Luminous v4.0.0 placeholder wiring** (`Luminous` commit `64c6a27`): replaced Today/Record/Medicine/Mine/Search/Report metric placeholder toasts with real navigation, provider invalidation, or filtering behavior.
- **Luminous settings page refactor** (2026-06-28): reorganized Settings into Account & Security / Notifications / Privacy / General / About groups, moved dialogs/inline actions to sub-pages, introduced reusable settings row widgets, and implemented master-toggle sleep reminder page.
- **Luminous UX audit HIGH Phase 1** (2026-06-28): unified back button with `AppBackButton`, added back button to `SearchPage`, wired `TodayEmptyView` and recommendation category navigation, replaced reminder quick-action fallback with create-page navigation plus no-medicine selector prompt. Tests: 489/489 passing.
- **Luminous UX audit HIGH Phase 2** (2026-06-28): moved `/settings/*`, `/assistant`, `/notifications/*`, and all `/record/*`, `/medicine/*`, `/mine/*` create/detail/edit sub-pages out of the `StatefulShellRoute` to top-level full-screen routes; reduced `ShellBranch` to the five visible tab branches; updated desktop sidebar settings/help actions to `context.push`. Tests: 495/495 passing.

## Deferred But Useful

- agent-assisted support discovery and map-backed nearby-care lookup
- environment signals for contextual Today/Mine use
- Report score/finding/pattern/trend/AI action card drill-down (needs product decision: detail page vs filter Record tab)
- voice input, photo/scan/OCR/barcode/prescription action shapes (need native plugins + backend contracts)
- real authenticated Web report preview beyond the competition site
- system health app bridging through Apple Health / Health Connect

## Medicine Safety Follow-Up Directions

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
