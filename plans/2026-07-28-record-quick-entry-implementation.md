# Record Quick Entry UX Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild the Record page quick-entry area into a fast action system with type-specific flows, real undo for immediate writes, and a dedicated quick-entry settings surface.

**Architecture:** Keep `RecordQuickEntryPanel` as a presentation widget and move behavior into a quick-entry executor plus type-specific flows. Persist user-facing quick-entry defaults through `QuickEntryPreferences`, route settings through typed GoRouter pages, and use one undo service for immediate writes.

**Tech Stack:** Flutter, Riverpod, GoRouter, Forui, SharedPreferences, existing Lucent repositories, existing generated API clients.

---

## Source Documents

- Design spec: `docs/superpowers/specs/2026-07-28-record-quick-entry-ux-design.md`
- Rolling UX plan: `plans/2026-07-28-record-quick-entry-ux.md`
- Record current state: `docs/00-current/Active_UI_Record.md`
- Medicine current state: `docs/00-current/Active_UI_Medicine.md`
- Luminous project rules: `AGENTS.md`

## File Structure

### Foundation Files

- Modify: `lib/features/record/presentation/widgets/sections/quick_entry_panel.dart`
  - Keep grid/header rendering.
  - Remove in-panel dynamic sort and reorder editing from the main quick panel.
  - Add help affordance, tile badges, and long-press callback hooks.
- Create: `lib/features/record/presentation/controllers/quick_entry.dart`
  - Riverpod controller that receives `RecordQuickAction` taps and delegates to the executor.
- Create: `lib/features/record/presentation/services/quick_entry_executor.dart`
  - Pure-ish orchestration layer for routing actions to flow objects.
- Create: `lib/features/record/presentation/services/quick_entry_undo.dart`
  - Undo action types and rollback coordinator.
- Create: `lib/features/record/presentation/services/quick_entry_context.dart`
  - Small immutable context object: selected date, current time, formatted date/time, auth state.
- Modify: `lib/features/record/presentation/pages/page.dart`
  - Replace `_handleQuickAction` with controller/executor call.
  - Add quick-entry settings header action.
- Modify: `lib/features/record/data/quick_entry_preferences.dart`
  - Add water default amount, water badge mode, sleep badge toggle.
  - Add reset default order helper separate from full reset.
- Modify: `lib/core/config/pref_keys.dart`
  - Add new quick-entry SharedPreferences keys.

### Flow Files

- Create: `lib/features/record/presentation/quick_entry/water_flow.dart`
  - Immediate water create, badge summary helper, undo registration.
- Create: `lib/features/record/presentation/quick_entry/symptom_flow.dart`
  - Common symptom sheet with single-select immediate save and multi-select confirm.
- Create: `lib/features/record/presentation/quick_entry/mood_flow.dart`
  - Mood sheet with single-tap immediate save.
- Create: `lib/features/record/presentation/quick_entry/medication_flow.dart`
  - Medicine list load, nearby pending slot resolution, zero/one/many medicine actions.
- Create: `lib/features/record/presentation/quick_entry/sleep_flow.dart`
  - Sleep start/wake temporary records, in-progress detection, merge confirmation.
- Create: `lib/features/record/presentation/quick_entry/meal_flow.dart`
  - Camera-first meal flow, image upload reuse, manual fallback, confirmation sheet.

### Settings Files

- Create: `lib/features/record/presentation/pages/quick_entry_settings.dart`
  - Dedicated quick-entry settings page.
- Create: `lib/features/record/presentation/pages/quick_entry_reorder.dart`
  - Focused manual order page, disabled when dynamic sorting is enabled.
- Modify: `lib/features/record/presentation/routes.dart`
  - Add `/record/quick-entry-settings` and `/record/quick-entry-settings/reorder`.
- Modify: `lib/app/router.dart`
  - Ensure generated Record routes remain included.
- Modify: `lib/features/settings/presentation/pages/page.dart`
  - Replace inline quick-entry toggles with a secondary navigation tile to the new page.
- Modify: `lib/l10n/src/record_zh.arb`
- Modify: `lib/l10n/src/record_en.arb`
- Modify: `lib/l10n/src/settings_zh.arb`
- Modify: `lib/l10n/src/settings_en.arb`
  - Add only fragment strings; then run ARB merge and `flutter gen-l10n`.

### Medicine Integration Files

- Modify: `lib/features/medicine/data/datasources/dose_log_remote.dart`
  - Add `delete(String doseLogId)` using the existing Lucent delete endpoint.
- Modify: `lib/features/medicine/data/datasources/dose_log_cached.dart`
  - Add cached delete support and pending sync behavior if required by existing cache design.
- Modify: `lib/features/medicine/presentation/providers/reminders.dart`
  - Expose helpers or ensure quick-entry flow can refresh today dose logs.
- Modify: `lib/features/medicine/presentation/providers/workspace.dart`
  - Ensure `DataChangeTopic.doseLogs` refreshes Medicine surfaces after Record writes.

### Docs And Tests

- Modify after each code phase: `plans/2026-07-28-record-quick-entry-ux.md`
- Modify after code phases: `docs/00-current/Active_UI_Record.md`
- Modify when medication sync changes: `docs/00-current/Active_UI_Medicine.md`
- Append after code phases: `docs/03-logs/migration-log/2026-07-28.md`
- Test: `test/record/quick_entry_preferences_test.dart`
- Test: `test/record/presentation/widgets/sections/quick_entry_panel_test.dart`
- Create: `test/record/presentation/controllers/quick_entry_controller_test.dart`
- Create: `test/record/presentation/services/quick_entry_undo_test.dart`
- Create: `test/record/quick_entry/water_flow_test.dart`
- Create: `test/record/quick_entry/symptom_flow_test.dart`
- Create: `test/record/quick_entry/mood_flow_test.dart`
- Create: `test/record/quick_entry/medication_flow_test.dart`
- Create: `test/record/quick_entry/sleep_flow_test.dart`
- Create: `test/record/quick_entry/meal_flow_test.dart`
- Create: `test/record/quick_entry_settings_page_test.dart`
- Modify: `test/settings/page_test.dart`

## Phase 0: Planning Commit

**Files:**

- Create: `plans/2026-07-28-record-quick-entry-implementation.md`
- Modify: `plans/2026-07-28-record-quick-entry-ux.md`

- [ ] **Step 1: Save this implementation plan**

Expected result: the plan exists under `Luminous/plans` so context compaction cannot lose the execution strategy.

- [ ] **Step 2: Update the rolling UX plan**

Add an implementation status section:

```markdown
## 实施状态

- 2026-07-28: 设计稿已确认，开始按阶段实施。阶段 0 产出实施计划；后续每完成一个代码阶段就更新本文档并提交。
```

- [ ] **Step 3: Verify planning-only diff**

Run:

```powershell
git diff -- plans/2026-07-28-record-quick-entry-implementation.md plans/2026-07-28-record-quick-entry-ux.md
git status --short
```

Expected: only the two plan files are changed.

- [ ] **Step 4: Commit phase 0**

Run:

```powershell
git add plans/2026-07-28-record-quick-entry-implementation.md plans/2026-07-28-record-quick-entry-ux.md
git commit -m "docs(record): 快速记录实施计划"
```

Expected: commit succeeds with no code doc-coverage requirement.

## Phase 1: Foundation, Preferences, Settings Skeleton

**Files:**

- Modify: `lib/core/config/pref_keys.dart`
- Modify: `lib/features/record/data/quick_entry_preferences.dart`
- Modify: `lib/features/record/presentation/widgets/sections/quick_entry_panel.dart`
- Modify: `lib/features/record/presentation/pages/page.dart`
- Create: `lib/features/record/presentation/controllers/quick_entry.dart`
- Create: `lib/features/record/presentation/services/quick_entry_context.dart`
- Create: `lib/features/record/presentation/services/quick_entry_executor.dart`
- Create: `lib/features/record/presentation/services/quick_entry_undo.dart`
- Create: `lib/features/record/presentation/pages/quick_entry_settings.dart`
- Create: `lib/features/record/presentation/pages/quick_entry_reorder.dart`
- Modify: `lib/features/record/presentation/routes.dart`
- Modify: `lib/features/settings/presentation/pages/page.dart`
- Modify: `lib/l10n/src/record_zh.arb`
- Modify: `lib/l10n/src/record_en.arb`
- Modify: `lib/l10n/src/settings_zh.arb`
- Modify: `lib/l10n/src/settings_en.arb`
- Modify generated after l10n/codegen: `lib/l10n/app_zh.arb`, `lib/l10n/app_en.arb`, `lib/l10n/app_localizations*.dart`, `lib/features/record/presentation/routes.g.dart`, `lib/features/settings/presentation/routes.g.dart`
- Test: `test/record/quick_entry_preferences_test.dart`
- Test: `test/record/presentation/widgets/sections/quick_entry_panel_test.dart`
- Create: `test/record/presentation/controllers/quick_entry_controller_test.dart`
- Create: `test/record/quick_entry_settings_page_test.dart`
- Modify: `test/settings/page_test.dart`

- [ ] **Step 1: Write failing preference tests**

Add assertions to `test/record/quick_entry_preferences_test.dart`:

```dart
test('default quick-entry action preferences match approved UX', () {
  const prefs = QuickEntryPreferences();

  expect(prefs.waterDefaultAmountMl, 250);
  expect(prefs.waterBadgeMode, QuickEntryWaterBadgeMode.dailyTotal);
  expect(prefs.sleepInProgressBadgeEnabled, isTrue);
});

test('setWaterDefaultAmountMl updates state and persists', () async {
  await readPrefs();

  final controller = container.read(quickEntryPreferencesProvider.notifier);
  await controller.setWaterDefaultAmountMl(500);

  final state = container.read(quickEntryPreferencesProvider).requireValue;
  expect(state.waterDefaultAmountMl, 500);

  final prefs = await SharedPreferences.getInstance();
  expect(prefs.getInt('record.quickEntry.water.defaultAmountMl'), 500);
});

test('setWaterBadgeMode updates state and persists', () async {
  await readPrefs();

  final controller = container.read(quickEntryPreferencesProvider.notifier);
  await controller.setWaterBadgeMode(QuickEntryWaterBadgeMode.dailyCount);

  final state = container.read(quickEntryPreferencesProvider).requireValue;
  expect(state.waterBadgeMode, QuickEntryWaterBadgeMode.dailyCount);

  final prefs = await SharedPreferences.getInstance();
  expect(prefs.getString('record.quickEntry.water.badgeMode'), 'dailyCount');
});

test('setSleepInProgressBadgeEnabled updates state and persists', () async {
  await readPrefs();

  final controller = container.read(quickEntryPreferencesProvider.notifier);
  await controller.setSleepInProgressBadgeEnabled(false);

  final state = container.read(quickEntryPreferencesProvider).requireValue;
  expect(state.sleepInProgressBadgeEnabled, isFalse);

  final prefs = await SharedPreferences.getInstance();
  expect(prefs.getBool('record.quickEntry.sleep.inProgressBadgeEnabled'), isFalse);
});

test('resetCustomOrder clears custom order without resetting defaults', () async {
  await readPrefs();

  final controller = container.read(quickEntryPreferencesProvider.notifier);
  await controller.setCustomOrder(['water', 'meal']);
  await controller.setWaterDefaultAmountMl(500);
  await controller.resetCustomOrder();

  final state = container.read(quickEntryPreferencesProvider).requireValue;
  expect(state.customOrder, isEmpty);
  expect(state.waterDefaultAmountMl, 500);
});
```

- [ ] **Step 2: Run preference tests and verify RED**

Run:

```powershell
flutter test test/record/quick_entry_preferences_test.dart
```

Expected: fail because new enum, fields, and setters do not exist.

- [ ] **Step 3: Implement preference model**

Add keys to `PrefKeys`:

```dart
static const recordQuickEntryWaterDefaultAmountMl =
    'record.quickEntry.water.defaultAmountMl';
static const recordQuickEntryWaterBadgeMode =
    'record.quickEntry.water.badgeMode';
static const recordQuickEntrySleepInProgressBadgeEnabled =
    'record.quickEntry.sleep.inProgressBadgeEnabled';
```

Extend `QuickEntryPreferences`:

```dart
enum QuickEntryWaterBadgeMode { dailyTotal, dailyCount, hidden }

class QuickEntryPreferences {
  const QuickEntryPreferences({
    this.dynamicSortEnabled = false,
    this.customOrder = const [],
    this.collapsed = false,
    this.frequency = const {},
    this.waterDefaultAmountMl = 250,
    this.waterBadgeMode = QuickEntryWaterBadgeMode.dailyTotal,
    this.sleepInProgressBadgeEnabled = true,
  });

  final int waterDefaultAmountMl;
  final QuickEntryWaterBadgeMode waterBadgeMode;
  final bool sleepInProgressBadgeEnabled;
}
```

Add loading, copyWith, setters, reset, and `resetCustomOrder()` so the tests pass. Parse invalid stored badge modes as `QuickEntryWaterBadgeMode.dailyTotal`.

- [ ] **Step 4: Run preference tests and verify GREEN**

Run:

```powershell
flutter test test/record/quick_entry_preferences_test.dart
```

Expected: all tests pass.

- [ ] **Step 5: Write failing panel/settings/controller tests**

Add or adjust widget tests for these keys and behaviors:

```dart
expect(find.byKey(const Key('record-quick-help-action')), findsOneWidget);
expect(find.byKey(const Key('record-quick-dynamic-sort')), findsNothing);
expect(find.byKey(const Key('record-quick-settings-action')), findsOneWidget);
expect(find.byKey(const Key('settings-row-quick-entry')), findsOneWidget);
```

Add controller routing tests using fake executor:

```dart
test('controller delegates tap action to executor', () async {
  final calls = <RecordEntryType>[];
  final controller = QuickEntryController(
    execute: (context) async => calls.add(context.action.type),
  );

  await controller.handleTap(testContextFor(RecordEntryType.water));

  expect(calls, [RecordEntryType.water]);
});
```

- [ ] **Step 6: Run targeted tests and verify RED**

Run:

```powershell
flutter test test/record/presentation/widgets/sections/quick_entry_panel_test.dart test/record/quick_entry_settings_page_test.dart test/settings/page_test.dart test/record/presentation/controllers/quick_entry_controller_test.dart
```

Expected: fail because the help action, settings page, settings route, and controller do not exist yet.

- [ ] **Step 7: Implement foundation UI and route skeleton**

Implementation requirements:

- `RecordQuickEntryPanel` header shows title plus `record-quick-help-action`.
- Dynamic sort switch and inline reorder button are removed from the Record panel.
- Tile callbacks include tap and long-press hooks:

```dart
final ValueChanged<RecordQuickAction>? onQuickAction;
final ValueChanged<RecordQuickAction>? onQuickActionLongPress;
```

- `RecordPage` adds a `record-quick-settings-action` header chip using `SemanticIcons.actionSettings` and routes to `/record/quick-entry-settings`.
- `QuickEntrySettingsPage` includes sections for sorting, default actions, display, and rules.
- `SettingsPage` quick-entry section becomes a navigation tile to `/record/quick-entry-settings` instead of owning quick-entry switches directly.
- `QuickEntryExecutor` may initially keep existing behavior by opening the old fast-entry dialog or create page; phase 2 replaces low-risk daily flows.

- [ ] **Step 8: Run ARB and route generation**

Run:

```powershell
dart scripts/arb_tools.dart merge
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
```

Expected: generated l10n and route files update without errors.

- [ ] **Step 9: Run targeted tests and verify GREEN**

Run:

```powershell
flutter test test/record/quick_entry_preferences_test.dart test/record/presentation/widgets/sections/quick_entry_panel_test.dart test/record/quick_entry_settings_page_test.dart test/settings/page_test.dart test/record/presentation/controllers/quick_entry_controller_test.dart
```

Expected: all targeted tests pass.

- [ ] **Step 10: Update docs**

Append migration log entry:

```markdown
## Record quick-entry foundation

- Added the quick-entry implementation plan and began the foundation refactor.
- Moved quick-entry sorting controls toward a dedicated quick-entry settings page.
- Added persisted preferences for water default amount, water badge mode, and sleep in-progress badge display.
```

Update `docs/00-current/Active_UI_Record.md` to mention the dedicated quick-entry settings entry and foundation controller boundary.

Update `plans/2026-07-28-record-quick-entry-ux.md` implementation status:

```markdown
- 2026-07-28: 阶段 1 foundation 完成：偏好模型、设置页骨架、Record header 入口、quick panel help 入口和 executor/controller 边界已落地。
```

- [ ] **Step 11: Run phase checks**

Run:

```powershell
flutter analyze
flutter test test/record/quick_entry_preferences_test.dart test/record/presentation/widgets/sections/quick_entry_panel_test.dart test/record/quick_entry_settings_page_test.dart test/settings/page_test.dart test/record/presentation/controllers/quick_entry_controller_test.dart
dart run tool/check_doc_coverage.dart --warning-only
```

Expected: no analyzer issues; targeted tests pass; doc coverage prints no blocking concern.

- [ ] **Step 12: Commit phase 1**

Run:

```powershell
git status --short
git diff --stat
git add lib/core/config/pref_keys.dart lib/features/record/data/quick_entry_preferences.dart lib/features/record/presentation/controllers/quick_entry.dart lib/features/record/presentation/services/quick_entry_context.dart lib/features/record/presentation/services/quick_entry_executor.dart lib/features/record/presentation/services/quick_entry_undo.dart lib/features/record/presentation/widgets/sections/quick_entry_panel.dart lib/features/record/presentation/pages/page.dart lib/features/record/presentation/pages/quick_entry_settings.dart lib/features/record/presentation/pages/quick_entry_reorder.dart lib/features/record/presentation/routes.dart lib/features/record/presentation/routes.g.dart lib/features/settings/presentation/pages/page.dart lib/l10n/src/record_zh.arb lib/l10n/src/record_en.arb lib/l10n/src/settings_zh.arb lib/l10n/src/settings_en.arb lib/l10n/app_zh.arb lib/l10n/app_en.arb lib/l10n/app_localizations.dart lib/l10n/app_localizations_zh.dart lib/l10n/app_localizations_en.dart test/record/quick_entry_preferences_test.dart test/record/presentation/widgets/sections/quick_entry_panel_test.dart test/record/quick_entry_settings_page_test.dart test/settings/page_test.dart test/record/presentation/controllers/quick_entry_controller_test.dart docs/00-current/Active_UI_Record.md docs/03-logs/migration-log/2026-07-28.md plans/2026-07-28-record-quick-entry-ux.md
git commit -m "feat(record): 搭建快速记录动作基础"
```

Expected: commit succeeds and pre-commit doc coverage passes.

## Phase 2: Water, Symptom, Mood Daily Record Flows

**Files:**

- Create: `lib/features/record/presentation/quick_entry/water_flow.dart`
- Create: `lib/features/record/presentation/quick_entry/symptom_flow.dart`
- Create: `lib/features/record/presentation/quick_entry/mood_flow.dart`
- Modify: `lib/features/record/presentation/services/quick_entry_executor.dart`
- Modify: `lib/features/record/presentation/services/quick_entry_undo.dart`
- Modify: `lib/features/record/presentation/widgets/sections/quick_entry_panel.dart`
- Test: `test/record/quick_entry/water_flow_test.dart`
- Test: `test/record/quick_entry/symptom_flow_test.dart`
- Test: `test/record/quick_entry/mood_flow_test.dart`
- Test: `test/record/presentation/services/quick_entry_undo_test.dart`

- [ ] **Step 1: Write failing tests for immediate daily-record undo**

Test desired undo behavior:

```dart
test('undo deletes the created daily record and emits dailyRecords change', () async {
  final deleted = <String>[];
  final emitted = <DataChangeTopic>[];
  final service = QuickEntryUndoService(
    deleteDailyRecord: (id) async => deleted.add(id),
    emitDataChange: emitted.add,
  );

  await service.undo(QuickEntryUndoAction.deleteDailyRecord(recordId: 'water-1'));

  expect(deleted, ['water-1']);
  expect(emitted, [DataChangeTopic.dailyRecords]);
});
```

- [ ] **Step 2: Write failing water flow tests**

Test desired create input:

```dart
expect(input.kind, DailyRecordKind.water);
expect(input.value, '250');
expect(input.unit, 'ml');
expect(input.occurredAt, '2026-07-28');
expect(input.occurredTime, '08:30');
```

Also test custom amount `500 ml` and failure does not register undo.

- [ ] **Step 3: Write failing symptom and mood tests**

Verify single-select creates one record immediately:

```dart
expect(input.kind, DailyRecordKind.symptom);
expect(input.title, '头痛');
expect(input.occurredTime, '08:30');
```

```dart
expect(input.kind, DailyRecordKind.mood);
expect(input.title, '平静');
expect(input.occurredTime, '08:30');
```

Verify multi-select symptom confirmation creates selected records and partial failure keeps failed selections retryable.

- [ ] **Step 4: Run phase 2 tests and verify RED**

Run:

```powershell
flutter test test/record/quick_entry/water_flow_test.dart test/record/quick_entry/symptom_flow_test.dart test/record/quick_entry/mood_flow_test.dart test/record/presentation/services/quick_entry_undo_test.dart
```

Expected: fail because flow files and undo actions do not exist.

- [ ] **Step 5: Implement undo and water flow**

Requirements:

- Water uses `prefs.waterDefaultAmountMl`.
- Successful immediate write shows undo toast through `QuickEntryUndoService`.
- Failed write shows failure toast and does not update badges.
- Every successful write emits `DataChangeTopic.dailyRecords`.

- [ ] **Step 6: Implement symptom and mood sheets**

Requirements:

- Symptom default mode: tapping one chip saves and closes after success.
- Symptom multi-select mode: confirm writes selected symptoms; confirmed batch does not require undo toast.
- Mood sheet: tapping one mood saves and closes after success.
- Save failure keeps the sheet open.

- [ ] **Step 7: Run phase 2 targeted tests and checks**

Run:

```powershell
flutter test test/record/quick_entry/water_flow_test.dart test/record/quick_entry/symptom_flow_test.dart test/record/quick_entry/mood_flow_test.dart test/record/presentation/services/quick_entry_undo_test.dart
flutter analyze
dart run tool/check_doc_coverage.dart --warning-only
```

- [ ] **Step 8: Update docs and commit phase 2**

Update:

- `docs/00-current/Active_UI_Record.md`
- `docs/03-logs/migration-log/2026-07-28.md`
- `plans/2026-07-28-record-quick-entry-ux.md`

Commit:

```powershell
git add lib/features/record/presentation/quick_entry/water_flow.dart lib/features/record/presentation/quick_entry/symptom_flow.dart lib/features/record/presentation/quick_entry/mood_flow.dart lib/features/record/presentation/services/quick_entry_executor.dart lib/features/record/presentation/services/quick_entry_undo.dart lib/features/record/presentation/widgets/sections/quick_entry_panel.dart test/record/quick_entry/water_flow_test.dart test/record/quick_entry/symptom_flow_test.dart test/record/quick_entry/mood_flow_test.dart test/record/presentation/services/quick_entry_undo_test.dart docs/00-current/Active_UI_Record.md docs/03-logs/migration-log/2026-07-28.md plans/2026-07-28-record-quick-entry-ux.md
git commit -m "feat(record): 快速记录饮水症状情绪"
```

## Phase 3: Medication Flow

**Files:**

- Create: `lib/features/record/presentation/quick_entry/medication_flow.dart`
- Modify: `lib/features/record/presentation/services/quick_entry_executor.dart`
- Modify: `lib/features/record/presentation/services/quick_entry_undo.dart`
- Modify: `lib/features/medicine/data/datasources/dose_log_remote.dart`
- Modify: `lib/features/medicine/data/datasources/dose_log_cached.dart`
- Modify: `lib/features/medicine/presentation/providers/reminders.dart`
- Test: `test/record/quick_entry/medication_flow_test.dart`
- Modify: `test/medicine/dose_log_remote_data_source_test.dart`
- Modify: `test/medicine/cached_dose_log_data_source_test.dart`

- [ ] **Step 1: Write failing slot-window tests**

Required behavior:

```dart
final window = MedicationQuickEntryWindow(now: DateTime(2026, 7, 28, 8));
expect(window.contains(DateTime(2026, 7, 28, 7, 30)), isTrue);
expect(window.contains(DateTime(2026, 7, 28, 10)), isTrue);
expect(window.contains(DateTime(2026, 7, 28, 7, 29)), isFalse);
expect(window.contains(DateTime(2026, 7, 28, 10, 1)), isFalse);
```

- [ ] **Step 2: Write failing dose-log delete tests**

Verify remote delete calls `DELETE /api/v1/user/medicine-dose-logs/{id}` and cached delete removes local cache or queues pending sync according to existing cached datasource behavior.

- [ ] **Step 3: Write failing medication flow tests**

Cover:

- zero current medicine opens add-medicine prompt and writes nothing.
- one current medicine with nearby pending slot calls `mark(status: taken)`.
- one current medicine without nearby slot creates a linked dose log.
- multiple medicines default-select only nearby pending slots.
- already taken slots do not duplicate writes.
- undo deletes new log or restores previous status.

- [ ] **Step 4: Run medication tests and verify RED**

Run:

```powershell
flutter test test/record/quick_entry/medication_flow_test.dart test/medicine/dose_log_remote_data_source_test.dart test/medicine/cached_dose_log_data_source_test.dart
```

- [ ] **Step 5: Implement medication flow**

Requirements:

- Base list comes from current medicines, not reminders only.
- Nearby pending slots are from now minus 30 minutes to now plus 2 hours.
- `DataChangeTopic.doseLogs` is emitted after successful dose writes and rollbacks.
- Batch partial success reports success and failure counts.

- [ ] **Step 6: Run checks, update docs, commit phase 3**

Run:

```powershell
flutter test test/record/quick_entry/medication_flow_test.dart test/medicine/dose_log_remote_data_source_test.dart test/medicine/cached_dose_log_data_source_test.dart test/medicine/reminder_providers_test.dart
flutter analyze
dart run tool/check_doc_coverage.dart --warning-only
```

Update `Active_UI_Record.md`, `Active_UI_Medicine.md`, migration log, and rolling plan.

Commit:

```powershell
git commit -m "feat(record): 联动用药快速记录"
```

## Phase 4: Sleep Flow

Status: implemented and verified 2026-07-28.

**Files:**

- Create: `lib/features/record/presentation/quick_entry/sleep_flow.dart`
- Modify: `lib/features/record/presentation/services/quick_entry_executor.dart`
- Modify: `lib/features/record/presentation/pages/page.dart`
- Test: `test/record/quick_entry/sleep_flow_test.dart`
- Modify: `test/record/page_test.dart`

- [ ] **Step 1: Write failing sleep payload tests**

Cover start payload, wake payload, duration calculation, cross-day duration, invalid same/negative time, and multiple-start selection requirement.

- [ ] **Step 2: Implement sleep flow**

Requirements:

- No start: create `sleepEvent: start` and show undo.
- One start: create `sleepEvent: wake`, then show merge confirmation.
- Confirm merge: delete temporary facts and create standard sleep record with `durationMinutes`, `startAt`, `endAt`.
- Cancel merge: keep raw facts.
- Multiple starts: show selection, do not guess.

- [ ] **Step 3: Run checks, update docs, commit phase 4**

Run:

```powershell
flutter test test/record/quick_entry/sleep_flow_test.dart test/record/presentation/widgets/sections/quick_entry_panel_test.dart
flutter analyze
dart run tool/check_doc_coverage.dart --warning-only
```

Commit:

```powershell
git commit -m "feat(record): 快速记录睡眠开始结束"
```

## Phase 5: Meal Camera Flow

Status: implemented and verified 2026-07-28.

**Files:**

- Create: `lib/features/record/presentation/quick_entry/meal_flow.dart`
- Modify: `lib/features/record/presentation/services/quick_entry_executor.dart`
- Modify: `lib/features/record/presentation/pages/page.dart`
- Test: `test/record/quick_entry/meal_flow_test.dart`
- Modify: `test/record/page_test.dart`

- [ ] **Step 1: Write failing meal flow tests**

Cover:

- camera cancel writes nothing.
- camera permission denied opens settings/manual fallback.
- successful photo upload creates meal confirmation state.
- analysis failure does not block record creation.
- manual no-photo fallback creates meal record after confirmation.

- [ ] **Step 2: Extract reusable image upload service if current create page owns too much logic**

Only extract code already used by meal create and quick meal. Do not introduce a new image pipeline.

- [ ] **Step 3: Implement meal flow**

Requirements:

- Single tap opens camera.
- Confirmation sheet shows the photo and prefilled meal context.
- Save uses existing `DailyRecordCreateInput.attachments`.
- Undo does not promise remote object deletion.

- [ ] **Step 4: Run checks, update docs, commit phase 5**

Run:

```powershell
flutter test test/record/quick_entry/meal_flow_test.dart test/record/create_page_test.dart test/record/presentation/models/meal_analysis_view_data_test.dart
flutter analyze
dart run tool/check_doc_coverage.dart --warning-only
```

Commit:

```powershell
git commit -m "feat(record): 快速记录餐食拍照确认"
```

## Phase 6: Sorting Completion And Full Verification

Status: implemented 2026-07-28. Verified with Record/Medicine suites, Settings root page, targeted
quick-entry tests, `flutter analyze`, and doc coverage. Full `test/settings` still has unrelated
pre-existing failures in `help_settings_page_test.dart` and `user_settings_controller_test.dart`,
so it is not counted as passed for this phase.

**Files:**

- Modify: `lib/features/record/presentation/pages/quick_entry_settings.dart`
- Modify: `lib/features/record/presentation/pages/quick_entry_reorder.dart`
- Modify: `lib/features/record/presentation/widgets/sections/quick_entry_panel.dart`
- Test: `test/record/quick_entry_settings_page_test.dart`
- Test: `test/record/presentation/widgets/sections/quick_entry_panel_test.dart`

- [ ] **Step 1: Write failing reorder/reset tests**

Cover:

- dynamic sort disabled allows manual reorder.
- dynamic sort enabled disables manual reorder with explanation.
- reset default order clears only custom order.
- help affordance shows single tap, long press, and undo rules without mentioning double tap.

- [ ] **Step 2: Implement reorder/reset/help completion**

Requirements:

- Manual reorder is a focused page or sheet, not a mode inside Record quick panel.
- Reset default order does not reset water/sleep display preferences.
- Quick panel help explains current behavior and reduces cognitive load.

- [ ] **Step 3: Run full verification**

Run:

```powershell
flutter test test/record test/medicine test/settings
flutter analyze
dart run tool/check_doc_coverage.dart --warning-only
```

If the targeted suites are clean and shared behavior changed broadly, run:

```powershell
flutter test
```

- [ ] **Step 4: Update docs and commit phase 6**

Update current docs, migration log, and remove completed plan sections from `plans/2026-07-28-record-quick-entry-ux.md` only when the implementation is actually complete.

Commit:

```powershell
git commit -m "feat(record): 完成快速记录设置和排序"
```

## Risk Controls

- Do not edit `lib/l10n/app_zh.arb` or `lib/l10n/app_en.arb` by hand.
- Do not remove the old create-page routes; quick entry still needs fallback routes.
- Do not create unlinked medication records in Record.
- Do not show undo toast for writes that happen only after an explicit confirmation.
- Do not silently swallow partial failures in medication or multi-select symptom writes.
- Do not promise deletion of remote meal image objects on undo.
- Keep each phase committed before starting the next phase.

## Final Acceptance

The refactor is complete when:

- Record quick-entry single taps follow the approved type-specific behavior.
- Immediate writes can be truly undone.
- Confirmed writes do not add unnecessary undo interruption.
- Water and sleep badges follow preferences.
- Medication writes synchronize with Medicine dose logs.
- Meal quick entry uses the camera-first confirmation flow.
- Dedicated quick-entry settings and manual sorting are reachable from Record and Settings.
- `flutter analyze`, relevant targeted tests, and `dart run tool/check_doc_coverage.dart --warning-only` pass.
