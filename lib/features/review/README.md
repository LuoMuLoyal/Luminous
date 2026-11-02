# review

一句话：五 tab shell 中的"回顾"tab（`Routes.review`）有双重职责。面向用户，它是"洞察优先"的纵向回顾：周/月周期开关 + 覆盖率概览 + 值得注意（或弃权）+ 单维与多维趋势 + 被动的事件回顾。面向 agent，它是长期记忆的承载面：周期摘要持久化为周报 / 月报，agent 通过报告摘要工具按区间或最近若干份读取，不必逐日重扫原始记录。事件动作已收口 Today；就诊摘要预览、PDF 导出与可撤销分享仍保留在「更多」。

## 职责与边界

- 管：纵向洞察主路径装配（`widgets/views/review_view.dart` + `presentation/pages/page.dart`），数据来自 `reviewDashboardProvider`（metrics/trends/findings + observedMetric 覆盖率语义）；event review 读模型与 provider（`domain/entities/review.dart`、`presentation/providers/review.dart`）；周期切换状态（`reviewDashboardSelectedQueryProvider`）与单维趋势维度（`reviewTrendDimensionProvider`）；冷启动记录引导；event review 详情页 `/review/:eventId`；就诊摘要预览/PDF/分享；周期 AI 摘要的生成与状态。
- 不管：健康事件创建/check-in/结束动作归 `health_event` 与 Today；导出任务状态归 `settings`；建议历史数据归 `today`；每日记录本体归 `record`；报告摘要的持久化与 agent 侧读取在 Lucent。
- **没有 legacy 兼容页**：AI 摘要（`ai_summary.event` / `ai_summary.period`）、建议历史（`history.suggestion`）、周期视图（`readiness.period` / `findings.period` / `patterns.period`）都是组件系统里的可编排组件，**默认不上屏**，用户从编排页自行添加。周期与事件是并列的产品视角，不是新旧替代。
- 桌面端与手机端渲染同一份表面布局（`ComponentHostGridSliver`，`SurfaceId.review`）：桌面 ≥1200 走两列，单列条目按竖向流动分配，卡片等宽、不出现占满整列的组件；骨架镜像新区块顺序。

## 对外契约

- 路由：`Routes.review` = `/review`（第 4 shell branch，tab key 兼容保留 `shell-tab-report`）；`Routes.reviewClinicSummaryShared` = `/review/clinic-summary/:token`（免登录 deep link）；`Routes.reviewDetail` = `/review/review/:eventId`。legacy dashboard 路由已移除。
- 组件：`presentation/components/catalog.dart` 定义 review surface 的组件目录与默认布局（`period.switch`、`coverage.strip`、`overview.noteworthy`、`overview.record_guide`、`event.*`、`trend.single`、`trend.multi`、`history.review` 等）；`period.dart` 注册周期视角组件（`readiness.period`、`findings.period`、`ai_summary.period`、`patterns.period`、`history.suggestion`）。
- 导出：`reviewCurrentProvider` / `reviewLastCurrentProvider` / `reviewHistoryProvider` / `reviewHistoryStatusProvider` / `reviewDetailProvider`、`reviewRepositoryProvider` / `reviewDashboardRepositoryProvider`、`reviewDashboardProvider` / `reviewDashboardSelectedQueryProvider` / `reviewLastDashboardProvider` / `reviewTrendDimensionProvider`、`EventReview` / `ReviewDashboard` 等 entity。
- AI 摘要：`presentation/providers/ai_summary.dart` 调 Lucent `POST /user/reports/summary/generate`（流式 / 异步），周期摘要按 `last7Days` / `last30Days` 生成，支持状态机与重试。
- 被依赖：`lib/app/router.dart`；`test/review/`、`integration_test/review/`。

## 不变量

- 洞察优先主路径（替代旧事件优先，ADR-0007 已 superseded）：载荷自上而下为 周期开关 → 覆盖率概览 → 值得注意（或弃权）→ 单维/多维趋势（有数据时）→ 事件回顾；无事件且数据过稀进冷启动记录引导，不生成趋势结论，不渲染任何事件动作。
- 事件动作收口 Today：review 不装配 start/check-in/end sheet 与 `activeHealthEventProvider`；有 active 事件仅渲染紧凑被动卡（`EventHeaderSection`）附「去今日 check-in」浅链接；ended 事件的四段完整回顾在详情页。
- 默认布局等于组件化前的渲染顺序；新增可选组件只进 `owned` / 编排候选，不进 `defaultLayout`（`metric.grid`、`ai_summary.event`、全部 `period.*` 都属于默认不上屏）。
- 覆盖率口径：热点指标卡必须带 observedMetric（`observedCount/expectedCount` 封面）；覆盖 `none` 或 <2 观察为灰态「数据太少」；未记录 ≠ 0，趋势卡带覆盖率说明脚注。
- 周期切换只接 `reviewDashboardSelectedQueryProvider.setRange(last7Days/last30Days)`；切换期间复用 `reviewLastDashboardProvider` 缓存旧数据 + 轻量加载态，不整页骨架。
- 冷启动判定：无 active/ended 事件 且 dashboard metrics 为空或全部 insufficient（或 trends 全空）→ 记录引导区；否则降级轻量解释卡 + 记录后预览预告卡。
- 四段 `ReviewSections` 各自独立 available/unknown，单段缺失不得锁整页。
- 契约外枚举/原因码折叠为 `unknown` 并保留原文；`ReviewEventStatus.unknown` 不得发给后端；时间戳保持契约原文，本地化格式化只在 presentation。
- 就诊摘要分享可撤销：`ClinicSummaryShareList.revoke`（DELETE `/user/reports/clinic-summary/shares/{shareId}`）；token 分享页免登录、只渲染 PDF 下载。

## 面向 agent 的长期记忆

- 周期视角的 AI 摘要（`ai_summary.period`，7 / 30 天）生成周报 / 月报式摘要；Lucent `ReportsAiSummaryService` 将其持久化为 `kind='report'` 的摘要记录，带 `sourceVersion` 版本栅栏，旧版本不会覆盖新版本。
- Assistant 侧通过工具读取：`get_report_summary_by_range`（区间摘要 / 周报 / 月报）、`get_recent_report_summaries`（最近若干份报告摘要），以及 `get_today_summary_by_date`、`get_recent_today_summaries`（今日摘要）。意图路由据此区分「某日的今日摘要」与「区间摘要 / 周报 / 月报」。
- 线程状态由 Lucent 的 LangGraph `PostgresSaver` checkpointer 持久化；长期事实来自已持久化的报告 / 今日摘要与健康数据本身，聊天原文不被当作健康事实。
- 客户端只负责触发周期摘要的生成与状态展示；记忆的写入与读取发生在 Lucent 侧的 agent 运行时。

## 陷阱与决策

- 组件 id 用 `*.period` 而不是 `*.legacy`：周期与事件是并列形态，组件面板里显示「周期发现」，不暗示「将被删除」。
- 2026-08 由 report 改名，任务从 Report 改为"回顾"；事件主路径不再是运行时事实（现为洞察优先）。
- `reviewLastCurrentProvider` 只采纳真正落地的 AsyncData，慢请求迟到不覆盖新数据；失败保留旧值，`ref.invalidate(reviewCurrentProvider)` 即手动重试。
- `reviewHistoryProvider` 关闭自动重试（`retry: _noHistoryRetry`），失败立即进入 error，避免静默重试掩盖故障。
- 覆盖概览行点击跳到对应单维趋势卡维度并滚动（`onTrendKindChanged`，页面接 `reviewTrendDimensionProvider`）；空 metrics 且无事件时整页落冷启动分支，概览行不渲染空壳。
