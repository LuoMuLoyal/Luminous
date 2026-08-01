# Active UI — Today

Last updated: 2026-07-25 (summary FCollapsible)

## 页面结构

Today 根页为行动面板，首屏顺序为 `主建议卡 → 次建议区 → 今日摘要 → 观察项 → 轻动作`。

桌面端双栏布局：`TopBar → Row[左7: Primary+Summary | 右5: Secondary+Observation] → QuickActions`。

旧的 `TodayOverviewSection / TodayPrioritySection / TodayAiSummarySection / TodayRecommendationSection / TodayTodoSection` 已整体下线。

## 主建议卡

- 承接当前最高优先的用药或饮水动作，卡内补齐 `证据 / 边界 / 主动作`。
- 用药类建议使用 `TodayCardTone.urgent`（destructive 边框 + 淡红底色），饮水类使用 `SemanticColor.primary`。
- 主卡图标使用 `gradient: true`，用药红色渐变、饮水蓝色渐变。
- 首屏只保留图标+标题+原因+进度条+主按钮，证据和边界收入 `FCollapsible` 折叠区。
- 底部 `已采纳 / 稍后处理 / 不适用 / 不再看到` 四个 ghost 按钮，根据后端 `feedbackOptions` 动态渲染，接入 `POST /today/suggestions/:id/feedback`。
- 证据折叠区内「AI 解释」按钮，按需加载 `POST /today/suggestions/:id/explain`（重试上限 3 次）。
- 证据区结构化逐条展示（`_EvidenceList` + `_EvidenceItemRow`），`subtype == 'water'` 显示 `FDeterminateProgress` 饮水进度条。
- `lifecycleState == fading` 时 `Opacity(0.6)` 视觉降级。
- 反馈提交后切换为只读「已反馈」指示器。

## 次建议区

- 使用 `FCard.raw` + `FTappable`，`TodayCardTone.soft` 与主卡形成层级差。
- error 状态显示重试 UI（`_SecondarySuggestionErrorState`）。

## 今日摘要

- 概览指标改成更轻的横排 compact 样式，减少首屏垂直占用。
- 指标不再使用摘要卡内的背景盒子，避免卡片套卡片；层级只由外层容器、图标和文字区分。
- AI 叙述保持轻量，默认只展示短总结和折叠入口。
- 「查看依据」展开/收起使用 Forui `FCollapsible`（`AnimationController` + `CurvedAnimation` + `AnimatedBuilder`），与主建议卡证据折叠区动画模式一致。
- 生成按钮保留在卡片右下角，但卡片本体不再使用大块分割线和高内边距。
- AI 摘要文本使用 `MarkdownBody` 渲染。
- 睡眠 vital 行读取持久化睡眠记录的真实时长；无数据时回退 `--`。
- 睡眠概览值不再追加单位（后端 `valueLabel` 已含单位）。
- 用药概览值使用 `todayMedicationOverviewCount` l10n 键（"{done}/{total} 种"）。分母已修正为今日有提醒计划的药品数（`_todayScheduledMedicineIds`），无提醒时回退为全部当前药品数。

## 观察项

- 从 `FTile` 改为自定义 `_ObservationTile`，使用 muted 图标色、无背景色。
- 数据源从旧 `todayRecommendationsProvider` 切换到 `todaySuggestionProvider.observations`。
- 置信度 tag 从后端 `confidence` 映射：`high → 去看看`、`medium → 值得留意`、`low → 仅供参考`。标签用 `FBadge` 呈现，high→`primary`、medium→`secondary`、low→`outline` 视觉分级。
- fallback 睡眠缺失提示保留，与后端观察项合并展示。
- section subtitle `以下内容仅供参考，不构成待办`。

## 轻动作区

- `FTileGroup` 分组入口：`确认用药 / 快速记录 / 用药安全 / 提醒设置 / 健康档案`。
- 确认用药副标题根据 `pendingCount` 动态生成。
- 快捷操作路由已修复：药品解读 → `/medicine/risk-check`，用药提醒 → `/medicine/reminders/new`（push）。

## 空态与提示

- 顶栏动态问候语根据用药待确认数和饮水剩余数动态生成。

## 骨架屏

- 移动端按真实 section 顺序：TopBar → PrimarySuggestion → SecondarySuggestions → Summary → Observation → QuickActions。
- 桌面端双栏 `Row[左7: Primary+Summary | 右5: Secondary+Observation] + QuickActions`。

## 数据层

- `todaySuggestionProvider`（`AsyncNotifier`）管理建议卡生命周期：拉取、反馈、dismiss、自动刷新。
- **ADR-0009 cache-first**: 建议卡数据接入本地缓存（网络成功持久化 → 网络失败 stale-while-error 兜底 → 缓存反序列化失败时清理 + rethrow）。
- `TodaySuggestionJsonCodec` 手动序列化 `TodaySuggestionBundle`。
- AI 解释不缓存，始终走网络按需加载。
- Dashboard 用药统计通过 `cachedDoseLogDataSourceProvider` 读取（cache-first）。
- 图标映射提取为独立 `SuggestionIconMapping` 类。
- Dashboard 超时默认 8 秒，支持 `--dart-define=DASHBOARD_TIMEOUT_SECONDS` 编译时配置。骨架屏加载 2 秒后底部显示 `todayLoadingSlowHint`（"加载较慢，请稍候…"）muted 提示。

## 助手入口

Last updated: 2026-08-01

- Today 顶部栏暴露一级助手入口（`FLucideIcons.sparkles` 图标按钮）→ `/assistant` 工作区。
- 助手页状态卡已从展开式 `AssistantHero` 替换为默认折叠的 `AssistantStatusBar`：仅显示 bot 徽章 + 标题 + 单行状态摘要 + 状态色圆点，不再展示工具数、上下文数、RAG、流式输出等技术标签。
- 助手设置（启用 AI 对话 / 持久化记忆 / 4 个上下文开关）从顶部齿轮一级入口移除，改从 `AssistantStatusBar` 右侧 subtle 设置图标进入，保留在 `AssistantControlsSheet` / `AssistantControlsPanel` 中。
- 流式滚底优化：仅当用户已处于底部附近时自动滚底；用户上翻后显示"回到底部"悬浮按钮。
- 助手状态文案已重写为自然语言（"AI 助手已准备好" / "AI 助手正在准备中" / "AI 助手暂时不可用" / "AI 助手已关闭"）。
- **页面结构拆分**：`AssistantPage` 仅保留控制器与高层回调，UI 布局下沉到 `AssistantPageBody`；消息列表 + 输入区由 `AssistantConversationStack` 负责；文件行数全部达标（`page.dart` 163 行，子组件均 < 250 行）。
- **输入区重构为 `AssistantInputBar`**：默认单行，最多 5 行；圆形发送图标按钮；空会话时显示 4 个本地化快捷提问 chip（今日总结 / 睡眠 / 用药 / 注意事项）；桌面端 focus 后显示 `Ctrl/⌘ + Enter` 快捷键提示，3 秒后自动淡出。
- **消息气泡去工程化**：`AssistantMessageBubble` 移除工具 chip 渲染与"正在生成"文字标签，流式期间使用 pulsing dots 动画指示器；上下文菜单改用 `FContextMenu.tiles`，支持复制，并预留"重新生成 / 重新发送"入口（当前 disabled，等 controller 支持后启用）。
- **流式 rebuild 优化**：`AssistantPage` 用多个 `ref.watch(...select(...))` 切片订阅状态，`streamingDraft` 变化不再触发父级重建；`AssistantConversationSurface` / `_ConversationView` 改为 `ConsumerWidget`，`messages` 与 `streamingDraft` 分别独立 select 订阅；`AssistantMessageBubble` 流式期间渲染纯 `Text`、结束后才切 `MarkdownBody`，避免每个 chunk 重复解析整段 markdown。
- **侧边栏重构为会话管理器**：`AssistantConversationDrawer` 从抽屉内大卡片改为紧凑会话列表；按"今天 / 最近 7 天 / 更早"分组；当前会话用 `prefix` 对勾图标高亮；顶部新增"新对话"按钮；重命名/删除菜单因后端暂无 `PATCH/DELETE /conversations/:id` 接口暂未接入。
- **测试覆盖**：`test/assistant/widgets_test.dart` 覆盖消息气泡上下文菜单、侧边栏分组/高亮/空态/新建按钮、状态消息等；流式渲染由 `test/assistant/page_test.dart` 覆盖。

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
