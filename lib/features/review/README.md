# review

一句话:五 tab shell 中的"回顾"tab(`Routes.review`),以纵向洞察为主单位的洞察优先主路径:顶栏下首行提供周|月周期开关(`ReviewPeriodSwitch`,reuse forui `FTabs`)+ 覆盖率概览行 + 值得注意区 + 单维趋势卡 + 事件回顾(紧凑被动卡 + 历史列表)。事件动作已收口 Today,review 侧只保留被动的事件回顾。就诊摘要(clinic summary)预览/导出/可撤销分享、legacy 兼容页在「更多」入口保留。

## 职责与边界
- 管:纵向洞察主路径装配(`widgets/views/review_view.dart` + `presentation/pages/page.dart`),数据来自 `reviewDashboardProvider`(`presentation/providers/dashboard.dart`,metrics/trends/findings + observedMetric 覆盖率语义);event review 读模型与 provider(`domain/entities/review.dart`、`presentation/providers/review.dart`);周期切换状态(`reviewDashboardSelectedQueryProvider`)与单维趋势维度(`reviewTrendDimensionProvider`);冷启动记录引导(`widgets/sections/record_guide.dart`);event review 详情页 `/review/:eventId`(`pages/detail.dart`);就诊摘要预览/PDF/分享(`presentation/providers/clinic_summary.dart`、`utils/pdf_download.dart`)。
- 不管:健康事件创建/check-in/结束动作归 `health_event` 与 Today(本页不再复用其 sheet 或 notifier);导出任务状态归 `settings`(`data_export.dart` provider);建议历史数据归 `today`(legacy `suggestionHistoryProvider`);每日记录本体归 `record`;AI 摘要(`ai_summary.dart` provider / `suggestion_history.dart` / `ai_summary.dart` section)主路径下线,仅 legacy 兼容页(AD)消费。
- 桌面/Web 沿用移动端单列约束(ADR-0008 冻结),不新增桌面专属布局;骨架镜像新区块顺序。

## 对外契约
- 路由:`Routes.review` = `/review`(第 4 shell branch,tab key 兼容保留 `shell-tab-report`,见 `features/shell/presentation/tab.dart`);`Routes.reviewClinicSummaryShared` = `/review/clinic-summary/:token`(免登录 deep link);`Routes.reviewLegacyDashboard` = `/review/legacy`;`Routes.reviewDetail` = `/review/review/:eventId`(均见 `lib/app/router.dart`)。
- 导出:`reviewCurrentProvider` / `reviewLastCurrentProvider` / `reviewHistoryProvider` / `reviewHistoryStatusProvider` / `reviewDetailProvider`(`presentation/providers/review.dart`)、`reviewRepositoryProvider` / `reviewDashboardRepositoryProvider`(`data/providers/`)、`reviewDashboardProvider` / `reviewDashboardSelectedQueryProvider` / `reviewLastDashboardProvider` / `reviewTrendDimensionProvider`(`presentation/providers/dashboard.dart`)、`EventReview` / `ReviewDashboard` 等 entity(`domain/entities/`)。不再导出 suggestion/ai-summary 的主路径装配。
- 被依赖:lib 内无 feature 级消费者;`test/review/`、`integration_test/review/review_closed_loop_e2e_test.dart`、`integration_test/review/report_e2e_test.dart`、`integration_test/support/e2e_test_helpers.dart`。

## 不变量
- 洞察优先主路径(替代旧事件优先,ADR-0007 已 superseded):载荷自上而下为 周期开关 → 覆盖率概览 → 值得注意(或弃权)→ 单维趋势(有数据时)→ 事件回顾;无事件且数据过稀进冷启动记录引导,不生成趋势结论,不渲染任何事件动作。
- 事件动作收口 Today:`review_view.dart` / `page.dart` 不装配 start/check-in/end sheet 与 `activeHealthEventProvider`;有 active 事件仅渲染紧凑被动卡(`EventHeaderSection`)附「去今日 check-in」浅链接(不深链传参),ended 事件的四段完整回顾仍在 `/review/:eventId` 详情页。
- 主路径不生成泛化 AI 长文与建议历史:`ai_summary` / `suggestion_history` 组件文件头 deferred 标注,`docs/TODO.md` 登记录入 agentic 计划复核(不是当前能力);legacy 兼容页(AD)仍消费,勿误删。
- 覆盖率口径:热点指标卡必须带 observedMetric(`observedCount/expectedCount` 封面);覆盖 `none` 或 <2 观察为灰态「数据太少」;未记录≠0 语义本期不假装精确,趋势卡带覆盖率说明脚注。
- 周期切换只接 `reviewDashboardSelectedQueryProvider.setRange(last7Days/last30Days)`;切换期间复用 `reviewLastDashboardProvider` 缓存旧数据 + 轻量加载态,不整页骨架;当前默认 `periodRange` 为 last7Days。
- 冷启动判定:无 active/ended 事件 且 dashboard metrics 为空或全部 insufficient(或 trends 全空)→ `ReviewRecordGuideSection`;否则降级轻量解释卡 + 记录后预览预告卡。
- 四段 `ReviewSections` 各自独立 available/unknown,单段缺失不得锁整页(`test/review/widgets/review_sections_test.dart`)。任一事件动作 key(`health-event-*`)不得在主路径断言出现。
- 契约外枚举/原因码折叠为 `unknown` 并保留原文;`ReviewEventStatus.unknown` 不得发给后端(`data/repositories/lucent_review.dart` `_apiStatus`)。时间戳保持契约原文,本地化格式化只在 presentation。
- 就诊摘要分享可撤销:`ClinicSummaryShareList.revoke`(DELETE `/user/reports/clinic-summary/shares/{shareId}`);token 分享页免登录、只渲染 PDF 下载(`pages/clinic_summary_shared.dart`)。AI 摘要(legacy)尊重 `aiSummariesEnabled` 设置。

## 依赖禁区
- 事件动作收口后,`health_event` presentation 依赖豁免解除:review 侧不再 import `activeHealthEventProvider` / start-checkin-end sheet。对 `health_event` 的消费限定在 `domain/entities` / repository 接口(事件读写走 `reviewRepositoryProvider` 与 `dataChangeVersionProvider`)。
- 数据刷新只依赖 `dataChangeVersionProvider`(dailyRecords/doseLogs/healthEvents,驱动 `reviewDashboardProvider` / `reviewCurrentProvider`)与 `authSessionProvider`(登录态/预览分支);`reviewDashboardProvider` 监听 `DataChangeTopic.dailyRecords`。本页不直接消费他 feature 的 data/domain 实现层。

## 陷阱与决策
- 2026-08 由 report 改名,任务从 Report 改为"回顾";ADR-0007 已 superseded,事件主路径不再是运行时事实(重组后现为洞察优先)。
- `reviewLastCurrentProvider` 只采纳真正落地的 AsyncData,慢请求迟到不覆盖新数据;失败保留旧值,`ref.invalidate(reviewCurrentProvider)` 即手动重试。
- `reviewHistoryProvider` 关闭自动重试(`retry: _noHistoryRetry`),失败立即进入 error,避免静默重试掩盖故障。
- legacy dashboard 按 `LEGACY` 文件头标注兼容期保留,勿在主路径重新装配,也不要顺手删除。
- 覆盖概览行点击跳到对应单维趋势卡维度并滚动(`onTrendKindChanged`,页面接 `reviewTrendDimensionProvider`);空 metrics 且无事件时整页落冷启动分支,概览行不渲染空壳。
