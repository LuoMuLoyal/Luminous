# Lumos Next Plan

Last updated: 2026-06-06

## Current Goal

Move from a stable five-tab baseline into real daily health loops without presenting mock features as real.

## Short-Term Targets

### Target 1: Record Stability And Date Navigation

Status: in progress. Daily-record single-image create/edit, upload, metadata save, and timeline/detail display are implemented. Record date navigation and timeline time mapping were stabilized on 2026-06-06.

Goal: make the daily-record loop dependable before expanding other modules.

Scope:

- Keep daily-record image selection, preview, upload, metadata save, edit prefill, replace, and remove under regression.
- Record header date controls update the selected day and reload the Lucent-backed timeline.
- Record timeline displays each record's own `occurredAt` time instead of the current clock time.
- Keep provider invalidation for Record and Today after create/edit/delete.
- Add TODOs/tests when attachment failure, edit detail, or form-by-kind gaps are found.

Why first: Record is already a real Lucent-backed loop, and small correctness fixes here improve the main daily workflow more than expanding More.

Observable result:

- A signed-in user can switch Record dates, add/edit/delete records with one image, reopen the timeline, and see the correct day/time/image state.

### Target 2: Record Detail And Form Quality

Goal: make record detail/edit feel complete without adding unsupported medical complexity.

Scope:

- Show complete fields: type, occurred time, value, unit, title, note, and image attachment where available.
- Keep edit/delete entry points clear from the timeline/detail path.
- Tighten the form for common types first: water, vital, symptom, and note.
- Keep richer analytics, medical document import, and multi-image gallery out of scope.

Why second: date navigation and attachments must be stable before detail UX and type-specific forms are worth polishing.

Observable result:

- A user can open an existing record and understand exactly what was saved before editing it.

### Target 3: Local Reminder Scheduling

Goal: turn notification preferences into local scheduled reminders without push delivery.

Scope:

- Define the first local schedule source, likely current medicines plus user-selected times.
- Luminous schedules/cancels local notifications when preferences or schedules change.
- Keep FCM/APNs, backend delivery workers, push tokens, and delivery logs out of scope.
- If schedule data needs to sync across devices, design Lucent reminder APIs before implementation.

Why third: permission and preference UI already exists, but real scheduling needs a clear schedule source.

Observable result:

- A user can enable a local reminder and receive a device-local notification in a testable path.

### Deferred: Environment Snapshot / More

Status: Lucent endpoint implemented on 2026-06-06; Luminous More wiring is intentionally deferred until core modules are steadier.

Goal: replace the More environment mock with a small real Lucent endpoint.

Scope:

- Lucent adds static reference data and `GET /api/v1/environment/snapshot`.
- Lucent exports OpenAPI.
- Luminous regenerates the client and wires More environment data to the endpoint.
- Luminous keeps a "reference/static" label when dataSource is `static`.
- No third-party weather API, location tracking, or push alert behavior.

Why deferred: More is useful, but it should wait until Record / Today / Medicine core flows are steadier.

Observable result:

- More displays environment data from Lucent instead of `MockMoreRepository`.

## Immediate Work Order

1. Keep Record attachment/date/timeline behavior under regression and fix defects as they surface.
2. Expand daily-record detail UX after the image upload flow and date navigation stay stable.
3. Tighten Record forms by type for water, vital, symptom, and note.
4. Implement local notification scheduling after the first reminder schedule source is explicit.
5. Keep auth/account deferred TODOs explicit until product/security decisions are made.

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
- More environment frontend wiring until Record / Today / Medicine core flows are steadier.
