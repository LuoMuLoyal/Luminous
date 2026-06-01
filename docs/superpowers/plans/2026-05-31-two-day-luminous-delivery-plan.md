# Luminous Two-Day Delivery Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** In the next two days, replace the highest-value remaining mock read paths with real Lucent-backed reads where APIs already exist, and finish the Mine theme selection UI so the frontend has one real user-profile path and one real medicine search/detail path.

**Architecture:** Keep the existing feature-first UI surfaces, but insert real data through explicit datasource/repository layers instead of page-local logic. Introduce one shared health-context data layer for Mine, and convert Search from a static mock `FutureProvider` into a query-driven Lucent repository + interactive provider. Do not invent unsupported backend capabilities.

**Tech Stack:** Flutter, Riverpod, GoRouter, Dio, Lucent OpenAPI client, SharedPreferences, flutter_test

---

## Read This First

- `AGENTS.md`
- `docs/README.md`
- `docs/UI_Implementation_Plan.md`
- `docs/OpenApi_Client.md`
- `../Lucent/docs/public/api-contract.md`
- `../Lucent/docs/backend-user-domain.md`

## Current Backend Reality

These are the only confirmed Lucent APIs that matter for this two-day window:

- `GET /api/v1/me/health-context`
- `GET /api/v1/medicines`
- `GET /api/v1/medicines/:id`
- auth endpoints already used by Luminous

Confirmed gaps:

- No write APIs yet for Mine profile/allergy/condition/current-medicine editing
- No real device/environment/tool endpoints for More
- No reminder/today-record/water/meal backend yet
- No real add-to-drugbox / reminder creation API in current frontend contract
- No real scan / OCR / barcode execution API in current frontend contract

## Hard Scope Boundary

Do these in the next two days:

1. Expose Lucent health-context API through the frontend network layer.
2. Build a shared health-context datasource/repository layer.
3. Replace Mine mock reads with real Lucent-backed reads where the backend supports them.
4. Add Mine theme mode UI wired to `appThemeControllerProvider`.
5. Replace Search mock reads with real Lucent medicine search/detail reads.
6. Make Search UI actually drive query/source/result state instead of showing a frozen mock dashboard.
7. Update docs and tests.

Do **not** do these in the next two days:

- More real integrations
- Medicine scan / OCR / barcode real execution
- Reminder creation / reminder scheduling
- Today full real-data migration
- Mine write/edit APIs
- Backend schema or API redesign unless frontend is blocked by an obvious contract bug

## File Map

### Existing files that must be read before editing

- `lib/core/network/lucent_dio_client.dart`
- `lib/core/network/lucent_network_providers.dart`
- `lib/core/theme/app_theme_controller.dart`
- `lib/features/auth/data/datasources/auth_remote_data_source.dart`
- `lib/features/today/domain/entities/today_dashboard.dart`
- `lib/features/today/data/repositories/mock_today_repository.dart`
- `lib/features/mine/domain/entities/mine_dashboard.dart`
- `lib/features/mine/data/repositories/mock_mine_repository.dart`
- `lib/features/mine/presentation/widgets/mine_dashboard_view.dart`
- `lib/features/search/domain/entities/medicine_search.dart`
- `lib/features/search/data/repositories/mock_medicine_search_repository.dart`
- `lib/features/search/presentation/providers/medicine_search_provider.dart`
- `lib/features/search/presentation/widgets/medicine_search_view.dart`
- `test/mine_page_test.dart`
- `test/search_page_test.dart`
- `test/app_theme_controller_test.dart`

### New files expected in this plan

- `lib/features/health_context/data/datasources/health_context_remote_data_source.dart`
- `lib/features/health_context/data/providers/health_context_data_providers.dart`
- `lib/features/health_context/data/mappers/health_context_mapper.dart`
- `lib/features/health_context/domain/entities/health_context_snapshot.dart`
- `lib/features/health_context/domain/repositories/health_context_repository.dart`
- `lib/features/health_context/data/repositories/lucent_health_context_repository.dart`
- `lib/features/mine/data/repositories/lucent_mine_repository.dart`
- `lib/features/search/data/datasources/medicine_search_remote_data_source.dart`
- `lib/features/search/data/mappers/medicine_search_mapper.dart`
- `lib/features/search/data/repositories/lucent_medicine_search_repository.dart`
- `test/health_context_repository_test.dart`
- `test/search_repository_test.dart`

## Day 1

### Task 1: Expose UserHealthContextApi in the frontend network layer

**Files:**
- Modify: `lib/core/network/lucent_dio_client.dart`
- Modify: `lib/core/network/lucent_network_providers.dart`

**Intent:** unblock all health-context-backed frontend work using the same pattern already used for `AuthApi` and `MedicinesApi`.

- [ ] Add `UserHealthContextApi get userHealthContextApi => _openapi.getUserHealthContextApi();` to `LucentDioClient`
- [ ] Add `lucentUserHealthContextApiProvider` in `lucent_network_providers.dart`
- [ ] Keep token injection / locale injection behavior unchanged
- [ ] Do **not** regenerate OpenAPI here unless the current package is actually missing the API type

**Verification**

Run:

```bash
flutter analyze lib/core/network
```

Expected:

- no analyzer issues
- no behavior change in auth or medicines imports

**Commit suggestion**

```bash
git add lib/core/network/lucent_dio_client.dart lib/core/network/lucent_network_providers.dart
git commit -m "feat: expose lucent health context api"
```

---

### Task 2: Build a shared health-context datasource and repository

**Files:**
- Create: `lib/features/health_context/domain/entities/health_context_snapshot.dart`
- Create: `lib/features/health_context/domain/repositories/health_context_repository.dart`
- Create: `lib/features/health_context/data/datasources/health_context_remote_data_source.dart`
- Create: `lib/features/health_context/data/mappers/health_context_mapper.dart`
- Create: `lib/features/health_context/data/repositories/lucent_health_context_repository.dart`
- Create: `lib/features/health_context/data/providers/health_context_data_providers.dart`
- Create: `test/health_context_repository_test.dart`

**Intent:** one shared read model should feed Mine now and Today later. Do not bury the Lucent call inside Mine.

**Implementation requirements**

- Create a small frontend-friendly snapshot entity, not a raw DTO mirror
- The snapshot must cover:
  - summary counts
  - missing profile fields
  - profile basics needed by Mine
  - active allergies
  - conditions
  - current medicines
- Put Lucent DTO-to-domain mapping logic into a dedicated mapper file
- Keep raw Lucent DTO types out of presentation code
- Keep this feature read-only

**Important mapping rules**

- `missingFields` from Lucent should stay machine-readable in the domain layer
- convert counts to `int`
- keep current medicine names/source/current-state available to consumers
- do not fabricate data that Lucent does not return

**Verification**

Run:

```bash
flutter test test/health_context_repository_test.dart
flutter analyze lib/features/health_context test/health_context_repository_test.dart
```

Expected:

- repository test passes with representative Lucent payload mapping
- no DTO leakage into widgets/providers outside the feature

**Commit suggestion**

```bash
git add lib/features/health_context test/health_context_repository_test.dart
git commit -m "feat: add shared health context data layer"
```

---

### Task 3: Replace Mine mock reads with real Lucent-backed reads

**Files:**
- Modify: `lib/features/mine/domain/entities/mine_dashboard.dart`
- Modify: `lib/features/mine/presentation/widgets/mine_copy.dart`
- Modify: `lib/features/mine/data/repositories/mock_mine_repository.dart`
- Create: `lib/features/mine/data/repositories/lucent_mine_repository.dart`
- Modify: `lib/features/mine/presentation/providers/mine_dashboard_provider.dart`
- Modify: `lib/features/mine/presentation/widgets/mine_dashboard_view.dart`
- Modify: `lib/features/mine/presentation/mine_page.dart`
- Modify: `test/mine_page_test.dart`

**Intent:** Mine should stop lying about obviously fake profile data when Lucent can provide real user + health-context reads.

**Key design decisions**

- Keep the current visual structure
- Replace fake account/header and health-summary values with real Lucent-derived values where possible
- Keep sections that have no backend support as static mock fragments
- Do not hard-fail the page for signed-out users

**Concrete behavior**

- Signed-in state:
  - account email comes from `/me`
  - display name uses nickname if present, else email local-part
  - signed-in / verified state reflects real auth user
  - health summary counts and missing-field prompts come from `/me/health-context`
  - current medicines count comes from health context
- Signed-out state:
  - show a guest-safe Mine dashboard, not a red error wall
  - sign-in entry can stay toast/nav based, but the page must render
- Remove or replace fake membership-expiry copy because Lucent does not provide it

**Important entity cleanup**

The current Mine entities overuse enum-backed copy keys for values that now need real strings. Refactor the entity model so runtime values can flow through cleanly. Examples:

- account display name / email / status / meta should be string fields, not enum-only fields
- status panel values should support runtime labels
- summary metrics may keep l10n titles but runtime values

**Verification**

Run:

```bash
flutter test test/mine_page_test.dart
flutter analyze lib/features/mine test/mine_page_test.dart
```

Expected:

- existing layout tests still pass after the data-model refactor
- signed-out state is renderable
- signed-in data mapping is covered by at least one unit or widget assertion

**Commit suggestion**

```bash
git add lib/features/mine test/mine_page_test.dart
git commit -m "feat: wire mine to lucent health context"
```

---

### Task 4: Add Mine theme mode UI

**Files:**
- Modify: `lib/features/mine/presentation/widgets/mine_dashboard_view.dart`
- Modify: `lib/features/mine/presentation/widgets/mine_components.dart`
- Modify: `lib/l10n/app_zh.arb`
- Modify: `lib/l10n/app_en.arb`
- Modify: generated `lib/l10n/app_localizations*.dart`
- Modify: `test/mine_page_test.dart`
- Reuse: `lib/core/theme/app_theme_controller.dart`

**Intent:** close the gap between existing theme persistence and missing theme-selection UI.

**Implementation requirements**

- Put the theme selector inside Mine settings
- Use one compact three-option control:
  - system
  - light
  - dark
- Read/write through `appThemeControllerProvider`
- Do not create a second theme state source
- Use ARB strings for the option labels

**Verification**

Run:

```bash
flutter gen-l10n
flutter test test/app_theme_controller_test.dart test/mine_page_test.dart
flutter analyze lib/features/mine lib/core/theme
```

Expected:

- theme controller tests remain green
- Mine widget tests remain green
- Mine settings visibly expose the selector

**Commit suggestion**

```bash
git add lib/features/mine lib/l10n test/app_theme_controller_test.dart test/mine_page_test.dart
git commit -m "feat: add mine theme selection ui"
```

## Day 2

### Task 5: Replace Search mock repository with Lucent-backed search/detail data layer

**Files:**
- Create: `lib/features/search/data/datasources/medicine_search_remote_data_source.dart`
- Create: `lib/features/search/data/mappers/medicine_search_mapper.dart`
- Create: `lib/features/search/data/repositories/lucent_medicine_search_repository.dart`
- Modify: `lib/features/search/domain/entities/medicine_search.dart`
- Modify: `lib/features/search/domain/repositories/medicine_search_repository.dart`
- Modify: `lib/features/search/data/repositories/mock_medicine_search_repository.dart`
- Create: `test/search_repository_test.dart`

**Intent:** Lucent already provides medicine search/detail. The frontend should stop pretending this is mock-only.

**Required repository capabilities**

- search by keyword
- switch source (`cn`, `drugbank`)
- fetch detail for selected medicine id + source
- map API results into stable frontend entities

**Domain cleanup required**

The current `MedicineSearchDashboard` shape is too static for real interaction. Refactor it so it can carry:

- query
- selected source
- recent keywords
- categories / quick actions
- results
- selected result id
- selected result detail preview
- loading/error status for search and detail if needed

Do not keep the current fake static `selectedResult` assumption if the real search returns empty results.

**Verification**

Run:

```bash
flutter test test/search_repository_test.dart
flutter analyze lib/features/search test/search_repository_test.dart
```

Expected:

- repository tests cover at least one search mapping and one detail mapping
- no direct DTO usage inside widgets

**Commit suggestion**

```bash
git add lib/features/search test/search_repository_test.dart
git commit -m "feat: add lucent medicine search data layer"
```

---

### Task 6: Make Search UI interactive and provider-driven

**Files:**
- Modify: `lib/features/search/presentation/providers/medicine_search_provider.dart`
- Modify: `lib/features/search/presentation/pages/search_page.dart`
- Modify: `lib/features/search/presentation/widgets/medicine_search_view.dart`
- Modify: `lib/features/search/presentation/widgets/medicine_search_parts.dart`
- Modify: `test/search_page_test.dart`

**Intent:** the current page is mostly a styled static mock. It needs real query / source / selection behavior.

**Provider expectations**

- move off the current one-shot `FutureProvider<MedicineSearchDashboard>`
- use `AsyncNotifier`, `Notifier`, or equivalent state holder with explicit methods:
  - initialize
  - updateQuery
  - switchSource
  - selectResult
  - retry
- keep the current route `/medicine/search`

**UI expectations**

- search input must actually trigger search
- source switch must actually refetch
- selecting a result must refresh the preview panel on desktop
- mobile should still show the result list cleanly
- quick actions and add-to-drugbox remain mock/toast unless a real API exists
- no fake detail preview disconnected from the selected result

**Verification**

Run:

```bash
flutter test test/search_page_test.dart
flutter analyze lib/features/search test/search_page_test.dart
```

Expected:

- search page test still passes after the provider rewrite
- at least one widget test covers source switching or result selection behavior

**Commit suggestion**

```bash
git add lib/features/search test/search_page_test.dart
git commit -m "feat: make medicine search interactive"
```

---

### Task 7: Docs, regression checks, and cleanup

**Files:**
- Modify: `docs/UI_Implementation_Plan.md`
- Modify: `docs/MigrationLog.md`
- Modify: `docs/OpenApi_Client.md`
- Modify: `docs/Localization.md` if user-visible text changed

**Intent:** leave a clean handoff trail and no unverifiable claims.

**Required verification bundle**

Run:

```bash
flutter gen-l10n
flutter analyze
flutter test test/mine_page_test.dart test/search_page_test.dart test/app_theme_controller_test.dart test/medicine_page_test.dart test/record_page_test.dart test/today_page_test.dart
git diff --check
```

Expected:

- all commands pass
- no overflow regressions
- no whitespace errors

**Commit suggestion**

```bash
git add docs
git commit -m "docs: update frontend delivery status"
```

## Parallelization Guidance

Use parallel agents only where file overlap is low.

### Safe parallel window A

After Task 2 is merged:

- Agent A: Task 3 (Mine real-data wiring)
- Agent B: no concurrent Mine UI task by default; start Task 4 only after Task 3 is merged and the Mine entity/view shape is stable

Do **not** let two agents edit `mine_dashboard.dart` or `mine_dashboard_view.dart` at the same time.

### Safe parallel window B

After Task 5 locks the Search domain/repository contract:

- Agent A: repository/data-layer mapping
- Agent B: provider/UI rewrite and widget tests

Do **not** let two agents independently redefine `MedicineSearchDashboard`.

## Stretch Goal Only If Main Scope Is Green By Day 2 Afternoon

Do not start this if any main-scope verification is still red.

### Stretch: Prepare Today for future real data

**Files:**
- Modify: `lib/features/today/domain/entities/today_dashboard.dart`
- Modify: `lib/features/today/data/repositories/mock_today_repository.dart`
- Optionally create: `lib/features/today/data/repositories/hybrid_today_repository.dart`
- Modify: `lib/features/today/presentation/providers/today_dashboard_provider.dart`
- Modify: `test/today_page_test.dart`

**Stretch outcome**

- keep Today visually the same
- pull at least medication count / current-medicine signal from shared health context
- keep unsupported cards mock-backed

This is not part of the required two-day success definition.

## Reviewer Checklist For Final Audit

This is the checklist I will use after Kimi finishes:

1. Mine no longer shows obviously fake membership/account summary data when signed in.
2. Mine still renders in signed-out state.
3. Theme mode UI writes through `appThemeControllerProvider` and persists.
4. Search no longer relies on a frozen mock dashboard for query/source/result state.
5. Search repository uses real Lucent search and detail APIs.
6. No new page-local snackbar/toast patterns outside shared `AppToast`.
7. All user-visible text stays in ARB.
8. Docs were updated.
9. `flutter analyze` is green.
10. Relevant widget tests are green.
11. No extra speculative backend or UI scope was dragged in.

## What Kimi Must Return After Each Task

Ask Kimi to return this after every task:

1. touched files
2. what changed
3. exact commands run
4. pass/fail result for each command
5. blockers or assumptions

If Kimi reports “done” without command evidence, treat that as incomplete.

## Recommended Dispatch Order

Do not send the whole plan in one huge shot.

Use this order:

1. Task 1
2. Task 2
3. Task 3
4. Task 4
5. Task 5
6. Task 6
7. Task 7
8. Stretch only if everything above is already green

That order matches the real dependency graph and keeps review cheap.
