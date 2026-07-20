# Active UI — Report

Last updated: 2026-07-18

## 页面结构

- Lucent-backed report dashboard，真实 medication / water / sleep 聚合。
- 用户可选范围：`last_7_days` / `last_30_days` / `custom`（Forui `FCalendar.grid` 日期范围选择器）。
- 移动端报告页为 readiness-first 状态页：
  - 顶部只保留标题 + 时间范围。
  - 首屏单一 `readiness` 主卡合并登录门槛、数据不足、生成总结、同步、数据更新时间。
  - `generatedAt` 从 Lucent report dashboard DTO 映射到前端 domain，显示"当前显示的数据更新于 …"。
- 桌面端与移动端对齐到同一回顾语义：顶部移除旧 snapshot 状态块，主内容首块为 `readiness` 主卡。
- 移动端预览层只保留：报告预览评分、健康趋势预览、重点发现。
- `历史建议回顾` 数据源从通知接口切换到 `GET /today/suggestions/history` API，展示建议生命周期状态（进行中/已过期/已忽略）和按类型映射的图标。
- 移动端完整层仅在 `已登录 + 数据足够` 时显示：AI 总结、导出摘要、健康模式分析、医疗免责声明。
- 未登录态返回真实前端预览 dashboard，不用大型登录提示块拦截整页。
- 移动端下拉刷新 + readiness 主卡内显式同步操作。

## 评分与指标

- `ReportScoreHero` 区分预览态/真实态文案（`isPreview` 参数）：预览显示"报告预览评分"，真实显示"健康评分"。
- `ReportMetricsGrid` 在移动端和桌面端均渲染，桌面端位于右栏。
- 指标卡 2 列网格，含 sparkline 趋势条、状态徽章、方向箭头。

## 趋势与发现

- 趋势区使用 `fl_chart` 多线折线图，日期标签从 `dashboard.startDate` 动态生成。各序列按自身 min/max 独立归一化到 [0, 1]，避免不同量纲（% / ml / h）共用 Y 轴压成平线；Y 轴不显示数值，tooltip 仍显示原始值+单位。
- 桌面端趋势区位于左栏（`showRangePill: false`，范围 pill 由外壳 trailing 提供），移动端位于指标卡下方。
- findings 卡片为信息展示型（非导航型），已移除装饰性 chevron，桌面端使用 `Wrap` 自动换行排列。
- patterns 卡片同样为信息展示型，已移除装饰性 chevron。

## AI 摘要

- 手动 AI 摘要生成，真实增量流 `/api/v1/user/reports/summary/generate/stream`（通过 `LucentSseClient`）。
- AI 摘要文本使用 `MarkdownBody` 渲染。
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
- 前端 Report 导出区分享按钮使用 `Share.share(url)`（`share_plus`）

## 骨架屏

- 桌面端双栏布局对齐真实页面：左7 `Trend+Findings`，右5 `MetricsGrid+Export+AiSummary+Patterns+ReferenceNotice`。
- 移动端按真实 section 顺序排列。

## 数据层

- 报告相关远程数据源（`ReportRemoteDataSource`、`AiSummaryRemoteDataSource`）通过 `generated/lucent_api` 的 Retrofit 客户端访问 Lucent API。
- DTO 直接返回扁平 DTO（`response.data`），Enum 序列化使用 `.json` 属性。
- AI 摘要增量流通过 `LucentSseClient` + Dio 直接消费 SSE。
- `userMessageFromError` 统一错误文案映射，不暴露内部异常文本。

## 2026-07-19 补充

- 趋势图 Y 轴恢复 `showTitles: true`，显示格式化数值。
- 序列配色区分：sleep 从 info 改为 warning（琥珀），general 从 primary 改为 success（绿），四个 kind 互异。
- `lineTouchData` 开启 touch tooltip（显示当前值+单位）。
- 图表外包 `Semantics(label: reportTrendSectionTitle)`。
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
- 桌面端趋势区传 `showRangePill: false`，避免与 `DesktopTabShell` trailing pill 重复。
