# Active UI — Record

Last updated: 2026-07-20 (P1 record)

## 支持的记录类型

- 症状
- 饮水（可选单位）
- 饮食/餐食
- 心情
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

- 活跃创建类型：water、meal、mood、symptom、note、sleep。
- 快速选项点击立即保存（选中日期 + 真实当前 `HH:mm`），`more` 打开完整创建表单。
- 快捷选项 label/unit 从硬编码改为 l10n 取值。
- **必填校验**：`onSave` 新增前端校验——value 字段必填（空值拦截+内联 error），water 额外校验数值有效性，title 字段必填（内联 error）。校验消息通过 `FTextField.error` 在字段下方内联显示，不再走 toast。

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

