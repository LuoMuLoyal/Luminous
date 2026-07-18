# Active UI — Today

Last updated: 2026-07-18

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
- Dashboard 超时支持 `--dart-define=DASHBOARD_TIMEOUT_SECONDS` 编译时配置。
