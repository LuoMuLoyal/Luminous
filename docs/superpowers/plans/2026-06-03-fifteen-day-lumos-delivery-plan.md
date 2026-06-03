# Lumos Fifteen-Day DeepSeek Delivery Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** From 2026-06-03 through 2026-06-17, move Lumos from a mostly mock health-copilot shell to a reviewable Lucent-backed personal health-context and medicine-loop baseline.

**Architecture:** Keep Lucent as the only active backend and Luminous as the Flutter client. Use the existing feature-first frontend layout, Riverpod providers, generated Lucent OpenAPI client, and Lucent's current Prisma user health-context models. Expand only the backend APIs that are already supported by the current schema, then regenerate the client and wire frontend flows through datasource/repository/provider boundaries.

**Tech Stack:** NestJS 11, Prisma 7, PostgreSQL, Redis, Jest, Flutter, Riverpod, GoRouter, Dio, generated `lucent_openapi`, Flutter l10n, `flutter_test`.

---

## Plan Ownership

- Created on: 2026-06-03.
- Covered window: 2026-06-03 to 2026-06-17.
- Executor: DeepSeek or another implementation agent.
- Reviewer: Codex.
- Repository layout: `Lucent` and `Luminous` are separate git repositories under `D:\25080\Documents\VSCodeProject\Lumos`; the workspace root is not a git repository.

## Required Reading Before Editing

Read these files before starting Task 1:

- `Lucent/AGENTS.md`
- `Lucent/README.md`
- `Lucent/docs/README.md`
- `Lucent/docs/public/api-contract.md`
- `Lucent/docs/backend-user-domain.md`
- `Lucent/docs/environment.md`
- `Lucent/prisma/schema.prisma`
- `Luminous/AGENTS.md`
- `Luminous/README.md`
- `Luminous/docs/README.md`
- `Luminous/docs/UI_Implementation_Plan.md`
- `Luminous/docs/OpenApi_Client.md`
- `Luminous/docs/Localization.md`
- `Luminous/docs/MigrationLog.md`

## Current Reality Snapshot

As of 2026-06-03:

- Lucent already exposes:
  - `GET /api/v1/health`
  - `GET /api/v1/medicines`
  - `GET /api/v1/medicines/:id`
  - `GET /api/v1/me/health-context`
  - `PATCH /api/v1/me/health-context/profile`
- Current `PATCH /me/health-context/profile` only supports `locale`, `timezone`, and `unitSystem`.
- Lucent Prisma already has `UserProfile`, `UserAllergy`, `UserCondition`, and `UserCurrentMedicine`.
- Luminous already has:
  - five-tab shell: `today / record / medicine / mine / more`
  - auth/session providers
  - generated Lucent OpenAPI package
  - health-context read layer
  - Lucent-backed search repository
  - Mine partly wired to health-context reads
  - Settings profile preference sync work currently visible in the dirty tree
- Confirmed gaps:
  - no backend write API for profile core fields, allergies, conditions, or current medicines
  - no real reminder schedule API
  - no real scan/OCR/barcode execution API
  - no backend records/timeline API for meals, vitals, mood, symptoms, water, or activity
  - no real More tools/device/emergency backend integration

## Hard Scope Boundary

Do this in the fifteen-day window:

1. Protect and verify the current dirty work in both repositories.
2. Finish and verify the in-flight Settings locale/profile-preference sync.
3. Expand Lucent health-context write APIs for existing Prisma-backed data only.
4. Export OpenAPI and regenerate the Luminous client through the existing wrapper.
5. Add Luminous repository write methods for profile, allergies, conditions, and current medicines.
6. Add Mine edit flows that use those writes.
7. Connect Search "add to current medicines" to Lucent.
8. Replace the Medicine tab's current-medicine surface with real health-context data.
9. Connect Today to the safe subset of real health-context signals.
10. Update docs, tests, and audit evidence.

Do not do this in the fifteen-day window:

- production deployment
- force-push, history rewrite, or destructive git reset
- broad UI redesign or landing-page work
- new production dependencies unless the existing stack cannot do the job
- AI medical advice, diagnosis, or treatment recommendation flows
- OCR, scan, barcode, push reminder, or calendar scheduling execution
- backend records/timeline schema for vitals/meals/mood/water/activity
- importing or rewriting the DrugBank pipeline unless medicine search/detail is broken by the current task
- editing legacy `Luminous/backend`
- adding new code under legacy Flutter folders listed in `Luminous/AGENTS.md`

## Execution Protocol For DeepSeek

DeepSeek must execute one task at a time. After every task, return this exact evidence bundle:

```text
Task:
Status: DONE / DONE_WITH_CONCERNS / BLOCKED
Touched files:
Behavior changed:
Commands run:
Command results:
Docs updated:
Assumptions:
Reviewer notes:
```

Rules:

- If a command was not run, say `not run` and give the reason.
- If `git status --short` shows unrelated dirty files, do not edit them.
- If a task touches API behavior, update Lucent docs and OpenAPI in the same task or in the explicitly paired OpenAPI task.
- If a task touches visible Flutter text, update both ARB files and run `flutter gen-l10n`.
- If a task adds UI, add or update widget tests.
- If a task adds backend behavior, add or update unit/e2e tests.
- If tests fail because they were already failing at baseline, preserve the failure output and do not claim the task is complete until Codex accepts the baseline note.

## Reviewer Protocol For Codex

For each DeepSeek task, Codex should review in this order:

1. Read DeepSeek's evidence bundle.
2. Run `git -C Lucent diff --check` or `git -C Luminous diff --check` for touched repositories.
3. Inspect diff for unrelated edits, hardcoded user-visible text, DTO leakage into Flutter widgets, and unsupported API claims.
4. Run the task's targeted verification commands.
5. For UI tasks, inspect at least one mobile-width and one desktop-width widget or app surface when the environment allows.
6. Accept only when behavior, tests, docs, and generated artifacts match the task.

If DeepSeek reports "done" without command evidence, treat the task as incomplete.

## Dispatch Template

Use this prompt when sending a task to DeepSeek:

```text
Use superpowers:executing-plans. Execute only Task <N> from:
Luminous/docs/superpowers/plans/2026-06-03-fifteen-day-lumos-delivery-plan.md

Before editing:
- read the Required Reading list if not already done
- run git status in Lucent and Luminous
- protect unrelated dirty work

After editing:
- run the exact verification commands for Task <N>
- return the required evidence bundle

Do not start Task <N+1>.
```

## File Map

### Lucent backend files likely to change

- `Lucent/src/user-health-context/user-health-context.controller.ts`
- `Lucent/src/user-health-context/user-health-context.service.ts`
- `Lucent/src/user-health-context/user-health-context.service.spec.ts`
- `Lucent/src/user-health-context/dto/health-context-response.dto.ts`
- `Lucent/src/user-health-context/dto/update-health-context-profile.dto.ts`
- `Lucent/src/user-health-context/dto/index.ts`
- `Lucent/test/user-health-context.e2e-spec.ts`
- `Lucent/docs/public/api-contract.md`
- `Lucent/docs/openapi.json`
- `Lucent/docs/backend-user-domain.md`
- `Lucent/CHANGELOG.md`

Possible new Lucent DTO files:

- `Lucent/src/user-health-context/dto/create-health-context-allergy.dto.ts`
- `Lucent/src/user-health-context/dto/update-health-context-allergy.dto.ts`
- `Lucent/src/user-health-context/dto/create-health-context-condition.dto.ts`
- `Lucent/src/user-health-context/dto/update-health-context-condition.dto.ts`
- `Lucent/src/user-health-context/dto/create-current-medicine.dto.ts`
- `Lucent/src/user-health-context/dto/update-current-medicine.dto.ts`

### Luminous frontend files likely to change

- `Luminous/lib/app/router.dart`
- `Luminous/lib/core/network/lucent_dio_client.dart`
- `Luminous/lib/core/network/lucent_network_providers.dart`
- `Luminous/lib/features/health_context/data/datasources/health_context_remote_data_source.dart`
- `Luminous/lib/features/health_context/data/mappers/health_context_mapper.dart`
- `Luminous/lib/features/health_context/data/providers/health_context_data_providers.dart`
- `Luminous/lib/features/health_context/data/repositories/lucent_health_context_repository.dart`
- `Luminous/lib/features/health_context/domain/repositories/health_context_repository.dart`
- `Luminous/lib/features/mine/data/repositories/lucent_mine_repository.dart`
- `Luminous/lib/features/mine/presentation/mine_page.dart`
- `Luminous/lib/features/mine/presentation/providers/mine_dashboard_provider.dart`
- `Luminous/lib/features/mine/presentation/widgets/mine_dashboard_view.dart`
- `Luminous/lib/features/medicine/domain/entities/medicine_workspace.dart`
- `Luminous/lib/features/medicine/domain/repositories/medicine_workspace_repository.dart`
- `Luminous/lib/features/medicine/presentation/providers/medicine_workspace_provider.dart`
- `Luminous/lib/features/medicine/presentation/widgets/medicine_workspace_view.dart`
- `Luminous/lib/features/search/presentation/providers/search_provider.dart`
- `Luminous/lib/features/search/presentation/widgets/search_view.dart`
- `Luminous/lib/features/today/data/repositories/mock_today_repository.dart`
- `Luminous/lib/features/today/domain/entities/today_dashboard.dart`
- `Luminous/lib/features/today/presentation/providers/today_dashboard_provider.dart`
- `Luminous/lib/l10n/app_en.arb`
- `Luminous/lib/l10n/app_zh.arb`
- `Luminous/docs/MigrationLog.md`
- `Luminous/docs/OpenApi_Client.md`
- `Luminous/docs/Localization.md`
- `Luminous/docs/UI_Implementation_Plan.md`

Possible new Luminous files:

- `Luminous/lib/features/mine/presentation/pages/profile_edit_page.dart`
- `Luminous/lib/features/mine/presentation/pages/allergy_edit_page.dart`
- `Luminous/lib/features/mine/presentation/pages/condition_edit_page.dart`
- `Luminous/lib/features/mine/presentation/pages/current_medicine_edit_page.dart`
- `Luminous/lib/features/mine/presentation/providers/health_profile_form_provider.dart`
- `Luminous/lib/features/mine/presentation/providers/allergy_form_provider.dart`
- `Luminous/lib/features/mine/presentation/providers/condition_form_provider.dart`
- `Luminous/lib/features/mine/presentation/providers/current_medicine_form_provider.dart`
- `Luminous/lib/features/medicine/data/repositories/lucent_medicine_workspace_repository.dart`
- `Luminous/test/health_context_repository_test.dart`
- `Luminous/test/mine_edit_pages_test.dart`
- `Luminous/test/medicine_workspace_repository_test.dart`

## Timeline

| Day | Date | Task |
| --- | --- | --- |
| 1 | 2026-06-03 | Task 1: Baseline and dirty-work protection |
| 2 | 2026-06-04 | Task 2: Finish in-flight Settings preference sync |
| 3-4 | 2026-06-05 to 2026-06-06 | Task 3: Expand profile write API |
| 5-6 | 2026-06-07 to 2026-06-08 | Task 4: Add allergy and condition write APIs |
| 7-8 | 2026-06-09 to 2026-06-10 | Task 5: Add current-medicine write APIs and OpenAPI export |
| 9 | 2026-06-11 | Task 6: Regenerate Luminous client and expand health-context repository writes |
| 10-11 | 2026-06-12 to 2026-06-13 | Task 7: Add Mine edit flows |
| 12 | 2026-06-14 | Task 8: Connect Search add-to-current-medicines |
| 13 | 2026-06-15 | Task 9: Wire Medicine tab to real current medicines |
| 14 | 2026-06-16 | Task 10: Wire Today to safe real health-context signals |
| 15 | 2026-06-17 | Task 11: Regression, docs, and audit package |

---

## Task 1: Baseline and Dirty-Work Protection

**Files:**

- Read only unless documenting results in the evidence bundle.

**Intent:** establish what is already dirty and what already passes before DeepSeek changes anything.

- [ ] Run from `D:\25080\Documents\VSCodeProject\Lumos`:

```powershell
git -C Lucent status --short
git -C Luminous status --short
```

Expected:

- output may show existing dirty files
- DeepSeek must copy the exact output into the evidence bundle

- [ ] Read the required docs listed above.

Expected:

- DeepSeek can name the active backend as `Lucent`
- DeepSeek does not plan work in `Luminous/backend`

- [ ] Run Lucent targeted baseline from `Lucent`:

```powershell
pnpm test -- user-health-context.service.spec.ts --runInBand
pnpm test:e2e:ci -- user-health-context.e2e-spec.ts
```

Expected:

- exit code 0, or a copied pre-existing failure with the failing test name and message

- [ ] Run Luminous targeted baseline from `Luminous`:

```powershell
flutter gen-l10n
flutter test test/settings_page_test.dart test/settings_flow_test.dart test/widget_test.dart
flutter analyze lib/app lib/core/i18n lib/features/settings test/settings_page_test.dart test/settings_flow_test.dart test/widget_test.dart
```

Expected:

- exit code 0, or a copied pre-existing failure with the failing test name and message

- [ ] Confirm no code files were edited during this task.

Verification:

```powershell
git -C Lucent status --short
git -C Luminous status --short
```

Expected:

- same files as the first status check, except generated l10n files may be touched if `flutter gen-l10n` refreshed existing generated output

**Reviewer acceptance checklist:**

- baseline status is captured
- pre-existing failures are separated from new failures
- no destructive git command was used

---

## Task 2: Finish In-Flight Settings Preference Sync

**Files:**

- Modify only if needed:
  - `Luminous/lib/app/app.dart`
  - `Luminous/lib/core/i18n/app_locale.dart`
  - `Luminous/lib/features/settings/data/datasources/settings_profile_remote_data_source.dart`
  - `Luminous/lib/features/settings/data/providers/settings_profile_data_providers.dart`
  - `Luminous/lib/features/settings/presentation/pages/settings_page.dart`
  - `Luminous/lib/features/settings/presentation/pages/more_settings_page.dart`
  - `Luminous/lib/features/settings/presentation/providers/settings_profile_sync_provider.dart`
  - `Luminous/lib/features/settings/presentation/widgets/settings_components.dart`
  - `Luminous/lib/l10n/app_en.arb`
  - `Luminous/lib/l10n/app_zh.arb`
  - `Luminous/docs/Localization.md`
  - `Luminous/docs/OpenApi_Client.md`
  - `Luminous/docs/UI_Implementation_Plan.md`
  - `Luminous/docs/MigrationLog.md`
- Tests:
  - `Luminous/test/settings_page_test.dart`
  - `Luminous/test/settings_flow_test.dart`
  - `Luminous/test/widget_test.dart`

**Intent:** turn the current dirty Settings work into a known-good baseline before expanding API scope.

- [ ] Inspect the current diff:

```powershell
git -C Luminous diff -- lib/app lib/core/i18n lib/features/settings lib/l10n docs/Localization.md docs/OpenApi_Client.md docs/UI_Implementation_Plan.md docs/MigrationLog.md test/settings_page_test.dart test/settings_flow_test.dart test/widget_test.dart
```

Expected:

- locale/profile sync uses `PATCH /me/health-context/profile`
- theme and notification toggles stay local/device-side when Lucent has no matching write API
- visible text is in ARB, not hardcoded in page widgets

- [ ] If tests are missing for locale backfill or profile sync, add widget/provider tests that cover:
  - selecting `system` clears backend locale preference
  - selecting `zh-CN` or `en` writes the mapped backend locale
  - auth restore can backfill the local app locale from health-context profile when the backend value is supported

- [ ] Run from `Luminous`:

```powershell
flutter gen-l10n
flutter test test/settings_page_test.dart test/settings_flow_test.dart test/widget_test.dart
flutter analyze lib/app lib/core/i18n lib/features/settings test/settings_page_test.dart test/settings_flow_test.dart test/widget_test.dart
git diff --check -- lib/app lib/core/i18n lib/features/settings lib/l10n docs test/settings_page_test.dart test/settings_flow_test.dart test/widget_test.dart
```

Expected:

- all commands pass
- docs describe the exact supported backend preference fields

**Reviewer acceptance checklist:**

- no second locale source is introduced
- no backend support is claimed for theme or notification writes
- settings child pages keep standard back-arrow plus centered-title headers

---

## Task 3: Expand Lucent Profile Write API

**Files:**

- Modify:
  - `Lucent/src/user-health-context/dto/update-health-context-profile.dto.ts`
  - `Lucent/src/user-health-context/dto/health-context-response.dto.ts` only if response docs need enum/example updates
  - `Lucent/src/user-health-context/user-health-context.controller.ts`
  - `Lucent/src/user-health-context/user-health-context.service.ts`
  - `Lucent/src/user-health-context/user-health-context.service.spec.ts`
  - `Lucent/test/user-health-context.e2e-spec.ts`
  - `Lucent/docs/public/api-contract.md`
  - `Lucent/docs/backend-user-domain.md`
  - `Lucent/CHANGELOG.md`

**Intent:** allow Luminous Mine profile editing to persist the core fields already present in `UserProfile`.

**API contract:**

`PATCH /api/v1/me/health-context/profile` accepts partial updates for:

```json
{
  "birthDate": "1998-03-15",
  "sexAtBirth": "female",
  "heightCm": 168,
  "pregnancyState": "not_pregnant",
  "lactationState": "no",
  "bloodType": "O+",
  "locale": "zh-CN",
  "timezone": "Asia/Shanghai",
  "unitSystem": "metric",
  "onboardingCompleted": true
}
```

Rules:

- every field is optional
- `null` clears nullable profile fields except `onboardingCompleted`
- empty strings for `locale` and `timezone` clear the preference
- `birthDate` must be `YYYY-MM-DD`
- `heightCm` must be an integer in a medically plausible broad range, use `1..300`
- `onboardingCompleted: true` sets `onboardingCompletedAt` when it is missing
- `onboardingCompleted: false` clears `onboardingCompletedAt`
- unsupported enum values fail validation
- handler derives user id from JWT only

- [ ] Add DTO validation decorators for the new fields.
- [ ] Rename service method internally from preference-only semantics to profile update semantics.
- [ ] Keep the public route path stable as `PATCH /me/health-context/profile`.
- [ ] Add unit tests for:
  - setting profile fields
  - clearing nullable profile fields
  - onboarding completion true/false behavior
  - rejecting invalid date and enum values
- [ ] Add e2e coverage for an authenticated profile update returning the refreshed aggregate.
- [ ] Update docs and changelog.

Run from `Lucent`:

```powershell
pnpm test -- user-health-context.service.spec.ts --runInBand
pnpm test:e2e:ci -- user-health-context.e2e-spec.ts
pnpm lint:check
pnpm build
```

Expected:

- all commands pass
- response envelope remains `{ code, message, data }`
- no Prisma schema migration is required for this task

**Reviewer acceptance checklist:**

- profile update cannot target another user
- docs no longer say profile write only supports `locale / timezone / unitSystem`
- no new speculative profile fields are added

---

## Task 4: Add Allergy and Condition Write APIs

**Files:**

- Create:
  - `Lucent/src/user-health-context/dto/create-health-context-allergy.dto.ts`
  - `Lucent/src/user-health-context/dto/update-health-context-allergy.dto.ts`
  - `Lucent/src/user-health-context/dto/create-health-context-condition.dto.ts`
  - `Lucent/src/user-health-context/dto/update-health-context-condition.dto.ts`
- Modify:
  - `Lucent/src/user-health-context/dto/index.ts`
  - `Lucent/src/user-health-context/user-health-context.controller.ts`
  - `Lucent/src/user-health-context/user-health-context.service.ts`
  - `Lucent/src/user-health-context/user-health-context.service.spec.ts`
  - `Lucent/test/user-health-context.e2e-spec.ts`
  - `Lucent/docs/public/api-contract.md`
  - `Lucent/docs/backend-user-domain.md`
  - `Lucent/CHANGELOG.md`

**Intent:** let users create and maintain allergy and condition records through authenticated, user-scoped APIs.

**API contract:**

```text
POST   /api/v1/me/health-context/allergies
PATCH  /api/v1/me/health-context/allergies/:id
DELETE /api/v1/me/health-context/allergies/:id

POST   /api/v1/me/health-context/conditions
PATCH  /api/v1/me/health-context/conditions/:id
DELETE /api/v1/me/health-context/conditions/:id
```

All write responses return the refreshed `HealthContextResponseData` aggregate in the normal envelope.

Allergy create payload:

```json
{
  "kind": "drug",
  "label": "Penicillin",
  "reaction": "Rash",
  "severity": "moderate",
  "note": "Avoid completely",
  "recordedAt": "2026-06-03T09:00:00.000Z"
}
```

Condition create payload:

```json
{
  "label": "Asthma",
  "status": "active",
  "diagnosedAt": "2024-02-01",
  "note": "Triggered during pollen season"
}
```

Rules:

- `label` is required and trimmed
- labels must not exceed 120 characters
- note/reaction fields must not exceed 1000 characters
- `DELETE /allergies/:id` sets `isActive=false`; it does not hard-delete
- `DELETE /conditions/:id` sets `status=resolved` and sets `resolvedAt` to the current UTC date when missing; it does not hard-delete
- update/delete must be scoped to the current user
- missing or foreign ids return 404

- [ ] Add DTOs and exports.
- [ ] Add controller methods with Swagger decorators.
- [ ] Add service methods for create/update/deactivate/resolve.
- [ ] Add unit tests for create, update, delete semantics, user scoping, and missing id behavior.
- [ ] Add e2e tests for happy path and foreign-id protection.
- [ ] Update docs and changelog.

Run from `Lucent`:

```powershell
pnpm test -- user-health-context.service.spec.ts --runInBand
pnpm test:e2e:ci -- user-health-context.e2e-spec.ts
pnpm lint:check
pnpm build
```

Expected:

- all commands pass
- no hard delete is used for allergy or condition removal

**Reviewer acceptance checklist:**

- aggregate excludes inactive allergies after deletion
- resolved conditions still follow the response contract
- validation errors use the existing Lucent envelope/error behavior

---

## Task 5: Add Current-Medicine Write APIs And Export OpenAPI

**Files:**

- Create:
  - `Lucent/src/user-health-context/dto/create-current-medicine.dto.ts`
  - `Lucent/src/user-health-context/dto/update-current-medicine.dto.ts`
- Modify:
  - `Lucent/src/user-health-context/dto/index.ts`
  - `Lucent/src/user-health-context/user-health-context.controller.ts`
  - `Lucent/src/user-health-context/user-health-context.service.ts`
  - `Lucent/src/user-health-context/user-health-context.service.spec.ts`
  - `Lucent/test/user-health-context.e2e-spec.ts`
  - `Lucent/docs/public/api-contract.md`
  - `Lucent/docs/backend-user-domain.md`
  - `Lucent/docs/openapi.json`
  - `Lucent/CHANGELOG.md`

**Intent:** make the user's current medicine list writable without building reminder scheduling.

**API contract:**

```text
POST   /api/v1/me/health-context/current-medicines
PATCH  /api/v1/me/health-context/current-medicines/:id
DELETE /api/v1/me/health-context/current-medicines/:id
```

Create payload:

```json
{
  "source": "drugbank",
  "sourceRefId": "DB01050",
  "displayName": "Ibuprofen",
  "strengthText": "200 mg",
  "doseText": "1 tablet after meals",
  "route": "oral",
  "startedAt": "2026-06-03",
  "note": "Use only when needed for headaches"
}
```

Rules:

- `displayName` is required and trimmed
- `source` must be one of `drugbank`, `cn`, or `manual`
- `sourceRefId` is required for `drugbank` and `cn`
- `sourceRefId` may be null for `manual`
- `startedAt` and `endedAt` use `YYYY-MM-DD`
- `DELETE /current-medicines/:id` sets `isCurrent=false` and sets `endedAt` to the current UTC date when missing
- no reminder, notification, or dose schedule API is added in this task
- all write responses return the refreshed aggregate

- [ ] Add DTOs and exports.
- [ ] Add controller methods.
- [ ] Add service methods for create/update/deactivate.
- [ ] Add tests for source validation, delete semantics, and user scoping.
- [ ] Update docs and changelog.
- [ ] Export OpenAPI from `Lucent`:

```powershell
pnpm export:openapi
```

Run from `Lucent`:

```powershell
pnpm test -- user-health-context.service.spec.ts --runInBand
pnpm test:e2e:ci -- user-health-context.e2e-spec.ts
pnpm lint:check
pnpm build
git diff --check -- src test docs CHANGELOG.md
```

Expected:

- all commands pass
- `Lucent/docs/openapi.json` includes the new health-context write operations

**Reviewer acceptance checklist:**

- current medicine removal is non-destructive
- route names use `current-medicines`, matching the existing response field
- no scheduling behavior is implied in API docs

---

## Task 6: Regenerate Luminous Client And Add Health-Context Write Repository Methods

**Files:**

- Modify generated files under:
  - `Luminous/packages/lucent_openapi/`
- Modify:
  - `Luminous/lib/core/network/lucent_dio_client.dart`
  - `Luminous/lib/core/network/lucent_network_providers.dart`
  - `Luminous/lib/features/health_context/data/datasources/health_context_remote_data_source.dart`
  - `Luminous/lib/features/health_context/data/mappers/health_context_mapper.dart`
  - `Luminous/lib/features/health_context/data/providers/health_context_data_providers.dart`
  - `Luminous/lib/features/health_context/data/repositories/lucent_health_context_repository.dart`
  - `Luminous/lib/features/health_context/domain/repositories/health_context_repository.dart`
  - `Luminous/docs/OpenApi_Client.md`
  - `Luminous/docs/MigrationLog.md`
- Test:
  - `Luminous/test/health_context_repository_test.dart`

**Intent:** expose the new Lucent write APIs to feature code without leaking generated DTOs into widgets.

- [ ] Run from `Luminous`:

```powershell
dart run tool/regenerate_lucent_openapi.dart
```

Expected:

- command completes using `Lucent/docs/openapi.json`
- generated package constraints remain normalized by the wrapper

- [ ] Add domain-facing write methods to `HealthContextRepository`:

```dart
Future<HealthContextSnapshot> updateProfile(HealthProfileUpdateInput input);
Future<HealthContextSnapshot> createAllergy(AllergyWriteInput input);
Future<HealthContextSnapshot> updateAllergy(String id, AllergyWriteInput input);
Future<HealthContextSnapshot> deactivateAllergy(String id);
Future<HealthContextSnapshot> createCondition(ConditionWriteInput input);
Future<HealthContextSnapshot> updateCondition(String id, ConditionWriteInput input);
Future<HealthContextSnapshot> resolveCondition(String id);
Future<HealthContextSnapshot> createCurrentMedicine(CurrentMedicineWriteInput input);
Future<HealthContextSnapshot> updateCurrentMedicine(String id, CurrentMedicineWriteInput input);
Future<HealthContextSnapshot> deactivateCurrentMedicine(String id);
```

- [ ] Define the input models in the health-context domain layer or a focused data input file. Keep generated DTOs out of presentation code.
- [ ] Map repository inputs to generated DTOs in the data layer.
- [ ] Invalidate or refresh `healthContextSnapshotProvider` after successful writes.
- [ ] Add repository tests for one profile update, one allergy write, one condition write, and one current-medicine write.
- [ ] Update docs.

Run from `Luminous`:

```powershell
flutter test test/health_context_repository_test.dart
flutter analyze lib/core/network lib/features/health_context test/health_context_repository_test.dart
git diff --check -- packages/lucent_openapi lib/core/network lib/features/health_context docs test/health_context_repository_test.dart
```

Expected:

- all commands pass
- widgets do not import generated Lucent DTO classes directly

**Reviewer acceptance checklist:**

- OpenAPI regeneration used the wrapper script
- no ad-hoc generated package repair steps are left undocumented
- repository methods return refreshed domain snapshots

---

## Task 7: Add Mine Edit Flows

**Files:**

- Create:
  - `Luminous/lib/features/mine/presentation/pages/profile_edit_page.dart`
  - `Luminous/lib/features/mine/presentation/pages/allergy_edit_page.dart`
  - `Luminous/lib/features/mine/presentation/pages/condition_edit_page.dart`
  - `Luminous/lib/features/mine/presentation/pages/current_medicine_edit_page.dart`
  - `Luminous/lib/features/mine/presentation/providers/health_profile_form_provider.dart`
  - `Luminous/lib/features/mine/presentation/providers/allergy_form_provider.dart`
  - `Luminous/lib/features/mine/presentation/providers/condition_form_provider.dart`
  - `Luminous/lib/features/mine/presentation/providers/current_medicine_form_provider.dart`
  - `Luminous/test/mine_edit_pages_test.dart`
- Modify:
  - `Luminous/lib/app/router.dart`
  - `Luminous/lib/features/mine/presentation/mine_page.dart`
  - `Luminous/lib/features/mine/presentation/widgets/mine_dashboard_view.dart`
  - `Luminous/lib/features/mine/presentation/widgets/mine_components.dart`
  - `Luminous/lib/l10n/app_en.arb`
  - `Luminous/lib/l10n/app_zh.arb`
  - `Luminous/docs/Localization.md`
  - `Luminous/docs/UI_Implementation_Plan.md`
  - `Luminous/docs/MigrationLog.md`
- Tests:
  - `Luminous/test/mine_page_test.dart`
  - `Luminous/test/mine_edit_pages_test.dart`

**Intent:** let signed-in users edit the health-context data that Mine already displays.

Routes:

```text
/mine/profile
/mine/allergies/new
/mine/allergies/:id
/mine/conditions/new
/mine/conditions/:id
/mine/current-medicines/new
/mine/current-medicines/:id
```

UI rules:

- child pages use a standard app header: left back arrow and centered title
- no hero headers, explanatory paragraphs, or marketing copy
- all visible text comes from ARB
- signed-out access redirects to `/login` or shows the existing auth-required state consistently
- routine success/failure feedback uses shared toast patterns already accepted in the app
- destructive-looking actions use non-destructive backend semantics from Tasks 4 and 5

Form scope:

- Profile: birth date, sex at birth, height, pregnancy state, lactation state, blood type, unit system
- Allergy: kind, label, reaction, severity, note
- Condition: label, status, diagnosed date, resolved date, note
- Current medicine: source, source ref id, display name, strength, dose, route, start date, end date, note

- [ ] Add routes.
- [ ] Add form providers with explicit saving/error/loading states.
- [ ] Add pages using existing design tokens and app state views.
- [ ] Wire Mine dashboard entry taps to the relevant routes.
- [ ] Refresh Mine/health-context providers after successful saves.
- [ ] Add widget tests for profile save, allergy save, condition save, and current medicine save using fake repository overrides.
- [ ] Update ARB, generate l10n, and update docs.

Run from `Luminous`:

```powershell
flutter gen-l10n
flutter test test/mine_page_test.dart test/mine_edit_pages_test.dart
flutter analyze lib/app lib/features/mine lib/features/health_context test/mine_page_test.dart test/mine_edit_pages_test.dart
git diff --check -- lib/app lib/features/mine lib/features/health_context lib/l10n docs test/mine_page_test.dart test/mine_edit_pages_test.dart
```

Expected:

- all commands pass
- Mine still renders signed-out state
- Mine signed-in state can navigate to edit pages

**Reviewer acceptance checklist:**

- no code is added under legacy Flutter folders
- no page-local `SnackBar` pattern is introduced for routine feedback
- long labels fit in mobile-width widget tests

---

## Task 8: Connect Search Add-To-Current-Medicines

**Files:**

- Modify:
  - `Luminous/lib/features/search/presentation/providers/search_provider.dart`
  - `Luminous/lib/features/search/presentation/widgets/search_view.dart`
  - `Luminous/lib/features/search/presentation/widgets/search_parts.dart`
  - `Luminous/lib/features/health_context/data/providers/health_context_data_providers.dart`
  - `Luminous/lib/l10n/app_en.arb`
  - `Luminous/lib/l10n/app_zh.arb`
  - `Luminous/docs/MigrationLog.md`
  - `Luminous/docs/Localization.md`
- Tests:
  - `Luminous/test/search_page_test.dart`

**Intent:** turn the search result action into a real "add to current medicines" write when signed in.

Behavior:

- If signed in, tapping add creates a current medicine with:
  - `source` from selected search source
  - `sourceRefId` from result id
  - `displayName` from result name
  - optional source payload only if the backend DTO supports it
- If signed out, tapping add routes to `/login` or shows the existing auth-required pattern.
- The action does not create reminders.
- The action does not claim interaction safety analysis exists.
- After success, health-context and medicine workspace providers are refreshed.

- [ ] Add provider method for add-to-current-medicines.
- [ ] Add UI loading/disabled state for the tapped action.
- [ ] Add ARB strings for success, auth-required, and failure labels.
- [ ] Add widget tests for signed-in success and signed-out behavior.
- [ ] Update docs.

Run from `Luminous`:

```powershell
flutter gen-l10n
flutter test test/search_page_test.dart
flutter analyze lib/features/search lib/features/health_context test/search_page_test.dart
git diff --check -- lib/features/search lib/features/health_context lib/l10n docs test/search_page_test.dart
```

Expected:

- all commands pass
- no mock add-to-drugbox claim remains on the real search action

**Reviewer acceptance checklist:**

- result source is preserved
- generated DTOs do not leak into widgets
- no reminder API is called

---

## Task 9: Wire Medicine Tab To Real Current Medicines

**Files:**

- Create:
  - `Luminous/lib/features/medicine/data/repositories/lucent_medicine_workspace_repository.dart`
  - `Luminous/test/medicine_workspace_repository_test.dart`
- Modify:
  - `Luminous/lib/features/medicine/domain/entities/medicine_workspace.dart`
  - `Luminous/lib/features/medicine/domain/repositories/medicine_workspace_repository.dart`
  - `Luminous/lib/features/medicine/presentation/providers/medicine_workspace_provider.dart`
  - `Luminous/lib/features/medicine/presentation/widgets/medicine_workspace_view.dart`
  - `Luminous/lib/features/medicine/presentation/widgets/medicine_workspace_parts.dart`
  - `Luminous/lib/features/medicine/presentation/widgets/medicine_copy.dart`
  - `Luminous/lib/l10n/app_en.arb`
  - `Luminous/lib/l10n/app_zh.arb`
  - `Luminous/docs/UI_Implementation_Plan.md`
  - `Luminous/docs/MigrationLog.md`
  - `Luminous/docs/Localization.md`
- Tests:
  - `Luminous/test/medicine_page_test.dart`
  - `Luminous/test/medicine_workspace_repository_test.dart`

**Intent:** show the user's actual current medicines in the Medicine tab while keeping unsupported reminder/scan features visibly non-real.

Behavior:

- Medicine hero current count comes from `HealthContextSnapshot.currentMedicines`.
- Current medicine list uses real display name, strength, dose, route, source, start/end date, and note when present.
- Empty state is calm and action-oriented, pointing to search/manual add.
- Existing scan/barcode/prescription quick actions remain disabled, toast-only, or clearly local placeholders.
- No fake dose time is shown as real if Lucent has no dose schedule.
- Stock/refill warnings remain mock-only unless derived from current backend fields.

- [ ] Add Lucent-backed workspace repository that depends on health context.
- [ ] Preserve existing mock repository only for unsupported static panels.
- [ ] Update entity shape so real current medicines are not forced into enum-only mock copy.
- [ ] Add repository tests for empty state and two current medicines.
- [ ] Update widget tests.
- [ ] Update docs and l10n.

Run from `Luminous`:

```powershell
flutter gen-l10n
flutter test test/medicine_workspace_repository_test.dart test/medicine_page_test.dart
flutter analyze lib/features/medicine lib/features/health_context test/medicine_workspace_repository_test.dart test/medicine_page_test.dart
git diff --check -- lib/features/medicine lib/features/health_context lib/l10n docs test/medicine_workspace_repository_test.dart test/medicine_page_test.dart
```

Expected:

- all commands pass
- Medicine page no longer presents static mock medicines as the user's real plan

**Reviewer acceptance checklist:**

- unsupported reminder scheduling remains out of scope
- real current medicine values flow through runtime strings safely
- mobile and desktop layouts retain stable dimensions

---

## Task 10: Wire Today To Safe Real Health-Context Signals

**Files:**

- Modify:
  - `Luminous/lib/features/today/domain/entities/today_dashboard.dart`
  - `Luminous/lib/features/today/data/repositories/mock_today_repository.dart`
  - `Luminous/lib/features/today/domain/repositories/today_repository.dart`
  - `Luminous/lib/features/today/presentation/providers/today_dashboard_provider.dart`
  - `Luminous/lib/features/today/presentation/widgets/today_dashboard_view.dart`
  - `Luminous/lib/features/today/presentation/widgets/today_components.dart`
  - `Luminous/lib/l10n/app_en.arb`
  - `Luminous/lib/l10n/app_zh.arb`
  - `Luminous/docs/UI_Implementation_Plan.md`
  - `Luminous/docs/MigrationLog.md`
- Tests:
  - `Luminous/test/today_page_test.dart`

**Intent:** let Today use the health-context data that is safe and real, without pretending records/reminders exist.

Behavior:

- User greeting/auth state can remain existing behavior.
- Current medicine count comes from health context.
- Next medicine label can use the first current medicine only when there is no dose schedule claim.
- Missing core profile fields can drive a profile-completion nudge.
- Water, vitals, meals, mood, environment, and timeline remain mock/local until APIs exist.
- Text must not imply diagnosis, treatment, or AI recommendation.

- [ ] Add or adapt a Today repository that can merge health-context snapshot with existing mock surfaces.
- [ ] Keep unsupported cards visually consistent but not falsely real.
- [ ] Add provider invalidation when health context changes.
- [ ] Update widget tests for signed-in health-context values and signed-out fallback.
- [ ] Update docs and l10n.

Run from `Luminous`:

```powershell
flutter gen-l10n
flutter test test/today_page_test.dart
flutter analyze lib/features/today lib/features/health_context test/today_page_test.dart
git diff --check -- lib/features/today lib/features/health_context lib/l10n docs test/today_page_test.dart
```

Expected:

- all commands pass
- Today displays real current-medicine count when health context is available

**Reviewer acceptance checklist:**

- no backend records API is invented
- no fake dose time is presented as backend-backed
- error/loading states use shared app state views or existing accepted skeleton patterns

---

## Task 11: Regression, Docs, And Audit Package

**Files:**

- Modify only docs that need final status correction:
  - `Lucent/README.md`
  - `Lucent/docs/README.md`
  - `Lucent/docs/public/api-contract.md`
  - `Lucent/docs/backend-user-domain.md`
  - `Lucent/CHANGELOG.md`
  - `Luminous/README.md`
  - `Luminous/docs/README.md`
  - `Luminous/docs/UI_Implementation_Plan.md`
  - `Luminous/docs/OpenApi_Client.md`
  - `Luminous/docs/Localization.md`
  - `Luminous/docs/MigrationLog.md`

**Intent:** leave the half-month work reviewable, documented, and regression-checked.

- [ ] Run from `Lucent`:

```powershell
pnpm lint:check
pnpm build
pnpm test:ci
pnpm test:e2e:ci
git diff --check
```

Expected:

- all commands pass

- [ ] Run from `Luminous`:

```powershell
flutter gen-l10n
flutter analyze
flutter test
git diff --check
```

Expected:

- all commands pass

- [ ] Review docs for drift:
  - API contract lists every implemented health-context write endpoint.
  - OpenAPI client doc says regeneration used `dart run tool/regenerate_lucent_openapi.dart`.
  - UI plan distinguishes real data from mock/local surfaces.
  - Migration log has newest entry at the top.
  - Localization doc mentions any newly added copy scope.

- [ ] Prepare final audit summary with:
  - completed tasks
  - commands run
  - pass/fail result
  - important files touched
  - known remaining mock surfaces
  - risks and follow-up suggestions

**Reviewer acceptance checklist:**

- full Lucent checks pass
- full Luminous checks pass
- docs do not overclaim scan/OCR/reminder/records support
- no secrets or local-only paths are introduced into committed source

---

## Parallelization Guidance

Default: do not run implementation agents in parallel because `health_context`, `mine`, `medicine`, docs, and OpenAPI generation overlap.

Safe parallel windows:

- After Task 5 is accepted:
  - Agent A can work on Task 6 client/regeneration.
  - Agent B can only draft frontend UI tests for Task 7 without editing production files.
- After Task 7 is accepted:
  - Agent A can work on Task 8 Search integration.
  - Agent B can work on Task 9 Medicine workspace if both agree on the health-context repository interface from Task 6.

Unsafe parallel edits:

- Two agents editing `Luminous/lib/features/health_context/**` at the same time.
- Two agents editing generated `packages/lucent_openapi/**`.
- One agent changing Lucent API contract while another regenerates the frontend client.
- Any agent editing docs status while implementation is still changing behavior.

## Stop Conditions

Stop and ask the human before continuing if any of these occur:

- a task requires a destructive migration or data deletion beyond the non-destructive semantics above
- a task requires a new paid external service
- a task needs production deployment or credentials
- OpenAPI generation breaks in a way the wrapper cannot repair
- baseline tests fail in a way that makes it impossible to identify new regressions
- a required dependency is missing and adding it would change production dependencies
- DeepSeek needs to overwrite unrelated dirty files

## Final Codex Audit Checklist

Codex should accept the full fifteen-day delivery only if all statements are true:

1. Lucent exposes authenticated write APIs for profile, allergies, conditions, and current medicines.
2. Lucent write APIs are user-scoped and covered by tests.
3. Lucent docs and OpenAPI match the implemented behavior.
4. Luminous client was regenerated through `dart run tool/regenerate_lucent_openapi.dart`.
5. Luminous widgets do not import generated Lucent DTOs directly.
6. Mine can edit persisted health-context data.
7. Search can add a medicine to current medicines without claiming reminder support.
8. Medicine tab uses real current medicines and does not present mock medicine plans as real.
9. Today uses only safe real health-context signals and keeps unsupported surfaces clearly bounded.
10. All new visible text is in ARB and generated localizations are refreshed.
11. `flutter analyze` and `flutter test` pass.
12. `pnpm lint:check`, `pnpm build`, `pnpm test:ci`, and `pnpm test:e2e:ci` pass.
13. Docs were updated before final reporting.
14. No unrelated dirty work was reverted or absorbed silently.

## Known Remaining Work After This Plan

These items intentionally remain for later plans:

- reminder schedules and notifications backed by Lucent
- records/timeline APIs for meals, vitals, mood, symptoms, water, and activity
- scan/OCR/barcode execution
- AI explanation layer with source-grounded boundaries
- More tab real tools/device/emergency integrations
- production deployment and release packaging

