---
status: active
owner: frontend
quadrant: reference
updated: 2026-08-07
---

# Active UI — Report

Last updated: 2026-08-07 (产品方向迁移说明；运行时 UI 未变)

> 本文件继续记录当前已经实现的 `Report` 运行时事实。产品方向已决定将用户可见任务改为“回顾”，以健康事件为主单位，移除综合健康评分并把导出/医生分享移入“更多”；这些变化尚未实现，待办见 [[00-current/TODO#`Report` 转为 `Review/回顾`]]。

## 页面结构

- Lucent-backed report dashboard，真实 medication / water / sleep 聚合。
- 用户可选范围：`last_7_days` / `last_30_days` / `custom`（Forui `FCalendar.grid` 日期范围选择器）。
- 时间范围选择器使用 Forui `FPopoverMenu`（`ReportRangeMenu`），从右上角 pill 按钮下方弹出，替代旧版底部弹出 bottom sheet。
- 移动端报告页为 readiness-first 状态页：
  - 顶部只保留标题 + 时间范围。
  - 首屏单一 `readiness` 主卡合并登录门槛、数据不足、生成总结、同步、数据更新时间。
  - `generatedAt` 从 Lucent report dashboard DTO 映射到前端 domain，显示"当前显示的数据更新于 …"。
  - 生成总结与同步操作仅在 readiness 主卡内提供，不再在内容区重复 `ReportActionBar`。
  - 时间范围由 Header `ReportRangeMenu` 表达，内容区不再重复日期范围文本。
- 桌面端与移动端对齐到同一现有 Report 布局：顶部移除旧 snapshot 状态块，主内容首块为 `readiness` 主卡。
- 未登录 preview 态：顶部显示与其他 tab 一致的轻量 `SignInHintBanner`；下方用显式空态卡片展示 Report 页职责范围（健康趋势、重点发现、历史建议回顾、导出预览），不再显示巨大的 readiness 锁定卡或灰色空白占位块。
- `历史建议回顾` 数据源从通知接口切换到 `GET /today/suggestions/history` API，展示建议生命周期状态（进行中/已过期/已忽略）和按类型映射的图标。
- 移动端完整层仅在 `已登录 + 数据足够` 时显示：AI 总结、健康模式分析、导出摘要、医疗免责声明。
  - section 顺序：readiness → metrics → trend → findings → suggestionHistory → aiSummary → patterns → export → reference。
  - 导出区移至页面末尾（规律分析之后），引导用户先阅读分析再导出。
  - 各 section 间距统一 `Spacing.level5`。

- 移动端下拉刷新 + readiness 主卡内显式同步操作。

## 评分与指标

- `ReportScoreHero` 已移除：健康评分计算不透明，0 分 preview 无信息价值，且产品文档未将评分列为 Report 页核心组件。
- 登录后 `dashboard.score.summary` 作为一句话摘要展示在 `ReportReadinessSection` 描述下方，保留评分结论但不独占首屏。
- `ReportMetricsGrid` 在移动端和桌面端均渲染，桌面端位于右栏。
- 指标卡 2 列网格，含 sparkline 趋势条、状态徽章、方向箭头。

## 趋势与发现

- 趋势区使用 `fl_chart` 单线折线图 + Forui `FTabs` 指标切换。每个 tab 对应一个指标（用药/饮水/睡眠），选中 tab 时只渲染该指标的单条折线，Y 轴显示真实值（不再归一化），图表上方显示当前值摘要。日期标签从 `dashboard.startDate` 动态生成。
- 桌面端趋势区位于左栏（`showRangePill: false`，范围 pill 由外壳 suffixes 提供），移动端位于指标卡下方。
- findings 卡片为信息展示型（非导航型），已移除装饰性 chevron，桌面端使用 `Wrap` 自动换行排列。
- patterns 卡片同样为信息展示型，已移除装饰性 chevron。

## AI 摘要

- 手动 AI 摘要生成，真实增量流 `/api/v1/user/reports/summary/generate/stream`（通过 `LucentSseClient`）。
- AI 摘要文本使用 `MarkdownBody` 渲染，样式走 `MarkdownStyle.ai(context, paragraphWeight: FontWeight.w700)`（见 [[Design_System#Markdown 渲染]]，2026-08-03 起统一）。
- 本地 signed-out / disabled / loading / success / error AI 摘要状态。
- 卡片内 `近 7 天 / 近 30 天` AI 摘要切换，带按范围缓存状态。
- AI 占位文案使用 l10n 兜底，无硬编码中文。

## 导出动作

四个导出动作已接入：

- `给校医院` — hospital PDF
- `月度报告` — monthly PDF
- `打印预览` — print PDF
- `分享给医生` — clinic share link（Redis 24h TTL + 原生 OS 分享面板）
- 导出卡片显示进行中的进度与有界状态文案；inFlight 时卡片灰化。
- 移动端在未登录或数据不足时不渲染导出卡，只显示轻量锁定说明。
- Mine/Settings 使用同一真实数据导出请求流；隐私设置由 Mine/Settings 持有。

## Clinic Summary（后端隐私保护医疗摘要）

用于医生分享的后端侧脱敏摘要：

- `POST /reports/clinic-summary/preview` — 脱敏摘要（姓名 mask 张**、年龄非 birthDate、仅诊断年份）
- `POST /reports/clinic-summary/share` — Redis 分享链接，24h TTL
- `GET /reports/clinic-summary/shared/:token` — 公开访问（无需认证），过期返回 410
- `GET /reports/clinic-summary/preview/pdf` — PDF 下载（需认证），A4 格式，含 profile/allergies/conditions/medicines/disclaimer，CJK 字体渲染
- `GET /reports/clinic-summary/shared/:token/pdf` — 公开 PDF 下载
- `@Public()` 装饰器 + `JwtAuthGuard`（支持 `Reflector` 的混合认证/公开路由）
- 前端 Report 导出区分享按钮点击后先弹出预览弹窗（`ClinicSummaryPreviewDialog`），弹窗内展示脱敏摘要内容 + [下载 PDF] + [分享给医生] 两个操作按钮。
- 预览弹窗桌面端使用 `showFDialog` + `AppDialogShell`，移动端使用 `showModalBottomSheet`。
- PDF 下载通过 Raw Dio（`ResponseType.bytes`）调用 `GET /reports/clinic-summary/preview/pdf`，保存为临时文件后通过 `share_plus` 分享。
- 分享按钮调用 `reportsControllerShareClinicSummaryV1()` 生成 Redis 分享链接，通过 `SharePlus.instance.share` 分享 URL。
- 公开分享页 `/report/clinic-summary/:token` 调用 `GET /reports/clinic-summary/shared/:token` 展示脱敏摘要，底部含 [下载 PDF] 按钮（调用 `shared/:token/pdf`，`skipAuthorization: true`）。
- `ClinicSummaryContent` 共享组件复用于预览弹窗和公开分享页，展示生成时间、数据范围、脱敏个人信息、过敏记录、疾病记录、当前用药、关键发现、免责声明。

## 骨架屏

- 桌面端双栏布局对齐真实页面：左7 `Trend+Findings`，右5 `MetricsGrid+AiSummary+Patterns+ReferenceNotice`；导出区移至双栏之后全宽展示。
- 移动端按真实 section 顺序排列（导出在末尾）。

## 数据层

- 报告相关远程数据源（`ReportRemoteDataSource`、`AiSummaryRemoteDataSource`）通过 `generated/lucent_api` 的 Retrofit 客户端访问 Lucent API。
- DTO 直接返回扁平 DTO（`response.data`），Enum 序列化使用 `.json` 属性。
- AI 摘要增量流通过 `LucentSseClient` + Dio 直接消费 SSE。
- `userMessageFromError` 统一错误文案映射，不暴露内部异常文本。

## 2026-07-19 补充

- 趋势图 Y 轴恢复 `showTitles: true`，显示格式化数值。
- 序列配色区分：sleep 从 info 改为 warning（琥珀），general 从 primary 改为 success（绿），四个 kind 互异。
- `lineTouchData` 开启 touch tooltip，显示触点实际值+单位+日期（`DateFormat.MMMEd(locale)` 格式化）。
- 图表外包 `Semantics` label 包含标题 + 各指标当前值摘要。
- `_LegendDot` 新增 `currentValue` 和 `unit` 参数，图例项带当前值+单位。
- X 轴标签改用 `DateFormat.Md(locale)` 格式化。
- readiness 三态徽章按 status 映射：insufficient 用 `warning`，ready 用 `success`。
- ready 标题按范围参数化（`reportReadinessReadyTitleRange`，`{range}报告已就绪`）。

## 2026-07-19 P2 低级一致性打磨

- `score_hero.dart` 的 `circleHelp` 帮助图标外包 `FTooltip`，显示 `reportScoreHelpTooltip`（评分构成说明）。
- `trend.dart` 图例色点从 8px 增大为 `Spacing.level3`（10px），提升可识别性。X 轴日期已走 `DateFormat.Md(locale)`，无需改动。
- `suggestion_history.dart` 手写 `DecoratedBox` 徽章改为 `FBadge.raw` + `.delta()` + `shapeDelta` 模式，与项目其他徽章实现一致。
- `report/page.dart` 移除 `isInsufficient: (_) => false` 恒 false 死代码。
- `report/page.dart` 加载副标题从 `placeholderNoData` 改为 `placeholderLoading`（"加载中…"）。

## 2026-07-19 剩余中级项

- 趋势图改为按序列独立归一化到 [0, 1]（Y 轴 [-0.1, 1.1]，去掉数值标签，tooltip 保留原始值+单位），解决不同量纲共用 Y 轴压成平线问题。
- 桌面 loading 外壳移除 `scrollable: false`（使用默认 `true`），矮窗不再溢出。
- 移动端错误态去掉 `AppBackButton`（tab 根页面不应有返回键），改为 `DecoratedBox` + `SafeArea` + `AppStateErrorView`。
- 同步按钮 `isSyncing` 接入 `dashboardAsync.isLoading`（`isRefreshing`），同步进行中显示进度态。
- 桌面 findings 从横向滚动 `Row` 改为 `Wrap` 自动换行。
- `range_picker_dialog` 日历弹窗新增"取消"按钮（ghost 样式 + `Navigator.pop(null)`）。
- 桌面端趋势区传 `showRangePill: false`，避免与 `DesktopTabShell` suffixes pill 重复。

## 2026-07-20 P1 修复

- **切时间范围保留旧值**：新增 `reportLastDashboardProvider` 缓存最近一次成功加载的 dashboard。切换时间范围时，新查询加载期间展示旧数据而非整页骨架，`isRefreshing` 指示器仍正常显示。
- **AI 总结"自定义"范围日期兜底**：`generate()` 在 `range == custom` 但 dashboard 非 custom 时，从缓存的 dashboard 取 `startDate`/`endDate`，不再传 null 日期。
- **桌面 loading 假按钮禁用**：`_buildLoadingShell` 中 `ReportActionBar` 传 `isGenerating: true, isSyncing: true`，加载态按钮不可点击。
- **图表 tooltip 触点值+日期**：tooltip 从恒显示 `currentValue` 改为根据 `spot.spotIndex` 取实际触点值，并新增日期行。
- **图表 Semantics 数值摘要**：`Semantics.label` 从仅标题扩展为包含各指标当前值摘要。

## 2026-07-20 P2 报告模块打磨

- **装饰图标 ExcludeSemantics**：`readiness.dart` 的状态头像图标和时钟图标包裹 `ExcludeSemantics`，避免屏幕阅读器重复朗读相邻文字。
- **就绪卡"生成总结"loading**：`readiness.dart` 的 `_PrimaryAction` ready 状态新增 `isGenerating` 参数，生成中禁用按钮 + 显示 `FCircularProgress`。`dashboard_view.dart` 传入 `isGenerating: aiSummaryState.status == ReportAiSummaryCardStatus.loading`。
- **emptyInsufficientBuilder 死代码删除**：`page.dart` 移除不可达的 `emptyInsufficientBuilder` 分支。
- **分数字号 token 外覆盖修复**：`score_hero.dart` 从 `TypographyToken.level9.display(context).copyWith(fontSize: ...)` 改为 `TextStyle(fontSize: ...)`，消除先套 token 再覆盖的矛盾写法。
- **导出卡禁用态 chevron 修复**：`export.dart` 的 `_ExportCard` trailing 图标在 `requestInFlight.inFlight` 时显示 `lock` 而非 `chevronRight`，正确表达“其他导出进行中”的禁用语义。

## 2026-07-20 联调修正

- **建议历史详情面板**：新增 `suggestion_history_detail_sheet.dart`，点击历史建议列表项弹出详情（桌面端 `showFDialog` + `AppDialogShell`，移动端 `showModalBottomSheet`）。展示类型图标+标题、生命周期 Badge、原因正文、规则 ID/版本/触发方式/置信度/生成时间 meta 字段、用户反馈（如有）、过期时间（如有）。`page.dart` 的 `onSuggestionTap` 从 `null` 改为调用 `showSuggestionHistoryDetailSheet`。
- **诊所摘要预览弹窗**：新增 `clinic_summary_preview_dialog.dart`，点击"分享给医生"导出按钮时先弹出预览弹窗，展示 `POST /reports/clinic-summary/preview` 返回的 `ClinicSummaryDto` 脱敏内容。弹窗内含 [下载 PDF] 和 [分享给医生] 两个操作按钮。
- **诊所摘要 PDF 下载**：`LucentApiPaths` 新增 `clinicSummaryPreviewPdf` 和 `clinicSummarySharedPdf(token)` 路径常量。通过 Raw Dio 以 `ResponseType.bytes` 下载 PDF 二进制，保存到临时目录后通过 `share_plus` 分享。
- **诊所摘要分享链路改造**：`page.dart` 的 `clinicShare` 导出入口从直接调用 `_handleClinicShare` 改为先弹出 `showClinicSummaryPreviewDialog`，用户在预览弹窗内点击 [分享给医生] 按钮触发分享。移除了 `page.dart` 中的 `_handleClinicShare` 方法（逻辑已迁移到弹窗内）。
- **诊所摘要公开分享页**：新增 `clinic_summary_shared.dart` 页面和 `/report/clinic-summary/:token` 路由（公开路由，无需认证）。页面调用 `GET /reports/clinic-summary/shared/:token` 展示分享的摘要内容，底部含 [下载 PDF] 按钮（调用 `shared/:token/pdf`，`extra: {skipAuthorization: true}`）。
- **诊所摘要 Provider**：新增 `clinic_summary.dart` provider 文件，包含 `clinicSummaryPreviewProvider`（autoDispose FutureProvider）和 `clinicSummarySharedProvider`（autoDispose family FutureProvider）。
- **诊所摘要共享内容组件**：新增 `clinic_summary_content.dart`，`ClinicSummaryContent` widget 复用于预览弹窗和公开分享页，展示生成时间、数据范围、脱敏个人信息、过敏/疾病/用药列表、关键发现、免责声明，底部可选 [下载 PDF] / [分享] 按钮。

## 2026-07-21 审查修复

- **公开分享页错误区分**：`clinic_summary_shared.dart` 的错误回调从统一显示"链接已过期"改为通过 `LucentErrorMapper.toAppError` 区分网络错误（`AppErrorKind.network`）和链接失效。网络错误显示"网络连接失败"+ `wifiOff` 图标 + 重试按钮；其他错误仍显示"链接已过期" + `triangleAlert` 图标。
- **PDF 下载逻辑提取**：新增 `pdf_download.dart` 工具文件，`downloadAndSharePdf()` 函数封装 Dio 二进制下载 → 写临时文件 → SharePlus 分享的完整流程。预览弹窗和公开分享页均改为调用此函数，消除重复代码。
- **MetaRow / formatDateTimeFull 提取**：`_MetaRow` widget 提取为 `components.dart` 中的公共 `MetaRow`；`_formatDateTime` 方法提取为 `date_format_utils.dart` 中的 `formatDateTimeFull()`。`clinic_summary_content.dart` 和 `suggestion_history_detail_sheet.dart` 均改用公共组件。
- **分享失败错误消息格式**：硬拼接 `'${l10n.reportExportFailedToast}: ${error.message}'` 改为 l10n 参数化字符串 `reportExportFailedWithReason(reason)`，中英文冒号格式由 ARB 模板控制。

## 2026-07-26 Report UX 瘦身

- **移除 `ReportActionBar`**：内容区不再重复生成总结/同步按钮，操作统一由 readiness 主卡提供，消除重复 CTA。
- **移除日期范围文本标签**：时间范围已由 Header `ReportRangeMenu` 表达，内容区不再重复展示。
- **section 重排**：导出区从 AI 总结后移至页面末尾（规律分析之后），引导先阅读再导出。桌面端导出从双栏上方移至双栏之后全宽展示。
- **间距统一**：移动端各 section 间距从 `Spacing.level4` 统一为 `Spacing.level5`，视觉节奏一致。
- **Findings 分隔线移除**：`findings.dart` 去掉标题与内容间的 `AppDivider`，与其他 section 头部风格统一。
