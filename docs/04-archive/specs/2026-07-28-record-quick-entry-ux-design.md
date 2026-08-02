# Record 快速记录 UX 重构设计

Date: 2026-07-28
Status: Draft approved in discussion; pending implementation plan

## Goal

Record 页快速记录区应从“更小的表单入口”重构为真正的快速事实写入系统：

- 单击是主路径：能直接记录就直接记录，必须选择时才打开轻量 sheet。
- 无确认即时写入提供底部可撤销 toast。
- 已经由 sheet/dialog 明确确认后才写入的动作不强制显示撤销 toast。
- Record 负责记录事实；Medicine 负责用药计划、安全解释和风险边界。

## Product Boundaries

Record answers “发生了什么”。Medicine answers “计划、提醒、安全、风险解释是什么”。

Record 的用药快捷入口写入 Medicine dose log，Medicine 今日计划、Today 摘要和 Report 趋势消费同一事实来源。Record 不展示药物风险判断，不调整提醒计划，不替用户修改用药方案。

## Architecture

The quick-entry refactor should create an action system instead of moving existing callbacks between widgets.

### Layers

1. `QuickEntryPanel`
   - Displays the quick-entry grid, icons, badges, help affordance, and long-press affordance.
   - Does not create records and does not own type-specific behavior.

2. `QuickEntryController` / `QuickEntryExecutor`
   - Receives user actions such as `tap water`, `tap medication`, and `tap sleep`.
   - Decides whether to write immediately, open a sheet, request the camera, navigate to add medicine, or open settings.

3. `QuickEntryUndoService`
   - Tracks what a quick action created or changed.
   - Shows undo toast only for no-confirmation immediate writes.
   - Rolls back daily records by deleting newly created records.
   - Rolls back dose logs by deleting newly created logs or restoring the previous status when a log already existed.

4. Type-specific flows
   - `water_flow`
   - `medication_flow`
   - `symptom_flow`
   - `meal_flow`
   - `sleep_flow`
   - `mood_flow`

Each flow owns its sheet UI, default behavior, write logic, and error handling.

## Gesture Model

- Single tap is the only required, discoverable primary action.
- Long press is an optional shortcut for more/settings, never the only path.
- Double tap is not part of the first version. It is too hard to discover on mobile and can interfere with immediate single-tap execution.

## Settings UX

Record header gets a right-side “快速记录设置” entry alongside the NLP/sparkles entry. Settings also gets a secondary entry. Mine does not expose this entry.

The quick-entry panel header should no longer contain dynamic sorting controls. Replace them with a lightweight help affordance explaining single tap, long press, and undo behavior.

### Quick Record Settings Structure

Sorting:

- Dynamic sorting switch.
- Manual sorting entry.
- Reset to default order.

Default actions:

- Water default amount, initially `250 ml`.
- Other quick-entry types show their current rules without first-version configuration.

Display:

- Water badge display: daily total, daily count, or hidden.
- Sleep in-progress badge switch, default on.

Rules:

- Medication: uses current medicine box plus nearby pending reminder slots.
- Meal: single tap opens camera; confirmation saves.
- Symptom: single select saves immediately; multi-select requires confirmation.
- Mood: selecting one mood saves immediately.
- Sleep: single tap starts or ends a sleep session.

Manual sorting should use a focused subpage or bottom sheet with drag, save, and cancel, rather than switching the main settings page into reorder mode.

## Type Flows

### Water

Single tap records `250 ml` by default. This is a no-confirmation immediate write, so success shows an undo toast. The water tile badge follows the user’s display setting.

Fast repeated taps are allowed. Each successful tap creates one independent record. Undo rolls back only the most recent tap.

### Medication

The medication flow reads current medicines as the base list and today’s reminders/dose logs as contextual hints.

No current medicine:

- Show a lightweight confirmation dialog.
- Primary action navigates to add medicine.
- Do not create unlinked medication facts.

One current medicine:

- Single tap records the medicine as taken at the current time.
- If a pending reminder slot exists from 30 minutes before now to 2 hours after now, use slot-aware mark.
- If no nearby pending slot exists, create or mark a dose log linked to the current medicine without a reminder slot.
- This is an immediate write and shows an undo toast.

Multiple current medicines:

- Open a selection sheet.
- Nearby pending reminder slots are selected by default.
- If no nearby slot exists, nothing is selected by default.
- Users may manually select medicines and confirm.
- Confirmed batch writes do not require undo toast.

Nearby reminder window: now minus 30 minutes through now plus 2 hours.

### Symptom

Single tap opens a common symptom sheet. In default single-select mode, tapping a symptom saves immediately and shows an undo toast.

The sheet has a multi-select entry. In multi-select mode, tapping symptoms toggles selection and bottom actions appear for confirm/cancel. Confirmed multi-select writes do not require undo toast.

### Mood

Single tap opens a mood sheet. Selecting a mood saves immediately and shows an undo toast. Mood does not support multi-select in the first version.

### Meal

Single tap opens the camera. After the user takes a photo, Record opens a lightweight confirmation sheet with the photo and prefilled meal context.

If camera permission is denied, show a guidance dialog with system settings and manual entry actions. If the user cancels the camera, do not write a record and do not show a toast.

Manual no-photo meal entry is available through long press or a fallback action. Confirmation saves the meal. Meal analysis failure must not block record creation.

Undo does not promise deletion of cloud image objects. The frontend only rolls back the record and attachment metadata; remote object cleanup belongs to backend contract or async cleanup.

### Sleep

If no in-progress sleep exists, single tap creates a temporary sleep record:

```json
{
  "sleepEvent": "start",
  "eventAt": "2026-07-28T23:15:00.000Z"
}
```

This is an immediate write and shows an undo toast. The sleep tile displays an in-progress badge when enabled.

If one in-progress sleep exists, single tap creates a temporary wake record:

```json
{
  "sleepEvent": "wake",
  "eventAt": "2026-07-29T07:10:00.000Z",
  "startedRecordId": "record-sleep-start-123"
}
```

Then show a merge confirmation sheet with start time, wake time, and duration. Confirming deletes or replaces temporary facts and creates a standard sleep record:

```json
{
  "durationMinutes": 475,
  "startAt": "2026-07-28T15:15:00.000Z",
  "endAt": "2026-07-28T23:10:00.000Z"
}
```

Canceling the merge keeps the start and wake facts as raw facts.

If multiple in-progress starts exist, show a selection sheet and do not guess automatically. Cross-day sleep uses actual ISO timestamps, not the selected Record date.

## Error Handling

Global rules:

- Immediate write failure: show failure toast, do not update badges/state, do not show undo.
- Confirmation write failure: keep the sheet/dialog open and show inline error or toast.
- Partial success: show “已记录 N 项，M 项失败”; successful items are marked complete, failed items remain retryable.
- Undo failure: show undo failure toast and refresh data.
- Offline optimistic success can be treated as recorded if the repository supports pending sync. Dose log delete/pending sync must be verified and completed during implementation.

Type-specific rules:

- Water save failure shows a retry toast.
- Medication loading disables the tile; load failure opens an error sheet with retry and “go to Medicine”.
- Already-taken nearby medication slots are not duplicated; refresh and tell the user it is already recorded.
- Meal upload/processing failure stays inside the flow and offers retry.
- Sleep identical or invalid start/wake time does not merge; keep raw facts and show an error.
- Symptom/mood save failure keeps the sheet open for retry.

## Implementation Phases

1. Foundation
   - Split display from execution.
   - Add executor and undo service.
   - Extend quick-entry preferences.
   - Add quick-entry settings entry and settings skeleton.

2. Low-risk daily record flows
   - Water.
   - Symptom.
   - Mood.

3. Medication flow
   - Current medicine integration.
   - Reminder slot window.
   - Dose log create/mark/delete/restore.
   - Medicine surface refresh.

4. Sleep flow
   - Temporary start/wake facts.
   - In-progress badge.
   - Merge confirmation.
   - Multiple-start resolution.

5. Meal flow
   - Reusable image pick/compress/upload logic.
   - Camera-first flow.
   - Confirmation sheet.
   - Manual fallback.

6. Settings and sorting completion
   - Dynamic sorting migration.
   - Manual sorting subpage/sheet.
   - Reset default order.
   - Help affordance in quick-entry panel.

## Verification

Unit tests:

- Executor routing.
- Undo service rollback.
- Preferences persistence.
- Medication slot window.
- Sleep payload and duration handling.

Widget tests:

- Quick-entry settings page.
- Manual sorting surface.
- Water immediate write and undo.
- Symptom/mood sheets.
- Medication selection and zero-medicine dialog.
- Sleep start/wake/merge.

Integration or broader widget coverage:

- Record medication writes refresh Medicine today plan.
- Meal camera cancel writes nothing.
- Meal upload failure remains retryable.
- Existing Record navigation and timeline flows still work.

Final local checks:

- `flutter analyze`
- Targeted `flutter test test/record test/medicine`
- Broader `flutter test` if shared behavior changes significantly
- `dart run tool/check_doc_coverage.dart --warning-only`
