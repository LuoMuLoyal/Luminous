---
status: active
owner: frontend
quadrant: reference
updated: 2026-08-18
---

# Active UI — Today

Last updated: 2026-08-18 (H-10 `todaySuggestionProvider` now watches `DataChangeTopic.healthEvents` so suggestion cards refresh after event create/end/check-in; F-9 afternoon greeting now reports water gap in ml based on observedMetric.state; secondary action skip_dose wired to real dose-log mark; health-event association options show retry on load failure; quick-actions second slot changed to one-tap water quick-entry; dashboard data sources report degraded per-section instead of full-page error; Today AI summary uses materialized read model with empty/pending/ready/stale/failed states; ai_today_summary push routes to / with foreground toast; observation tiles render suppress feedback entry; AI explain falls back to rule-based label without retry when aiGenerated is false; TodayUserSnapshot.hasUnreadNotifications now reflects real notification unread count; medication summary dead enum TodayMedicationKind and nextMedicine removed; Today vital row reads real heart-rate/blood-pressure daily records; summary fallback narrative uses neutral onboarding copy)

## 页面结构

Today 根页为行动面板；手机端顺序为 `问候语 → 主建议卡 → 次建议区 → 今日摘要 → 健康观察 → 观察项 → 轻动作`。

桌面端双栏布局：`TopBar → Row[左7: Primary+Summary | 右5: Secondary+Observation] → QuickActions`。

旧的 `TodayOverviewSection / TodayPrioritySection / TodayAiSummarySection / TodayRecommendationSection / TodayTodoSection` 已整体下线。

## 主建议卡

- 承接当前最高优先的用药或饮水动作，卡内补齐 `证据 / 边界 / 主动作`。
- 用药类建议使用 `TodayCardTone.urgent`（destructive 边框 + 淡红底色），饮水类使用 `SemanticColor.primary`。
- 主卡图标使用 `gradient: true`，用药红色渐变、饮水蓝色渐变。
- 首屏只保留图标+标题+原因+进度条+主按钮，证据和边界收入 `FCollapsible` 折叠区。
- 原因下方渲染后端 `secondaryActions`（ghost `xs` 按钮）。其中 `skip_dose` 解析 route query 后调用 `DoseLogRepository.mark(status: 'skipped')`，成功后经 `DataChangeBus.doseLogs` 刷新建议；失败仅 toast `todaySuggestionSkipDoseError`，不切换反馈行状态。
- 底部 `已采纳 / 稍后处理 / 不适用 / 不再看到` 四个 ghost 按钮，根据后端 `feedbackOptions` 动态渲染，接入 `POST /today/suggestions/:id/feedback`。
  - 反馈提交期间保持旧卡内容可见，仅按钮自身进入本地 loading 状态；提交成功后按钮切换为只读「已反馈」指示器，同时 provider 在后台静默拉取新物化结果并替换卡片内容。
  - 若提交请求本身失败，显示失败 toast，不切换「已反馈」状态；若提交成功但后台刷新失败，仅记录日志，不替换当前卡片，不抛异常给 UI。
- 证据折叠区内「AI 解释」按钮，按需加载 `POST /today/suggestions/:id/explain`。瞬时网络错误保留最多 3 次重试；若后端返回 `aiGenerated: false`（模型未配置/策略拒绝/生成失败回退到规则文案），则直接展示 fallback 解释内容并标注「基于规则 / Rule-based」，不再空转重试。
- 证据区结构化逐条展示（`_EvidenceList` + `_EvidenceItemRow`），`subtype == 'water'` 显示 `FDeterminateProgress` 饮水进度条。
- `lifecycleState == fading` 时 `Opacity(0.6)` 视觉降级。
- 反馈提交后切换为只读「已反馈」指示器。

## 次建议区

- 使用 `FCard.raw` + `FTappable`，`TodayCardTone.soft` 与主卡形成层级差。
- error 状态显示重试 UI（`_SecondarySuggestionErrorState`）。

## 今日摘要

- AI 摘要接入服务端物化读模型：`todayAiAnalysisControllerProvider` 通过 `GET /today/analysis` 读取 `empty/pending/ready/stale/failed` 五种物化状态，不直接调用生成接口。
  - `ready`：展示 `analysis` 内容，标签显示「AI 生成摘要」。
  - `empty`：显示真实空态（`todayAnalysisEmptyTitle` / `todayAnalysisEmptyBody`）并提供刷新按钮。
  - `pending/stale/failed`：保留上一次可用的 analysis 内容，同时在卡片顶部显示物化提示条（`todayAnalysisPendingHint` / `todayAnalysisStaleHint` / `todayAnalysisFailedHint`），允许用户点击刷新重新物化。
  - provider 监听 `DataChangeBus` 相关 topic 并以 300ms debounce 重新读取；应用 resume 时比较 `sourceVersion`，变化才刷新。
- 概览指标改成更轻的横排 compact 样式，减少首屏垂直占用。
- 指标不再使用摘要卡内的背景盒子，避免卡片套卡片；层级只由外层容器、图标和文字区分。
- AI 叙述保持轻量，默认只展示短总结和折叠入口。
- 「查看依据」展开/收起使用 Forui `FCollapsible`（`AnimationController` + `CurvedAnimation` + `AnimatedBuilder`），与主建议卡证据折叠区动画模式一致。
- 生成按钮保留在卡片右下角，但卡片本体不再使用大块分割线和高内边距。
- AI 摘要文本使用 `MarkdownBody` 渲染。
- 睡眠 vital 行读取持久化睡眠记录的真实时长；无数据时回退 `--`。
- 睡眠概览值不再追加单位（后端 `valueLabel` 已含单位）。
- 用药概览值使用 `todayMedicationOverviewCount` l10n 键（"{done}/{total} 种"）。分母已修正为今日有提醒计划的药品数（`_todayScheduledMedicineIds`），无提醒时回退为全部当前药品数。
- Today domain 的 water `observedMetric` 只汇总可确认的 `ml` 记录；无记录为 `unknown/none`，明确的 `0 ml` 保留为 observed zero，混入不可换算单位或分页不完整时标记 `partial`，不再把记录条数当作毫升数。
- Today 摘要概览在有 observed metric 时显示 canonical ml（例如 `500 / 2000 ml`）；unknown 仍显示 `-- / 2000 ml`，不把记录条数投影成健康值。

## 观察项

- 从 `FTile` 改为自定义 `_ObservationTile`，使用 muted 图标色、无背景色。
- 数据源从旧 `todayRecommendationsProvider` 切换到 `todaySuggestionProvider.observations`。
- 置信度 tag 从后端 `confidence` 映射：`high → 去看看`、`medium → 值得留意`、`low → 仅供参考`。标签用 `FBadge` 呈现，high→`primary`、medium→`secondary`、low→`outline` 视觉分级。
- fallback 睡眠缺失提示保留，与后端观察项合并展示。
- section subtitle `以下内容仅供参考，不构成待办`。
- 后端观察项卡片若携带 `feedbackOptions` 且包含 `suppress`，则在 tile 内渲染精简版「不再看到」ghost 按钮；点击后调用 `todaySuggestionProvider.submitFeedback(suppress)`，成功后切换为只读「已反馈」指示器，失败时显示 `todaySuggestionFeedbackError` toast 且不切换状态。fallback 观察项不显示反馈入口。

## 轻动作区

- `FTileGroup` 分组入口：`确认用药 / 去喝水 / 用药安全 / 提醒设置 / 健康档案`。
- 确认用药副标题根据 `pendingCount` 动态生成。
- 第二个入口「去喝水」是一键饮水快捷动作：点击后直接调用 `executeTodayWaterQuickEntry`，使用 `WaterQuickEntryFlow` 创建一条饮水记录、发射 `DataChangeTopic.dailyRecords`，并显示"已快速记录 + 撤销"toast；撤销时通过 `QuickEntryUndoService` 删除记录。
- 快捷操作路由已修复：药品解读 → `/medicine/risk-check`，用药提醒 → `/medicine/reminders/new`（push）。

## 空态与提示

- 顶栏动态问候语根据用药待确认数和饮水状态动态生成。
  - 早上：按 `medication.pendingCount` 提示待确认用药数或“暂无用药安排”。
  - 下午：按 `water.observedMetric.state` 判断：
    - `observed`：按目标 ml 与已记录 ml 的缺口报“还差 {gap} ml”；缺口 ≤ 0 时报“饮水已达标”。
    - `unknown`（今天没有饮水记录）：报“今天还没记饮水”。
    - `degraded` 等不可确认状态同样回退到“今天还没记饮水”，避免与概览区 ml 口径冲突。
  - 晚上：按 `medication.pendingCount` 提示未确认用药数或“今天的记录都已处理”。

## 骨架屏

- 移动端按真实 section 顺序：TopBar → Greeting → PrimarySuggestion → SecondarySuggestions → Summary → HealthObservation → Observation → QuickActions。
- 桌面端双栏 `Row[左7: Primary+Summary | 右5: Secondary+Observation] + QuickActions`。

## 健康观察

- 手机 Today 在无 active event 时显示“开始一段健康观察”入口；开始只要求短标题，关联触发记录和当前短期用药保持可选。
- active event 显示事件标题和当天一次结果确认入口；当天已有 check-in 时不重复提交入口。
- check-in 与结束都只接受“好转 / 差不多 / 加重”，结束必须由用户选择结果。
- 三个确认弹窗由父层提供 repository action；请求失败时弹窗保留输入并显示可重试错误，取消不发请求。
- 写入成功后刷新 active event、Today dashboard 和 suggestion 数据；桌面端暂不接入新入口。
- check-in 日期按用户 profile 时区计算；缺失或无效时使用后端约定的 `Asia/Shanghai` 默认值。时区读取与 `yyyy-MM-dd` 日期键逻辑提取为共享工具 `lib/core/utils/local_date.dart`（`readUserTimezone` / `localDateKey`），today 与 report 的 check-in / 关联选项预读共用。
- 开始观察弹窗预读当前用药与今日症状记录时设 2 秒超时；任一预读失败不再静默返回空列表，而是在对应选项区显示 `todayHealthEventOptionsLoadFailed`（“加载失败，可重试”）与 ghost `xs` 重试按钮，点击后重新预读并更新弹窗状态。成功路径下选项区保持原样。

## 数据层

- `todaySuggestionProvider`（`AsyncNotifier`）管理建议卡生命周期：拉取、反馈、dismiss、自动刷新。
- **ADR-0009 cache-first**: 建议卡数据接入本地缓存（网络成功持久化 → 网络失败 stale-while-error 兜底 → 缓存反序列化失败时清理 + rethrow）。
- `TodaySuggestionJsonCodec` 手动序列化 `TodaySuggestionBundle`。
- AI 解释不缓存，始终走网络按需加载。
- Dashboard 用药统计通过 `cachedDoseLogDataSourceProvider` 读取（cache-first）。
- 图标映射提取为独立 `SuggestionIconMapping` 类。
- Dashboard repository 统一捕获健康快照失败，不再抛到 provider；页面级 8 秒 timeout 已移除，不再因单一上游超时导致整页白屏。饮水记录、服药日志、日常记录摘要等数据源失败时，对应指标标记为 `degraded`（`TodayObservedMetricState.degraded`），概览项渲染为 "暂不可用 / Temporarily unavailable" 并使用 destructive 颜色，与真实空态区分。血压等无真实数据源的指标仍保持 `unknown`。
- Today 移动骨架包含健康观察区块，顺序与加载完成后的移动页面一致；桌面骨架保持原双栏结构。
- `activeHealthEventProvider` 读取当前用户事件并提供经过认证守卫的 create/check-in/end action；空响应/404 映射为空态，其他请求错误保留为可重试错误。
- Lucent Task 6 已将建议采集口径收敛到 reminder slot：服务端按用户时区返回 `planned/taken/skipped/unconfirmed/overdueUnconfirmed`，同一药品的多个提醒槽位独立；Luminous 代码暂不改动，Task 8 负责把这些状态接入 Today domain/UI。
- Lucent Task 7 已将 Today Analysis 改为服务端事件驱动的物化读模型：GET 只读取 `empty/pending/ready/stale/failed` 状态，写入相关事实后由服务端限次生成；Luminous generated client 已同步 GET、refresh 及相关响应模型，domain 新增 `TodayAiAnalysisMaterializationStatus` 与 `TodayAiAnalysisCardState` 映射五种状态。由于生成的 `TodayAnalysisRefreshResponseDtoData` 把 oneOf 分支合并为所有字段 required 的扁平 DTO，refresh 走 raw Dio + 按 `status`/`analysis` 手工归一化，避免反序列化异常。
- Today AI data source 已按 generate API envelope 解包 `analysis`，并保留 direct analysis data 的类型安全映射；generated DTO 未被改写。
- Today suggestion GET 已切换为只读物化结果：domain 映射 `ready / stale / pending / failed / empty`，旧缓存缺失状态元数据时按 `ready` 兼容。
- `pending / stale / failed` 会保留可用的旧建议内容；`failed` 提供重试，`empty` 保持真实空态；缺少 `computedAt` 的 stale 结果仍显示更新中提示。
- Today suggestion provider 监听相关 `DataChangeBus` 事件（`dailyRecords`、`doseLogs`、`medicineReminders`、`healthContext`、`currentMedicines`、`userSettings`、`healthEvents`）并以 300ms 去抖重新 GET，不调用生成接口；应用 resume 时重新读取并比较 `sourceVersion`。
- `todayDashboardProvider` 同步监听 `healthEvents`，事件创建/结束/check-in 后 dashboard 自动刷新；`dashboard_view.dart` 中事件操作成功后的手动 `onRefresh()` 调用已移除，改由数据总线驱动刷新。
- 应用重启后的首次 GET 也会先恢复本地 suggestion cache，再将 `pending / stale / failed` 状态与旧卡合并，避免服务端尚未完成物化时覆盖可用内容。
- DataChangeBus、resume 和手动操作触发的建议 GET 按 FIFO 串行执行，旧请求完成后不会覆盖较新的刷新结果。
- Proactive Suggestion Runtime Task 9 已完成：服务端写入 → worker 物化 → Today 只读 GET 的 PostgreSQL + Redis live acceptance 已通过；连续 10 次相关写入最终收敛到同一 `sourceVersion / computedVersion`，客户端继续保留 `pending / stale / failed` 的旧卡回退语义。
- `TodayUserSnapshot.hasUnreadNotifications` 不再硬编码为 `false`；`LucentTodayRepository` 在 `fetchDashboard` 中调用 `NotificationRepository.getUnreadCount()`，将未读数映射为布尔标志，获取失败时降级为 `false`。

## 助手入口

Last updated: 2026-08-21

- Today 顶部栏暴露一级助手入口（`FLucideIcons.sparkles` 图标按钮）→ `/assistant` 工作区。
- 助手页使用轻量 Forui header：从左到右为返回、历史对话、新会话、设置；不再在消息区常驻技术状态卡。
- 历史对话使用页面内不透明 push drawer：聊天页整体向右移动，抽屉内容不会通过透明 modal barrier 覆盖聊天页。
- 助手设置（启用 AI 对话 / 持久化记忆 / 4 个上下文开关）从 header 设置按钮跳转到独立 `/settings/ai` 页面调整。
- 流式滚底优化：仅当用户已处于底部附近时自动滚底；用户上翻后显示"回到底部"悬浮按钮。
- 助手状态文案已重写为自然语言（"AI 助手已准备好" / "AI 助手正在准备中" / "AI 助手暂时不可用" / "AI 助手已关闭"）。
- **页面结构拆分**：`AssistantPage` 仅保留控制器与高层回调，UI 布局下沉到 `AssistantPageBody`；消息列表 + 输入区由 `AssistantConversationStack` 负责；文件行数全部达标（`page.dart` 163 行，子组件均 < 250 行）。
- **输入区重构为 `AssistantInputBar`**：默认单行，最多 5 行；发送按钮放入同一个 Forui `FTextField` suffix，避免盒中盒；空会话的 4 个本地化快捷提问 chip（今日总结 / 睡眠 / 用药 / 注意事项）移到中央欢迎区，点击后写入输入框；桌面端 focus 后显示 `Ctrl/⌘ + Enter` 快捷键提示，3 秒后自动淡出。
- **消息气泡去工程化**：`AssistantMessageBubble` 移除工具 chip 渲染与"正在生成"文字标签，流式期间使用 pulsing dots 动画指示器；用户气泡文字使用主色实色，避免浅色背景上使用浅色 `primaryForeground` 导致不可读；上下文菜单改用 `FContextMenu.tiles`，复制和"重新生成 / 重新发送"操作的完整按钮化交互仍列入 TODO。
- **流式 rebuild 优化**：`AssistantPage` 用多个 `ref.watch(...select(...))` 切片订阅状态，`streamingDraft` 变化不再触发父级重建；`AssistantConversationSurface` / `_ConversationView` 改为 `ConsumerWidget`，`messages` 与 `streamingDraft` 分别独立 select 订阅；`AssistantMessageBubble` 流式期间渲染纯 `Text`、结束后才切 `MarkdownBody`，避免每个 chunk 重复解析整段 markdown。当前后端对常见 graph 回答先执行 `graph.invoke()`，再通过空白切分回放伪 chunk；SSE 传输正常，但尚未实现从 graph/LLM 到 HTTP 的真实增量流。
- **侧边栏重构为会话管理器**：`AssistantConversationDrawer` 通过页面内 `Stack` 从左侧推入，固定不透明背景；顶部使用 Forui 搜索框、关闭和新对话按钮；会话仍按"今天 / 最近 7 天 / 更早"分组，当前会话用 `prefix` 对勾图标高亮；搜索只过滤已加载列表，重命名/删除因后端暂无对应接口暂未接入。
- **首屏重做**：空会话在消息区展示居中的 `AssistantWelcomePanel` 和 starter prompts；输入区保持轻量圆角表面，聊天消息状态不改变。
- **设置页独立化**：聊天页设置按钮跳转现有 `/settings/ai` 独立页面；`AssistantControlsSheet` 保留为未使用的旧实现，当前聊天流程不再打开透明设置浮层。
- **测试覆盖**：`test/assistant/widgets_test.dart` 覆盖消息气泡上下文菜单、会话 drawer 分组/高亮/空态/新建按钮/搜索过滤、状态消息等；流式渲染、drawer 推移、header 四入口和设置跳转由 `test/assistant/page_test.dart` 覆盖。
- **drawer 宽度缓存**（2026-08-03）：`AssistantPage` 的 `drawerWidth` 由每帧 `MediaQuery.sizeOf` 计算改为 `useMemoized` 缓存，仅屏幕宽度变化时重算。
- **会话分组边界**（2026-08-03）：会话列表"今天/本周"边界由 `isAfter` 改为 `!isBefore`（等价 isAfterOrEqualTo），正好 00:00:00 更新的会话归入当天/本周而非"更早"。
- **AI 内容 Markdown 样式统一**（2026-08-03）：助手消息气泡、Today AI 摘要（w600）、建议 reason/boundary 均接入 `MarkdownStyle.ai`（见 [[Design_System#Markdown 渲染]]）；气泡传入自身背景色使代码背景自适配。
- **Drawer 状态投影**（2026-08-04）：新增 `AssistantDrawerState` 轻量数据类（`conversationId / isOpeningConversation / isLoadingRecentConversations / recentConversationError / recentConversations`）。`AssistantPage` 通过 `select(...)` 仅投影 drawer 所需字段，避免流式消息/`streamingDraft` 变化时重建整个 `AssistantConversationDrawer` 与列表。
- **FlowUI 主题桥接**（2026-08-21）：assistant 入口局部注入从当前 Forui 主题和 Luminous 语义色/字体派生的 `FlowTheme`，保留父主题已有扩展；FlowUI 主题不会泄露到其他页面。bridge 作用域测试和真实 `AssistantPage` 构建树接线测试覆盖该约束。

## 2026-07-19 补充

- preview 问候语根据设备当前小时计算 moment（不再硬编码 morning）。
- `SuggestionSkeleton` 重构为匹配真实 `SuggestionPrimaryCard` 结构（header + reason + action 行）。
- 次级建议加载中渲染 `SecondarySuggestionSkeleton`（2 行骨架占位），消除加载后跳变。
- `openRoute` 统一改为 `context.push`，保证用户可返回。
- "未记录"降字重为 w500 + mutedForeground（`isFallback` 标志）。
- 置信度标签从 `TypographyToken.level1` 升级为 `level2`。
- observation 骨架行包 `AppSkeletonShimmer`。
- 次要操作标题改为正常前景色，仅图标保持 muted。
- `TodayTopBar` 改为 `FHeader.nested`，问候语从 Header 拆分到内容区。
- `FHeader.nested` 从 `ListView` 中拆出放到 `Column` 顶部，避免 Forui 0.24.x tight width 约束崩溃。布局模式为 `Column(FHeader.nested + Expanded(RefreshIndicator(ListView(...))))`。
- `DesktopTabShell` 新增 `showHeader` 参数（Today 页面设为 false，由内容区 `TodayTopBar` 提供唯一标题）。
- 桌面端 ListView 移除水平 padding，由 `DesktopTabShell` 内容区统一提供。

## 2026-07-19 P2 低级一致性打磨

### Today 模块

- `view_models.dart` 新增共享 `openRoute` 函数，统一 today 模块路由跳转逻辑（`suggestion_primary_card.dart`、`observation.dart` 引用）。
- `buildQuickActionItems` 的 `usePush` 参数添加导航语义注释，明确 push vs go 使用场景。
- 英文 ARB 问候语和警告串改为 ICU plural 格式（`todayGreetingMorningPending`、`todayGreetingAfternoonWaterShort`、`todayGreetingEveningPending`）。
- `TodayGlyphTile` 渐变背景上的图标改用 `palette.foreground` 保证可读性。
- `SuggestionPrimaryCard` 在 `fading` 状态外包 `IgnorePointer` 禁用交互。
- `observation.dart` 各 `_ObservationTile` 间新增 `Divider`；`onPress` 非空时显示 `ChevronRight`；错误图标用 `colors.destructive`；置信度标签用 `todayObservationMediumConfidenceTag`。
- `_refreshAll` 新增 try-catch + `context.mounted` 检查，失败时显示 `todayRefreshErrorToast`。
- `_NotificationButton` 新增 `Semantics` 标签（`todayNotificationsUnreadLabel`），未登录时用 `showAuthRequiredDialog` 引导。

### Assistant 模块

- `AssistantContextAccess` 新增 `total` getter（值固定为 4），`hero.dart` 状态 chip 从硬编码 `/4` 改为动态 `/${capabilities.assistantContext.total}`。

## 2026-07-22 今日摘要卡片调整

- **按钮对齐**：`Show basis` / `Hide` 展开按钮与右下角 `Generate` 操作按钮放入同一 `Row`，`crossAxisAlignment: CrossAxisAlignment.center`，消除原先不在同一水平线的问题。

## 2026-08-17 Today 用药概览死代码清理

- `TodayMedicationKind` 枚举与 `TodayMedicationSummary.nextMedicine` 字段已删除；UI 只消费 `nextMedicineName`，不再维护虚假的分类枚举。
- `view_models.dart` 中未使用的 `medicationName()` 辅助函数已删除。
- `lib/l10n/src/today_zh.arb` / `today_en.arb` 删除 `todayMedicationName*` 系列键。

## 2026-08-17 Today 心率/血压指标读真实 vital 记录

- `LucentTodayRepository` 新增 `_VitalReadout`：从 `DailyRecordKind.vital` 记录中按 `vitalType` 筛选最新心率/血压条目，读取 `value`、`secondaryValue`、`unit` 与 `observedMetric`。
- 摘要卡 vital 行的心率、血压值与 observed metric 现在来自真实日常记录；无记录时回退 `--`；读取失败时随整体 dashboard 标记 `degraded`。

## 2026-08-17 Today 摘要 fallback 叙述改为中性引导文案

- `lib/l10n/src/today_zh.arb` / `today_en.arb` 中 `todaySummaryFallbackNarrative` 改为中性引导文案（"点生成，用今天的记录整理一句总结。" / "Tap generate to summarize today's records."），不再假装 AI 已生成摘要。

## 2026-08-14 建议卡曝光测量

- 主建议卡进入可见区域时上报 `suggestion_impression`（surface=today，suggestionRuleCode=卡片 ruleId），按 session + 规则码去重；视口外/非活动 tab 不上报，build/rebuild 不重复计数。实现位于 `suggestion_primary_card.dart` 的 `_SuggestionImpressionTracker`。
- 复审微调：曝光检测的滚动挂载改用 `Scrollable.maybeOf` 防御式取值（无行为变化）。


## 2026-08-17 Today 轻动作区第二入口改为一键饮水

- 第二个快捷操作由"快速记录"改为一键饮水，点击后直接创建饮水记录并刷新相关 dashboard，不再跳转表单页。
- `WaterQuickEntryFlow` 与 `QuickEntryUndoService` 从 record presentation 层迁移到 `lib/features/record/application/usecases/`，Today 通过 `executeTodayWaterQuickEntry` 复用，避免跨 feature 直接依赖 record presentation。
