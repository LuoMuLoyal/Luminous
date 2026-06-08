# Lumos Next Plan

Last updated: 2026-06-08

## Current Goal

Move from the Product_Vision-converged five-tab mobile UI into real daily health loops without presenting mock or deferred features as real.

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

Status: first pass completed on 2026-06-08 for water, meal, vital, symptom, and note.

Goal: make record create/edit feel complete without adding unsupported medical complexity.

Scope:

- Keep the detail page showing complete fields: type, occurred time, value, unit, title, note, source, updated time, and image attachment where available.
- Keep edit/delete entry points clear from the timeline/detail path.
- Keep common type form rules under regression: water uses value/unit/note with default `ml`; meal uses title/value/note without unit; vital uses title/value/unit/note; symptom uses title/value/note without unit; note uses title/note without value/unit.
- Keep mood and activity as backend enum compatibility only; do not surface them as MVP create choices until an explicit product/API decision exists.
- Keep richer analytics, medical document import, and multi-image gallery out of scope.

Why second: date navigation, attachments, and detail must stay stable before type-specific forms are worth polishing.

Observable result:

- A user can create or edit common record types with fields that fit the selected type.

### Target 3: Medicine Schedule Contract And Local Reminders

Status: Medicine closed-loop v1 completed on 2026-06-08 for active current medicines plus same-day manual dose logs. Lucent now exposes schedule-only medicine reminders, and Luminous reads active reminders for Today and Medicine next-dose displays. Inventory/refill tracking is removed from scope for now.

Goal: make Medicine's reminder source explicit before turning notification preferences into local scheduled reminders.

Scope:

- Keep active current-medicine filtering, same-day dose-log update/create behavior, Today pending counts, and completed-dose UI under regression.
- Keep Lucent medicine reminder CRUD schedule-only: current medicine link, local hour/minute, weekday repeat, active state, note, and soft delete.
- Add Luminous reminder create/edit/delete UI when the product flow is ready.
- Luminous schedules/cancels local notifications only after the reminder schedule source is wired into a tested local notification coordinator.
- Keep FCM/APNs, backend delivery workers, push tokens, and delivery logs out of scope.
- If schedule data needs to sync across devices, design Lucent reminder APIs before local implementation.

Why third: permission and preference UI already exists, but real scheduling needs a clear schedule source.

Observable result:

- A signed-in user sees pending/taken/skipped medicine state from Lucent-backed dose logs without duplicate same-day records, and the next implementation step has a concrete schedule contract instead of frontend-only guesswork.

### Product_Vision UI Boundary

Status: completed on 2026-06-08 for mobile UI and l10n/test cleanup.

Goal: keep logic-layer work aligned with the narrowed competition product vision.

Active MVP tab boundaries:

- Today: medication tasks, hydration tasks, custom Today todos, AI summary/advice placeholders, immediate risk/campus suggestions.
- Record: symptoms, hydration, diet/meal, natural-language record placeholder, supported daily-record timeline/detail/create/edit.
- Medicine: drugbox, reminders, dose check-in, safety explanations, pregnancy/lactation/special-group medication safety conditions.
- Report: daily/weekly-style summaries, medication/sleep/water/diet/symptom trend placeholders, campus hospital/pharmacist export controls.
- Mine/Settings: account, profile, allergies, current medicines, privacy, notifications, campus hospital/pharmacy/emergency/support resources, Advanced settings.

Removed from active scope:

- Old More tab and `features/more`.
- Women-health and period management.
- Sport recovery, specialist health packs, family profiles, smart devices, skin recognition, report photo import, desktop-first workflows.

Deferred but intentionally kept in code with `Deferred by Product_Vision MVP` comments:

- Sleep entry shapes until a sleep contract/UI job is ready.
- Lightweight mood record shapes until a future self-check-in product job is ready.
- Environment signals until a contextual Today/Mine job is ready.
- Medicine scan/OCR/photo/barcode/prescription quick-action/search shapes until recognition contracts are ready.
- Pregnancy/lactation/special-group medication safety conditions remain active inside Medicine safety boundaries, not as women-health or period modules.

Observable result:

- The mobile UI stays five-tab and Product_Vision-scoped while the next work implements logic instead of reviving broad-health mock modules.

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
2. Implement Medicine reminder create/edit/delete UI on top of the existing Lucent schedule-only reminder contract.
3. Keep Medicine dose-log and schedule-reminder behavior under regression while adding reminder edit UI and local notification scheduling.
4. Implement local notification scheduling only after the first reminder schedule source is explicit and backed by Lucent or a documented local-only model.
5. Keep auth/account deferred TODOs explicit until product/security decisions are made.

## Active Planning References

- `docs/superpowers/plans/2026-06-06-thirty-day-lumos-deepseek-plan.md`
- `docs/superpowers/plans/next-month-backlog.md`
- `../Lucent/docs/public/ROADMAP.md`
- `../Lucent/docs/public/reminder-contract.md`
- `../Lucent/docs/public/environment-contract.md`

## Do Not Start Yet

- Real push delivery through FCM/APNs.
- OCR/barcode/photo/prescription recognition UI or contracts.
- Family profiles.
- Smart device registry.
- Watch companion app.
- Women-health or period management.
- Sport recovery.
- Specialist health packs.
- Skin recognition or report photo import.
- Paid or credentialed external services without explicit approval.
- Environment frontend wiring until Record / Today / Medicine core flows are steadier and the target Today/Mine job is explicit.
- Standalone More tab or generic utility hub.
