# review

一句话:五 tab shell 中的"回顾"tab(`Routes.review`),以健康事件为主单位的纵向洞察主路径:当前事件四段式回顾、事件历史/详情、AI 摘要、就诊摘要(clinic summary)预览/导出/可撤销分享。

## 职责与边界
- 管:event review 读模型与 provider(`domain/entities/review.dart`、`presentation/providers/review.dart`);AI 摘要 SSE 流(`presentation/providers/ai_summary.dart` + `data/datasources/ai_summary_remote.dart`);就诊摘要预览/PDF/分享(`presentation/providers/clinic_summary.dart`、`utils/pdf_download.dart`);旧 7/30 天 dashboard 兼容页(`pages/legacy_dashboard_compat.dart` + `widgets/views/legacy/`)。
- 不管:健康事件创建/check-in/结束动作归 `health_event`(本页复用其 sheet 与 notifier);导出任务状态归 `settings`(`data_export.dart` provider);建议历史数据归 `today`(`suggestionHistoryProvider`);每日记录本体归 `record`。

## 对外契约
- 路由:`Routes.review` = `/review`(第 4 shell branch,tab key 兼容保留 `shell-tab-report`,见 `features/shell/presentation/tab.dart`);`Routes.reviewClinicSummaryShared` = `/review/clinic-summary/:token`(免登录 deep link);`Routes.reviewLegacyDashboard` = `/review/legacy`;`Routes.reviewDetail` = `/review/review/:eventId`(均见 `lib/app/router.dart`)。
- 导出:`reviewCurrentProvider` / `reviewLastCurrentProvider` / `reviewHistoryProvider` / `reviewHistoryStatusProvider` / `reviewDetailProvider`(`presentation/providers/review.dart`)、`reviewRepositoryProvider`(`data/providers/review.dart`)、`EventReview` 等 entity(`domain/entities/review.dart`)。
- 被依赖:lib 内无 feature 级消费者;`test/review/`、`integration_test/review/review_closed_loop_e2e_test.dart`、`integration_test/support/e2e_test_helpers.dart`。

## 不变量
- 事件优先回顾主路径(ADR-0007):`reviewCurrentProvider` 后端优先 active、否则最近 ended;无事件是空信封 `Right(null)` 而非错误;旧 dashboard 不由主路径装配。
- 四段 `ReviewSections` 各自独立 available/unknown,单段缺失不得锁整页(`test/review/widgets/review_sections_test.dart`)。
- 契约外枚举/原因码折叠为 `unknown` 并保留原文;`ReviewEventStatus.unknown` 不得发给后端(`data/repositories/lucent_review.dart` `_apiStatus`)。
- 时间戳保持契约原文(ISO 8601 / YYYY-MM-DD),本地化格式化只在 presentation(`presentation/utils/review_formatters.dart`)。
- 历史列表合同仅 status/cursor/limit,客户端不发明日期过滤(`presentation/providers/review.dart` 注释)。
- 就诊摘要分享可撤销:`ClinicSummaryShareList.revoke`(DELETE `/user/reports/clinic-summary/shares/{shareId}`);token 分享页免登录、只渲染 PDF 下载(`pages/clinic_summary_shared.dart`)。
- AI 摘要尊重 `userSettingsControllerProvider.aiSummariesEnabled`,403 → disabled(`test/review/ai_summary_provider_test.dart`)。

## 依赖禁区
- 事件动作复用 `health_event` 的 `activeHealthEventProvider` + start/check-in/end 三个 sheet(与 today 相同的既有豁免),除此之外不新增他 feature presentation import。
- 数据刷新只监听 `dataChangeVersionProvider`(dailyRecords/doseLogs/healthEvents);health_context 快照 provider 仅用于开始观察时预读当前用药选项,不触其他 feature 的 data 实现层。

## 陷阱与决策
- 2026-08 由 report 改名,任务从 Report 改为"回顾";该 ADR 状态 superseded,但事件主路径是保留的运行时事实:../../../docs/reference/adr/0007-event-led-sparse-record-product-loop.md
- `reviewLastCurrentProvider` 只采纳真正落地的 AsyncData,慢请求迟到不覆盖新数据;失败保留旧值,`ref.invalidate(reviewCurrentProvider)` 即手动重试。
- `reviewHistoryProvider` 关闭自动重试(`retry: _noHistoryRetry`),失败立即进入 error,避免静默重试掩盖故障。
- legacy dashboard 按 `LEGACY` 文件头标注兼容期保留,勿在主路径重新装配,也不要顺手删除。
