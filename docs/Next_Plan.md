# Lumos Next Plan

Last updated: 2026-06-06

## Current Goal

Move from a stable five-tab baseline into real daily health loops without presenting mock features as real.

## Short-Term Targets

### Target 1: Daily Record Images

Status: implemented on 2026-06-06 for single-image create/edit, upload, metadata save, and timeline/detail display.

Goal: make daily-record image attachment real end to end.

Scope:

- Luminous adds image selection for daily-record create/edit.
- Luminous calls Lucent's Tencent COS presigned upload endpoint.
- Luminous uploads directly to COS, then saves attachment metadata with the daily record.
- Record detail/timeline renders saved image attachments.
- Keep provider invalidation for Record and Today after create/edit/delete.

Why first: Lucent already exposes the backend contract and generated client; the current frontend TODO is the missing bridge.

Observable result:

- A signed-in user can add a record with an image, reopen it, and see the attachment metadata/image in the record UI.

### Target 2: Environment Snapshot

Status: Lucent endpoint implemented on 2026-06-06; Luminous More wiring remains next.

Goal: replace the More environment mock with a small real Lucent endpoint.

Scope:

- Lucent adds static reference data and `GET /api/v1/environment/snapshot`.
- Lucent exports OpenAPI.
- Luminous regenerates the client and wires More environment data to the endpoint.
- Luminous keeps a "reference/static" label when dataSource is `static`.
- No third-party weather API, location tracking, or push alert behavior.

Why second: it turns one More section real without paid services, credentials, or broad product decisions.

Observable result:

- More displays environment data from Lucent instead of `MockMoreRepository`.

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

## Immediate Work Order

1. Wire Luminous More environment data to Lucent `GET /api/v1/environment/snapshot`.
2. Expand daily-record detail UX after the image upload flow is stable.
3. Implement local notification scheduling after the first reminder schedule source is explicit.
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
