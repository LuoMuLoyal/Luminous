# Lumos Next Plan

Last updated: 2026-06-08

## Current Goal

Move from a stable five-tab baseline into real daily health loops without presenting mock features as real.

## Short-Term Targets

### Target 1: Record Stability And Date Navigation

Status: completed for the first mobile logic pass. Daily-record single-image create/edit, upload, metadata save, timeline/detail display, date navigation, and timeline time mapping were stabilized on 2026-06-06. Record mobile logic v1 was completed on 2026-06-07: supported quick actions route to create with selected kind/date, date chips reload selected-day data, and filter chips map to supported Lucent daily-record kinds.

Goal: make the daily-record loop dependable before expanding other modules.

Scope:

- Keep daily-record image selection, preview, upload, metadata save, edit prefill, replace, and remove under regression.
- Keep Record date controls updating the selected day and reloading the Lucent-backed timeline.
- Keep Record timeline entries displaying each record's own `occurredAt` time instead of the current clock time.
- Keep provider invalidation for Record and Today after create/edit/delete.
- Keep quick-action routing and filter mapping under regression as type-specific forms expand.
- Add TODOs/tests when attachment failure, edit detail, or form-by-kind gaps are found.

Why first: Record is already a real Lucent-backed loop, and small correctness fixes here improve the main daily workflow more than expanding deferred utility surfaces.

Observable result:

- A signed-in user can switch Record dates, filter supported daily-record kinds, add/edit/delete records with one image, reopen the timeline, and see the correct day/time/image state.

### Target 2: Record Form Quality

Status: first pass completed on 2026-06-08 for water, vital, symptom, and note.

Goal: make record create/edit feel complete without adding unsupported medical complexity.

Scope:

- Keep the detail page showing complete fields: type, occurred time, value, unit, title, note, source, updated time, and image attachment where available.
- Keep edit/delete entry points clear from the timeline/detail path.
- Keep common type form rules under regression: water uses value/unit/note with default `ml`; vital uses title/value/unit/note; symptom uses title/value/note without unit; note uses title/note without value/unit.
- Keep richer analytics, medical document import, and multi-image gallery out of scope.

Why second: date navigation, attachments, and detail must stay stable before type-specific forms are worth polishing.

Observable result:

- A user can create or edit common record types with fields that fit the selected type.

### Target 3: Medicine Schedule Contract And Local Reminders

Status: Medicine closed-loop v1 completed on 2026-06-08 for active current medicines plus same-day manual dose logs. Formal schedule occurrences, reminder times, and inventory/refill tracking remain TODO because Lucent does not expose those contracts yet.

Goal: make Medicine's reminder source explicit before turning notification preferences into local scheduled reminders.

Scope:

- Keep active current-medicine filtering, same-day dose-log update/create behavior, Today pending counts, and completed-dose UI under regression.
- Define the first formal medication schedule source in Lucent: occurrence date/time, timezone behavior, repeat rules, and whether the schedule belongs to current medicines or a separate reminder resource.
- Define medication inventory/refill fields only if the product wants real stock tracking; until then, keep `提醒未设置` / `库存未跟踪` placeholders instead of mock stock.
- Luminous schedules/cancels local notifications only after the schedule source is real and testable.
- Keep FCM/APNs, backend delivery workers, push tokens, and delivery logs out of scope.
- If schedule data needs to sync across devices, design Lucent reminder APIs before local implementation.

Why third: permission and preference UI already exists, but real scheduling needs a clear schedule source.

Observable result:

- A signed-in user sees pending/taken/skipped medicine state from Lucent-backed dose logs without duplicate same-day records, and the next implementation step has a concrete schedule contract instead of frontend-only guesswork.

### Deferred: Environment Snapshot / Contextual Surfaces

Status: Lucent endpoint implemented on 2026-06-06; Luminous frontend wiring is intentionally deferred until core modules are steadier.

Goal: expose environment reference data only where it supports a concrete mobile job, such as Today contextual signals or Mine campus/service resources.

Scope:

- Lucent adds static reference data and `GET /api/v1/environment/snapshot`.
- Lucent exports OpenAPI.
- Luminous regenerates the client and creates a shared environment repository.
- Today and/or Mine consume the repository only when the UI job is explicit.
- Luminous keeps a "reference/static" label when dataSource is `static`.
- No third-party weather API, location tracking, or push alert behavior.

Why deferred: environment data is useful only as context. It should wait until Record / Today / Medicine core flows are steadier and must not reintroduce a generic More tab.

Observable result:

- Today or Mine displays environment data from Lucent with a visible reference/static source label.

## Immediate Work Order

1. Keep Record quick-action routing, filter chips, selected-date reload, common type form mapping, attachment handling, detail cache invalidation, and timeline time display under regression.
2. Keep Medicine dose-log closed-loop behavior under regression while designing the formal schedule occurrence and inventory/refill contracts.
3. Implement local notification scheduling only after the first reminder schedule source is explicit and backed by Lucent or a documented local-only model.
4. Keep auth/account deferred TODOs explicit until product/security decisions are made.

## Active Planning References

- `docs/superpowers/plans/2026-06-06-thirty-day-lumos-deepseek-plan.md`
- `docs/superpowers/plans/next-month-backlog.md`
- `../Lucent/docs/public/ROADMAP.md`
- `../Lucent/docs/public/reminder-contract.md`
- `../Lucent/docs/public/environment-contract.md`

## Do Not Start Yet

- Real push delivery through FCM/APNs.
- OCR/barcode scanning.
- Family profiles.
- Smart device registry.
- Watch companion app.
- Paid or credentialed external services without explicit approval.
- Environment frontend wiring until Record / Today / Medicine core flows are steadier and the target Today/Mine job is explicit.
- Standalone More tab or generic utility hub.
