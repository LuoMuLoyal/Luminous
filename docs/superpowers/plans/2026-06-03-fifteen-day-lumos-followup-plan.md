# Lumos Follow-Up Fifteen-Day DeepSeek Delivery Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to execute this plan task-by-task. Use `superpowers:subagent-driven-development` only when splitting reviewable backend/frontend work after Codex accepts the task boundary. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** From 2026-06-04 through 2026-06-18, move Lumos from the completed health-context write baseline to a reviewable daily-record and medicine-adherence loop: Lucent stores user-owned daily records and dose logs, Luminous can read/write them through stable domain boundaries, and Today/Record/Medicine show real safe signals without pretending to provide medical advice.

**Architecture:** Keep `Lucent` as the only active backend and `Luminous` as the Flutter client. Use NestJS modules, Prisma 7 migrations, OpenAPI export, generated `lucent_openapi`, Riverpod repositories/providers, GoRouter, and Luminous domain input objects. Do not add code under legacy Flutter folders or `Luminous/backend`.

**Tech Stack:** NestJS 11, Prisma 7, PostgreSQL, Redis, Jest, Supertest, Flutter, Riverpod, GoRouter, Dio, generated `lucent_openapi`, Flutter l10n, `flutter_test`.

---

## Plan Ownership

- Created on: 2026-06-03.
- Covered window: 2026-06-04 to 2026-06-18.
- Executor: DeepSeek or another implementation agent.
- Reviewer: Codex.
- Repository layout: `Lucent` and `Luminous` are separate git repositories under `D:\25080\Documents\VSCodeProject\Lumos`; the workspace root is not a git repository.

## Current Baseline

As of 2026-06-03 after Codex post-audit fixes:

- Lucent latest relevant commit: `8f5bd91 fix(user-health-context): 补齐profile创建完成时间`.
- Luminous latest relevant commit: `a13408d fix(health_context): 收紧写入边界和编辑流程`.
- Health-context profile/allergy/condition/current-medicine write APIs exist and have unit/e2e coverage.
- Luminous health-context write inputs live in `lib/features/health_context/domain/entities/health_context_write_inputs.dart`.
- Luminous write payloads use raw Dio JSON maps for explicit `null` preservation. Generated OpenAPI write DTOs must not leak into domain or presentation code.
- Search add-to-current-medicines now handles signed-out routing, signed-in writes, and provider invalidation.
- Mine dashboard routes to real profile/allergy/condition/current-medicine edit flows.
- Lucent currently has no Prisma models or APIs for daily records, timeline entries, medicine dose logs, real reminder schedules, OCR, scan upload, or push notification execution.
- Luminous Record and More remain mock-oriented. Today uses health-context medicines only for the safe real subset.

## Lessons From The Previous DeepSeek Run

Every task in this plan must apply these rules:

- Generated DTOs are data-layer response/mapping details. Domain repositories and Flutter widgets use local domain entities or input classes.
- Nullable writes need explicit tests for three states: omitted/no change, `null`/clear, and concrete value/update.
- Any backend `upsert` behavior must test both `create` and `update` branches.
- Any signed-in write path must have a signed-out branch test and must invalidate every affected Riverpod provider.
- UI pages inside `PageScaffoldShell(scrollable: true)` must not nest vertical `ListView` or other unbounded scrollables.
- Route wiring is incomplete until a widget test proves the tap opens the intended route or login page.
- A task is not done until docs and generated artifacts are updated in the same task or in its explicitly paired regeneration task.

## Required Reading Before Editing

Read these files before Task 1, and re-read the closest docs before editing a module:

- `Lucent/AGENTS.md`
- `Lucent/README.md`
- `Lucent/docs/README.md`
- `Lucent/docs/environment.md`
- `Lucent/docs/public/ROADMAP.md`
- `Lucent/docs/public/api-contract.md`
- `Lucent/docs/backend-user-domain.md`
- `Lucent/prisma/schema.prisma`
- `Luminous/AGENTS.md`
- `Luminous/README.md`
- `Luminous/docs/README.md`
- `Luminous/docs/UI_Implementation_Plan.md`
- `Luminous/docs/OpenApi_Client.md`
- `Luminous/docs/Localization.md`
- `Luminous/docs/MigrationLog.md`
- `Luminous/docs/superpowers/plans/2026-06-03-fifteen-day-lumos-delivery-plan.md`

## Hard Scope Boundary

Do this in this fifteen-day window:

1. Harden current health-context edit UX and tests.
2. Add a minimal Lucent daily-record domain for user-owned records.
3. Export OpenAPI and regenerate the Luminous client through the wrapper.
4. Wire Record read/write flows to Lucent daily records.
5. Add a minimal Lucent medicine dose-log domain for manual adherence tracking.
6. Wire Medicine and Today to dose logs and daily-record summaries.
7. Keep More as mostly mock, but document the boundary instead of pretending device/tool integrations exist.
8. Update docs, tests, and review evidence after every task.

Do not do this in this fifteen-day window:

- production deployment
- force-push, history rewrite, destructive reset, or `--no-verify`
- AI medical advice, diagnosis, or treatment recommendations
- OCR, barcode, camera upload, push notification execution, calendar integration, or wearable sync
- broad visual redesign or landing pages
- new production dependencies unless the current stack cannot support the task
- DrugBank pipeline changes unless a current task is blocked by medicine search/detail
- Luminous legacy folder revival

## Execution Protocol For DeepSeek

DeepSeek must execute one task at a time. After every task, return this exact evidence bundle:

```text
Task:
Status: DONE / DONE_WITH_CONCERNS / BLOCKED
Commit:
Touched files:
Behavior changed:
Commands run:
Command results:
Docs updated:
Generated artifacts:
Assumptions:
Risks / reviewer notes:
```

Rules:

- If a command was not run, write `not run` and give the reason.
- Run `git status --short` in both `Lucent` and `Luminous` before editing.
- Do not edit unrelated dirty files. If dirty files are related, explain why before touching them.
- Each task should normally produce exactly one commit in the touched repository. A paired backend/frontend task may produce one commit per repository.
- If API behavior changes, update Lucent docs and OpenAPI in the same backend task or the explicitly paired regeneration task.
- If visible Flutter text changes, update both ARB files and run `flutter gen-l10n`.
- If Flutter UI is added or routed, add widget tests.
- If backend behavior is added, add unit and e2e tests.
- If generated DTOs appear outside Luminous data-layer files or tests, treat the task as incomplete.

## Reviewer Protocol For Codex

For each DeepSeek task, Codex should review in this order:

1. Read the evidence bundle and verify the commit(s).
2. Run `git -C Lucent diff --check` and/or `git -C Luminous diff --check`.
3. Inspect diffs for unrelated edits, DTO leakage, missing docs, hardcoded visible text, provider invalidation gaps, and nullable write bugs.
4. Run the task's targeted verification commands.
5. For UI tasks, inspect mobile-width and desktop-width behavior when environment allows.
6. Accept only when behavior, tests, docs, generated artifacts, and commit scope match the task.

Codex should reject "done" reports that do not include command evidence.

## Dispatch Template

Use this prompt when sending a task to DeepSeek:

```text
Use superpowers:executing-plans. Execute only Task <N> from:
Luminous/docs/superpowers/plans/2026-06-03-fifteen-day-lumos-followup-plan.md

Before editing:
- read the Required Reading list if not already done
- run git status in Lucent and Luminous
- protect unrelated dirty work

After editing:
- run the exact verification commands for Task <N>
- commit using the existing repository commit-message style
- return the required evidence bundle

Do not start Task <N+1>.
```

## Schedule

| Day | Date | Task |
| --- | --- | --- |
| 1 | 2026-06-04 | Task 1: Baseline and post-audit guardrails |
| 2 | 2026-06-05 | Task 2: Harden health-context edit flows |
| 3 | 2026-06-06 | Task 3: Design daily-record contract and schema |
| 4-5 | 2026-06-07 to 2026-06-08 | Task 4: Implement Lucent daily-record APIs |
| 6 | 2026-06-09 | Task 5: Export OpenAPI and regenerate Luminous client |
| 7-8 | 2026-06-10 to 2026-06-11 | Task 6: Wire Record tab to real daily records |
| 9 | 2026-06-12 | Task 7: Add Record quick-create/edit/delete flows |
| 10 | 2026-06-13 | Task 8: Wire Today to real daily-record summaries |
| 11 | 2026-06-14 | Task 9: Design medicine dose-log contract and schema |
| 12-13 | 2026-06-15 to 2026-06-16 | Task 10: Implement dose-log APIs and regenerate client |
| 14 | 2026-06-17 | Task 11: Wire Medicine and Today dose-log actions |
| 15 | 2026-06-18 | Task 12: Regression, docs, and handoff audit |

---

## Task 1: Baseline And Post-Audit Guardrails

**Intent:** establish the true clean baseline after the health-context fixes and make the previous mistakes visible before new work starts.

### Scope

- Read required docs.
- Confirm latest commits in both repos.
- Confirm no unrelated dirty work.
- Add a short "Follow-up plan baseline" entry to `Luminous/docs/MigrationLog.md` only if the current doc does not already point to this plan.
- Do not change runtime code.

### Commands

```bash
git -C Lucent status --short
git -C Luminous status --short
git -C Lucent log --oneline -n 5
git -C Luminous log --oneline -n 5
git -C Lucent diff --check
git -C Luminous diff --check
```

### Acceptance

- The evidence bundle names the latest Lucent and Luminous commits.
- No runtime files are changed.
- Any dirty work is explained before Task 2 starts.

### Suggested Commit

```bash
git -C Luminous commit -m "docs(plan): 记录后续执行基线"
```

---

## Task 2: Harden Health-Context Edit Flows

**Intent:** finish the quality pass on the flows created in the previous plan before building more features on top of them.

### Scope

- Existing edit routes for allergy, condition, and current medicine must prefill from `healthContextSnapshotProvider` by id.
- Missing id should show `AppStateErrorView` or route back safely; do not silently create a new record.
- Required fields (`label`, `displayName`, etc.) must block save when empty.
- Date fields should keep simple text input for now, but validation must prevent obviously invalid ISO date strings from being sent.
- Keep generated OpenAPI DTOs out of presentation/domain files.

### Likely Files

- `Luminous/lib/features/mine/presentation/pages/allergy_edit.dart`
- `Luminous/lib/features/mine/presentation/pages/condition_edit.dart`
- `Luminous/lib/features/mine/presentation/pages/current_medicine_edit.dart`
- `Luminous/lib/features/mine/presentation/pages/profile_edit.dart`
- `Luminous/lib/features/mine/presentation/providers/health_edit_forms.dart`
- `Luminous/test/mine_edit_pages_test.dart`

### Verification

```bash
flutter analyze
flutter test test/mine_edit_pages_test.dart test/mine_page_test.dart
flutter test
```

### Acceptance

- Widget tests cover create, edit-prefill, empty-required-field validation, and delete/soft-delete callbacks.
- No unbounded nested scrollables are introduced.
- `rg "lucent_openapi" lib/features/mine lib/features/health_context/domain` returns no presentation/domain DTO leakage.

### Suggested Commit

```bash
git -C Luminous commit -m "fix(mine): 完善健康档案编辑流程"
```

---

## Task 3: Design Daily-Record Contract And Schema

**Intent:** define a minimal backend-owned record model before writing APIs.

### Scope

- Add Lucent docs for daily records under the user domain.
- Extend `Lucent/docs/public/api-contract.md` with proposed endpoints and response shape.
- Add Prisma schema and migration for a generic `UserDailyRecord` model.
- Keep the model minimal and extensible:
  - `id`
  - `userId`
  - `kind`
  - `occurredAt`
  - `title`
  - `value`
  - `unit`
  - `note`
  - `payload`
  - `source`
  - `deletedAt`
  - timestamps
- Suggested enum: `water`, `meal`, `vital`, `mood`, `symptom`, `activity`, `note`.
- No AI interpretation, diagnosis, or nutrition inference.

### Likely Files

- `Lucent/prisma/schema.prisma`
- `Lucent/prisma/migrations/...`
- `Lucent/docs/backend-user-domain.md`
- `Lucent/docs/public/api-contract.md`
- `Lucent/CHANGELOG.md`

### Verification

```bash
pnpm exec prisma validate
pnpm lint:check
pnpm build
```

### Acceptance

- Migration is present and reviewable.
- Docs state exactly what the model does and does not do.
- No controller/service behavior is added yet unless it is necessary for compilation.

### Suggested Commit

```bash
git -C Lucent commit -m "feat(records): 设计每日记录数据模型"
```

---

## Task 4: Implement Lucent Daily-Record APIs

**Intent:** expose authenticated CRUD for the daily records designed in Task 3.

### Scope

- Add a `daily-records` Lucent module, controller, service, DTOs, and tests.
- Endpoints:
  - `GET /api/v1/me/daily-records?date=YYYY-MM-DD&kind=&page=1&pageSize=50`
  - `POST /api/v1/me/daily-records`
  - `PATCH /api/v1/me/daily-records/:id`
  - `DELETE /api/v1/me/daily-records/:id`
  - `GET /api/v1/me/daily-records/summary?date=YYYY-MM-DD`
- Use authenticated `userId` for every query and mutation.
- `DELETE` should soft-delete via `deletedAt`.
- `PATCH` must distinguish omitted/no change from explicit `null` where fields are nullable.
- Summary should count records by kind and expose only factual totals/last-record fields.

### Likely Files

- `Lucent/src/daily-records/**`
- `Lucent/src/app.module.ts`
- `Lucent/test/daily-records.e2e-spec.ts`
- `Lucent/docs/public/api-contract.md`
- `Lucent/CHANGELOG.md`

### Verification

```bash
pnpm test -- daily-records.service.spec.ts --runInBand
pnpm test:e2e:ci -- daily-records.e2e-spec.ts
pnpm lint:check
pnpm build
```

### Acceptance

- Unit tests cover create, list-by-date, update-null-clear, update-omitted-no-change, soft-delete, and summary.
- E2E tests cover auth required, user isolation, and response envelope.
- API docs and changelog are updated.

### Suggested Commit

```bash
git -C Lucent commit -m "feat(records): 新增每日记录API"
```

---

## Task 5: Export OpenAPI And Regenerate Luminous Client

**Intent:** move the daily-record contract into the generated client using the supported wrapper.

### Scope

- Run Lucent OpenAPI export.
- Regenerate Luminous client through `dart run tool/regenerate_lucent_openapi.dart`.
- Add Luminous daily-record data/domain repository boundaries.
- Use local domain input objects for writes, including a no-change sentinel for nullable update fields.
- If generated DTO serializers drop explicit `null`, use the same raw Dio JSON pattern as health-context writes.

### Likely Files

- `Lucent/docs/openapi.json`
- `Luminous/packages/lucent_openapi/**`
- `Luminous/lib/features/record/data/**`
- `Luminous/lib/features/record/domain/**`
- `Luminous/docs/OpenApi_Client.md`
- `Luminous/docs/MigrationLog.md`

### Verification

```bash
pnpm --prefix ../Lucent export:openapi
dart run tool/regenerate_lucent_openapi.dart
flutter analyze
flutter test test/record_page_test.dart
```

Run from the appropriate repo root; if `pnpm --prefix ../Lucent export:openapi` is not valid from `Luminous`, run `pnpm export:openapi` inside `Lucent` first and document the actual commands.

### Acceptance

- Generated client is updated only through the wrapper.
- Record domain/presentation files do not import generated OpenAPI DTOs.
- Payload tests prove explicit `null` survives for nullable daily-record fields.

### Suggested Commit

```bash
git -C Lucent commit -m "docs(openapi): 导出每日记录接口"
git -C Luminous commit -m "feat(record): 接入每日记录数据层"
```

---

## Task 6: Wire Record Tab To Real Daily Records

**Intent:** replace Record's mock timeline data with Lucent-backed records while keeping unsupported trend panels honest.

### Scope

- Record tab reads `GET /me/daily-records` for the selected date.
- Timeline items render real records.
- Existing mock trend cards may remain, but labels/docs must clearly mark them as static until trend APIs exist.
- Signed-out users should see a login affordance or static signed-out state, not call protected APIs repeatedly.
- Add loading skeletons and `AppStateErrorView` for errors.

### Likely Files

- `Luminous/lib/features/record/data/repositories/**`
- `Luminous/lib/features/record/presentation/providers/**`
- `Luminous/lib/features/record/presentation/widgets/**`
- `Luminous/lib/features/record/presentation/record_page.dart`
- `Luminous/test/record_page_test.dart`

### Verification

```bash
flutter analyze
flutter test test/record_page_test.dart
flutter test
```

### Acceptance

- Widget tests cover signed-out, loading, error, empty, and populated real-record states.
- No hardcoded visible text is added outside ARB if new copy is needed.
- Mobile and desktop layouts remain overflow-free in tests or manual screenshots.

### Suggested Commit

```bash
git -C Luminous commit -m "feat(record): 每日时间线接入真实记录"
```

---

## Task 7: Add Record Quick Create/Edit/Delete Flows

**Intent:** let users create and maintain minimal daily records from the Record tab.

### Scope

- Add create/edit UI for `water`, `mood`, `symptom`, and generic `note` first.
- Keep meal/vital/activity forms minimal or disabled if they need richer domain decisions.
- Signed-out create action routes to `/login`.
- Successful writes invalidate Record and Today providers.
- Use local domain input objects and raw Dio write payloads if explicit `null` is needed.

### Likely Files

- `Luminous/lib/app/router.dart`
- `Luminous/lib/features/record/presentation/pages/**`
- `Luminous/lib/features/record/presentation/providers/**`
- `Luminous/lib/features/record/presentation/widgets/**`
- `Luminous/lib/l10n/app_en.arb`
- `Luminous/lib/l10n/app_zh.arb`
- `Luminous/test/record_page_test.dart`

### Verification

```bash
flutter gen-l10n
flutter analyze
flutter test test/record_page_test.dart
flutter test
```

### Acceptance

- Tests cover signed-out routing, create success, edit prefill, explicit clear, delete, and provider invalidation.
- No nested unbounded scrollables.
- All new visible text is localized.

### Suggested Commit

```bash
git -C Luminous commit -m "feat(record): 新增每日记录编辑流程"
```

---

## Task 8: Wire Today To Real Daily-Record Summaries

**Intent:** make Today show factual daily-record summaries from Lucent while preserving safe mock boundaries.

### Scope

- Today repository reads health context plus daily-record summary.
- Water, mood, symptom, and latest note signals can become real.
- Meal, environment, Lumi suggestion, and unsupported health advice remain static or hidden with clear docs.
- Signed-out behavior should avoid protected API loops.

### Likely Files

- `Luminous/lib/features/today/data/repositories/**`
- `Luminous/lib/features/today/domain/entities/today_dashboard.dart`
- `Luminous/lib/features/today/presentation/providers/**`
- `Luminous/lib/features/today/presentation/widgets/**`
- `Luminous/test/today_page_test.dart`
- `Luminous/docs/MigrationLog.md`

### Verification

```bash
flutter analyze
flutter test test/today_page_test.dart test/record_page_test.dart
flutter test
```

### Acceptance

- Tests prove Today updates after Record writes via provider invalidation.
- Today does not infer diagnosis, treatment, or medical recommendations.
- Docs list which Today sections are real and which remain static.

### Suggested Commit

```bash
git -C Luminous commit -m "feat(today): 接入每日记录摘要"
```

---

## Task 9: Design Medicine Dose-Log Contract And Schema

**Intent:** define manual adherence logging without pretending to implement reminders or scheduling.

### Scope

- Add a minimal `UserMedicineDoseLog` Prisma model related to `User` and optionally `UserCurrentMedicine`.
- Suggested fields:
  - `id`
  - `userId`
  - `currentMedicineId`
  - `status` (`taken`, `skipped`, `missed`, `planned`)
  - `scheduledFor`
  - `takenAt`
  - `doseText`
  - `note`
  - `source`
  - `deletedAt`
  - timestamps
- Add docs stating this is manual adherence tracking, not push reminder execution.

### Likely Files

- `Lucent/prisma/schema.prisma`
- `Lucent/prisma/migrations/...`
- `Lucent/docs/backend-user-domain.md`
- `Lucent/docs/public/api-contract.md`
- `Lucent/CHANGELOG.md`

### Verification

```bash
pnpm exec prisma validate
pnpm lint:check
pnpm build
```

### Acceptance

- Model supports user isolation and soft delete.
- Docs explicitly state "no push notifications / no real reminder scheduling".

### Suggested Commit

```bash
git -C Lucent commit -m "feat(medicine): 设计用药打卡数据模型"
```

---

## Task 10: Implement Dose-Log APIs And Regenerate Client

**Intent:** expose dose-log writes and bring them into Luminous through OpenAPI.

### Scope

- Lucent endpoints:
  - `GET /api/v1/me/medicine-dose-logs?date=YYYY-MM-DD`
  - `POST /api/v1/me/medicine-dose-logs`
  - `PATCH /api/v1/me/medicine-dose-logs/:id`
  - `DELETE /api/v1/me/medicine-dose-logs/:id`
- Enforce user ownership of linked `UserCurrentMedicine`.
- Add unit/e2e tests.
- Export OpenAPI.
- Regenerate Luminous client through the wrapper.
- Add Luminous medicine dose-log data/domain repository boundaries.

### Likely Files

- `Lucent/src/medicine-dose-logs/**`
- `Lucent/test/medicine-dose-logs.e2e-spec.ts`
- `Lucent/docs/openapi.json`
- `Luminous/packages/lucent_openapi/**`
- `Luminous/lib/features/medicine/data/**`
- `Luminous/lib/features/medicine/domain/**`
- `Luminous/docs/OpenApi_Client.md`
- `Luminous/docs/MigrationLog.md`

### Verification

```bash
pnpm test -- medicine-dose-logs.service.spec.ts --runInBand
pnpm test:e2e:ci -- medicine-dose-logs.e2e-spec.ts
pnpm lint:check
pnpm build
dart run tool/regenerate_lucent_openapi.dart
flutter analyze
flutter test test/medicine_workspace_repository_test.dart
```

### Acceptance

- Tests cover linked medicine ownership, omitted/no-change, explicit null clear, soft delete, and auth.
- Luminous domain/presentation does not import generated dose-log DTOs.
- OpenAPI docs and Luminous client docs are updated.

### Suggested Commit

```bash
git -C Lucent commit -m "feat(medicine): 新增用药打卡API"
git -C Luminous commit -m "feat(medicine): 接入用药打卡数据层"
```

---

## Task 11: Wire Medicine And Today Dose-Log Actions

**Intent:** let users mark current medicines as taken/skipped and reflect that in Today safely.

### Scope

- Medicine tab shows current medicines with today's dose-log status.
- Add actions for taken/skipped/manual note.
- Signed-out actions route to `/login`.
- Successful write invalidates medicine workspace, health-context if needed, and Today providers.
- Today medication summary reads dose-log status and current medicines.

### Likely Files

- `Luminous/lib/features/medicine/presentation/**`
- `Luminous/lib/features/medicine/data/repositories/**`
- `Luminous/lib/features/today/data/repositories/**`
- `Luminous/lib/features/today/presentation/**`
- `Luminous/lib/l10n/app_en.arb`
- `Luminous/lib/l10n/app_zh.arb`
- `Luminous/test/medicine_page_test.dart`
- `Luminous/test/today_page_test.dart`

### Verification

```bash
flutter gen-l10n
flutter analyze
flutter test test/medicine_page_test.dart test/today_page_test.dart
flutter test
```

### Acceptance

- Tests cover signed-out routing, taken/skipped actions, state invalidation, and Today reflection.
- UI text fits in mobile and desktop test viewports.
- Docs do not call this "reminders"; call it manual adherence/dose logging.

### Suggested Commit

```bash
git -C Luminous commit -m "feat(medicine): 用药打卡接入今日状态"
```

---

## Task 12: Regression, Docs, And Handoff Audit

**Intent:** close the plan with full checks and a concise handoff for Codex review.

### Scope

- Update all owner docs:
  - `Lucent/CHANGELOG.md`
  - `Lucent/docs/public/api-contract.md`
  - `Lucent/docs/backend-user-domain.md`
  - `Luminous/docs/MigrationLog.md`
  - `Luminous/docs/OpenApi_Client.md`
  - `Luminous/docs/UI_Implementation_Plan.md`
  - `Luminous/docs/Localization.md` if visible text changed
- Run full checks in both repos.
- Search for forbidden DTO leakage and unsupported claims.
- Produce a final task summary with commit hashes.

### Commands

```bash
# From D:\25080\Documents\VSCodeProject\Lumos
git -C Lucent diff --check
git -C Luminous diff --check

# From D:\25080\Documents\VSCodeProject\Lumos\Lucent
cd Lucent
pnpm lint:check
pnpm build
pnpm test:ci
pnpm test:e2e:ci

# From D:\25080\Documents\VSCodeProject\Lumos\Luminous
cd ../Luminous
flutter analyze
flutter test

# From D:\25080\Documents\VSCodeProject\Lumos
cd ..
rg "lucent_openapi" Luminous/lib/features/record Luminous/lib/features/medicine Luminous/lib/features/today Luminous/lib/features/mine
rg -n "diagnos|treat|recommend|reminder|push|OCR|barcode" Lucent/docs Luminous/docs
```

If using a different shell, report the actual command lines in the evidence bundle.

### Acceptance

- Full Lucent unit/e2e/build/lint pass.
- Full Luminous analyze/test pass.
- Docs match the implemented behavior.
- Final evidence bundle includes all commits and any remaining risks.

### Suggested Commit

```bash
git -C Luminous commit -m "docs: 更新每日记录和用药打卡交付记录"
```

---

## Final Review Checklist

Before Codex accepts the whole plan, verify:

- [ ] Lucent and Luminous git histories show small, task-scoped commits.
- [ ] OpenAPI was regenerated only through supported commands.
- [ ] Luminous generated DTOs do not cross into domain/presentation.
- [ ] Every nullable write has explicit null/omitted/value coverage.
- [ ] Every user-owned backend endpoint enforces auth and user isolation.
- [ ] Every write that affects Today/Record/Medicine invalidates all affected providers.
- [ ] Signed-out UI paths route to `/login` or show a stable signed-out state.
- [ ] UI pages have no nested vertical scroll layout failures.
- [ ] Docs state unsupported features plainly: no AI advice, no push reminders, no OCR/barcode execution.
- [ ] Full regression commands pass or unresolved failures are documented with exact output.
