# Lumos Error-Prevention DeepSeek Review Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to execute this plan task-by-task. This is a guardrail plan, not a feature backlog. Attach these gates to the next feature plan and return evidence for each gate.

**Goal:** Prevent the mistakes found during the 2026-06-04 DeepSeek follow-up review from recurring: branch-baseline drift, incomplete backend contract bundles, stale OpenAPI/client generation, generated DTO leakage, nullable-write loss, cross-page provider staleness, status-enum inconsistency, generated import collisions, and weak handoff evidence.

**Owner docs:** `Luminous/docs/Project_Error_Audit.md`, `Luminous/docs/OpenApi_Client.md`, `Luminous/docs/MigrationLog.md`, `Lucent/docs/public/api-contract.md`, `Lucent/docs/backend-user-domain.md`, `Lucent/CHANGELOG.md`.

---

## Baseline

- Created on: 2026-06-04.
- Current Lucent branch: `dev`.
- Current Luminous branch: `refactor`.
- Latest reviewed Lucent fix: `038f225 fix(health-context): 恢复写接口并补齐用药打卡验证`.
- Latest reviewed Luminous fix: `f6237a1 fix(medicine): 修复用药打卡与今日状态联动`.
- Relevant audit IDs: `ERR-BE-018`, `ERR-BE-019`, `ERR-BE-020`, `ERR-BE-022`, `ERR-FE-011`, `ERR-FE-012`, `ERR-FE-013`, `ERR-FE-029`, `ERR-FE-030`, `ERR-FE-031`, `ERR-FE-032`, `ERR-XR-003`, `ERR-XR-005`.

## Required Reading

Before executing any future feature plan, read:

- `Lucent/AGENTS.md`
- `Lucent/docs/README.md`
- `Lucent/docs/public/api-contract.md`
- `Lucent/docs/backend-user-domain.md`
- `Luminous/AGENTS.md`
- `Luminous/docs/README.md`
- `Luminous/docs/Project_Error_Audit.md`
- `Luminous/docs/OpenApi_Client.md`
- The active feature plan being executed

## Evidence Bundle

Every DeepSeek task must return this exact bundle. "Done" without this bundle is rejected.

```text
Task:
Status: DONE / DONE_WITH_CONCERNS / BLOCKED
Lucent branch/status/log:
Luminous branch/status/log:
Touched files:
Behavior changed:
Commands run:
Command results:
OpenAPI paths/schemas:
Generated artifacts:
Provider invalidation:
Nullable write coverage:
Auth / ownership coverage:
Docs updated:
Risks / reviewer notes:
Commit:
```

Rules:

- If a command was not run, write `not run` and the exact reason.
- Do not report test counts from memory. Copy the current command result summary.
- Do not use relative time such as "today" in long-lived docs; use `YYYY-MM-DD`.
- Do not push, force-push, reset, or rewrite history.

---

## Gate 1: Active Branch And Dirty-Work Baseline

**Purpose:** stop work from being reviewed against the wrong branch or stale task summary.

### Commands

```bash
git -C Lucent branch --show-current
git -C Lucent status --short --branch
git -C Lucent log -1 --oneline
git -C Luminous branch --show-current
git -C Luminous status --short --branch
git -C Luminous log -1 --oneline
git -C Lucent diff --check
git -C Luminous diff --check
```

### Reject If

- Branch is not the expected branch for the feature plan.
- Dirty files exist and are not named in the evidence bundle.
- Diff check fails before editing.
- The task summary references commits that are not reachable from the active branch.

## Gate 2: Backend Contract Bundle

**Purpose:** API work is not complete unless schema, migration, implementation, docs, OpenAPI, and tests move together.

### Required For Backend API Changes

- Prisma model/enum and migration, if persistence changes.
- DTO validation for request and response envelope.
- Controller decorators and OpenAPI response schemas.
- Unit tests for service behavior.
- E2E tests for auth required, user isolation, response envelope, and edge cases.
- `Lucent/docs/public/api-contract.md`, `Lucent/docs/backend-user-domain.md`, and `Lucent/CHANGELOG.md`.

### Commands

```bash
cd Lucent
pnpm dev:stack:up
pnpm db:migrate:all
pnpm exec prisma validate
pnpm lint:check
pnpm build
pnpm test:ci
pnpm test:e2e:ci
pnpm export:openapi
```

### Reject If

- A new persistent API has no migration.
- A controller returns an untyped response in OpenAPI.
- `docs/openapi.json` does not include the new/changed path.
- Tests skip auth, user isolation, create/update branches, or soft-delete behavior for user-owned data.

## Gate 3: OpenAPI Client Regeneration

**Purpose:** prevent Lucent/Luminous contract drift and generated-client toolchain breakage.

### Commands

```bash
cd Lucent
pnpm export:openapi
cd ../Luminous
dart run tool/regenerate_lucent_openapi.dart
git -C ../Luminous diff --check
flutter analyze
flutter test
```

### Additional Checks

```bash
cd Luminous
rg "package:lucent_openapi" lib test
rg "lucent_openapi" lib/features/*/domain lib/features/*/presentation
```

### Reject If

- Client was regenerated with ad-hoc `npx` or direct generator commands.
- Generated Markdown has trailing whitespace or new blank-line EOF failures.
- Domain or presentation files import generated DTOs.
- Generated package warnings are not listed in the evidence bundle.

## Gate 4: Nullable Write Semantics

**Purpose:** prevent generated DTO serializers from dropping explicit `null` clears.

### Required Tests

For every nullable PATCH/write field:

- omitted field means no change.
- explicit `null` means clear.
- concrete value means update.

### Commands

```bash
cd Luminous
rg "includeIfNull|toJson\(|data:" lib/features test
flutter test test
```

### Reject If

- A generated write DTO with `includeIfNull: false` is used for a write where explicit clear matters.
- Tests do not inspect the outgoing payload or backend persisted value.

## Gate 5: Cross-Feature State Consistency

**Purpose:** prevent Medicine, Today, and Record from showing different truths after a write.

### Required Matrix

| Write action | Must refresh |
| --- | --- |
| Record create/edit/delete | Record dashboard, Today dashboard |
| Medicine taken/skipped/edit | Medicine workspace, Today dashboard |
| Health-context current medicine write/delete | Health context snapshot, Medicine workspace, Today dashboard when medication summary depends on it |
| Search add-to-current-medicines | Health context snapshot, Medicine workspace |

### Commands

```bash
cd Luminous
rg "invalidate\(" lib/features
flutter test test/record_page_test.dart test/medicine_workspace_repository_test.dart test/shell_page_test.dart
flutter test
```

### Reject If

- The evidence bundle says "provider invalidation: not applicable" for a signed-in write without explaining why.
- Status labels/enums differ between data, domain, UI copy, and Today summary.
- `skipped`/`taken`/`pending` or any future dose-log status is mapped in one feature but not the others.

## Gate 6: Auth, Ownership, And Signed-Out Paths

**Purpose:** prevent protected API loops and user data leakage.

### Backend Required Tests

- Unauthenticated request returns auth error.
- User A cannot read/update/delete User B data.
- Linked resources, such as `currentMedicineId`, are checked against the current user.

### Frontend Required Tests

- Signed-out write routes to `/login` or stable signed-out state.
- Signed-out read does not repeatedly call protected health-context/record/medicine APIs.

### Commands

```bash
cd Lucent
pnpm test:e2e:ci
cd ../Luminous
flutter test
```

### Reject If

- Any user-owned endpoint lacks user isolation coverage.
- A signed-out widget test only checks a toast and not the route/state.

## Gate 7: UI, Localization, And Layout

**Purpose:** prevent unlocalized text, nested scroll failures, and unsupported product claims.

### Commands

```bash
cd Luminous
flutter gen-l10n
flutter analyze
flutter test
rg "MaterialPageRoute|Navigator\.push|Navigator\.of\(context\)\.push" lib
rg "catch \(_\) \{\}" lib
rg "reminder|push|OCR|barcode|diagnos|treat|recommend" docs lib
```

### Reject If

- New visible text is not in ARB.
- A page in a scrollable shell nests an unbounded vertical scrollable.
- Manual dose logging is described as real reminder scheduling or push notification execution.
- Daily-record summaries are described as diagnosis, treatment, or medical advice.

## Gate 8: Final Handoff And Commit Hygiene

**Purpose:** make the final state reviewable without relying on memory.

### Commands

```bash
git -C Lucent diff --check
git -C Luminous diff --check
git -C Lucent status --short --branch
git -C Luminous status --short --branch
git -C Lucent log --oneline -n 5
git -C Luminous log --oneline -n 5
```

### Reject If

- Commit contains unrelated files, local secrets, `.env`, generated noise unrelated to the task, or docs-only claims that do not match code.
- The final evidence omits commands that failed earlier and were later fixed.
- The final summary does not name remaining unsupported features.

---

## Codex Review Order

1. Verify branch/status/log evidence first.
2. Inspect backend contract bundle if Lucent changed.
3. Inspect OpenAPI diff and Luminous regenerated client if API changed.
4. Search for generated DTO leakage and nullable-write risks.
5. Check provider invalidation matrix for each write path.
6. Run targeted tests, then full regression if shared behavior changed.
7. Confirm docs say what is real, what is mock/static, and what remains unsupported.

## Dispatch Template

```text
Use superpowers:executing-plans.
Before executing Task <N> from <active feature plan>, apply every relevant gate from:
Luminous/docs/superpowers/plans/2026-06-04-lumos-error-prevention-plan.md

Return the required evidence bundle.
Do not start the next task until Codex accepts this one.
```
