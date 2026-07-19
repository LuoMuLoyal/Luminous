# Active UI — Record

Last updated: 2026-07-18

## 支持的记录类型

- 症状
- 饮水（可选单位）
- 饮食/餐食
- 笔记（独立类型：有自己的快捷操作、筛选、时间线项）
- 睡眠（结构化录入：就寝/起床/质量/阶段）
- 用药（非创建型快捷操作）

## 自然语言录入

- 移动端顶部输入条是唯一的自然语言录入入口；点击输入条本体打开底部弹层。
- 语音与 OCR 作为输入条右侧的辅助入口。
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
- 时间线项可点击跳转详情，保留骨架屏加载态。
- 移动端首屏默认展示前 7 条；超过 7 条显示"查看全部记录/收起"切换。
- **空态**：`entries.isEmpty` 时渲染图标+标题+描述+CTA 结构化空态，CTA 跳 `/record/create?date=<选中日期>`。桌面端额外附"清除筛选"按钮。

## 创建与快捷操作

- 活跃创建类型：water、meal、symptom、note、sleep。
- 快速选项点击立即保存（选中日期 + 真实当前 `HH:mm`），`more` 打开完整创建表单。
- 快捷选项 label/unit 从硬编码改为 l10n 取值。
- **必填校验**：`onSave` 新增前端校验——value 字段必填（空值拦截+toast），water 额外校验数值有效性，title 字段必填。

## 骨架屏

- 删除 `_GuidePlaceholder`（对应已删除的 `RecordGuideRow`）。

## 数据层

- `LucentDailyRecordRepository` 为 cache-first 模式：
  - **读**: 先读本地 Drift 缓存（有则返回 + 后台刷新节流 30s），缓存空则走网络 + 写缓存。
  - **写**: `create` 先写乐观本地副本（`syncStatus='pending'`），尝试远程写入，成功则 `confirmSync`，失败则入队 `PendingSyncItems`。
  - **SyncWorker replay**: `daily_record` entity type 的 replay handler 重放离线写操作（create/delete/update）。
- `DailyRecordJsonCodec` 手动序列化 `DailyRecordItem`。
- 错误反馈使用 l10n 消息（`recordDeletedToast`/`recordDeleteFailedToast`），不用通用"已保存"/"创建失败"。
- 删除操作 `context.pop()` 直接回列表页。

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
