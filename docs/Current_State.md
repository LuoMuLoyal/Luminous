# Luminous Current State

Last updated: 2026-06-18

This file records current implementation facts only. Product direction lives in `Product_Vision.md`; next work lives in `Next_Plan.md`; reusable rules live in `Project_Guardrails.md`.

## Repository Split

- `Lucent` is the active NestJS backend.
- `Luminous` is the active Flutter client.
- `Luminous/backend` is legacy reference only.
- The shared workspace root is not a git repository; `Lucent` and `Luminous` are separate child repositories.

## Product Surface

- Mobile is the current product surface.
- Bottom tabs are fixed at `today / record / medicine / report / mine`.
- Web is reserved for report preview/export and competition display.
- `Luminous-site` currently serves as a competition/marketing homepage, not a signed-in report preview surface.
- Desktop visual behavior is not part of current UI acceptance.

## Lucent Contract Snapshot

- API base: `/api/v1`.
- Response envelope: `{ code, message, data }`.
- Generated API contract: `Lucent/docs/openapi.json`.
- Current generated client baseline after AI chat conversation persistence contracts: 57 paths / 168 schemas.
- Implemented backend areas used by Luminous: auth/account, user-scoped health context, medicine search/detail, current medicines, dose logs, medicine reminders, daily records with single-image attachment metadata, environment snapshot, user settings, support resources, app info, and data export requests.
- User-scoped business data is served under `/api/v1/user/*`; account profile/security actions remain under `/api/v1/account/*`.

## Luminous Runtime Snapshot

- Stack: Flutter + Riverpod + GoRouter.
- Generated Lucent client: `packages/lucent_openapi`.
- Auth/session state is split into restoring, confirmed signed-out, and signed-in.
- Integration coverage now includes four real Android-emulator full-stack lanes against Lucent test runtime:
  - auth sign-in smoke
  - Record create/detail/edit/delete CRUD lane
  - Record sleep structured-entry lane
  - Today + Report protected-dashboard lane with Report sync verification plus real Today/Report AI streaming generation
- Repo-local validation entrypoints are now split into:
  - `tool/run_daily_checks.ps1` for repo-safe checks (`flutter pub get`, `flutter gen-l10n`, `flutter analyze`, `flutter test`)
  - `tool/run_fullstack_checks.ps1` for Android emulator + Lucent test-runtime lanes
- Melos now provides shorter local script-style wrappers for the same validation flows, including `dart run melos run daily`, `dart run melos run fullstack`, and per-lane full-stack entries that read `.env.fullstack-e2e` through `--dart-define-from-file`.
- Frontend tests are now grouped by feature under nested `test/` and `integration_test/` directories instead of one flat root.
- The real full-stack helper uses explicit Dart defines, Lucent test-state preparation, stable shell/login/action keys, and an in-memory session store so old secure-storage sessions do not leak into the lane.
- Full-stack mobile E2E is intentionally local/manual right now. It is not part of the current GitHub Actions pipeline because the lane still depends on a separate Lucent test runtime, Docker-backed test Postgres, and Android emulator orchestration across two repositories.
- Shared support-resource reads now live under a dedicated `features/support/` frontend boundary instead of staying nested under `settings`, because the same contract-backed resource set is consumed by Mine, Medicine, and Settings.
- Protected providers do not call Lucent while auth is restoring or confirmed signed out.
- Protected entry taps show a modal login prompt on the current page; direct/deep-link protected pages keep destination guards as fallback.
- Skeleton loading is section-scoped: stable chrome and local/mock/static sections render immediately, backend-backed fields shimmer locally.
- Report now fetches the Lucent report dashboard on page entry for signed-in users, keeps section-level shimmer loading, shows explicit signed-out gating, and now wires all three export cards to Lucent data-export request flows (`hospital + pdf + last_7_days`, `monthly + pdf + last_30_days`, `print + pdf + last_7_days`).

## Active Mobile UI

- Today: compressed health overview, repository-provided medication/hydration priority list, medication tasks, hydration tasks with count targets, UI-only custom todos, manual Lucent-backed Today AI analysis generation with signed-out/disabled/loading/success/error card states, real incremental summary streaming through `/api/v1/user/today-analysis/generate/stream`, final structured bullets/action/confidence render after stream completion, immediate risk/proactive suggestions, sleep vital row reading real duration from persisted sleep records (falls back to `--` when no data), and neutral error copy instead of `mock` phrasing.
- Record: symptoms, hydration with selectable units, diet/meal, note as a first-class type (own quick action, filter, and timeline entry), sleep as a create-capable kind with structured bedtime/wake-time/quality/stage inputs backed by payload fields `startAt/endAt/durationMinutes/quality/deepMinutes/lightMinutes/remMinutes`, medication as non-create quick action, mobile natural-language bottom-sheet intake wired to Lucent candidate parsing plus confirm-before-save flow, selected-date timeline/detail/create/edit, top date bar, filters, summary/timeline-driven today overview, and panel-backed quick record/timeline sections whose inner rows use dividers instead of nested cards. Active create kinds are water, meal, symptom, note, and sleep. Natural-language candidate kinds currently stay bounded to water, meal, symptom, note, and sleep. Candidate review is now editable and selectively savable: user can adjust title/value/unit/note, edit sleep duration/quality payload, unselect items, keep failed items in place, and explicitly retry only failed candidates instead of resubmitting the full batch. Candidate editors now also apply light per-kind polish for MVP usability: water uses a numeric amount plus the same `ml / cup / times` unit picker as the formal form, meal/symptom cards use more specific field labels, and note cards emphasize body text instead of a generic remark field. Sleep timeline rows now derive their compact duration label from payload when `value/unit` are intentionally null. Lucent-backed filter results no longer fall back to a static mock timeline, and record error copy now uses neutral boundary wording instead of `mock data`.
- Medicine: active current-medicine drugbox, reminder-derived next dose, Lucent schedule-only reminder detail/create/edit/delete UI with optional start/end date window, local sound preference, on-device local notification scheduling synced from reminder schedules, SMS unavailable state, read-only reminder delivery history display, panel-backed medication actions, same-day taken/skipped dose logs, a real current-medicine risk-check page, workspace safety cards sourced from the same risk result, add-before-save risk precheck on medicine search results, source-review safety previews, and pregnancy/lactation/special-group medication safety conditions. The frozen MVP risk-check boundary is intentionally narrow but now explicit and consistent across entry points: it evaluates current medicines plus the pending add candidate, uses existing medicine-detail data only, surfaces a shared coverage summary when manual entries, missing source detail, or fully unchecked medicine sets cannot be checked, and applies a bounded reviewed rule set for allergy matching, age-gated pediatric/geriatric warnings, pregnancy/lactation warnings, and duplicate-ingredient checks for reviewed `cn` ingredient strings plus DrugBank synonym overlap. When pediatric, geriatric, pregnancy, or lactation detail is missing, the UI now keeps that uncertainty visible instead of silently treating it as clear. Fixed red-flag alerts now surface at the top of the risk-check page and can open a matching campus emergency or campus hospital resource when Lucent provides a real action target. It does not claim broad cross-source normalization or unreviewed interaction expansion.
- Report: Lucent-backed last-7-days dashboard with real medication/water/sleep aggregates, contract-driven findings/patterns text, manual AI summary generation with real incremental summary streaming through `/api/v1/user/reports/summary/generate/stream`, local signed-out/disabled/loading/success/error AI-summary states, in-card `近 7 天 / 近 30 天` AI summary switching with per-range cached state, a mobile-safe wrapped header layout for the AI summary controls, mobile pull-to-refresh plus explicit sync action, a tightened mobile report layout with a balanced 2x2 metric grid, a real derived fourth metric card for overall report status based on the report score, and a lighter signed-out inline notice instead of a large warning block. Three real PDF export actions are wired: `给校医院` uses `hospital + pdf + last_7_days`, `月度报告` uses `monthly + pdf + last_30_days`, and `打印预览` uses `print + pdf + last_7_days`. Report export cards now show active in-flight progress and bounded status wording for requesting, processing, completed-but-link-missing, failed, and unavailable states. Mine/Settings still uses the same real data-export request flow and request status. Privacy settings are owned by Mine/Settings.
- Mine/Settings: account, basic health archive, allergies, current medicines, contract-backed support resources, server-backed privacy/AI settings, notification summaries from local settings state, data export request status, help/about metadata, Advanced settings, and AI chat controls. Settings privacy copy is scoped to report sharing and AI summaries/advice rather than broad AI memory, the sleep reminder row now shows a local-only placeholder label instead of an enabled/disabled state, and Mine uses neutral error copy instead of `mock` wording. The AI chat experience is no longer hidden as a settings-only subpage: Today top bar now exposes a first-level assistant entry that routes to a standalone `/assistant` chat workspace, while Settings keeps the same capability/permission controls as a secondary way to reach it. The assistant workspace reads real Lucent capabilities, restores the latest persisted conversation, can archive the latest active conversation through the backend, exposes the authenticated user's AI chat enable toggle plus fine-grained context toggles, and streams Markdown replies through SSE. Mine profile editing currently surfaces birth date, height, blood type, unit system, and onboarding state only. Campus/support resource rows are now backed by real support-resource data, and rows without a server action target render as visible but inactive instead of pretending they can open something.

## Mock Or Deferred

- AI chat Phase 1 mobile surface now exists as a standalone `/assistant` workspace reachable from the Today top bar and Settings: authenticated users can view real backend capabilities, choose whether AI chat is enabled, choose whether health profile / recent records / sleep data / current medicines may be used as chat context, restore the latest persisted conversation, clear the latest active conversation, and send real SSE streaming chat requests with Markdown assistant rendering. This is still a lightweight single-page surface without multi-conversation management, RAG, voice input, or free-form agent orchestration UI.
- Additional report export kinds beyond the current `hospital` / `monthly` / `print` PDF set.
- Export lifecycle polish is still intentionally lightweight: there is no in-page request history list, no explicit retry queue, and no share-link workflow beyond opening the latest signed download URL.
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

- Old More tab and its leftover `features/more` mock workspace.
- Women-health and period management.
- Sport recovery.
- Specialist health packs.
- Smart devices.
- Family profiles.
- Skin recognition.
- Report photo import.
- Desktop-first workflows.
