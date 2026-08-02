# 同步失败详情 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将 Mine 页同步失败横幅从 Toast 占位行为改为可查看失败项并可重试的详情对话框。

**Architecture:** 复用本地 Drift pending sync queue 作为单一数据源。DAO 提供永久失败条目及重试重置操作，Mine presentation 通过现有 Forui 对话框展示安全诊断字段并调用现有 `SyncWorker.flush()`，不新增后端接口或数据库结构。

**Tech Stack:** Flutter, Riverpod, Drift, Forui, Flutter widget tests, Dart l10n fragments。

---

### Task 1: DAO failure details and retry reset

**Files:**
- Modify: `lib/core/database/daos/pending_sync_dao.dart`
- Test: `test/core/database/dao_test.dart`

- [ ] Write a test that exhausts an item, reads it from `fetchPermanentlyFailed`, and asserts `lastError`, retry count, and metadata.
- [ ] Write a test that resets a permanently failed item and asserts it is returned by `fetchReady` with retry count zero.
- [ ] Run `flutter test test/core/database/dao_test.dart` and confirm the new tests fail because the API is absent.
- [ ] Add `lastError` to `PendingSyncEntry`, map it from Drift, add ordered `fetchPermanentlyFailed()`, and add `resetForRetry(String id)`.
- [ ] Run the DAO test again and confirm it passes.

### Task 2: Mine details dialog and banner interaction

**Files:**
- Create: `lib/features/mine/presentation/widgets/sections/sync_failed_details.dart`
- Modify: `lib/features/mine/presentation/widgets/sections/sync_failed_banner.dart`
- Test: `test/mine/sync_failed_banner_test.dart`

- [ ] Add a widget test with an in-memory pending queue and provider overrides that taps “查看详情” and asserts the dialog renders a real failed item.
- [ ] Run the widget test and confirm it fails because the banner still shows a Toast.
- [ ] Implement the details dialog with localized labels, safe metadata rendering, loading/empty states, and a “重试全部” action.
- [ ] Change the banner callback to load details and open the dialog; remove the success Toast.
- [ ] Run the widget test and confirm it passes.

### Task 3: Localization and documentation

**Files:**
- Modify: `lib/l10n/src/mine_en.arb`
- Modify: `lib/l10n/src/mine_zh.arb`
- Regenerate: `lib/l10n/app_*.arb`, `lib/l10n/app_localizations*.dart`
- Modify: `docs/00-current/Active_UI_Mine_Settings.md`
- Modify: `docs/00-current/Runtime_Snapshot.md`
- Modify: `docs/02-reference/Localization.md`
- Append: `docs/03-logs/migration-log/2026-08-02.md`

- [ ] Add strings for dialog title, field labels, empty/loading/error states, retry action, and retry feedback to the Mine ARB fragments.
- [ ] Run `dart scripts/arb_tools.dart merge` and `flutter gen-l10n`.
- [ ] Record that the banner opens details and supports retry, then append the dated migration entry.
- [ ] Run `dart run scripts/check_doc_coverage.dart --warning-only`.

### Task 4: Verification

- [ ] Run `dart format` on changed Dart files.
- [ ] Run `flutter test test/core/database/dao_test.dart test/mine/sync_failed_banner_test.dart`.
- [ ] Run `flutter analyze`.
- [ ] Inspect `git diff` and confirm unrelated Assistant changes are untouched.
