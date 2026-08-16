---
status: active
owner: frontend
quadrant: reference
updated: 2026-08-16
---

# Active UI — Record

Last updated: 2026-08-16 (健康同步指标标题本地化与身高类型统一)

## Sparse Record Semantics 客户端边界

- 饮水的健康指标只把可解析且 `unit == ml` 的记录汇总为 canonical ml；明确的 `0 ml` 仍是 observed zero，无有效记录或只有不可换算单位时保持 `unknown/none`，分页或混合结果不完整时标记 `partial`。记录数量只保留为旧版快捷角标/兼容字段，不能冒充容量。
- 用药按 reminder slot 保持身份：同一药品的不同提醒不合并；`planned` 在客户端语义中是 `unconfirmed`，`taken`、`skipped` 和超时未确认分别保留。没有 reminder 的临时 dose log 独立处理，不猜测 `scheduledTime`，也不进入计划槽位分母。
- 睡眠标准记录使用 `sleepType`、`startedAt`、`endedAt`、`durationMinutes`（可选质量）；`nightSleep` 与 `nap` 同日均保留。快速录入产生的 start/wake facts 只是合并前的临时事实，取消合并时不删除它们。
- 健康平台导入把饮水规范为 `ml`，保留来源、平台 external ID 和睡眠 episode 起止时间；external ID 优先去重，缺失时使用 kind/source/start/end/value/unit 稳定指纹，因此同日多条睡眠或饮水不会互相覆盖。
- 自动同步能力明确区分 `unsupported`、`notConfigured` 和 `available`。当前没有后台 executor，前台导入仍可用，但自动同步开关保持关闭；平台不可用或未配置时不显示为通用可用能力。
- 健康同步导入页（`HealthSyncPage`）可选择的数据类型包含身高（`HealthMetricType.height`，走 HealthKit/Health Connect 的 HEIGHT，单位 cm），与导入链路一致；预览区指标标题由 `healthSyncMetricTitle*` l10n 键渲染，不再硬编码中文。

## 支持的记录类型

- 症状
- 饮水（可选单位）
- 饮食/餐食
- 心情
- 笔记（独立类型：有自己的快捷操作、筛选、时间线项）
- 睡眠（结构化录入：就寝/起床/质量/阶段）
- Lucent 后端已支持 nightSleep/nap episode；Flutter 快速录入合并睡眠时写入 `sleepType`、`startedAt`、`endedAt` 和 `durationMinutes`，旧临时 start/wake facts 仍只作为录入过程使用。
- 用药（非创建型快捷操作）

## 自然语言录入

- 移动端 header 右上角为 NLP 入口（sparkles 图标，`recordNlpHeaderAction`），点击打开 NLP bottom sheet（`showFSheet`，btt 方向）。
- 语音与 OCR 功能已移除（产品职责重新判定 + 中文医疗词汇准确率无法保证）。
- 接入 Lucent candidate 解析，确认后保存。
- 候选审核可编辑、可选择性保存：调整 title/value/unit/note、编辑睡眠 payload、取消选中项、仅重试失败候选。
- 候选编辑器按类型做轻量打磨：water 数字量 + 单位选择器、meal/symptom 更具体字段标签、note 强调正文。

## 日期与时间

- 选中日期时间线 / 详情 / 创建 / 编辑。
- 顶部日期栏、筛选器。
- panel-backed 快速记录与时间线 section。
- 创建/编辑表单使用 Forui `FDateField.calendar` + `FTimeField.picker`。
- Lucent daily-record 持久化保留 `occurredAt` 作为日期键，单独持久化 `occurredTime`。

## 桌面月历

- `RecordMonthCalendarPanel` 为 `StatefulWidget`，月份浏览（`_viewedMonth`）与日期选中（`selectedDate`）解耦。
- 左右箭头切换月份仅更新本地查看月份，不再调用 `onDateSelected` 强制跳到 1 号。
- 查看月份与选中日期同月时使用父组件传入的 `days`（含服务端标记），否则本地生成该月日历网格（无标记，仅高亮选中日）。
- `didUpdateWidget` 在 `selectedDate` 跨月变化时自动同步 `_viewedMonth`。
- 月历标题使用 `DateFormat.yMMMM(locale).format(selectedDate)` 动态格式化。

## 时间线

- 桌面端 `RecordTimelinePanel` 与移动端 `RecordMobileTimeline` 均使用 `timeline_tile` 绘制。
- 时间线项可点击跳转详情。移动端不再使用骨架屏（loading 时显示 `RecordSkeletonView`，时间线区域 `isLoading` 始终为 false）。
- 移动端首屏默认展示前 7 条；超过 7 条显示"查看全部记录/收起"切换。
- 时间线条目按 `occurredTime ?? occurredAt` 倒序排列（最新在最上方），排序在 `LucentRecordRepository` 的原始 `DailyRecordItem` 列表上完成。
- 移动端图标容器背景使用 `softColor.muted(context)`（tinted background），圆角 `RadiusTokens.level3`，时间标签宽度 44px。
- **空态**：`entries.isEmpty` 时渲染图标+标题+描述+CTA 结构化空态，CTA 跳 `/record/create?date=<选中日期>`。桌面端额外附"清除筛选"按钮。
- **桌面端拖拽改日期**：时间线卡片（仅 `recordId != null` 的真实记录）包裹 `Draggable<TimelineDragData>`，可拖拽到日历日期单元格（`DragTarget`）改变记录日期。拖拽时源卡片半透明（opacity 0.4），拖拽预览为紧凑浮动卡片（图标+标题+日历图标）。目标日历日期悬浮高亮（primary 色调背景+边框）。成功后调用 `dailyRecordRepositoryProvider.update()` 更新 `occurredAt`，发射 `DataChangeTopic.dailyRecords` 触发看板刷新，自动导航到新日期，Toast 反馈结果。移动端不启用拖拽。
- **桌面端 badge 溢出修复（2026-08-13）**：时间线标题行的状态 badge（`entry.badgeKey`）在桌面窄列下横向溢出（RenderFlex overflow，确定性复现并阻断 `-d windows` e2e）；badge 外层与内层文案均改为 `Flexible` 参与收缩 + 单行省略号截断（`timeline_item.dart`）。

## 创建与快捷操作

- 活跃创建类型：water、meal、mood、symptom、note、sleep。
- 快速选项点击立即保存（选中日期 + 真实当前 `HH:mm`），`more` 打开完整创建表单。
- 快捷选项 label/unit 从硬编码改为 l10n 取值。
- **必填校验**：`onSave` 新增前端校验——value 字段必填（空值拦截+内联 error），water 额外校验数值有效性，title 字段必填（内联 error）。校验消息通过 `FTextField.error` 在字段下方内联显示，不再走 toast。

## 快速记录 UX 重构

- 阶段 1 已建立 quick-entry foundation：
  - Record header 新增 `record-quick-settings-action`，进入 `/record/quick-entry-settings`。
  - Settings 页保留快速记录次入口 `settings-row-quick-entry`，不再直接承载动态排序/收起开关。
  - `quick_entry_panel.dart` 回归展示职责：渲染网格、Note 独立入口和 help affordance；动态排序开关与手动排序入口迁入专门设置页。
  - `QuickEntryExecutor` 作为兼容执行边界，仍保留旧 `RecordFastEntryDialog` / 创建页 fallback 给未重构类型使用；后续阶段继续替换 medication/sleep/meal flows。
  - `QuickEntryPreferences` 新增饮水默认量、饮水角标模式、睡眠进行中标记偏好，并保留动态排序和自定义顺序。
- 阶段 2 已接入低风险 daily record 快速写入：
  - 饮水单击不再打开 fast-entry 弹窗，按 `QuickEntryPreferences.waterDefault`（`QuickEntryWaterDefault` 枚举，可设 250 ml / 500 ml / 1 杯 / 1 次 / 自定义 ml）立即创建 water daily record，默认 `250 ml`；自定义值存 `waterCustomMl`。
  - `QuickEntryUndoService` 支持撤销即时 daily record 写入：删除刚创建的记录并发射 `DataChangeTopic.dailyRecords`。
  - 饮水、症状单选、情绪单选这些无确认即时写入成功后显示带“撤销”的快速记录 toast；写入失败不注册撤销。
  - 症状弹窗支持多选模式：点击“多选”后 chip 仅切换选中，底部“确认”批量写入；批量确认属于用户显式确认，不显示撤销 toast，部分失败时保留失败项可重试。
  - 情绪仍使用旧 fast-entry 弹窗展示常见情绪，点选一个情绪立即保存并可撤销。
- 阶段 3 已接入用药快速记录：
  - Record 用药入口读取当前药箱、提醒计划和所选日期 dose logs，不再跳空白创建页。
  - 0 种当前用药时弹轻量确认框，引导去 `/medicine/search` 添加药品。
  - 1 种当前用药时，若当前时间前 30 分钟到后 2 小时内有 pending reminder slot，直接调用 slot-aware dose log mark；没有附近 slot 时走临时服药路径，不猜测 `scheduledTime`，并明确提示未关联提醒。
  - 附近 slot 已 taken/skipped 时不重复写入，只提示附近用药已记录。
  - 2+ 种当前用药时打开选择弹窗，默认选中附近 pending slot 对应药品；普通 reminder slot 确认写入不显示撤销 toast，临时服药选择会显示批量撤销 toast，部分失败时保留失败项。
  - 用药即时写入撤销走 dose log 真实回滚：新建 log 删除，已有 log 恢复旧状态，并刷新 `DataChangeTopic.doseLogs`。
- 阶段 4 已接入睡眠快速记录：
  - 睡眠入口单击不再打开旧的时长选择 fast-entry 弹窗。
  - 没有进行中睡眠时，单击先选择夜间睡眠或午睡，可选填写大致分钟数与睡眠质量，再按当前时间创建 `DailyRecordKind.sleep` 临时 start fact：`payload.sleepEvent=start`、`payload.sleepType=nightSleep|nap`、`payload.approximateDurationMinutes`、`payload.quality`、`payload.eventAt=<UTC ISO>`，成功后显示可撤销 toast。
  - 若前一天或当天存在一个未被 wake fact 关联的 start fact，再次单击先创建 wake fact：`payload.sleepEvent=wake`、`payload.eventAt=<UTC ISO>`、`payload.startedRecordId=<start id>`，随后展示合并确认。
  - 合并确认展示入睡、醒来和总时长；确认后创建标准 sleep episode payload（`sleepType/startedAt/endedAt/durationMinutes`），再删除 start/wake 临时事实。取消则保留两条事实。
  - 若发现多个未结束 start，弹出选择对话框，由用户选择要结束哪一段；不自动猜测。
- 阶段 5 已接入餐食快速记录：
  - 餐食入口单击不再打开旧的早/中/晚餐 fast-entry 弹窗，而是优先调用相机。
  - 相机取消时不写入、不 toast。
  - 拍照成功后弹出轻量确认对话框，展示图片并允许补充标题、名称/描述和备注；默认标题按当前时间预填早餐/午餐/晚餐/加餐。
  - 用户确认后才上传图片并创建 `DailyRecordKind.meal` daily record，attachments 继续复用既有 `uploadImage` + `DailyRecordCreateInput.attachments` 链路，因此可进入后端 meal analysis 流程。
  - 餐食确认保存属于显式确认写入，成功后显示普通保存反馈，不显示撤销 toast。
- 阶段 6 已完成快速记录排序/帮助/角标收尾：
  - quick panel help 按钮会弹出轻量说明对话框，复用各快捷项规则文案，说明当前单击/确认式行为，不引入双击心智负担。
  - 快速记录设置页在动态排序开启时禁用手动排序入口，并显示“请先关闭动态排序再编辑顺序”。
  - 手动排序页从占位页改为说明 + `ReorderableListView`，按默认顺序或用户自定义顺序展示 7 个快捷入口，拖拽后写入 `QuickEntryPreferences.customOrder`。
  - “重置为默认顺序”只清除 `customOrder`，不影响饮水默认量、角标或睡眠进行中标记。
  - quick panel 现在接收 dashboard summary/timeline：饮水角标按偏好显示今日累计量或次数；睡眠角标在发现未合并的 sleep start fact 时显示“进行中”。
- 阶段 7 已还原长按行为并迁移图标选择器：
  - 长按快捷瓦片不再打开图标选择器，改为按类型弹出 Forui 弹窗：water → 饮水默认量/角标设置；meal → 无照片手动录入（`MealQuickConfirmationDialog`）；medication/symptom/mood/sleep → 该类型当前规则说明。回调经 `onQuickActionLongPress`（`page.dart` → `RecordDashboardView` → `RecordQuickEntryPanel`）分发到 `handleQuickActionLongPress`。饮水默认量下拉含"自定义"选项：选中后弹出 `water_custom_amount_dialog` 输入毫升数，确认后保存 `custom` + `waterCustomMl`；设置页与长按弹窗共用 `handleWaterDefaultSelect`。
  - 自定义图标选择器迁移到两处：快速记录设置页"自定义图标"区（7 种类型逐行选择 + 恢复默认）与创建/编辑记录页的 `RecordKindIconField`（仅对映射到快捷类型的 kind 渲染）。
  - `RecordDashboard.defaultQuickActions` / `quickActionFor` 与 `resolveQuickActionIcon` 作为默认图标与生效图标的统一来源。
- 阶段 8 详情页增强：
  - 按类型富展示：water 记录显示"今日饮水"卡片（聚合当天 ml 记录，`{total} / 2000 ml` + 进度条）；mood 记录解析 `payload.moodLabel` 展示本地化情绪行。
  - 相邻导航：底部"上一条/下一条"按钮（`dailyRecordListForDateProvider` 拉当天记录，按发生时间排序），`pushReplacement` 切换；边界禁用。
  - 复制摘要：`record-detail-copy-action` 复制类型/数值/情绪/备注/来源/更新时间到剪贴板。
- 阶段 8 编辑页重构：
  - 逻辑下沉 `RecordEditController`（`presentation/providers/record_edit_controller.dart`）：`RecordEditState` 不可变表单状态 + load/save/isDirty/字段 setter/pickImage；页面瘦身为纯表单渲染。
  - 未保存提醒：文本监听保持 dirty 实时，`PopScope` 拦截系统返回 + `AppBackButton` 自定义返回，弹“放弃修改？”确认（`recordEditDiscard*` 文案）。
- 阶段 9 长按设置面板（Symptom / Mood / Sleep / Medication）：
  - 长按 symptom 快捷瓦片不再只显示静态规则文本，改为弹出可配置面板：默认严重程度 `FSelect`（mild/moderate/severe）+ 症状选项 `FilterChip` 勾选。
  - `QuickEntryPreferences` 新增 `symptomDefaultSeverity`、`symptomEnabledChoices` 字段，对应 PrefKeys `record.quickEntry.symptom.defaultSeverity` / `.enabledChoices`。
  - `RecordFastEntryDialog` 读取偏好过滤症状选项并应用默认严重程度。
  - `QuickEntrySettingsPage` 新增“症状选项”分区，与长按弹窗双向同步。
  - 长按 mood 快捷瓦片弹出默认心情级别选择（很棒/不错/一般/不太好/很糟）+ 角标模式设置（今日最新 / 不显示），`QuickEntryPreferences` 新增 `moodDefaultLevel`、`moodBadgeMode` 字段。
  - `quick_entry_panel.dart` 新增 mood 徽章逻辑：`latest` 模式显示今日最新心情标签。
  - `RecordFastEntryDialog` 读取 `moodDefaultLevel`，在 mood 弹窗中为匹配的选项下方显示 primary 色圆点高亮，提示默认项。
  - 长按 sleep 快捷瓦片弹出默认睡眠时长选择（6h/7h/8h/9h）+ 进行中徽章开关，`QuickEntryPreferences` 新增 `sleepDefaultDurationMinutes` 字段。
  - `RecordFastEntryDialog` 读取默认时长偏好，将匹配的选项排在最前面。
  - 长按 medication 快捷瓦片弹出两个开关：单药自动记录 + 已记录提示。`QuickEntryPreferences` 新增 `medicationAutoRecordSingle`、`medicationShowAlreadyRecordedHint` 字段。
  - `MedicationQuickEntryFlow.handleTap` 新增 `autoRecordSingle` 参数控制单药是否自动记录。`handleMedicationQuickAction` 读取 `showAlreadyRecordedHint` 控制已记录 toast。
- 阶段 10 详情页 / 编辑页区分度精进（2026-08-06，已实施，见 `docs/03-logs/migration-log/2026-08-06.md`）：
  - 详情页 = 只读快照：顶栏编辑图标移除；头部 Hero 化——`_KindHeroAvatar` 52px 圆形类型图标（`RecordDashboard.quickActionFor` + `resolveQuickActionIcon` 与快速记录面板图标同源，vitals/activity 回退 primary）+ 标题旁 `_SourceBadge` 来源徽章（信息行的「来源」行移除避免重复，复制摘要仍含来源）。
  - 详情页底部操作重排：`record-detail-edit-action` primary 主按钮「编辑这条记录」→ 上一条/下一条 ghost 并排 → 复制摘要 ghost → 删除 destructive 置底。
  - 编辑页 = 编辑工作台：表单顶部 `_EditStatusHint` 提示条，默认「修改后点击保存生效」（muted），dirty 时切换警告色「有未保存的更改」（`SemanticColor.warning`），与返回丢弃确认（`recordEditDiscard*`）形成闭环。
  - 详情页票据式排版：核心数值行（value + unit）`highlight` 大字号（`level6.display` + primary 加粗）；信息行间 `AppDivider` 细分隔线。
  - 编辑页表单面板：全部字段收进浅灰底衬面板（`colors.secondary` + 圆角），与页面白底产生层次，一眼区分「输入区」。

## 骨架屏

- 删除 `_GuidePlaceholder`（对应已删除的 `RecordGuideRow`）。
- 桌面端骨架为三栏布局（左 sidebar + 中 summary/timeline + 右 new-entry），与真实 `_DesktopRecordDashboard` 对齐。

## 数据层

- `LucentDailyRecordRepository` 为 cache-first 模式：
  - **读**: 先读本地 Drift 缓存（有则返回 + 后台刷新节流 30s），缓存空则走网络 + 写缓存。
  - **写**: `create` 先写乐观本地副本（`syncStatus='pending'`），尝试远程写入，成功则 `confirmSync`，失败则入队 `PendingSyncItems`。
  - **SyncWorker replay**: `daily_record` entity type 的 replay handler 重放离线写操作（create/delete/update）。
- `DailyRecordJsonCodec` 手动序列化 `DailyRecordItem`。
- 错误反馈使用 l10n 消息（`recordDeletedToast`/`recordDeleteFailedToast`），不用通用"已保存"/"创建失败"。
- 删除操作通过 `deleteRecord` use case（`application/usecases/record_detail_actions.dart`）编排：确认对话框 → repo.delete → provider invalidation → toast → pop。编辑页 popCount=2，详情页 popCount=1。
- 编辑入口通过 `editRecord` use case 编排 auth-required route push。

## 2026-07-19 补充

- 移动端标题按选中日期动态文案（今日用 `recordTodayEntriesTitle`，非今日用 `recordDateEntriesTitle`）。
- 占位条目跳创建页传入选中日期而非 `DateTime.now()`。
- 桌面端"语音记录"按钮文案改为"新建记录"（与实际行为一致）。
- "动态排序"开关新增文字标签；编辑顺序按钮在动态排序开启时真正禁用。
- 睡眠校验 toast 改为"请选择就寝和起床时间"（与表单使用时间选择器一致）。
- 保存按钮新增 `FCircularProgress` 进度指示器。
- 删除失败 toast 使用 `recordDeleteFailedToast`（"删除失败"）。
- "来源"行使用 `_sourceLabel` 映射（`manual`/`local`/`ai`/`import` → l10n 标签）。
- 营养热量补 `kcal` 单位；食材匹配箭头从 ASCII `->` 改为 `→`。
- 删除确认标题改为"删除记录"。
- `loadRecord` 失败渲染 `AppStateErrorView` + 重试按钮（不再 toast+pop 闪烁）。
- `RecordMonthCalendarPanel._dateForDay` 基于 `viewedMonth` 而非 `selectedDate` 计算日期（修复跨月浏览时日期计算错误）。

## 2026-07-19 P2 低级一致性打磨

- `date_bar.dart` 的 `_weekdayFontSize` 和 `_dateFontSize` 提取为文件级常量，消除魔数。
- `form_fields.dart` 和 `nlp_candidate_editor.dart` 水量值字段新增 `keyboardType: TextInputType.number`，移动端弹出数字键盘。
- `create.dart` 和 `fast_entry_dialog.dart` 保存成功 toast 从 `mineEditSavedToast` 改为专用 `recordCreateSavedToast`（"记录已保存"）。
- `fast_entry_dialog.dart` 保存时新增 `FProgress` 指示器。
- `nlp_dialog.dart` 的 `handleReset` 改为 async 并新增确认弹窗（`AppDialogShell` + `recordNlpResetConfirmTitle/Body/Action`），避免误触清空草稿。
- `dashboard.dart` 的 `onTimeout` 文案改为英文与全 App 一致。

## 2026-07-19 剩余中级项

- 记录主页两端接入下拉刷新（桌面 `DesktopTabShell.onRefresh`，移动 `RefreshIndicator`），失败显示 `recordRefreshErrorToast`。
- 记录详情 meal 分析"分析中"状态自动 5 秒轮询（`Timer.periodic` → `ref.invalidate(dailyRecordDetailProvider)`），状态变更后自动停止。
- 编辑页锁定类型不可切换（`showKindField: false`），消除切型静默丢弃 payload。
- 菜品"确认当前结果"按钮改为可切换态（选中 `primary` + 对勾图标，未选中 `outline`），不再恒设 true。
- NLP 主弹层 `scrollable` 从 `false` 改为 `true`，候选多时可滚动。
- OCR 弹层识别结果从只读 `Text` 改为可编辑 `FTextField`；新增“重新选择”按钮（`recordOcrRetakeAction`），重置图片和文本。

## 2026-07-20 P1 记录模块

- **桌面筛选单选语义**：`_FilterRow` 图标从 `squareCheckBig`/`square`（复选框）改为 `circleCheck`/`circle`（单选），选中色从 `foreground` 改为 `primary`。点击已选中筛选可取消（传回 `null`）。
- **语音 sheet 错误显示**：`errorMessage` 不再只存不显，新增内联错误显示区（图标+红色文案）。
- **语音 sheet 分类文案**：初始化失败区分三类场景——权限拒绝（`recordMicPermissionDenied`）、语音不可用（`recordSpeechUnavailable`）、locale 不支持（`recordSpeechLocaleUnsupported`），不再统一报“麦克风权限未授权”。
- **语音结果可编辑**：识别结果从只读 `Text` 改为 `TextField`，用户可手动编辑修正（`recordVoiceEditHint` 提示）。
- **标题标签修正**：`recordCreateFieldTitleOptional`（“标题（可选）”）改为 `recordCreateFieldTitle`（“标题”），消除与必填校验的矛盾。
- **保存中表单整体禁用**：`DailyRecordFormFields` 新增 `enabled` 参数，`saving` 时所有字段（kind/value/unit/title/note）连同图片附件一起禁用。
- **NLP 预生成失败提示**：`nlp_dialog.dart` 新增 `RecordNlpStatus.error` 状态分支，显示图标+错误文案（`state.errorMessage` 或 `recordNlpGenerateFailedToast` 兜底）。

## 2026-07-20 P2 记录模块打磨

- **locked 筛选策略一致**：`sidebar.dart` 的 `_FilterRow` onTap 增加 `filter.locked` 检查，locked 筛选在桌面端也禁用点击，与移动端一致。
- **创建页分区标题**：`create.dart` 在 `RecordOccurredAtFields` 前添加"基本信息"标题，在 `DailyRecordFormFields` 前添加"记录内容"标题，字段不再无分区堆叠。
- **切类型清理不适字段**：`onKindChanged` 新增 `dailyRecordFormRules(newKind)` 检查，不显示的字段（`showValue`/`showTitle`/`showUnit` 为 false 时）自动清空 controller，避免切回时旧内容静默重现。
- **date_bar 字号 token 化**：`_weekdayFontSize` / `_dateFontSize` 改为 `TypographyToken.level2` / `TypographyToken.level3` 的 `fontSize` 取值。
- **移动端"回到今天"入口**：非今日选中时标题行右侧显示"回到今天"按钮。
- **移动端筛选空态"清除筛选"**：筛选激活且无结果时空态显示"清除筛选"按钮。
- **OCR 空结果反馈**：OCR 返回空文本时显示提示图标+文案。
- **详情页编辑入口去重**：移除底部重复的"编辑"按钮，仅保留"删除"。
- **详情页标签弹性宽**：`_DetailRow` 从 `SizedBox(width: 88)` 改为 `ConstrainedBox` 弹性约束。
- **菜品删除 tooltip/语义**：删除图标按钮新增 `Tooltip` + `semanticLabel`。
- **图片附件拍照入口**：新增可选 `onCameraPick` 回调，有值时显示"拍照"按钮。
- **脏状态返回确认**：新增 `PopScope` + `_isDirty` + `_confirmDiscardChanges`，表单有未保存内容时返回弹出确认。
- **NLP 候选睡眠时间选择器**：分钟数文本输入改为就寝/起床 `FTimeField.picker`，自动计算时长。

## 2026-07-21 快速记录区补齐与视觉优化

- **补齐七个入口**：移动端 `Quick record` 在未登录/静态 dashboard 下从 5 个补齐到 7 个，顺序为 Symptom、Medication、Water、Meal、Sleep、Mood、Note。缺口的 Medication / Mood 已加入 `RecordDashboard.signedOut` 的 `_defaultQuickActions` 和 `_defaultFilters`，以及 `dashboard_tokens.dart` 的 `defaultQuickActionOrder` / `buildMobileFilters` preferred order。
- **Note 与其他入口统一**：移除 `quick_entry_panel.dart` 中 Note 的独立灰色 `FButton`，改为和网格 tile 一致的圆形 `FAvatar` + label 样式；上面 6 个入口保持 3 列网格，Note 独占底部一行，且为左图标右文字的横向布局，垂直内边距减小，整体高度更低。
- **图标统一**：未登录与登录后的静态 quick actions 使用同一套图标（`briefcaseMedical` / `pill` / `droplets` / `utensils` / `moon` / `smile` / `notebookPen`），登录态原本深色的 `primary` softColor 改为 `neutral`，避免图标和背景融为一体。
- **图标尺寸与背景**：`quick_entry_panel.dart` 的 `FAvatar` 背景从 `softColor.solid(context)` 改为 `softColor.subtle(context)`，去掉过深的圆形底色；头像容器从 `level6–level7`（20–28px）放大到 `level6–level7`（28–36px）；内部图标从 `Spacing.level4` 放大到 `Spacing.level5`（约 20px）。
- **筛选条同步**：底部筛选 chip 同步显示 7 个类型，与快速记录入口一致。

## 2026-07-21 筛选 Provider 修改延迟模式

- **问题**：点击筛选 chip 时 `onFilterSelected` 回调在 widget build 生命周期内直接修改 `selectedRecordFilterProvider`，触发 `FlutterError: Tried to modify a provider while the widget tree was building`。
- **修复**：`RecordPage` 向 `RecordDashboardView` 传递的 `onFilterSelected` 回调使用 `Future(() => ...)` 延迟 provider 修改，使其在 widget tree 构建完成后执行。此模式与 `onQuickAction` 中已有的 `quickEntryPreferencesProvider` 延迟修改保持一致。
- **影响范围**：移动端 `RecordMobileFilter` 的 chip 点击、桌面端 `RecordFilterPanel` 的 `_FilterRow` 点击均通过此回调间接受益。

## 2026-07-25 桌面端记录页 UI 优化

### 三栏布局

- 左栏（**260px 固定**）：月历 + 筛选面板，更紧凑
- 中间（**Expanded 自适应**）：摘要网格 + 时间线
- 右栏（**220px 固定**）：新建记录面板

### 新建记录面板（桌面端）

- `RecordNewEntryPanel` 根据 `width >= Breakpoints.desktop` 切换桌面/移动布局
- 桌面端使用垂直列表布局（`_DesktopEntryButton`）：32px 圆形图标 + 文字标签占满面板宽度
- hover 状态使用 `SemanticColor.neutral.subtle(context)` 背景变化
- 底部主按钮使用 `FButtonVariant.primary`，占满宽度

### 日历面板

- 月份导航按钮使用 `FButtonSizeVariant.xs`，图标 16px（`IconSizeTokens.level2`）
- 日历网格 `childAspectRatio: 0.95`，间距 `Spacing.level1`
- 筛选面板「全选」按钮图标为 `checkCheck`（语义：全选，非导航）

### 时间线面板

- 标题右侧显示当前选中日期（`DateFormat.yMd(locale)`）
- 空状态使用 `Center` + `ConstrainedBox(maxWidth: 320)` 居中
- 时间线卡片使用 `DecoratedBox` + 左侧 3px 色条（`entry.accent.solid`）区分记录类型，不再使用嵌套 `FCard`

### 摘要网格

- 桌面端固定 4 列，`minTileWidth: 160px`
- 图标容器固定 28px，图标 16px
- 数值字体 `TypographyToken.level6`

## 2026-08-04 全仓库审查修复（Record 模块）

### 常量与 token 统一

- 新增 `lib/features/record/presentation/constants.dart`，定义 `kCalendarMinYear = 2000` 与 `kCalendarMinDate`，替换 `record/presentation/pages/page.dart` 中日历选择器硬编码 `DateTime(2000)`。
- 快速记录/确认弹窗中 7 处硬编码 `maxWidth: 440` 统一改为 `LayoutScaleResolver.dialogStandardMaxWidth`（`lib/core/design/layout_scale.dart`），涉及 medication/sleep/meal/quick-entry 与水杯自定义量等弹窗。

### 异常日志补齐

- `quick_entry_medication.dart`、`quick_entry_sleep.dart`、`quick_entry_meal.dart`、`record/presentation/pages/page.dart` 中原 `catch (_)` 块改为 `catch (e, st)`，并通过 `ref.read(talkerProvider).error(...)` 记录异常与堆栈，便于线上问题追踪。

### 数据层稳健性

- `LucentDailyRecordRepository._refreshInBackground` 内联 `Duration(seconds: 30)` 改为复用 `backgroundRefreshThrottle`（`lib/core/database/cache_constants.dart`）。
- 新增按日期维度的连续后台刷新失败计数器；连续失败 3 次后将日志级别从 warning 提升为 error，成功时清空计数器，避免过期缓存长期静默。

## 2026-08-15 全仓库审查修复（Record 模块）

### 详情页分析轮询退避与防重入

- `record/presentation/pages/detail.dart` 的餐食分析轮询从 `Timer.periodic`（固定 5s、fire-and-forget）改为链式单次 `Timer`：每轮 `invalidate` 后 `await` provider future 覆盖整个请求周期（防重入锁，请求超过间隔不再堆积并发），成功回到基础 5s 间隔、失败按指数退避至 30s 上限；`dispose` 时取消链，分析完成由 build 驱动照常停轮。

### NLP 错误状态与保存失败信息

- `nlp.dart` generate 失败时：无候选可回退才进入 `error` 态并展示错误横幅；保留旧候选时回到 `reviewing` 且清空 `errorMessage`，消除"审查中 + 错误提示"并存的困惑状态。
- 并行保存失败时 `RecordNlpSaveOutcome.partial.message` 汇总全部失败原因（去重、换行拼接），不再只暴露最后一个错误。
