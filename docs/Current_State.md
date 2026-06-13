# Luminous Current State

Last updated: 2026-06-13

This file records current implementation facts only. Product direction lives in `Product_Vision.md`; next work lives in `Next_Plan.md`; reusable rules live in `Project_Guardrails.md`.

## Repository Split

- `Lucent` is the active NestJS backend.
- `Luminous` is the active Flutter client.
- `Luminous/backend` is legacy reference only.
- `D:\25080\Documents\VSCodeProject\Lumos` is not a git repository; `Lucent` and `Luminous` are separate child repositories.

## Product Surface

- Mobile is the current product surface.
- Bottom tabs are fixed at `today / record / medicine / report / mine`.
- Web is reserved for report preview/export and competition display.
- Desktop visual behavior is not part of current UI acceptance.

## Lucent Contract Snapshot

- API base: `/api/v1`.
- Response envelope: `{ code, message, data }`.
- Generated API contract: `Lucent/docs/openapi.json`.
- Current generated client baseline after report dashboard + range-based AI summary contracts: 47 paths / 138 schemas.
- Implemented backend areas used by Luminous: auth/account, user-scoped health context, medicine search/detail, current medicines, dose logs, medicine reminders, daily records with single-image attachment metadata, environment snapshot, user settings, support resources, app info, and data export requests.
- User-scoped business data is served under `/api/v1/user/*`; account profile/security actions remain under `/api/v1/account/*`.

## Luminous Runtime Snapshot

- Stack: Flutter + Riverpod + GoRouter.
- Generated Lucent client: `packages/lucent_openapi`.
- Auth/session state is split into restoring, confirmed signed-out, and signed-in.
- Integration coverage now includes three real Android-emulator full-stack lanes against Lucent test runtime:
  - auth sign-in smoke
  - Record create/detail/edit/delete CRUD lane
  - Today + Report protected-dashboard lane with Report sync verification
- Frontend tests are now grouped by feature under nested `test/` and `integration_test/` directories instead of one flat root.
- The real full-stack helper uses explicit Dart defines, Lucent test-state preparation, stable shell/login/action keys, and an in-memory session store so old secure-storage sessions do not leak into the lane.
- Full-stack mobile E2E is intentionally local/manual right now. It is not part of the current GitHub Actions pipeline because the lane still depends on a separate Lucent test runtime, Docker-backed test Postgres, and Android emulator orchestration across two repositories.
- Protected providers do not call Lucent while auth is restoring or confirmed signed out.
- Protected entry taps show a modal login prompt on the current page; direct/deep-link protected pages keep destination guards as fallback.
- Skeleton loading is section-scoped: stable chrome and local/mock/static sections render immediately, backend-backed fields shimmer locally.
- Report now fetches the Lucent report dashboard on page entry for signed-in users, keeps section-level shimmer loading, shows explicit signed-out gating, and still keeps export actions as frontend-only placeholders until export contracts exist.

## Active Mobile UI

- Today: compressed health overview, repository-provided medication/hydration priority list, medication tasks, hydration tasks with count targets, UI-only custom todos, manual Lucent-backed Today AI analysis generation with signed-out/disabled/loading/success/error card states, immediate risk/proactive suggestions, sleep vital row reading real duration from persisted sleep records (falls back to `--` when no data), and neutral error copy instead of `mock` phrasing.
- Record: symptoms, hydration with selectable units, diet/meal, note as a first-class type (own quick action, filter, and timeline entry), sleep as a create-capable kind with payload support for startAt/endAt/durationMinutes/quality/deepMinutes/lightMinutes/remMinutes, medication as non-create quick action, natural-language placeholder, selected-date timeline/detail/create/edit, top date bar, filters, summary/timeline-driven today overview, and panel-backed quick record/timeline sections whose inner rows use dividers instead of nested cards. Active create kinds are water, meal, symptom, note, and sleep. Lucent-backed filter results no longer fall back to a static mock timeline, and record error copy now uses neutral boundary wording instead of `mock data`.
- Medicine: active current-medicine drugbox, reminder-derived next dose, Lucent schedule-only reminder detail/create/edit/delete UI with optional start/end date window, local sound preference, on-device local notification scheduling synced from reminder schedules, SMS unavailable state, read-only reminder delivery history display, panel-backed medication actions, same-day taken/skipped dose logs, risk-check entry, source-review safety previews, and pregnancy/lactation/special-group medication safety conditions. Medicine no longer surfaces a local medication-report shortcut, and preview medicine names now use neutral example labels instead of real drug names.
- Report: Lucent-backed last-7-days dashboard with real medication/water/sleep aggregates, contract-driven findings/patterns text, manual AI summary generation through `/api/v1/user/reports/summary/generate`, local signed-out/disabled/loading/success/error AI-summary states, in-card `近 7 天 / 近 30 天` AI summary switching with per-range cached state, mobile pull-to-refresh plus explicit sync action, signed-out in-tab placeholder plus login notice instead of a full-page error gate, frontend-only export placeholders, and reference notice. Privacy settings are owned by Mine/Settings.
- Mine/Settings: account, basic health archive, allergies, current medicines, contract-backed support resources, server-backed privacy/AI settings, notification summaries from local settings state, data export request status, help/about metadata, and Advanced settings. Settings privacy copy is scoped to report sharing and AI summaries/advice rather than broad AI memory, the sleep reminder row now shows a local-only placeholder label instead of an enabled/disabled state, and Mine uses neutral error copy instead of `mock` wording. Mine profile editing currently surfaces birth date, height, blood type, unit system, and onboarding state only.

## Mock Or Deferred

- Report export data/files.
- Worker-populated reminder delivery history; the UI can read audit rows, but no local/push/SMS worker writes them yet.
- Lightweight mood record wiring.
- Environment contextual wiring for Today or Mine.
- Medicine scan/OCR/photo/barcode/prescription recognition.
- Pregnancy/lactation/special-group health-context fields remain available for medicine safety, but Mine does not surface them as standalone profile collection.

Deferred code that remains useful should be marked with:

```dart
// Deferred by Product_Vision MVP: keep this code because the capability is useful, but do not surface it until the matching contract/product job is ready.
```

## Removed From Active Scope

- Old More tab and `features/more`.
- Women-health and period management.
- Sport recovery.
- Specialist health packs.
- Smart devices.
- Family profiles.
- Skin recognition.
- Report photo import.
- Desktop-first workflows.
