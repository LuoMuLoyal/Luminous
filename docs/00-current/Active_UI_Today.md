# Active UI — Today

Last updated: 2026-07-19

## 页面结构

Today 根页为行动面板，首屏顺序为 `主建议卡 → 次建议区 → 今日摘要 → 观察项 → 轻动作`。

桌面端双栏布局：`TopBar → RecordHint → Row[左7: Primary+Summary | 右5: Secondary+Observation] → QuickActions`。

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

- 概览指标和 AI 解释收拢到同一张低权重卡。
- AI 叙述默认折叠（最多 2 行 + 省略号），点击展开 bullets 和 confidenceNote。
- 生成按钮移至卡片右下角。
- AI 摘要文本使用 `MarkdownBody` 渲染。
- 睡眠 vital 行读取持久化睡眠记录的真实时长；无数据时回退 `--`。
- 睡眠概览值不再追加单位（后端 `valueLabel` 已含单位）。
- 用药概览值使用 `todayMedicationOverviewCount` l10n 键（"{done}/{total} 种"），"种"后缀明确分母为药品种类数而非今日应服次数。

## 观察项

- 从 `FTile` 改为自定义 `_ObservationTile`，使用 muted 图标色、无背景色。
- 数据源从旧 `todayRecommendationsProvider` 切换到 `todaySuggestionProvider.observations`。
- 置信度 tag 从后端 `confidence` 映射：`high → 去看看`、`medium/low → 仅供参考`。
- fallback 睡眠缺失提示保留，与后端观察项合并展示。
- section subtitle `以下内容仅供参考，不构成待办`。

## 轻动作区

- `FTileGroup` 分组入口：`确认用药 / 快速记录 / 用药安全 / 提醒设置 / 健康档案`。
- 确认用药副标题根据 `pendingCount` 动态生成。
- 快捷操作路由已修复：药品解读 → `/medicine/risk-check`，用药提醒 → `/medicine/reminders`。

## 空态与提示

- 记录密度提示条：当用户无任何记录时显示 `FAlert` + `FButton(ghost)` CTA 按钮（`todayRecordHintAction` "去记录" → `/record/create`）。
- 顶栏动态问候语根据用药待确认数和饮水剩余数动态生成。

## 骨架屏

- 移动端按真实 section 顺序：TopBar → RecordHint → PrimarySuggestion → SecondarySuggestions → Summary → Observation → QuickActions。
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

- Today 顶部栏暴露一级助手入口（`FLucideIcons.sparkles` 图标按钮）→ `/assistant` 工作区。
- 助手控制面板（启用 AI 对话 / 持久化记忆 / 4 个上下文开关）从对话页底部常驻移入底部抽屉（`_AssistantControlsSheet`），由助手页顶栏 `settings2` 图标按钮打开，释放对话区垂直空间。
- 流式滚底优化：仅当用户已处于底部附近时自动滚底；用户上翻后显示"回到底部"悬浮按钮。
- 助手禁用时的提示文案指向右上角设置入口。
- **流式 rebuild 优化**：`AssistantPage` 用多个 `ref.watch(...select(...))` 切片订阅状态，`streamingDraft` 变化不再触发父级重建；`AssistantConversationSurface` / `_ConversationView` 改为 `ConsumerWidget`，`messages` 与 `streamingDraft` 分别独立 select 订阅；`AssistantMessageBubble` 流式期间渲染纯 `Text`、结束后才切 `MarkdownBody`，避免每个 chunk 重复解析整段 markdown。
- **输入区桌面快捷键 + 禁用态同步**：桌面宽度（`>= Breakpoints.tablet`）下 `FTextField` 外包 `Focus(onKeyEvent:)`，`Ctrl/⌘ + Enter` 触发发送（移动端 `Enter` 仍为换行）；助手禁用时 `FTextField.enabled = false` 真正禁用输入框，输入框上方显示 `assistantInputDisabledHint` 提示行，桌面端输入框下方显示 `assistantSendShortcutHint` 快捷键提示。
- **Hero 折叠**：对话开始后（`hasConversation && !heroExpanded`）`AssistantHero` 自动折叠为单行紧凑状态条（bot 小徽章 + 标题 + 单行省略状态摘要 + 状态色圆点 + 展开钮），用户可点击展开/再折叠，`AnimatedSize`（`DurationTokens.widgetStandard` = 300ms）平滑过渡。状态色圆点映射 disabled → `mutedForeground` / 未配置或未就绪 → `SemanticColor.warning.solid` / 就绪 → `SemanticColor.success.solid`，带 `Tooltip` 显示完整状态文案。

## 2026-07-19 补充

- preview 问候语根据设备当前小时计算 moment（不再硬编码 morning）。
- `SuggestionSkeleton` 重构为匹配真实 `SuggestionPrimaryCard` 结构（header + reason + action 行）。
- 次级建议加载中渲染 `SecondarySuggestionSkeleton`（2 行骨架占位），消除加载后跳变。
- `openRoute` 统一改为 `context.push`，保证用户可返回。
- "未记录"降字重为 w500 + mutedForeground（`isFallback` 标志）。
- 置信度标签从 `TypographyToken.level1` 升级为 `level2`。
- observation 骨架行包 `AppSkeletonShimmer`。
- 次要操作标题改为正常前景色，仅图标保持 muted。
- `AppTopBar` 新增 `disableSafeAreaAndPadding` 参数（`TodayTopBar` 设为 true）。
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
