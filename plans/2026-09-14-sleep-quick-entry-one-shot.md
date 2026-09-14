# 睡眠快速录入改为一次性录入

破坏性改动：睡眠从「状态机式两阶段记录」（start → wake → 合并）改为**一次性录入一条完整睡眠**，
不保留任何向后兼容。

## 已定决策

1. **一次性录入**：就寝 + 起床 + 类型 + 质量 + 备注 → 一条完整记录，时长由时间差算出。
2. **界面显式写出归属日**：表单里直接写「记为 9月14日 睡眠」，不靠用户猜。
3. **就寝不允许跨多天**：一次睡眠最多跨一个午夜（由构造保证）。
4. **小睡是显式类型**：`sleepType` 由用户选（夜间睡眠 / 小睡），不再按时长推断。
5. **主观评分（睡眠质量）与备注进表单**。
6. **不留向后兼容**：删除 start/wake 事件语义、合并流程、Lucent 校验里 `sleepEvent` 的逃生口，
   payload 键位统一到一套。
7. **时长上限**：小睡 ≤ 3 小时、夜间睡眠 ≤ 16 小时，超限在表单内报错、不关 sheet。
8. **预填**：沿用最近一条睡眠记录的时刻与类型；无历史则夜间 23:00–07:00、小睡 13:00–13:30。
9. **睡眠瓦片徽标直接去掉**，不改成「今日睡眠总时长」（夜间与小睡分列时总时长口径含糊）。
10. **深/浅/REM 手填输入框本次保留不动**，只改快速录入这一条路径。

## 兼容口径

App 尚未上线，因此**不设兼容窗口**：

- 不做数据迁移，旧 `sleepEvent` 记录**不管**——不读取、不合并、不为它们写降级分支或兜底测试。
- payload 不做双键兼容读，`startAt` / `endAt` 直接停用（客户端与服务端同时切到 `startedAt` / `endedAt`）。
- 没有灰度、没有中间态，双仓同批硬切；提交拆分只是为了评审粒度，不代表上线顺序约束。

## 现状（将被整体替换）

单击睡眠瓦片走 `handleSleepQuickAction`（`application/usecases/quick_entry_sleep.dart`）：
拉取选中日 ±1 天的睡眠记录 → 无进行中记录则弹「睡眠类型」弹窗（夜间/小睡 + 大致时长 + 质量）
→ 记一条 `sleepEvent: 'start'`；已有进行中记录则记 `sleepEvent: 'wake'` 并弹「合并」弹窗；
多个进行中记录则弹「选择要结束的睡眠」。相关实现：`presentation/quick_entry/sleep_flow.dart`、
`presentation/widgets/dialogs/sleep_merge.dart`，共 3 个自定义弹窗。

已存在的死配置 / 死分支（一并清理）：

- `quickEntryPreferences.sleepInProgressBadgeEnabled` → 只驱动「进行中」徽标，一次性录入后语义消失。
- `quickEntryPreferences.sleepDefaultDurationMinutes` → 只在 `fast_entry_dialog.dart` 的睡眠分支被读，
  而睡眠单击在 `handleQuickAction` 就已被拦截，**该分支不可达**。
- `fast_entry_choices.dart` 的 `DailyRecordKind.sleep` 分支与 `kSleepDurationOptions` → 同上不可达。

## 调研依据

| 结论 | 来源 |
| --- | --- |
| 归属日以「起床日」为最主流（Fitbit `dateOfSleep` = 结束那天、Garmin 睡眠记起床日、vivo 官方明文） | [Fitbit Web API](https://dev.fitbit.com/build/reference/web-api/sleep/get-sleep-log-by-date/)、[vivo 使用指南](https://health-h5.vivo.com.cn/doc/helpwear/health/sleepWatch.html)、[Sahha 汇总](https://sahha.ai/blog/which-day-does-sleep-belong-to/) |
| HealthKit / Health Connect 只存 start/end 瞬时，**不带日期**，归属规则由 App 自己发明 | [Health Connect](https://developer.android.com/health-and-fitness/health-connect/features/sleep-sessions) |
| Samsung 用时钟大小比较推断跨天（start 时分晚于 end ⇒ 前一日开始），即我们 `computeSleepDurationMinutes` 的算法 | [Samsung Developer](https://developer.samsung.com/health/blog/en/managing-sleep-data-with-samsung-health-and-health-connect) |
| Apple Health / Samsung / 华为的手动录入都只收「入睡 + 起床」，**时长算出来不让填** | [Levels 转述 Apple Health 流程](https://support.levels.com/article/382-how-to-add-sleep-data-to-the-levels-app)、[华为官方](https://consumer.huawei.com/cn/support/content/zh-cn16058410/) |
| 「整条补录」的范式：Sleep as Android 的 `(+) Add sleep` | [Sleep as Android 文档](https://sleep.urbandroid.org/docs/sleep/graph_edit.html) |
| Oura 只允许**缩短**、手动编辑需 ≥3 小时、超 3 天不可改；nap 定义 15 min–3 h | [Oura 编辑就寝/起床](https://support.ouraring.com/hc/lv/articles/360025445994-Edit-Bedtime-and-Wake-Up-Time)、[Nap Detection](https://support.ouraring.com/hc/en-us/articles/1500009653181-Nap-Detection) |
| 没有任何一家在录入界面告诉用户「这条记为哪天」→ 本方案第 2 条即差异化空位 | 同上各来源 |

## 目标形态

### 入口与载体

记录页睡眠瓦片**单击** → 底部 sheet（`showFSheet`，与饮水快捷录入一致）。
选择 sheet 而非居中弹窗：表单有 5 个字段 + 两个时间选择器，弹窗会过窄；且饮水已有 sheet 先例。

**长按** → 该类型的规则说明（沿用 `QuickEntryTypeSettingsDialog` 的 `_ruleText` 分支）。
`_SleepSettings` 整个删除——它只有「默认时长」和「进行中徽标」两项，都已消失。

### 表单规格（自上而下）

| 字段 | 控件 | 必填 | 说明 |
| --- | --- | --- | --- |
| 标题 | — | — | 「记录睡眠」 |
| 类型 | `FTabs`（夜间睡眠 \| 小睡） | 是 | 默认夜间；小睡默认时段 13:00–13:30 |
| 就寝时间 | `FTimeField.picker`（复用 key `sleep-bedtime-picker`） | 是 | 预填见下 |
| 起床时间 | `FTimeField.picker`（复用 key `sleep-waketime-picker`） | 是 | 预填见下 |
| 时长 | 只读文本 | — | `时长：7 小时 30 分钟`，实时随两个时间变化 |
| **归属日** | 只读文本（neutral 小字） | — | **「记为 9月14日 睡眠」**，explicit 写出 |
| 睡眠质量 | `FSelect`（较差/一般/良好/优秀） | 否 | 复用 `sleepQualityOptions` |
| 备注 | `FTextField` | 否 | 记录级 `note`，不写 payload |
| 保存 | `FButton` | — | 落库 + toast「已保存 / 撤销」 |

关闭 sheet（下滑 / 点外部）不产生任何记录。

### 归属日与跨天规则

- **归属日 = 记录页当前选中日期**（`selectedRecordDateProvider`），语义为**起床日**；
  写库时 `occurredAt = 该日期`、`occurredTime = 起床时刻`。这与 Lucent 既有注释和测试用例名
  （"wake-date convention"）一致。
- 具体时刻用一条纯规则解出，两种类型不同：
  - `nightSleep`：`bedClock < wakeClock` → 就寝与起床同日；否则就寝 = 归属日 − 1 天。
  - `nap`：就寝必须与起床同日，`bedClock < wakeClock`；否则校验失败。
- 由构造保证单次睡眠跨度 **< 24h**，即「最多跨一个午夜」，满足决策 3。
- 归属日文案随类型变化：小睡固定显示归属日本身；夜间睡眠若就寝落在前一天，
  文案仍只声明归属日（「记为 9月14日 睡眠」），因为**归属日只有一个**，避免引入第二个日期概念。

### 校验

| 规则 | 提示 |
| --- | --- |
| 就寝与起床都必填 | `recordSleepInvalidValueToast`（复用：请选择就寝和起床时间） |
| 时长 > 0 | `recordQuickSleepInvalidDurationToast`（复用：醒来时间必须晚于入睡时间） |
| 小睡 ≤ 3 小时 | 新增 copy（依据 Oura 的 nap 定义 15 min–3 h） |
| 夜间睡眠 ≤ 16 小时 | 新增 copy；防手滑，同时兜住「跨两次午夜」这类构造 |

校验失败时错误文案贴在时间行下方，不关 sheet。

### 预填

1. 优先**沿用最近一条睡眠记录**（归属日或前一天的最近一条完整记录）的就寝 / 起床时刻与类型；
   复用现有 `fetchSleepQuickCandidates`。
2. 无历史 → 夜间睡眠 23:00–07:00；小睡 13:00–13:30。

### 保存与撤销

保存 = 一次 `create`；成功后 emit `DataChangeTopic.dailyRecords`，toast「已保存 / 撤销」，
撤销 = 删除该记录（`QuickEntryUndoService`）。复用 `QuickEntryExecutor._undo` 的守卫形态。

## payload 契约（统一后）

```jsonc
{
  "startedAt": "2026-09-13T15:00:00.000Z",   // 可选，与 endedAt 成对
  "endedAt": "2026-09-13T23:00:00.000Z",     // 可选，与 endedAt 成对
  "durationMinutes": 480,                     // 必填，> 0（由时间差算出）
  "sleepType": "nightSleep",                  // 可选：nightSleep | nap
  "quality": "good",                          // 可选：poor|fair|good|excellent
  "deepMinutes": 90,                          // 可选，仅设备导入写入
  "lightMinutes": 240,                        // 可选，仅设备导入写入
  "remMinutes": 110                           // 可选，仅设备导入写入
}
```

**键位收敛到 `startedAt` / `endedAt`**：Lucent 的 DTO 文档已经把 `startedAt`/`endedAt` 定义为
正式键、把 `startAt`/`endAt` 标为 legacy，而 Luminous 的创建/编辑/详情/NLP 反而写读 legacy 键——
本次一次性对齐到正式键，并停用 legacy 键（不做兼容读）。

`deep/light/rem` 是设备侧（HealthKit / Health Connect stages）数据，**手动录入不写**；
create / edit 页现有的三个手填输入框本次保留不动。

## 改动清单

### Luminous（Flutter）

**新增**

- `lib/features/record/domain/services/sleep_entry.dart` — 纯函数领域服务：
  `resolveSleepWindow({required DateTime recordDate, required TimeOfDay bedtime,
  required TimeOfDay wakeTime, required SleepKind kind})` → `({DateTime startedAt, DateTime endedAt, int durationMinutes})`；
  `buildSleepPayload(...)`；`validateSleepEntry(...)` → 错误枚举。
  create / edit / quick 三处共用，杜绝现在三份重复的跨天算术。
- `lib/features/record/presentation/widgets/dialogs/sleep_quick_entry_sheet.dart` — 新 sheet
  （含 `SleepQuickEntrySheetBody`，便于 widget 测试直接挂载）。

**删除**

- `application/usecases/quick_entry_sleep.dart`（整文件：3 个弹窗 + `handleSleepQuickAction`
  + `sleepEventLabel` + `formatSleepDuration` + `showSleepMergeDialog` +
  `showSleepStartSelectionDialog` + `showSleepTypeSelectionDialog`）
- `presentation/quick_entry/sleep_flow.dart`（整文件：`SleepQuickEntryFlow` / start/wake / merge）
- `presentation/widgets/dialogs/sleep_merge.dart`
- `presentation/widgets/forms/sleep_structured_fields.dart` 中的 `computeSleepDurationMinutes`
  与 `_formatDuration`（迁入领域服务与共享格式化），`SleepStructuredFields` 保留给 create / edit 页
- 偏好 `sleepInProgressBadgeEnabled`、`sleepDefaultDurationMinutes`（含 `PrefKeys` 两项、
  控制器 setter、`reset()` 清理项）
- `fast_entry_choices.dart` 的 `DailyRecordKind.sleep` 分支、`kSleepDurationOptions`
- `quick_type_settings_dialog.dart` 的 `_SleepSettings`
- `quick_entry_panel.dart` 的 `_sleepBadge` 及 `_badgeFor` 的 sleep 分支）
- l10n（zh/en 两片）：`recordQuickSleepStartedToast`、`recordQuickSleepTypeTitle`、
  `recordQuickSleepNightAction`、`recordQuickSleepNapAction`、
  `recordQuickSleepApproximateDurationLabel`、`recordQuickSleepSelectStartTitle`、
  `recordQuickSleepMergeTitle`、`recordQuickSleepMergeBody`、`recordQuickSleepStartLabel`、
  `recordQuickSleepWakeLabel`、`recordQuickSleepInProgressBadge`、
  `recordQuickSleepKeepSeparateAction`、`recordQuickSleepMergeAction`、
  `recordQuickSettingsSleepBadge`、`recordQuickSettingsSleepBadgeHint`、
  `recordQuickSettingsSleepDefaultDuration`、`recordQuickSettingsSleepDurationHours`
  （保留 `recordQuickSleepLoadFailedToast`、`recordQuickSleepInvalidDurationToast`、
  `recordSleep*` 系列）

**修改**

- `application/usecases/quick_entry.dart` — sleep 分支改为「打开 sheet → 保存 → toast 撤销」
- `presentation/pages/create.dart` / `widgets/forms/record_create_form.dart` — 改用领域服务，
  键位 `startAt/endAt` → `startedAt/endedAt`
- `presentation/providers/record_edit_controller.dart` — 读/写 `startedAt`/`endedAt`
- `presentation/widgets/detail/body.dart` — 读 `startedAt`/`endedAt`
- `presentation/widgets/nlp/candidate_editor.dart` — `startAt/endAt` → `startedAt/endedAt`
- `data/repositories/health_sync.dart` — 去掉 `?? startAt` / `?? endAt` 回退
- `presentation/pages/quick_entry_settings.dart` — 去掉睡眠徽标 / 默认时长两行
- `presentation/widgets/sections/quick_entry/header.dart` — 帮助弹窗的睡眠规则文案更新
- l10n 新增：sheet 标题、类型标签、时长、**归属日**（带 `{date}` 占位）、两类时长上限错误
- `lib/features/record/README.md` — 不变量里的「单击 = 记录 + 可撤销 / 长按 = 设置」补充
  睡眠的一次性录入语义与 wake-date 归属规则
- `docs/reference/localization.md`、`docs/logs/migration-log/2026-09-14.md`

### Lucent（NestJS）

- `src/modules/daily-records/services/records-validator.service.ts` —
  删除 `sleepEvent === 'start' | 'wake'` 逃生口；`startedAt ?? startAt` / `endedAt ?? endAt` 收敛为
  `startedAt` / `endedAt` 单键
- `src/modules/daily-records/dto/create-record.dto.ts`、`dto/update-record.dto.ts`、
  `dto/record-item.dto.ts` — payload 描述串统一为
  `{ sleepType?, startedAt?, endedAt?, durationMinutes, quality? }`，删掉
  "Legacy startAt/endAt remain readable"
- `src/modules/today-suggestion/services/collectors/sleep-trend-builder.service.ts` —
  去掉 `?? startAt` / `?? endAt` 回退
- 测试：`daily-records/services/records.service.spec.ts` 删除
  "should allow temporary sleep start / wake event record" 两个用例、其余用例键位改名；
  `reports/services/event-review/changes.service.spec.ts` 中构造 `sleepEvent` 的用例改造；
  `today-suggestion/services/collectors/record.service.spec.ts` 若有 `startAt` 一并改名
- `src/modules/daily-records/README.md`（若描述了两阶段睡眠）、
  `docs/logs/migration-log/2026-09-14.md`

## 测试计划（不跑全量）

- 新增 `test/record/quick_entry/sleep_entry_test.dart` — 领域服务纯函数：夜间跨天、夜间同日、
  小睡同日、小睡跨天报错、时长 > 0、两类上限、`startedAt/endedAt/durationMinutes` 键位
- 重写 `test/record/page_test.dart` 的睡眠快捷用例（当前构造 `sleepEvent` 的那几段）
- 删除 `test/record/quick_entry/sleep_flow_test.dart`
- 新增 `test/record/sleep_quick_entry_sheet_test.dart` — 断言：类型切换、**「记为 X月X日」文案**、
  跨天时段解析、小睡跨天报错、保存后 payload 键位与值
- 修 `test/record/quick_entry_preferences_test.dart`（去掉两个已删偏好）
- 修 `test/record/presentation/widgets/sections/quick_entry_panel_test.dart`（去掉进行中徽标断言）
- 收尾：`flutter analyze`；`flutter test test/record test/settings test/today`
- Lucent：`pnpm test -- records.service`、`-- sleep-trend-builder`、`-- changes.service`、`pnpm typecheck`

## 提交拆分（仅评审粒度）

无兼容窗口，先后顺序不影响正确性；这样拆只是为了让每个提交只讲一件事。

1. `refactor(record,health_data): 睡眠 payload 键位统一为 startedAt/endedAt`
   — 抽领域服务 + 四处键位改名
2. `refactor(daily-records)!: 睡眠 payload 校验收敛并移除 start/wake 事件例外`（Lucent，带 `BREAKING CHANGE` body）
3. `feat(record): 睡眠快速录入改为一次性录入` — 新 sheet + 删除状态机与三个弹窗
4. `chore(record): 移除睡眠进行中标记与默认时长偏好` — 死配置、死分支、l10n 清理
5. `docs(reference,logs): 登记睡眠录入语义与 payload 契约收敛`

每个提交各自追加当日迁移日志条目。

## 风险与取舍

- **小睡类型 vs 设备导入**：手动录入写显式 `sleepType`；HealthKit / Health Connect 导入仍用
  `durationMinutes <= 180 ? nap : nightSleep` 推断（设备数据没有用户声明）。此差异写入 record README。
- **`FTimeField.picker` 在 sheet 内**：需实测滚轮在 sheet 内的布局约束（此前 `FPicker` 在 sheet 里
  因无界高度崩过，已用固定高度解决）。
