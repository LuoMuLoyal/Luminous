# Lumos Thirty-Day DeepSeek Execution Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to execute this plan task-by-task. Before every task, apply the relevant guardrails from `Luminous/docs/Project_Guardrails.md`. Use `superpowers:subagent-driven-development` only when Codex explicitly splits a backend/frontend task boundary for review.

**Goal:** From 2026-06-06 through 2026-07-05, move Lumos from a stable five-tab health assistant baseline into a stronger personal health loop: polished app identity/theme/loading states, closed auth/account debt, reliable daily-record and medicine-adherence workflows, first real notification/reminder boundaries, and a clearer plan for More/device/tool integrations without presenting mock features as real.

**Architecture:** Keep `Lucent` as the only active backend and `Luminous` as the Flutter client. Use NestJS modules, Prisma 7 migrations, OpenAPI export, generated `lucent_openapi`, Riverpod repositories/providers, GoRouter, ARB localization, shared design tokens, and feature-first Flutter folders.

**Non-goals:** no production deployment, no paid external service integration without explicit approval, no AI diagnosis/treatment advice, no fake OCR/barcode/device/push behavior, no legacy Flutter folders, no ad-hoc OpenAPI generation, no broad redesign outside the task.

---

## Plan Ownership

- Created on: 2026-06-06.
- Covered window: 2026-06-06 to 2026-07-05.
- Executor: DeepSeek or another implementation agent.
- Reviewer: Codex.
- Repository layout: `Lucent` and `Luminous` are separate git repositories under `D:\25080\Documents\VSCodeProject\Lumos`; the workspace root is not a git repository.

## Current Baseline

As of 2026-06-06:

- Lucent branch: `dev`.
- Lucent latest commit: `bf28542 chore(todo): auth后续增强添加TODO`.
- Luminous branch: `refactor`.
- Luminous latest commit: `720a460 build(icon): 更换app图标`.
- Auth/account basics exist, including account settings, WeChat OAuth paths, identity binding/unlinking, and TODO markers for deferred hardening.
- Theme mode and palette selection exist, including default, blue-pink, and yellow-green palettes.
- Android launch screen is white with centered vector mark; app launcher icons are generated from `assets/icons/luminous_app_icon.png`.
- Main-tab loading states preserve static page chrome and use local shimmer only for backend-backed sections.
- Today, Record, Medicine, Search, Mine, Settings, and Account have feature-first Flutter structure and widget coverage.
- Record daily records, Medicine manual dose logs, and Today summary wiring have already gone through a prior contract/client integration cycle.
- More remains mostly mock/static and must not be described as real device/tool integration.

## Required Reading Before Task 1

Read these files before editing:

- `Lucent/AGENTS.md`
- `Lucent/README.md`
- `Lucent/docs/README.md`
- `Lucent/docs/public/ROADMAP.md`
- `Lucent/docs/openapi.json`
- `Lucent/docs/public/reminder-contract.md`
- `Lucent/docs/public/environment-contract.md`
- `Lucent/prisma/schema.prisma`
- `Luminous/AGENTS.md`
- `Luminous/README.md`
- `Luminous/docs/README.md`
- `Luminous/docs/Current_State.md`
- `Luminous/docs/Next_Plan.md`
- `Luminous/docs/Project_Guardrails.md`
- `Luminous/docs/OpenApi_Client.md`
- `Luminous/docs/UI_Implementation_Plan.md`
- `Luminous/docs/Localization.md`
- `Luminous/docs/MigrationLog.md`

## Execution Protocol For DeepSeek

Execute exactly one task at a time. Do not start the next task until Codex accepts the current one.

After every task, return this exact evidence bundle:

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
- Run branch/status/log in both repos before editing and before final report.
- Do not edit unrelated dirty files.
- Each task should normally produce exactly one commit in the touched repository; paired backend/frontend tasks may produce one commit per repository.
- If API behavior changes, update Lucent docs, export OpenAPI, regenerate Luminous through the wrapper, and update Luminous docs.
- If visible Flutter text changes, update both ARB files and run `flutter gen-l10n`.
- If frontend UI or routing changes, add or update widget tests.
- If backend behavior changes, add or update unit/e2e tests.
- Domain/presentation code must not import generated OpenAPI DTOs.

## Codex Review Protocol

Codex should reject a task unless:

- Branch/status/log evidence matches the active repositories.
- Diffs are task-scoped and do not include unrelated cleanup.
- `git diff --check` passes; for Luminous generated OpenAPI use `git diff --check -- . ':!packages/lucent_openapi/**'`.
- The task's targeted verification commands pass or failures are explicitly justified.
- Docs and generated artifacts match the behavior.
- UI changes keep mobile/desktop layout safe.
- Unsupported features remain clearly marked as mock/static/unsupported.

## Dispatch Template

```text
Use superpowers:executing-plans.
Execute only Task <N> from:
Luminous/docs/superpowers/plans/2026-06-06-thirty-day-lumos-deepseek-plan.md

Before editing:
- read the Required Reading list if not already done
- apply relevant guardrails from Luminous/docs/Project_Guardrails.md
- run branch/status/log in Lucent and Luminous
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
| 1 | 2026-06-06 | Task 1: Month baseline and guardrail refresh |
| 2-3 | 2026-06-07 to 2026-06-08 | Task 2: Visual identity and startup polish |
| 4 | 2026-06-09 | Task 3: Theme system regression and token usage audit |
| 5-6 | 2026-06-10 to 2026-06-11 | Task 4: Auth/account TODO triage and safe closeout |
| 7 | 2026-06-12 | Task 5: Account security UX hardening |
| 8-9 | 2026-06-13 to 2026-06-14 | Task 6: Record list/edit/delete quality pass |
| 10-11 | 2026-06-15 to 2026-06-16 | Task 7: Today factual dashboard pass |
| 12-13 | 2026-06-17 to 2026-06-18 | Task 8: Medicine adherence workflow pass |
| 14 | 2026-06-19 | Task 9: Cross-feature provider consistency audit |
| 15-16 | 2026-06-20 to 2026-06-21 | Task 10: Notification/reminder contract design |
| 17-18 | 2026-06-22 to 2026-06-23 | Task 11: Minimal local notification preference bridge |
| 19 | 2026-06-24 | Task 12: More module boundary and route cleanup |
| 20-21 | 2026-06-25 to 2026-06-26 | Task 13: More real-contract design for tools/devices/environment |
| 22-23 | 2026-06-27 to 2026-06-28 | Task 14: Search and medicine knowledge UX hardening |
| 24 | 2026-06-29 | Task 15: Settings and account child-page consistency audit |
| 25 | 2026-06-30 | Task 16: Test suite speed and determinism pass |
| 26-27 | 2026-07-01 to 2026-07-02 | Task 17: Documentation and API contract alignment pass |
| 28 | 2026-07-03 | Task 18: Full regression and issue ledger |
| 29 | 2026-07-04 | Task 19: Reviewer fix buffer |
| 30 | 2026-07-05 | Task 20: Final handoff and next-month backlog |

---

## Task 1: Month Baseline And Guardrail Refresh

**Intent:** create a reliable starting point for the next 30 days and ensure DeepSeek cannot start from stale state.

### Scope

- Read required docs.
- Confirm clean branch/status/log evidence for both repos.
- Update today's `Luminous/docs/migration-log/YYYY-MM-DD.md` with this plan entry.
- Do not change runtime code.

### Commands

```bash
git -C Lucent branch --show-current
git -C Lucent status --short --branch
git -C Lucent log -1 --oneline
git -C Luminous branch --show-current
git -C Luminous status --short --branch
git -C Luminous log -1 --oneline
git -C Lucent diff --check
git -C Luminous diff --check -- . ':!packages/lucent_openapi/**'
```

### Acceptance

- Evidence bundle names active branch and latest commit in both repos.
- The plan is discoverable from the `MigrationLog.md` index.
- No runtime code changes.

### Suggested Commit

```bash
git -C Luminous commit -m "docs(plan): 制定未来一个月执行计划"
```

---

## Task 2: Visual Identity And Startup Polish

**Intent:** make launcher icon, splash screen, and first visible Flutter frame feel consistent across platforms.

### Scope

- Inspect generated launcher icons on Android, iOS, Web, Windows, and macOS resource paths.
- Confirm Android adaptive icon background is white and foreground is not clipped.
- Confirm native splash screen remains white and centered.
- If Flutter first-frame transition flashes a different color, align app shell background to the splash color.
- Do not replace the approved app icon unless the image is visibly clipped in generated resources.

### Likely Files

- `Luminous/assets/icons/luminous_app_icon.png`
- `Luminous/pubspec.yaml`
- `Luminous/android/app/src/main/res/**`
- `Luminous/ios/Runner/Assets.xcassets/AppIcon.appiconset/**`
- `Luminous/web/**`
- `Luminous/windows/runner/resources/app_icon.ico`
- `Luminous/macos/Runner/Assets.xcassets/AppIcon.appiconset/**`

### Verification

```bash
flutter analyze
flutter test
flutter build apk --debug
git diff --check -- . ':!packages/lucent_openapi/**'
```

### Acceptance

- Generated icon resources are intentional and documented.
- Android debug APK builds.
- Known `fluwx` KGP warning is reported but not treated as task failure.

### Suggested Commit

```bash
git -C Luminous commit -m "fix(app): 打磨启动屏和应用图标"
```

---

## Task 3: Theme System Regression And Token Usage Audit

**Intent:** keep the new theme palettes stable without changing token values to hide inconsistent usage.

### Scope

- Audit page-level usage of spacing, radius, shadow, typography, and theme surface tokens.
- Fix page/component token inconsistency where the same semantic surface uses mixed token sizes.
- Do not change token numeric values unless Codex explicitly approves.
- Add or update tests for theme palette persistence and settings navigation if gaps exist.
- Check default, blue-pink, yellow-green, light, and dark modes on core pages.

### Likely Files

- `Luminous/lib/core/design/**`
- `Luminous/lib/core/theme/**`
- `Luminous/lib/features/settings/**`
- `Luminous/lib/features/today/**`
- `Luminous/lib/features/record/**`
- `Luminous/lib/features/medicine/**`
- `Luminous/lib/features/mine/**`
- `Luminous/test/app_theme_controller_test.dart`
- `Luminous/test/settings_flow_test.dart`

### Verification

```bash
flutter analyze
flutter test test/app_theme_controller_test.dart test/settings_flow_test.dart
flutter test
```

### Acceptance

- Token usage is semantically consistent.
- No token numeric-size churn is introduced to mask page inconsistencies.
- Docs state the theme boundary clearly.

### Suggested Commit

```bash
git -C Luminous commit -m "fix(theme): 统一页面token使用"
```

---

## Task 4: Auth/Account TODO Triage And Safe Closeout

**Intent:** close the low-risk auth debt that was intentionally deferred and leave high-risk OAuth/security work clearly marked.

### Scope

- Search auth/account TODO markers and classify them:
  - safe to implement now
  - blocked by external platform credentials
  - blocked by product/security decision
  - should remain TODO
- Implement only low-risk internal improvements.
- Do not change OAuth provider secrets, callback domains, or production behavior without explicit approval.
- Keep `/account` as the public account-management route language.

### Likely Files

- `Lucent/src/auth/**`
- `Lucent/src/account/**`
- `Luminous/lib/features/auth/**`
- `Luminous/lib/features/mine/**`
- `Luminous/docs/MigrationLog.md`
- today's `Luminous/docs/migration-log/YYYY-MM-DD.md`

### Verification

```bash
rg -n "TODO|FIXME" Lucent/src/auth Lucent/src/account Luminous/lib/features/auth Luminous/lib/features/mine
pnpm --dir ../Lucent lint:check
pnpm --dir ../Lucent build
flutter analyze
flutter test test/account_settings_page_test.dart test/login_page_test.dart
```

### Acceptance

- TODOs are either resolved or rewritten with owner/reason/blocked condition.
- No credentials or deployment assumptions are added.
- Tests cover any behavior change.

### Suggested Commit

```bash
git -C Lucent commit -m "chore(auth): 梳理账号后续增强边界"
git -C Luminous commit -m "chore(auth): 梳理账号后续增强边界"
```

---

## Task 5: Account Security UX Hardening

**Intent:** make account security states understandable and safe for email/password/OAuth users.

### Scope

- Confirm account page shows password set/unset, linked identities, email verification timestamp-derived state, and destructive action protections.
- OAuth-only users should not be allowed into impossible password-dependent flows without a safe explanation.
- Keep visible text localized.
- Backend behavior changes require unit/e2e coverage and OpenAPI regeneration.

### Likely Files

- `Lucent/src/account/**`
- `Lucent/src/auth/**`
- `Luminous/lib/features/auth/presentation/pages/account_settings_page.dart`
- `Luminous/lib/features/auth/presentation/providers/**`
- `Luminous/lib/l10n/app_en.arb`
- `Luminous/lib/l10n/app_zh.arb`
- `Luminous/test/account_settings_page_test.dart`

### Verification

```bash
flutter gen-l10n
flutter analyze
flutter test test/account_settings_page_test.dart test/change_email_page_test.dart
flutter test
```

If backend changes:

```bash
pnpm --dir ../Lucent lint:check
pnpm --dir ../Lucent build
pnpm --dir ../Lucent test -- auth.service.spec.ts --runInBand
pnpm --dir ../Lucent test:e2e:ci -- auth.e2e-spec.ts
```

### Acceptance

- OAuth-only, password, and email-unverified states have test coverage.
- Destructive actions are protected and localized.
- No generated DTOs leak outside Luminous data layer.

### Suggested Commit

```bash
git -C Luminous commit -m "fix(account): 收紧账号安全状态展示"
```

---

## Task 6: Record List/Edit/Delete Quality Pass

**Intent:** make daily records feel reliable for ordinary user maintenance, not just quick-create demos.

### Scope

- Audit Record list, empty, loading, error, create, edit, and delete flows.
- Ensure create/edit/delete invalidates Record and Today providers.
- Add missing widget tests for edit prefill, delete, signed-out path, and explicit nullable field clearing.
- Do not expand into rich analytics or diagnosis.

### Likely Files

- `Luminous/lib/features/record/**`
- `Luminous/lib/features/today/**`
- `Luminous/test/record_page_test.dart`
- `Luminous/test/today_page_test.dart`

### Verification

```bash
flutter analyze
flutter test test/record_page_test.dart test/today_page_test.dart
flutter test
```

### Acceptance

- Record writes refresh Today.
- Signed-out paths do not call protected APIs repeatedly.
- Unsupported trend panels are static/mock in docs.

### Suggested Commit

```bash
git -C Luminous commit -m "fix(record): 完善每日记录维护流程"
```

---

## Task 7: Today Factual Dashboard Pass

**Intent:** make Today factual, fast, and honest about which panels are real.

### Scope

- Audit Today data sources and ensure real/static sections are separated.
- Keep water/vital/medicine/dose-log summaries factual.
- Do not present meal/environment/Lumi static sections as AI medical advice.
- Loading should remain local to backend-backed cards only.
- Add tests for empty and partial-data states if missing.

### Likely Files

- `Luminous/lib/features/today/**`
- `Luminous/lib/features/record/**`
- `Luminous/lib/features/medicine/**`
- `Luminous/test/today_page_test.dart`

### Verification

```bash
flutter analyze
flutter test test/today_page_test.dart test/record_page_test.dart test/medicine_page_test.dart
flutter test
```

### Acceptance

- Tests prove partial data does not crash Today.
- Docs list real/static Today sections.
- No diagnosis/treatment/recommendation wording is added.

### Suggested Commit

```bash
git -C Luminous commit -m "fix(today): 收紧今日页真实数据边界"
```

---

## Task 8: Medicine Adherence Workflow Pass

**Intent:** improve manual dose logging without calling it reminder scheduling.

### Scope

- Audit Medicine current-medicine list, taken/skipped actions, error feedback, and Today reflection.
- Ensure latest dose-log status mapping is consistent across Medicine and Today.
- Signed-out actions route to `/login`.
- Do not implement push reminders, calendar sync, barcode/OCR, or wearable sync in this task.

### Likely Files

- `Luminous/lib/features/medicine/**`
- `Luminous/lib/features/today/**`
- `Luminous/test/medicine_page_test.dart`
- `Luminous/test/today_page_test.dart`

### Verification

```bash
flutter analyze
flutter test test/medicine_page_test.dart test/today_page_test.dart
flutter test
```

### Acceptance

- Tests cover taken, skipped, pending, and failed write states.
- Provider invalidation is explicit.
- UI copy says manual adherence/dose logging, not real reminders.

### Suggested Commit

```bash
git -C Luminous commit -m "fix(medicine): 完善用药打卡流程"
```

---

## Task 9: Cross-Feature Provider Consistency Audit

**Intent:** prevent stale Today/Record/Medicine state after writes.

### Scope

- Build an explicit provider invalidation matrix in docs or tests.
- Search all signed-in write operations.
- Add missing invalidations and tests.
- Do not add new product features.

### Required Matrix

| Write action | Must refresh |
| --- | --- |
| Record create/edit/delete | Record dashboard, Today dashboard |
| Medicine taken/skipped/edit | Medicine workspace, Today dashboard |
| Health-context current medicine write/delete | Health context snapshot, Medicine workspace, Today dashboard |
| Search add-to-current-medicines | Health context snapshot, Medicine workspace, Today dashboard |
| Account profile/email/security mutation | Auth session/account data, Mine account summary when applicable |

### Verification

```bash
rg "invalidate\(" lib/features
flutter analyze
flutter test test/record_page_test.dart test/medicine_page_test.dart test/today_page_test.dart test/search_page_test.dart test/account_settings_page_test.dart
flutter test
```

### Acceptance

- Evidence bundle lists every affected provider per write path.
- Tests prove at least one dependent page refreshes after each important write.

### Suggested Commit

```bash
git -C Luminous commit -m "test(state): 补齐跨页刷新覆盖"
```

---

## Task 10: Notification/Reminder Contract Design

**Intent:** define reminders carefully before implementation, separating local notification permission from backend scheduling.

### Scope

- Decide a minimal `reminder` contract in Lucent docs only.
- Clarify what will be local-device preference vs backend-owned schedule.
- Do not implement push notification delivery yet.
- Do not add FCM/APNs credentials or deployment assumptions.
- If a schema is needed, add only after Codex accepts the contract boundary.

### Likely Files

- `Lucent/docs/public/reminder-contract.md`
- `Lucent/CHANGELOG.md`
- `Luminous/docs/UI_Implementation_Plan.md`
- today's `Luminous/docs/migration-log/YYYY-MM-DD.md`

### Verification

```bash
git -C Lucent diff --check
git -C Luminous diff --check -- . ':!packages/lucent_openapi/**'
rg -n "push|reminder|notification|schedule" Lucent/docs Luminous/docs
```

### Acceptance

- Docs explicitly say no production push delivery yet.
- Local notification permission and backend schedule are not conflated.
- No runtime code changes unless explicitly approved.

### Suggested Commit

```bash
git -C Lucent commit -m "docs(reminders): 设计提醒能力边界"
git -C Luminous commit -m "docs(reminders): 记录前端提醒边界"
```

---

## Task 11: Minimal Local Notification Preference Bridge

**Intent:** improve local notification UX without pretending cloud reminders exist.

### Scope

- Make Settings notification page reflect system permission and local preference clearly.
- If local scheduling is implemented, keep it device-local and documented.
- Do not add backend push delivery.
- Add tests for permission service states and setting persistence.

### Likely Files

- `Luminous/lib/features/settings/**`
- `Luminous/lib/core/notifications/**` if it exists or is needed.
- `Luminous/lib/l10n/app_en.arb`
- `Luminous/lib/l10n/app_zh.arb`
- `Luminous/test/settings_flow_test.dart`

### Verification

```bash
flutter gen-l10n
flutter analyze
flutter test test/settings_flow_test.dart
flutter test
```

### Acceptance

- Settings page distinguishes permission state from preference state.
- Tests cover denied, granted, and unknown/plugin-unavailable states.
- Docs say local-only if no backend schedule exists.

### Suggested Commit

```bash
git -C Luminous commit -m "fix(settings): 收紧通知设置状态"
```

---

## Task 12: More Module Boundary And Route Cleanup

**Intent:** prevent mock utility cards from looking like implemented tools.

### Scope

- Audit More page cards and click actions.
- Replace misleading toasts with disabled/planned states where appropriate.
- Keep emergency card language safe and non-deceptive.
- Ensure every route/action either works, routes to a real page, or is clearly planned.
- Add widget tests for mobile and desktop More layouts.

### Likely Files

- `Luminous/lib/features/more/**`
- `Luminous/lib/l10n/app_en.arb`
- `Luminous/lib/l10n/app_zh.arb`
- `Luminous/test/more_page_test.dart`
- `Luminous/docs/UI_Implementation_Plan.md`

### Verification

```bash
flutter gen-l10n
flutter analyze
flutter test test/more_page_test.dart
flutter test
```

### Acceptance

- More does not imply real device/emergency/AI tools exist when they do not.
- Planned states are localized and tested.

### Suggested Commit

```bash
git -C Luminous commit -m "fix(more): 明确更多功能实现边界"
```

---

## Task 13: More Real-Contract Design For Tools/Devices/Environment

**Intent:** define the next real More integrations before coding UI against fantasies.

### Scope

- Pick one narrow More integration to design first: environment snapshot, family profiles, or device registry.
- Prefer environment snapshot if no external credentials are required.
- Add Lucent API contract docs only unless Codex approves schema/implementation.
- State data freshness, source, and unsupported behavior.

### Likely Files

- `Lucent/docs/public/environment-contract.md`
- `Lucent/CHANGELOG.md`
- `Luminous/docs/UI_Implementation_Plan.md`

### Verification

```bash
git -C Lucent diff --check
git -C Luminous diff --check -- . ':!packages/lucent_openapi/**'
rg -n "environment|device|family|More" Lucent/docs Luminous/docs
```

### Acceptance

- Exactly one narrow real-contract path is selected.
- External-service needs are listed as blockers, not silently assumed.
- No runtime code unless explicitly approved.

### Suggested Commit

```bash
git -C Lucent commit -m "docs(more): 设计更多模块首个真实接口"
```

---

## Task 14: Search And Medicine Knowledge UX Hardening

**Intent:** make source-aware medicine search easier to trust and harder to misuse.

### Scope

- Audit source selector, result cards, detail preview, and add-to-current-medicines flow.
- Ensure CN/DrugBank source labels and returned `source` / `sourceRefId` stay visible where useful.
- Keep generated DTOs out of presentation/domain.
- Add missing tests for empty, error, source switching, detail selection, and signed-out add.

### Likely Files

- `Luminous/lib/features/search/**`
- `Luminous/lib/features/health_context/**`
- `Luminous/test/search_page_test.dart`
- `Luminous/docs/UI_Implementation_Plan.md`

### Verification

```bash
rg "lucent_openapi" lib/features/search lib/features/health_context/domain
flutter analyze
flutter test test/search_page_test.dart
flutter test
```

### Acceptance

- Source selection and returned source metadata are tested.
- Signed-out add routes to `/login`.
- No source-specific medical claims are fabricated.

### Suggested Commit

```bash
git -C Luminous commit -m "fix(search): 强化药品搜索来源体验"
```

---

## Task 15: Settings And Account Child-Page Consistency Audit

**Intent:** keep settings/account navigation predictable after moving away from bottom sheets.

### Scope

- Audit all settings and account child pages for standard header, back behavior, centered title, no extra hero/narrative copy.
- Replace any remaining bottom-sheet settings flows with child pages.
- Confirm visible text is localized.
- Add route tests for important child pages.

### Likely Files

- `Luminous/lib/features/settings/**`
- `Luminous/lib/features/auth/presentation/pages/**`
- `Luminous/lib/app/router.dart`
- `Luminous/test/settings_flow_test.dart`
- `Luminous/test/account_settings_page_test.dart`

### Verification

```bash
rg "showModalBottomSheet|AppBottomSheet" lib
flutter gen-l10n
flutter analyze
flutter test test/settings_flow_test.dart test/account_settings_page_test.dart
flutter test
```

### Acceptance

- No settings/account routine flow depends on bottom sheet.
- Header/back/title behavior is consistent.
- Tests cover route entry points.

### Suggested Commit

```bash
git -C Luminous commit -m "fix(settings): 统一设置子页面导航"
```

---

## Task 16: Test Suite Speed And Determinism Pass

**Intent:** keep the growing Flutter and backend tests usable for daily agent execution.

### Scope

- Identify flaky, slow, or timer-dependent tests.
- Replace arbitrary waits with provider/test harness synchronization.
- Keep coverage; do not delete tests to improve speed.
- Document any intentionally skipped platform checks.

### Likely Files

- `Luminous/test/**`
- `Lucent/test/**`
- `Luminous/docs/Project_Guardrails.md` if a new recurring risk is found

### Verification

```bash
flutter test
pnpm --dir ../Lucent test:ci
pnpm --dir ../Lucent test:e2e:ci
```

### Acceptance

- Tests pass twice locally if a flake was suspected.
- Evidence bundle lists before/after runtime if measured.
- No coverage is removed without replacement.

### Suggested Commit

```bash
git -C Luminous commit -m "test: 提升前端测试稳定性"
git -C Lucent commit -m "test: 提升后端测试稳定性"
```

---

## Task 17: Documentation And API Contract Alignment Pass

**Intent:** make the docs match the actual app after three weeks of changes.

### Scope

- Update owner docs only; do not duplicate long status blocks.
- Check README, MigrationLog, OpenApi_Client, Localization, UI plan, Lucent docs/OpenAPI output, public contracts, and changelog.
- Mark mock/static/unsupported features explicitly.
- Use absolute dates.

### Likely Files

- `Lucent/CHANGELOG.md`
- `Lucent/docs/README.md`
- `Lucent/docs/openapi.json`
- `Lucent/docs/public/*.md`
- `Luminous/docs/MigrationLog.md`
- affected `Luminous/docs/migration-log/YYYY-MM-DD.md` entries
- `Luminous/docs/OpenApi_Client.md`
- `Luminous/docs/UI_Implementation_Plan.md`
- `Luminous/docs/Localization.md`
- `Luminous/docs/Current_State.md`
- `Luminous/docs/Next_Plan.md`
- `Luminous/docs/Project_Guardrails.md`

### Verification

```bash
git -C Lucent diff --check
git -C Luminous diff --check -- . ':!packages/lucent_openapi/**'
rg -n "TODO|mock|static|unsupported|reminder|push|OCR|barcode|diagnos|treat|recommend" Lucent/docs Luminous/docs
```

### Acceptance

- Docs describe current behavior, not aspirations.
- Unsupported features are not implied as real.
- No large duplicated status blocks are added to README/AGENTS.

### Suggested Commit

```bash
git -C Luminous commit -m "docs: 对齐当前前端状态"
git -C Lucent commit -m "docs: 对齐当前后端合同"
```

---

## Task 18: Full Regression And Issue Ledger

**Intent:** run a full cross-repo regression and convert any failures into tracked issues or fixes.

### Commands

```bash
git -C Lucent diff --check
git -C Luminous diff --check -- . ':!packages/lucent_openapi/**'

cd Lucent
pnpm dev:stack:up
pnpm db:migrate:all
pnpm exec prisma validate
pnpm lint:check
pnpm build
pnpm test:ci
pnpm test:e2e:ci
pnpm export:openapi

cd ../Luminous
dart run tool/regenerate_lucent_openapi.dart
flutter gen-l10n
flutter analyze
flutter test
flutter build apk --debug
```

### Acceptance

- Full backend and frontend checks pass, or every failure has exact output and an owner.
- Generated OpenAPI changes are intentional.
- Known `fluwx` Built-in Kotlin warning can remain only if still plugin-side and documented.

### Suggested Commit

```bash
git -C Luminous commit -m "test: 记录月度回归结果"
```

---

## Task 19: Reviewer Fix Buffer

**Intent:** reserve time for Codex review findings instead of squeezing fixes into the final handoff.

### Scope

- Fix only issues raised by Codex from Tasks 1-18.
- Do not start new features.
- If no findings exist, use this task for targeted visual/manual verification notes.

### Verification

Use the exact commands requested by Codex for each finding, plus:

```bash
flutter analyze
flutter test
git -C Luminous diff --check -- . ':!packages/lucent_openapi/**'
```

Add backend commands if Lucent changed.

### Acceptance

- Every reviewer finding is fixed, explicitly deferred, or rejected with evidence.
- No unrelated refactors.

### Suggested Commit

```bash
git -C Luminous commit -m "fix: 处理月度计划复审问题"
git -C Lucent commit -m "fix: 处理月度计划复审问题"
```

---

## Task 20: Final Handoff And Next-Month Backlog

**Intent:** close the month with a concise, reviewable status and a scoped backlog for the next plan.

### Scope

- Summarize completed tasks, commits, tests, and remaining unsupported features.
- Update today's `Luminous/docs/migration-log/YYYY-MM-DD.md`.
- Update `Luminous/docs/UI_Implementation_Plan.md`.
- If backend contracts changed, update `Lucent/CHANGELOG.md` and API docs.
- Create a short next-month candidate list, not a full new plan.

### Commands

```bash
git -C Lucent status --short --branch
git -C Lucent log --oneline -n 10
git -C Luminous status --short --branch
git -C Luminous log --oneline -n 10
git -C Lucent diff --check
git -C Luminous diff --check -- . ':!packages/lucent_openapi/**'
flutter analyze
flutter test
```

### Acceptance

- Final handoff names exact commit hashes.
- Remaining risks are explicit.
- Next-month backlog does not claim external service, deployment, or production readiness.

### Suggested Commit

```bash
git -C Luminous commit -m "docs(plan): 完成月度执行交接"
```

---

## Final Review Checklist

- [ ] Every task has an evidence bundle.
- [ ] Lucent and Luminous commits are small and task-scoped.
- [ ] OpenAPI was regenerated only through supported commands.
- [ ] Generated DTOs do not cross into Luminous domain/presentation.
- [ ] Nullable writes have omitted/null/value coverage.
- [ ] User-owned backend endpoints test auth and user isolation.
- [ ] Signed-out frontend paths do not loop protected APIs.
- [ ] Writes invalidate every affected provider.
- [ ] Loading states preserve static UI and use local skeletons only for backend-backed sections.
- [ ] Settings/account child pages use standard navigation, not bottom sheets.
- [ ] More, Today, Medicine, and Record docs state real/static/unsupported boundaries.
- [ ] No feature is described as diagnosis, treatment, push reminder execution, OCR/barcode execution, or wearable sync unless it truly exists.
- [ ] Full regression commands pass or exact unresolved failures are documented.
