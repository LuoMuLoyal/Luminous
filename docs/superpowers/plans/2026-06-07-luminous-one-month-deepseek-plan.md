# Luminous One-Month DeepSeek 推进 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** From 2026-06-07 through 2026-07-06, move Luminous from the latest committed five-tab health assistant baseline into steadier real health loops: Mine post-refactor hardening, Record type-specific forms, environment snapshot wiring, cross-feature state refresh coverage, and reminder scheduling groundwork without presenting planned features as real.

**Architecture:** Keep Lucent as the only backend contract source and Luminous as the Flutter client. Add narrow feature/repository boundaries before wiring real data, keep generated OpenAPI DTOs inside data-layer code, and keep unsupported surfaces explicitly mock/static/planned.

**Tech Stack:** Flutter, Riverpod, GoRouter, Flutter gen-l10n ARB files, Dio, generated `packages/lucent_openapi`, Lucent NestJS/OpenAPI, widget tests, integration tests.

---

## Baseline Anchor

This plan is based on the latest committed state observed on 2026-06-07:

- `Luminous` repository: branch `refactor`, commit `682f1d17ef84939bf6e68493f011f8f81eb21e9a`, `refactor(mine): 我的页面重做`.
- `Lucent` repository: branch `dev`, commit `cc4712e9c042a464790a2916a289ecf6d9db9217`, `feat(environment): 添加环境快照接口`.
- The workspace root `D:\25080\Documents\VSCodeProject\Lumos` is not a git repository. `Lucent` and `Luminous` are separate repositories.
- The Luminous working tree had unrelated uncommitted local edits when this plan was written. DeepSeek must treat `HEAD` as the baseline and protect unrelated dirty files before editing.
- This plan supersedes `docs/superpowers/plans/2026-06-06-thirty-day-lumos-deepseek-plan.md` for new execution dispatches because the older plan was anchored to Luminous `720a460` and predates the committed Mine rewrite.

## Scope Check

The month spans several subsystems, so tasks are split into independently reviewable slices. Each task should produce working, testable software on its own and should normally end with one commit in the touched repository. Cross-repo contract tasks may produce one Lucent commit and one Luminous commit.

## Required Reading

Before Task 1, read these committed files:

- `Luminous/AGENTS.md`
- `Luminous/README.md`
- `Luminous/docs/README.md`
- `Luminous/docs/Current_State.md`
- `Luminous/docs/Next_Plan.md`
- `Luminous/docs/Project_Guardrails.md`
- `Luminous/docs/UI_Implementation_Plan.md`
- `Luminous/docs/OpenApi_Client.md`
- `Luminous/docs/Localization.md`
- `Lucent/docs/public/ROADMAP.md`
- `Lucent/docs/public/reminder-contract.md`
- `Lucent/docs/public/environment-contract.md`

## File Structure Map

Planned Luminous files and responsibilities:

- `lib/features/mine/**`: keep the committed Mine rewrite stable; fix only regressions found by tests.
- `test/mine_page_test.dart`: mobile Mine dashboard, signed-in/signed-out, route entry coverage.
- `test/mine_edit_pages_test.dart`: Mine health-context edit page regression coverage.
- `lib/features/record/presentation/widgets/daily_record_form_fields.dart`: new reusable Record create/edit field widget for water, vital, symptom, and note.
- `lib/features/record/presentation/pages/record_create.dart`: consume the reusable form widget and keep create provider invalidation.
- `lib/features/record/presentation/pages/record_edit.dart`: consume the reusable form widget, keep omitted/null/value PATCH behavior, and replace page-level spinner with a skeleton/local state view.
- `test/record_form_fields_test.dart`: field visibility and input mapping tests for the reusable Record form.
- `test/record_page_test.dart`: create/edit/delete/date/detail regression tests.
- `lib/features/environment/domain/entities/environment_snapshot.dart`: Luminous-owned environment domain entity; no generated DTO imports.
- `lib/features/environment/domain/repositories/environment_repository.dart`: repository interface for current environment snapshot.
- `lib/features/environment/data/datasources/environment_remote_data_source.dart`: generated `EnvironmentApi.environmentControllerGetSnapshotV1` wrapper.
- `lib/features/environment/data/mappers/environment_mapper.dart`: maps generated DTOs to Luminous domain entities.
- `lib/features/environment/data/repositories/lucent_environment_repository.dart`: Lucent-backed environment repository with static mock fallback at caller boundary.
- `lib/features/environment/data/providers/environment_data_providers.dart`: Riverpod providers for Environment API/data source/repository.
- `lib/features/more/data/repositories/mock_more_repository.dart`: keep static non-environment More sections available as fallback and planned placeholders.
- `lib/features/more/data/repositories/lucent_more_repository.dart`: merge static More tools with real environment snapshot.
- `lib/features/more/domain/entities/more_dashboard.dart`: add source/update metadata to `MoreEnvironmentSnapshot`.
- `lib/features/more/presentation/providers/more_dashboard_provider.dart`: remove stale environment backend wait marker and use the real repository provider.
- `test/more_environment_repository_test.dart`: maps static/live/error environment states into More dashboard.
- `test/more_page_test.dart`: More planned badges plus real environment/reference badge coverage.
- `lib/features/today/data/repositories/lucent_today_repository.dart`: consume the shared environment repository for Today environment signals.
- `lib/features/today/domain/entities/today_dashboard.dart`: carry environment source metadata needed by the view.
- `test/today_page_test.dart`: Today real/static/partial-data coverage.
- `lib/features/settings/presentation/providers/notification_settings_controller.dart`: keep preference toggles local and prepare for schedule refresh.
- `lib/features/settings/data/services/notification_permission_service.dart`: permission bridge stays the platform boundary.
- `lib/features/settings/data/services/local_notification_schedule_service.dart`: new device-local schedule/cancel wrapper only after a schedule source exists.
- `test/settings_flow_test.dart`: notification permission, preference persistence, and local scheduling bridge tests.
- `docs/migration-log/2026-06-07.md`: Task 1 baseline entry if a committed-state regression is fixed.
- `docs/migration-log/2026-06-08.md`: Task 2 Mine hardening entry.
- `docs/migration-log/2026-06-11.md`: Task 3 Record form extraction entry.
- `docs/migration-log/2026-06-14.md`: Task 4 Record common type entry.
- `docs/migration-log/2026-06-18.md`: Task 5 provider invalidation entry.
- `docs/migration-log/2026-06-21.md`: Task 6 More environment entry.
- `docs/migration-log/2026-06-24.md`: Task 7 Today environment entry.
- `docs/migration-log/2026-06-26.md`: Task 8 medicine adherence entry.
- `docs/migration-log/2026-06-29.md`: Task 9 OpenAPI reminder sync entry.
- `docs/migration-log/2026-07-02.md`: Task 10 reminder UI/local bridge entry.
- `docs/migration-log/2026-07-05.md`: Task 11 monthly regression entry.
- `docs/Current_State.md`, `docs/Next_Plan.md`, `docs/UI_Implementation_Plan.md`, `docs/OpenApi_Client.md`, `docs/Localization.md`: update only when the corresponding task changes behavior, docs, OpenAPI, or visible text.

Planned Lucent files for reminder contract implementation:

- `prisma/schema.prisma`: add `UserNotificationPreference` and `UserMedicineReminder` only in the reminder backend task.
- `src/modules/notifications/**`: new user-scoped notification preference module.
- `src/modules/reminders/**`: new user-scoped medicine reminder schedule module.
- `docs/public/reminder-contract.md`: keep contract aligned with actual implementation.
- `docs/openapi.json`: regenerate through Lucent's supported export command.

## Execution Protocol For DeepSeek

- [ ] Before each task, run `git -C D:\25080\Documents\VSCodeProject\Lumos\Luminous status --short --branch`.
- [ ] Before each task, run `git -C D:\25080\Documents\VSCodeProject\Lumos\Lucent status --short --branch` if the task can touch Lucent.
- [ ] If unrelated dirty files exist, leave them untouched and name them in the handoff.
- [ ] Execute exactly one task, then stop for review.
- [ ] Use ARB files for every new user-visible string and run `flutter gen-l10n`.
- [ ] Do not import `package:lucent_openapi` from Luminous presentation/domain code.
- [ ] Do not run ad-hoc OpenAPI generator commands. Use `dart run tool/regenerate_lucent_openapi.dart` from `Luminous`.
- [ ] Keep mock/static/planned features labeled. Do not describe OCR, barcode, device sync, family profiles, push delivery, diagnosis, or treatment as implemented.

Return this evidence bundle after each task:

```text
Task:
Status: DONE / DONE_WITH_CONCERNS / BLOCKED
Baseline commit:
Touched files:
Behavior changed:
Commands run:
Command results:
Generated artifacts:
Provider invalidation:
OpenAPI paths/schemas:
Docs updated:
Unrelated dirty files left untouched:
Risks / reviewer notes:
Commit:
```

## Month Schedule

| Dates | Task |
| --- | --- |
| 2026-06-07 | Task 1: Baseline guardrail and Mine regression check |
| 2026-06-08 to 2026-06-10 | Task 2: Mine post-refactor hardening |
| 2026-06-11 to 2026-06-13 | Task 3: Record reusable form fields |
| 2026-06-14 to 2026-06-17 | Task 4: Record common type refinement |
| 2026-06-18 to 2026-06-20 | Task 5: Cross-feature provider invalidation coverage |
| 2026-06-21 to 2026-06-23 | Task 6: Environment repository and More integration |
| 2026-06-24 to 2026-06-25 | Task 7: Today environment integration |
| 2026-06-26 to 2026-06-28 | Task 8: Medicine adherence and reminder source audit |
| 2026-06-29 to 2026-07-01 | Task 9: Lucent reminder schedule API, no push delivery |
| 2026-07-02 to 2026-07-04 | Task 10: Luminous reminder schedule UI/local bridge |
| 2026-07-05 | Task 11: Month regression and docs alignment |
| 2026-07-06 | Task 12: Reviewer fix buffer and next-month handoff |

---

## Task 1: Baseline Guardrail And Mine Regression Check

**Intent:** lock the execution baseline and confirm the committed Mine rewrite is testable before new work starts.

**Files:**

- Modify: `docs/migration-log/2026-06-07.md`
- Modify: `docs/Next_Plan.md`
- Test: `test/mine_page_test.dart`
- Test: `test/mine_edit_pages_test.dart`

- [ ] **Step 1: Record branch and dirty state**

Run:

```powershell
git -C D:\25080\Documents\VSCodeProject\Lumos\Luminous branch --show-current
git -C D:\25080\Documents\VSCodeProject\Lumos\Luminous log -1 --oneline
git -C D:\25080\Documents\VSCodeProject\Lumos\Luminous status --short --branch
git -C D:\25080\Documents\VSCodeProject\Lumos\Lucent branch --show-current
git -C D:\25080\Documents\VSCodeProject\Lumos\Lucent log -1 --oneline
git -C D:\25080\Documents\VSCodeProject\Lumos\Lucent status --short --branch
```

Expected:

- Luminous baseline starts at `682f1d1 refactor(mine): 我的页面重做`.
- Lucent baseline starts at `cc4712e feat(environment): 添加环境快照接口`.
- Any unrelated dirty files are named and left untouched.

- [ ] **Step 2: Run Mine-focused tests**

Run:

```powershell
flutter test test/mine_page_test.dart test/mine_edit_pages_test.dart
```

Expected: PASS.

- [ ] **Step 3: Update docs only if the test baseline changes project state**

If tests reveal a real committed-state regression and it is fixed in this task, append the migration entry to `docs/migration-log/2026-06-07.md` and update `docs/Next_Plan.md` to remove completed Mine follow-up work. If no code changes happen, do not edit docs.

- [ ] **Step 4: Verify docs and whitespace**

Run:

```powershell
git diff --check -- . ':!packages/lucent_openapi/**'
```

Expected: no whitespace errors in touched files.

- [ ] **Step 5: Commit**

If files changed, commit:

```powershell
git add docs/migration-log/2026-06-07.md docs/Next_Plan.md test/mine_page_test.dart test/mine_edit_pages_test.dart lib/features/mine
git commit -m "test(mine): 稳定我的页面重做回归"
```

If no files changed, return `Commit: not created, baseline tests passed without changes`.

## Task 2: Mine Post-Refactor Hardening

**Intent:** finish the Mine rewrite by making signed-in, signed-out, routing, and edit-page behavior resilient.

**Files:**

- Modify: `lib/features/mine/presentation/mine_page.dart`
- Modify: `lib/features/mine/presentation/widgets/mine_dashboard_view.dart`
- Modify: `lib/features/mine/presentation/widgets/mine_sections.dart`
- Modify: `lib/features/mine/presentation/providers/mine_dashboard_provider.dart`
- Modify: `test/mine_page_test.dart`
- Modify: `test/mine_edit_pages_test.dart`

- [ ] **Step 1: Add missing signed-out assertions**

In `test/mine_page_test.dart`, ensure the signed-out test asserts:

- `healthContextSnapshotProvider` is not called.
- the page shows `mineSignedOutNoticeTitle`.
- the page does not show `mineErrorTitle`.
- the login action routes to `/login`.

Run:

```powershell
flutter test test/mine_page_test.dart --plain-name "Mine page renders signed-out static view without loading"
```

Expected before fix if coverage is missing: FAIL because the route assertion is not present. Expected after fix: PASS.

- [ ] **Step 2: Add edit-route regression coverage**

In `test/mine_edit_pages_test.dart`, cover these routes:

- `/mine/profile/edit`
- `/mine/allergies/edit`
- `/mine/conditions/edit`
- `/mine/current-medicines/edit`

Each test must assert the standard child header with back button and centered localized title.

- [ ] **Step 3: Fix only failing Mine behavior**

Use existing `PageScaffoldShell`, `SettingsBackButton`, ARB keys, and Mine repository/provider patterns. Do not change dashboard composition unless a test exposes a regression.

- [ ] **Step 4: Verify**

Run:

```powershell
flutter analyze
flutter test test/mine_page_test.dart test/mine_edit_pages_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```powershell
git add lib/features/mine test/mine_page_test.dart test/mine_edit_pages_test.dart docs/migration-log/2026-06-08.md docs/UI_Implementation_Plan.md
git commit -m "fix(mine): 收紧我的页面重做回归"
```

## Task 3: Record Reusable Form Fields

**Intent:** remove create/edit duplication and make type-specific Record form work testable before changing user behavior.

**Files:**

- Create: `lib/features/record/presentation/widgets/daily_record_form_fields.dart`
- Modify: `lib/features/record/presentation/pages/record_create.dart`
- Modify: `lib/features/record/presentation/pages/record_edit.dart`
- Create: `test/record_form_fields_test.dart`
- Modify: `test/record_page_test.dart`
- Modify: `lib/l10n/app_zh.arb`
- Modify: `lib/l10n/app_en.arb`
- Generated: `lib/l10n/app_localizations*.dart`

- [ ] **Step 1: Write form widget tests**

Create `test/record_form_fields_test.dart` with tests for these visible field sets:

- `DailyRecordKind.water`: kind, value, unit, note, image; no title.
- `DailyRecordKind.vital`: kind, title, value, unit, note, image.
- `DailyRecordKind.symptom`: kind, title, value, note, image; no unit.
- `DailyRecordKind.note`: kind, title, note, image; no value, no unit.

Run:

```powershell
flutter test test/record_form_fields_test.dart
```

Expected: FAIL because `DailyRecordFormFields` does not exist.

- [ ] **Step 2: Create the reusable widget**

Create `DailyRecordFormFields` in `lib/features/record/presentation/widgets/daily_record_form_fields.dart` with this public shape:

```dart
class DailyRecordFormFields extends StatelessWidget {
  const DailyRecordFormFields({
    super.key,
    required this.kind,
    required this.onKindChanged,
    required this.valueController,
    required this.unitController,
    required this.titleController,
    required this.noteController,
  });

  final DailyRecordKind kind;
  final ValueChanged<DailyRecordKind> onKindChanged;
  final TextEditingController valueController;
  final TextEditingController unitController;
  final TextEditingController titleController;
  final TextEditingController noteController;
}
```

The widget owns only field visibility and labels. It must not upload images, save records, invalidate providers, or read repositories.

- [ ] **Step 3: Refactor create page**

Replace the duplicated dropdown/text fields in `record_create.dart` with `DailyRecordFormFields`. Keep:

- signed-out prompt
- image attachment field
- `DailyRecordCreateInput`
- `recordDashboardProvider` invalidation
- `todayDashboardProvider` invalidation
- save failure toast

- [ ] **Step 4: Refactor edit page**

Replace duplicated dropdown/text fields in `record_edit.dart` with `DailyRecordFormFields`. Keep:

- signed-out prompt
- detail load by id
- existing image attachment behavior
- `dailyRecordNoChange` attachment PATCH behavior
- explicit empty-field clearing for title/value/unit/note
- delete confirmation
- provider invalidation after save/delete

- [ ] **Step 5: Replace loading spinner**

The edit page currently uses `CircularProgressIndicator` while loading. Replace it with a local shimmer or `AppStateSkeletonView` according to `AGENTS.md`. Do not use a full-page blank loading screen.

- [ ] **Step 6: Verify**

Run:

```powershell
flutter gen-l10n
flutter analyze
flutter test test/record_form_fields_test.dart test/record_page_test.dart
```

Expected: PASS.

- [ ] **Step 7: Commit**

```powershell
git add lib/features/record lib/l10n test/record_form_fields_test.dart test/record_page_test.dart docs/migration-log/2026-06-11.md docs/Localization.md docs/UI_Implementation_Plan.md
git commit -m "refactor(record): 提取每日记录表单字段"
```

## Task 4: Record Common Type Refinement

**Intent:** make the four supported common record types feel complete without adding unsupported medical analytics.

**Files:**

- Modify: `lib/features/record/presentation/widgets/daily_record_form_fields.dart`
- Modify: `lib/features/record/presentation/pages/record_create.dart`
- Modify: `lib/features/record/presentation/pages/record_edit.dart`
- Modify: `test/record_form_fields_test.dart`
- Modify: `test/record_page_test.dart`
- Modify: `lib/l10n/app_zh.arb`
- Modify: `lib/l10n/app_en.arb`
- Generated: `lib/l10n/app_localizations*.dart`

- [ ] **Step 1: Define exact field rules**

Implement these rules only:

| Kind | Fields | Defaults |
| --- | --- | --- |
| `water` | value, unit, note, image | unit defaults to `ml`; title omitted |
| `vital` | title, value, unit, note, image | no automatic title |
| `symptom` | title, value, note, image | value label is localized severity/feeling text; unit omitted |
| `note` | title, note, image | value and unit omitted |

Leave `meal`, `mood`, and `activity` on the existing bounded generic behavior until Lucent has richer typed contracts.

- [ ] **Step 2: Add tests for input mapping**

In `test/record_page_test.dart`, add create/edit tests proving:

- water create sends `unit: 'ml'` when the unit field is untouched.
- water edit can clear `value` and `note`.
- symptom create sends title and value, and does not send unit.
- note create sends title and note, and does not send value/unit.

- [ ] **Step 3: Implement minimal mapping**

Keep `DailyRecordCreateInput` and `DailyRecordUpdateInput` unchanged. Map omitted fields to `null` on create and to explicit `null` on edit only when the visible field is empty. Do not add new backend DTOs.

- [ ] **Step 4: Verify**

Run:

```powershell
flutter gen-l10n
flutter analyze
flutter test test/record_form_fields_test.dart test/record_page_test.dart test/today_page_test.dart
```

Expected: PASS. Today tests are required because Record writes invalidate Today.

- [ ] **Step 5: Commit**

```powershell
git add lib/features/record lib/l10n test/record_form_fields_test.dart test/record_page_test.dart docs/migration-log/2026-06-14.md docs/Localization.md docs/Next_Plan.md
git commit -m "feat(record): 完善常用记录类型表单"
```

## Task 5: Cross-Feature Provider Invalidation Coverage

**Intent:** prevent stale Today, Record, Medicine, Mine, and Account state after writes.

**Files:**

- Modify: `test/record_page_test.dart`
- Modify: `test/medicine_page_test.dart`
- Modify: `test/today_page_test.dart`
- Modify: `test/search_page_test.dart`
- Modify: `test/account_settings_page_test.dart`
- Modify only when tests fail: corresponding provider/page files under `lib/features/**`
- Modify: `docs/Project_Guardrails.md`

- [ ] **Step 1: Write the refresh matrix in tests**

Cover these refresh requirements with provider-level or widget tests:

| Write action | Must refresh |
| --- | --- |
| daily record create/edit/delete | Record dashboard, Today dashboard |
| manual dose taken/skipped | Medicine workspace, Today dashboard |
| current medicine create/update/delete | health context snapshot, Medicine workspace, Today dashboard, Mine dashboard |
| search add-to-current-medicines | health context snapshot, Medicine workspace, Today dashboard, Mine dashboard |
| account profile/email/security mutation | auth session/account data and Mine account summary when visible |

- [ ] **Step 2: Run targeted tests**

Run:

```powershell
flutter test test/record_page_test.dart test/medicine_page_test.dart test/today_page_test.dart test/search_page_test.dart test/account_settings_page_test.dart
```

Expected before fixes: at least one new test may fail if invalidation is missing.

- [ ] **Step 3: Add missing invalidations**

Use `ref.invalidate(...)` next to the write success path. Keep write-side ownership local to the feature doing the mutation. Do not introduce a global event bus.

- [ ] **Step 4: Verify**

Run:

```powershell
rg "invalidate\(" lib/features
flutter analyze
flutter test
```

Expected: PASS. The evidence bundle must list every provider invalidated by each touched write path.

- [ ] **Step 5: Commit**

```powershell
git add lib/features test docs/Project_Guardrails.md docs/migration-log/2026-06-18.md
git commit -m "test(state): 补齐跨功能刷新覆盖"
```

## Task 6: Environment Repository And More Integration

**Intent:** use Lucent's committed environment snapshot API in More while keeping the rest of More explicitly planned/mock.

**Files:**

- Create: `lib/features/environment/domain/entities/environment_snapshot.dart`
- Create: `lib/features/environment/domain/repositories/environment_repository.dart`
- Create: `lib/features/environment/data/datasources/environment_remote_data_source.dart`
- Create: `lib/features/environment/data/mappers/environment_mapper.dart`
- Create: `lib/features/environment/data/repositories/lucent_environment_repository.dart`
- Create: `lib/features/environment/data/providers/environment_data_providers.dart`
- Create: `lib/features/more/data/repositories/lucent_more_repository.dart`
- Modify: `lib/features/more/data/repositories/mock_more_repository.dart`
- Modify: `lib/features/more/domain/entities/more_dashboard.dart`
- Modify: `lib/features/more/presentation/providers/more_dashboard_provider.dart`
- Modify: `lib/features/more/presentation/widgets/more_dashboard_sections.dart`
- Modify: `lib/features/more/presentation/widgets/more_dashboard_panels.dart`
- Modify: `lib/features/more/presentation/widgets/more_copy.dart`
- Create: `test/more_environment_repository_test.dart`
- Modify: `test/more_page_test.dart`
- Modify: `lib/l10n/app_zh.arb`
- Modify: `lib/l10n/app_en.arb`
- Generated: `lib/l10n/app_localizations*.dart`

- [ ] **Step 1: Write repository tests**

Create tests proving:

- generated `EnvironmentSnapshotDto.dataSource == 'static'` maps to a visible reference/source state.
- More dashboard still contains emergency/family/AI/device/knowledge planned sections from the mock dashboard.
- API failure falls back to the current static environment values and marks the source as fallback/static.

Run:

```powershell
flutter test test/more_environment_repository_test.dart
```

Expected: FAIL because the environment feature does not exist.

- [ ] **Step 2: Add Luminous environment domain entity**

Use a Luminous-owned entity with this shape:

```dart
class EnvironmentSnapshot {
  const EnvironmentSnapshot({
    required this.pollenLevel,
    required this.uvLevel,
    required this.airQualityLevel,
    required this.temperatureCelsius,
    required this.humidityPercent,
    required this.updatedAt,
    required this.dataSource,
    required this.regionHint,
  });

  final String pollenLevel;
  final String uvLevel;
  final String airQualityLevel;
  final num temperatureCelsius;
  final num humidityPercent;
  final DateTime updatedAt;
  final EnvironmentDataSource dataSource;
  final String? regionHint;
}

enum EnvironmentDataSource { staticReference, live, fallback }
```

Generated DTOs stay in `data/datasources` and `data/mappers`.

- [ ] **Step 3: Implement remote data source**

Call:

```dart
environmentApi.environmentControllerGetSnapshotV1(lat: lat, lon: lon)
```

Use `lucentEnvironmentApiProvider` or `LucentDioClient.environmentApi`; do not instantiate `LucentOpenapi` directly.

- [ ] **Step 4: Wire More repository**

`LucentMoreRepository` should fetch the mock base dashboard, replace only `dashboard.environment`, and leave other More sections unchanged. Remove the stale environment wait marker from `more_dashboard_provider.dart`.

- [ ] **Step 5: Add source labels**

Add localized labels:

- Chinese: `参考值`, `实时`, `本地参考`
- English: `Reference`, `Live`, `Local reference`

Display `参考值` / `Reference` for `dataSource == staticReference`.

- [ ] **Step 6: Verify**

Run:

```powershell
flutter gen-l10n
flutter analyze
flutter test test/more_environment_repository_test.dart test/more_page_test.dart
```

Expected: PASS.

- [ ] **Step 7: Commit**

```powershell
git add lib/features/environment lib/features/more lib/l10n test/more_environment_repository_test.dart test/more_page_test.dart docs/migration-log/2026-06-21.md docs/Localization.md docs/UI_Implementation_Plan.md docs/Current_State.md docs/Next_Plan.md
git commit -m "feat(more): 接入环境快照参考数据"
```

## Task 7: Today Environment Integration

**Intent:** replace Today's static environment signals with the same real Lucent snapshot path used by More.

**Files:**

- Modify: `lib/features/today/domain/entities/today_dashboard.dart`
- Modify: `lib/features/today/data/repositories/lucent_today_repository.dart`
- Modify: `lib/features/today/presentation/widgets/today_dashboard_view.dart`
- Modify: `lib/features/environment/**`
- Modify: `test/today_page_test.dart`
- Modify: `test/more_environment_repository_test.dart`
- Modify: `lib/l10n/app_zh.arb`
- Modify: `lib/l10n/app_en.arb`
- Generated: `lib/l10n/app_localizations*.dart`

- [ ] **Step 1: Add Today fallback tests**

In `test/today_page_test.dart`, cover:

- environment API static snapshot renders pollen and UV levels.
- environment API failure keeps Today available.
- source label is reference/static when `dataSource == staticReference`.

Run:

```powershell
flutter test test/today_page_test.dart
```

Expected before implementation: FAIL because Today uses `_staticEnvironment`.

- [ ] **Step 2: Extend Today environment entity**

Add source metadata to `TodayEnvironmentSummary`:

```dart
class TodayEnvironmentSummary {
  const TodayEnvironmentSummary({
    required this.signals,
    required this.dataSource,
  });

  final List<TodayEnvironmentSignal> signals;
  final TodayEnvironmentDataSource dataSource;
}

enum TodayEnvironmentDataSource { staticReference, live, fallback }
```

- [ ] **Step 3: Map environment snapshot into Today**

In `LucentTodayRepository`, read `environmentRepositoryProvider` and map:

- pollen `low/medium/high` to existing `TodayEnvironmentLevel`
- UV `low/moderate` to `medium` or `low`, and `high/very_high/extreme` to `high`
- on error, use the current static summary with `fallback`

- [ ] **Step 4: Keep Today factual**

Do not add medical advice copy. The Today environment card can say it is reference/static data, but it must not tell the user to diagnose, treat, or change medication.

- [ ] **Step 5: Verify**

Run:

```powershell
flutter gen-l10n
flutter analyze
flutter test test/today_page_test.dart test/more_environment_repository_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit**

```powershell
git add lib/features/today lib/features/environment lib/l10n test/today_page_test.dart test/more_environment_repository_test.dart docs/migration-log/2026-06-24.md docs/Localization.md docs/UI_Implementation_Plan.md docs/Current_State.md docs/Next_Plan.md
git commit -m "feat(today): 使用环境快照参考数据"
```

## Task 8: Medicine Adherence And Reminder Source Audit

**Intent:** make the current medicine/dose-log state reliable before building reminder schedules.

**Files:**

- Modify: `lib/features/medicine/data/repositories/lucent_medicine_workspace.dart`
- Modify: `lib/features/medicine/presentation/widgets/medicine_mobile_drugbox_section.dart`
- Modify: `lib/features/medicine/presentation/widgets/medicine_mobile_sections.dart`
- Modify: `lib/features/today/data/repositories/lucent_today_repository.dart`
- Modify: `test/medicine_page_test.dart`
- Modify: `test/today_page_test.dart`
- Modify: `docs/Next_Plan.md`

- [ ] **Step 1: Add dose-log state tests**

Cover:

- taken dose renders taken state.
- skipped dose renders skipped state.
- no dose log renders pending state.
- failed dose-log fetch keeps the Medicine page available.
- Today pending count excludes taken and skipped medicines.

Run:

```powershell
flutter test test/medicine_page_test.dart test/today_page_test.dart
```

Expected before fixes: failing tests identify missing coverage or stale state.

- [ ] **Step 2: Audit reminder schedule source**

Document the current source facts in `docs/Next_Plan.md`:

- Current medicine has display name, strength text, dose text, route, and current medicine id.
- Current medicine does not have structured reminder hour/minute/day fields in Luminous.
- Local scheduling must wait for a structured schedule source from Lucent.

- [ ] **Step 3: Fix only adherence defects**

Fix mapping, fallback, or invalidation defects found by tests. Do not parse free-form `doseText` into scheduled notifications.

- [ ] **Step 4: Verify**

Run:

```powershell
flutter analyze
flutter test test/medicine_page_test.dart test/today_page_test.dart
flutter test
```

Expected: PASS.

- [ ] **Step 5: Commit**

```powershell
git add lib/features/medicine lib/features/today test/medicine_page_test.dart test/today_page_test.dart docs/Next_Plan.md docs/migration-log/2026-06-26.md docs/UI_Implementation_Plan.md
git commit -m "fix(medicine): 稳定用药打卡状态"
```

## Task 9: Lucent Reminder Schedule API, No Push Delivery

**Intent:** implement backend-owned reminder schedules and preferences without push delivery or external credentials.

**Files:**

- Modify: `Lucent/prisma/schema.prisma`
- Create: `Lucent/src/modules/notifications/**`
- Create: `Lucent/src/modules/reminders/**`
- Modify: `Lucent/src/app.module.ts`
- Modify: `Lucent/docs/public/reminder-contract.md`
- Generated: `Lucent/docs/openapi.json`
- Modify after OpenAPI export: `Luminous/packages/lucent_openapi/**`
- Modify after regeneration: `Luminous/docs/OpenApi_Client.md`

- [ ] **Step 1: Write Lucent tests first**

Add tests for:

- user can read default notification preferences.
- user can patch notification preferences.
- user can create/list/update/delete own medicine reminder.
- user cannot read/update/delete another user's reminder.
- invalid hour/minute is rejected.

Run:

```powershell
pnpm --dir D:\25080\Documents\VSCodeProject\Lumos\Lucent test -- notifications --runInBand
pnpm --dir D:\25080\Documents\VSCodeProject\Lumos\Lucent test -- reminders --runInBand
```

Expected before implementation: FAIL because modules do not exist.

- [ ] **Step 2: Add Prisma models exactly from contract**

Use the `UserNotificationPreference` and `UserMedicineReminder` shapes from `Lucent/docs/public/reminder-contract.md`. Keep push token, delivery worker, delivery log, FCM, APNs, email, SMS, and calendar integration out of scope.

- [ ] **Step 3: Add controllers and services**

Use user-scoped routes:

- `GET /api/v1/me/notification-preferences`
- `PATCH /api/v1/me/notification-preferences`
- `GET /api/v1/me/medicine-reminders`
- `POST /api/v1/me/medicine-reminders`
- `PATCH /api/v1/me/medicine-reminders/:id`
- `DELETE /api/v1/me/medicine-reminders/:id`

Every query/mutation must scope by the authenticated user id.

- [ ] **Step 4: Export OpenAPI**

Run:

```powershell
pnpm --dir D:\25080\Documents\VSCodeProject\Lumos\Lucent lint:check
pnpm --dir D:\25080\Documents\VSCodeProject\Lumos\Lucent build
pnpm --dir D:\25080\Documents\VSCodeProject\Lumos\Lucent test:ci
pnpm --dir D:\25080\Documents\VSCodeProject\Lumos\Lucent export:openapi
```

Expected: PASS and `Lucent/docs/openapi.json` changes intentionally.

- [ ] **Step 5: Regenerate Luminous client**

Run from `Luminous`:

```powershell
dart run tool/regenerate_lucent_openapi.dart
flutter analyze
```

Expected: PASS. Update `docs/OpenApi_Client.md` with the new path/schema counts from export output.

- [ ] **Step 6: Commit**

Commit Lucent:

```powershell
git -C D:\25080\Documents\VSCodeProject\Lumos\Lucent add prisma src docs
git -C D:\25080\Documents\VSCodeProject\Lumos\Lucent commit -m "feat(reminders): 添加用户用药提醒计划接口"
```

Commit Luminous generated client:

```powershell
git add packages/lucent_openapi docs/OpenApi_Client.md docs/migration-log/2026-06-29.md
git commit -m "chore(openapi): 同步提醒计划接口"
```

## Task 10: Luminous Reminder Schedule UI And Local Bridge

**Intent:** let users manage structured medicine reminder schedules and schedule local device notifications from those schedules, still with no push delivery.

**Files:**

- Create: `lib/features/reminders/domain/entities/medicine_reminder.dart`
- Create: `lib/features/reminders/domain/repositories/reminder_repository.dart`
- Create: `lib/features/reminders/data/datasources/reminder_remote_data_source.dart`
- Create: `lib/features/reminders/data/mappers/reminder_mapper.dart`
- Create: `lib/features/reminders/data/repositories/lucent_reminder_repository.dart`
- Create: `lib/features/reminders/data/providers/reminder_data_providers.dart`
- Create: `lib/features/settings/data/services/local_notification_schedule_service.dart`
- Modify: `lib/features/settings/presentation/providers/notification_settings_controller.dart`
- Modify: `lib/features/settings/presentation/pages/notification_settings_page.dart`
- Modify: `lib/features/medicine/presentation/widgets/medicine_mobile_sections.dart`
- Modify: `lib/app/router.dart`
- Modify: `test/settings_flow_test.dart`
- Create: `test/reminder_repository_test.dart`
- Create: `test/local_notification_schedule_service_test.dart`
- Modify: `lib/l10n/app_zh.arb`
- Modify: `lib/l10n/app_en.arb`
- Generated: `lib/l10n/app_localizations*.dart`

- [ ] **Step 1: Write repository tests**

Cover:

- list reminders maps generated DTOs into Luminous domain entities.
- create reminder validates hour 0-23 and minute 0-59 before calling remote data source.
- update reminder can disable `isActive`.
- delete reminder calls the generated API with the reminder id.

Run:

```powershell
flutter test test/reminder_repository_test.dart
```

Expected before implementation: FAIL.

- [ ] **Step 2: Write local scheduling service tests**

Use a fake scheduling adapter and cover:

- granted permission schedules active reminders.
- denied permission saves preferences but does not schedule notifications.
- disabled medication reminder preference cancels medication reminders.
- inactive reminders are canceled.

Run:

```powershell
flutter test test/local_notification_schedule_service_test.dart
```

Expected before implementation: FAIL.

- [ ] **Step 3: Add reminder domain**

Use Luminous-owned domain types:

```dart
class MedicineReminder {
  const MedicineReminder({
    required this.id,
    required this.currentMedicineId,
    required this.label,
    required this.scheduledHour,
    required this.scheduledMinute,
    required this.daysOfWeek,
    required this.isActive,
  });

  final String id;
  final String? currentMedicineId;
  final String? label;
  final int scheduledHour;
  final int scheduledMinute;
  final List<int>? daysOfWeek;
  final bool isActive;
}
```

Do not expose generated OpenAPI DTOs outside `data`.

- [ ] **Step 4: Add Settings schedule management**

Add a child page under settings for medicine reminders. The page must use the standard header, localized text, and no hero/narrative copy. It can list, create, enable/disable, and delete reminders. It must not claim cloud push delivery.

- [ ] **Step 5: Schedule local notifications only from structured reminders**

Use `flutter_local_notifications` through `LocalNotificationScheduleService`. Do not parse current medicine `doseText`. Do not add FCM/APNs or push tokens.

- [ ] **Step 6: Verify**

Run:

```powershell
flutter gen-l10n
flutter analyze
flutter test test/reminder_repository_test.dart test/local_notification_schedule_service_test.dart test/settings_flow_test.dart test/medicine_page_test.dart
flutter test
```

Expected: PASS.

- [ ] **Step 7: Commit**

```powershell
git add lib/features/reminders lib/features/settings lib/features/medicine lib/app/router.dart lib/l10n test/reminder_repository_test.dart test/local_notification_schedule_service_test.dart test/settings_flow_test.dart test/medicine_page_test.dart docs/migration-log/2026-07-02.md docs/Localization.md docs/UI_Implementation_Plan.md docs/Current_State.md docs/Next_Plan.md
git commit -m "feat(reminders): 添加本地用药提醒计划"
```

## Task 11: Month Regression And Docs Alignment

**Intent:** make the docs match the actual app after the month of changes.

**Files:**

- Modify: `docs/Current_State.md`
- Modify: `docs/Next_Plan.md`
- Modify: `docs/UI_Implementation_Plan.md`
- Modify: `docs/OpenApi_Client.md`
- Modify: `docs/Localization.md`
- Modify: `docs/Project_Guardrails.md`
- Modify: `docs/migration-log/2026-07-05.md`
- Modify Lucent docs only if Task 9 changed Lucent behavior.

- [ ] **Step 1: Run full Luminous verification**

Run:

```powershell
flutter gen-l10n
flutter analyze
flutter test
flutter test integration_test
git diff --check -- . ':!packages/lucent_openapi/**'
```

Expected: PASS, or exact platform/environment failure documented.

- [ ] **Step 2: Run Lucent verification if Lucent changed this month**

Run:

```powershell
pnpm --dir D:\25080\Documents\VSCodeProject\Lumos\Lucent lint:check
pnpm --dir D:\25080\Documents\VSCodeProject\Lumos\Lucent build
pnpm --dir D:\25080\Documents\VSCodeProject\Lumos\Lucent test:ci
pnpm --dir D:\25080\Documents\VSCodeProject\Lumos\Lucent export:openapi
```

Expected: PASS.

- [ ] **Step 3: Update docs with exact behavior**

Docs must state:

- Record common forms are supported only for water, vital, symptom, and note.
- Environment data comes from Lucent snapshot and is static/reference unless `dataSource == live`.
- Reminder schedules are local notification triggers from structured reminders, not push delivery.
- More family/device/OCR/barcode/report-import features remain planned/mock unless separate tasks implemented them.

- [ ] **Step 4: Verify docs**

Run:

```powershell
rg -n "OCR|barcode|push|diagnos|treat|doctor|real-time|live reminder|planned|mock|static|reference" docs
git diff --check -- . ':!packages/lucent_openapi/**'
```

Expected: unsupported features are explicitly bounded; no whitespace errors.

- [ ] **Step 5: Commit**

```powershell
git add docs
git commit -m "docs: 对齐月度推进后的前端状态"
```

## Task 12: Reviewer Fix Buffer And Next-Month Handoff

**Intent:** reserve time for review findings and create a short next-month backlog without starting new features.

**Files:**

- Modify only files needed by Codex review findings.
- Modify: `docs/superpowers/plans/next-month-backlog.md`
- Modify: `docs/Next_Plan.md`

- [ ] **Step 1: Address review findings**

Fix only issues raised during review of Tasks 1-11. Do not add new feature scope in this buffer.

- [ ] **Step 2: Run targeted and full checks**

Run the exact command requested by the reviewer for each finding, then run:

```powershell
flutter analyze
flutter test
git diff --check -- . ':!packages/lucent_openapi/**'
```

Run Lucent checks too if a finding touched Lucent.

- [ ] **Step 3: Update next-month backlog**

Create a concise candidate list in `docs/superpowers/plans/next-month-backlog.md` with these sections:

- Ready for implementation
- Needs contract design
- Blocked by external dependency
- Deferred
- Technical debt

Keep it a backlog, not a full plan.

- [ ] **Step 4: Commit**

```powershell
git add docs/superpowers/plans/next-month-backlog.md docs/Next_Plan.md
git commit -m "docs(plan): 更新下月候选清单"
```

## Final Review Checklist

- [ ] Each task produced a reviewable evidence bundle.
- [ ] Dirty files unrelated to a task were left untouched.
- [ ] Luminous generated OpenAPI was regenerated only with `dart run tool/regenerate_lucent_openapi.dart`.
- [ ] No generated OpenAPI DTOs leaked into Luminous domain or presentation code.
- [ ] Record update tests cover omitted field, explicit `null`, and concrete value semantics.
- [ ] Signed-out pages do not repeatedly call protected APIs.
- [ ] Provider invalidation is explicit after Record, Medicine, Search, Mine, and Account writes.
- [ ] Environment labels distinguish reference/static/live/fallback data.
- [ ] Reminders do not claim push delivery unless FCM/APNs infrastructure is actually implemented.
- [ ] New user-visible strings are present in both ARB files and generated localization output.
- [ ] `flutter analyze` and `flutter test` pass.
- [ ] `flutter test integration_test` was run or the exact environment limitation was documented.
- [ ] Lucent checks passed if Lucent changed.
- [ ] Docs state current behavior rather than aspirations.
