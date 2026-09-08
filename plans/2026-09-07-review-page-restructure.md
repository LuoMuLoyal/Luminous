# Review 页重组:洞察优先 + 覆盖感知(事件动作收口 Today、建议历史下线、周期周/月)

Created: 2026-09-07

> 定位:把五 Tab 中的 review 页从「事件优先的纵向堆叠」重组为「洞察优先、事件按需、
> AI 退居叠加层」的回顾页,回答「过去一周/一月,我的记录里有什么值得我知道的变化」。
> 依据:`../research/01-用户价值调研/record-review-assistant-纵向洞察归属与Tab验证.md`
> 的对抗性桌面研究结论(阶段 1 推荐)与三个已决决策(见「已决决策」)。
>
> 范围:仅 Luminous 客户端 review 页重组 + 配套测试/文档;不增删 Tab、不改 shell;
> 后端聚合增强(Lucent observed-metric 域迁移)是**后置依赖**,见「数据分层与契约」。
> 桌面/Web 冻结(ADR-0008)不变:桌面沿用移动端单列约束,不新增桌面专属布局。

## 已决决策(2026-09-07)

1. **事件动作收口 Today**:review 页移除「开始健康观察 / 今日 check-in / 结束事件」
   行动入口(含无事件时的开始卡片),只保留**被动的事件回顾**(紧凑事件卡 + 事件历史
   列表 + 详情页);有进行中事件时给一条「去今日 check-in」浅入口。事件动作 sheet 与
   notifier 继续由 `health_event` 提供、由 Today 装配(现状已如此)。
2. **周期粒度 = 周 | 月**(映射现有 `last_7_days` / `last_30_days`);「日」尺度由
   Today 每日轻量总结承接,不在 review 主路径重复;主路径不做自定义区间与年度。
3. **建议历史下线**:review 主路径不再展示 `ReviewSuggestionHistorySection`、不再
   消费 `suggestionHistoryProvider`(数据源仍归 today feature,供 assistant 上下文与
   legacy 兼容页使用);相关去重/详情 sheet 仅保留给 legacy 路径。

## 现状锚点(代码事实,2026-09-07)

- review 页主路径(`lib/features/review/presentation/pages/page.dart` +
  `widgets/views/review_view.dart`)当前自上而下装配:
  preview banner → (无事件:`_StartObservationCard` + 五张锁卡预告) 或
  (有事件:`EventHeaderSection` 含 check-in/end 动作 + 四段
  whatHappened/keyChanges/completedActions/nextStep)→ `ReviewAiSummarySection`
  (7/30/自定义 + 流式生成)→ `ReviewSuggestionHistorySection`(前 3 条 + 查看全部)
  → `ReviewHistorySection`(事件历史 + status 筛选 + 分页)→ `ReviewTrendSection`
  (饮水/睡眠/用药单折线,数据来自 reviewDashboardProvider)。
- 数据基础已具备大半:
  - `reviewCurrentProvider` / `reviewHistoryProvider`(事件现状与历史,分页+筛选);
  - `reviewDashboardProvider(query)` 真实调 Lucent dashboard(7/30/custom),已带
    coverage 语义:`ReviewObservedMetric`(state/coverage/sources/observedCount/
    expectedCount/windowStart/windowEnd)、metrics(值/Δ/方向/sparkline)、trends
    (逐日 values/currentValue/observedMetric)、findings/patterns、exportActions;
    含缓存(dao cacheKey by range)+ 后台刷新节流 + `dataChangeVersionProvider`
    (dailyRecords)自动刷新 + 5s 超时 + signed-out fallback
    (`presentation/providers/dashboard.dart`、`data/repositories/lucent_dashboard.dart`)。
  - 注意 legacy scalar 投影被标注 deprecated,observed-metric 域迁移目标 2026 Q4
    (`lucent_dashboard.dart` 文件头 TODO)——本计划的 Wave 2 与该迁移挂钩。
- 已知缺口(本计划要处理):dashboard 维度仅 medication/water/sleep/general,不含
  mood/symptom/meal/activity;findings/patterns 无证据引用(record id/日期)与反馈
  通道;趋势逐日 values 是 legacy scalar 投影(缺记录的天如何取值需随域迁移锁定),
  客户端目前无法区分「空档=无记录」与「0」。
- review 页现从 `health_event` 复用 start/check-in/end 三个 sheet 与
  `activeHealthEventProvider`(review README「依赖禁区」列为唯一豁免);Today 已有同套
  事件区块与动作(`today/.../health_event_section.dart`、`today/presentation/pages/page.dart`)。
- review 主路径同时消费 today 的 `suggestionHistoryProvider`(去重函数
  `dedupeTodaySuggestions`)与 `showSuggestionHistoryDetailSheet`;legacy 兼容页
  (`pages/legacy_dashboard_compat.dart`)仍消费二者,故数据/组件不删除。
- AI 摘要 section(`widgets/sections/ai_summary.dart`)仅被主路径 review_view 装配,
  legacy 路径用 `sections/legacy/ai_summary.dart`;移除主路径装配后前者可能孤儿化,
  处置见任务 P0-7(标记,不删除,与 agentic P0-3 统一 AI 数据层对齐)。
- 测试/e2e 引用 review 事件动作与 section 的 key:`test/review/*`(page/golden/
  review_view/event_header/more_actions/sections…)、`integration_test/review/
  review_closed_loop_e2e_test.dart`、`report_e2e_test.dart`、`shell_navigation_e2e_test.dart`、
  `app/app_smoke_test.dart`——重组会牵动其中的选择器与事件流步骤。

## 目标结构(移动端线框)

```
┌──────────────────────────────────────────┐
│ ← 回顾                      [问助手] [⋯] │ ← [问助手]=现有 /assistant 通用入口
├──────────────────────────────────────────┤
│   (周)   (月)          ← 周期切换(FTabs),默认周;映射 last7/last30
│  ───────────────────────────              │
│  💧饮水  4/7天 -12%  😴睡眠 5/7天 =       │ ← ① 覆盖率概览行(每维度小卡,横滑)
│  💊用药  …            (维度=后端可用集)   │    记 N/7 天 + 值 + Δ;覆盖<2 天灰态
├──────────────────────────────────────────┤
│  🔍 值得注意(≤后端 findings/patterns 门控)│ ← ② 结构化洞察卡(≤2)
│   标题/正文/数据窗口  [展开证据(后置)]     │    无新信息→弃权占位,不生成泛化长文
├──────────────────────────────────────────┤
│  💧 饮水 · 近7天                 [对比]   │ ← ③ 单维趋势卡(折线+覆盖标注+Δ)
│  ▁▁▁▁▁▁▁  (空档语义后置)    [覆盖率说明] │    维度切换=现有 trends
├──────────────────────────────────────────┤
│  📋 事件回顾(折叠)                       │ ← ④ 事件列表(status 筛选/分页保留)
│  ▸ 感冒观察 · 进行中 · 第4天 [去今日确认] │    有进行中事件时页首置顶紧凑被动卡
│  ▸ …已结束… → 详情(/review/:eventId 不变) │
├──────────────────────────────────────────┤
│  (数据过稀 → 顶部整卡:本周记录进度+引导)  │ ← 冷启动/记录引导态
└──────────────────────────────────────────┘
```

页面状态机(在既有六态上改写):

| 状态 | 触发 | 呈现 |
|---|---|---|
| loading | 无缓存首次加载 | 新骨架(`ReviewSkeletonView` 镜像新区块) |
| error(无缓存) | 主数据失败 | 既有 `StateErrorView` + 重试 |
| error-with-cache | 刷新失败有旧数据 | 既有 stale banner,保留旧内容 |
| preview(未登录) | signed-out | 登录横幅 + 预告卡改为「记录后你会看到什么」(覆盖概览/趋势/事件) |
| 冷启动/数据过稀 | 无事件 且 dashboard 全 insufficient/空 | 记录引导卡 + ④事件区(若有历史);不生成趋势结论 |
| 常态 | 无事件有数据 | ①→②(或弃权)→③→④ |
| 进行中事件 | 有 active event | 页首紧凑事件卡(被动,含「去今日 check-in」)+ 常态洞察;事件卡展开/详情不变 |

## 任务清单

### P0 结构重组(纯客户端,复用现有 dashboard 数据)

- [x] **P0-1 周期开关**
  - 页面顶部(顶栏下首行)新增 周|月 切换,默认周;映射
    `reviewDashboardSelectedQueryProvider.setRange(last7Days/last30Days)`;
    直接生效,切换期间用 `reviewLastDashboardProvider` 旧数据 + 轻量加载态(不整页骨架)。
  - 周期切换的 a11y label 与语义顺序对齐现有约定(`Semantics sortKey` 语义:标题 →
    状态 → 洞察 → 历史 → 更多)。
- [x] **P0-2 覆盖率概览行(新 `widgets/sections/coverage_strip.dart`)**
  - 数据:`dashboard.metrics` 中带 `observedMetric` 的维度小卡(interim 维度集 =
    后端可用集 water/sleep/medication/general);每卡:图标/名称、`observedCount/
    expectedCount` → 「X/N 天」覆盖文案、`value+unit`、`delta`(方向色),点击 → ③趋势
    卡切到该维度并滚动到图表。
  - 覆盖 `none` 或 <2 观察:灰态小卡,文案「数据太少」,不可点击进趋势。
  - 空 metrics 且无事件:整页落入冷启动/记录引导分支(P0-5),概览行不渲染空壳。
  - 新增单元/Widget 测试 + l10n 文案(`review` 分片)。
- [x] **P0-3 值得注意区(新 `widgets/sections/noteworthy.dart`)**
  - 数据:`dashboard.findings`(title/body/kind/icon/color),最多展示 2 张结构化卡;
    卡头类型图标 + 标题 + 正文 + 数据窗口(`startDate`–`endDate`)。
  - 无 findings → 弃权占位一行(「这段时间没有新的值得注意的变化」),不生成长文。
  - findings 为空且 dashboard 整体 insufficient → 交给 P0-5 记录引导,不展示弃权卡。
  - 反馈(有用/不适用)与证据引用字段 Wave 2 再做;本期不做假按钮。
  - 新 Widget 测试覆盖 有卡/弃权/混合 三态。
- [x] **P0-4 单维趋势卡收口(改 `widgets/sections/trend.dart`)**
  - 承接 ① 的维度点击与本身维度 chips 切换(FTabs,沿用现状);保留单折线 + 面积,
    底部一行覆盖率说明(取该维度 `observedMetric`:X/N 天 + 窗口),不再裸画
    legacy scalar 而不标注。
  - 空档=无记录的逐日语义本期末锁定,图表上方加一行「未记录的天不参与结论」口径说明
    (随 Wave 2 换逐日覆盖数据后可移除);删除旧「7/30 天」范围 pill 在主路径的残留。
  - 「让助手看这个趋势」上下文入口**本期不做**(依赖 agentic P1-1/P1-3 预置上下文),
    在顶栏 [问助手] 提供通用入口即可;条目记入跨计划依赖。
- [x] **P0-5 冷启动/记录引导态**
  - 判定:无 active/ended 事件 且 `dashboard.metrics` 为空或全部
    `insufficientData/unknown`(或 dashboard 请求成功但 trends 全空)。
  - 呈现:顶部引导卡(本周已记录 X/N 天、还差几天能看到趋势、入口去 record 补记)——
    复用「本周记录进度」文案语义,不回退成「开始健康观察」动作;下方保留 ④ 事件历史
    (若存在)与 preview 教育。
  - 无事件时移除 `_StartObservationCard` 的开始按钮与「事件驱动」文案(动作收口 Today)。
- [x] **P0-6 事件区被动化(compact 卡 + 列表保留)**
  - `EventHeaderSection` 中 check-in/end 动作从 review 主路径移除;active event 时渲染
    紧凑被动卡(事件标题、状态 chip、已进行天数、今日是否已确认一行文案),附一条浅链接
    「去今日 check-in」→ 切到 today tab(不做深链传参,Today 事件区块自行呈现)。
  - `ReviewHistorySection`(历史列表 + status 筛选 + 分页 + load-more)原样保留在 ④;
    ended 事件的四段完整回顾仍在 `/review/:eventId` 详情页(不改)。
  - 页面不再装配 start/check-in/end 三个 sheet 与 `activeHealthEventProvider`;
    `page.dart` 对应 `_openStart/_openCheckIn/_openEnd/_readCurrentMedicineOptions/
    _readReasonRecordOptions` 删除或移到 Today(若 Today 缺对应副本——现状 Today 已装配,
    仅做对照确认),review 对 health_event 的 presentation 依赖随之解除。
- [x] **P0-7 建议历史与 AI 摘要主路径下线**
  - `review_view.dart` / `page.dart` 移除 `ReviewSuggestionHistorySection` 装配、
    `suggestionHistoryProvider` watch 与 `dedupeTodaySuggestions` 调用、详情 sheet 入口;
    legacy 兼容页路径不动。
  - 移除 `ReviewAiSummarySection` 主路径装配与其在 `page.dart` 的
    aiSummaryState/range/enabled/generate 接线;代码文件**不删除**——标注 LEGACY/
    deferred 与 TODO(agentic P0-3 统一 AI 数据层后复核是否归档);`aiSummariesEnabled`
    设置语义不改(Today 摘要仍受其门控)。
  - 检查 `widgets/sections/ai_summary.dart` 是否孤儿:若仅 review_view 消费,在文件头
    加 deferred 标注 + `docs/TODO.md` 条目;移除后 `review_view_test` 中相关断言同步更新。
- [x] **P0-8 页面骨架与 preview 预告卡**
  - `skeleton_view.dart` 镜像新区块顺序(周期行 → 概览 → 值得注意 → 趋势 → 事件)。
  - preview(未登录)预告卡内容由「事件五段锁卡」改为「记录后你会看到什么」:
    覆盖率概览 / 值得注意的变化 / 单维趋势 / 事件回顾 / 去登录。
- [x] **P0-9 顶栏与入口**
  - 顶栏后缀保留 [⋯ 更多](导出/就诊摘要/分享管理/PDF/打印/legacy 全不动);
    新增 [问助手] 图标按钮 → `context.push('/assistant')`(与 today 顶栏助手入口同一语义,
    preview 态沿用 assistant 未登录预览行为)。

### P1 收口与替换(旧组件留用处置、测试、l10n)

- [x] **P1-1 删除/标记主路径死引用**:确认移除后无编译残留(lint: unused import /
  discard);legacy 路径消费的符号逐一核对不误删;孤儿文件按 P0-7 标注。
- [x] **P1-2 l10n**:新增/修改文案全部走 `lib/l10n/src/review_zh.arb` /
  `review_en.arb`(周期、覆盖文案、值得注意、弃权、记录引导、去今日 check-in、预告卡、
  [问助手] 等);`dart scripts/l10n/arb_tools.dart merge` + `flutter gen-l10n`;
  同步 `docs/reference/localization.md`。
- [x] **P1-3 单元/Widget 测试**
  - 更新:`test/review/` 下 page/review_view/golden/sections 依赖旧装配的用例;
    ai_summary/suggestion 相关测试按新装配语义改写或移至 legacy 覆盖。
  - 新增:coverage_strip(含灰态)、noteworthy(有卡/弃权)、周期切换(状态映射+旧值缓存)、
    冷启动引导、compact 事件卡(无动作 + 去今日入口)。
  - fixture:`test/review/review_fixtures.dart` 按新 dashboard 字段补数据构造。
- [x] **P1-4 集成/E2E 迁移**
  - `review_closed_loop_e2e_test.dart`:事件 start/check-in/end 动作步骤迁到 today 流;
    review 侧只断言被动卡与「去今日」跳转。
  - 核对 `report_e2e_test.dart` / `shell_navigation_e2e_test.dart` /
    `app_smoke_test.dart` 中 review key(`review-more-action`、tab key、事件动作 key、
    `review-start-observation-action` 删除后无残留引用)并更新。
  - e2e 不硬编码内部 ID 的既有约定保持(改用语义可读 key)。
- [x] **P1-5 review README 与文档**
  - 更新 `lib/features/review/README.md`:职责与边界(主路径=洞察+事件列表;动作归
    Today;建议历史/AI 摘要主路径下线)、对外契约(移除 suggestion/ai-summary 主路径
    导出)、不变量(覆盖率口径、冷启动分支、[问助手] 入口)、依赖禁区(解除
    health_event presentation 豁免,如已无 review 侧动作)。
  - 检查 ADR/IA/vision 文档是否需要指正(review 现仍「事件优先主路径」表述的地方
    在重组后更新或标注运行时事实变化)。

### P2 收尾验证与后置项

- [x] **P2-1 全量验证**:`flutter analyze`、`flutter test`、
  `dart run scripts/docs/verify.dart --warning-only`、必要时
  `flutter test integration_test`;金样测试若受影响按仓库规则重生成。
- [x] **P2-2 迁移日志**:追加 `docs/logs/migration-log/2026-09-07.md`(或执行当日)条目,
  描述范围与验证结论(append,不覆盖)。
- [x] **P2-3 后置依赖登记**(不在本期客户端范围,仅登记跟踪):
  - agentic P1-1/P1-3:「看这个趋势/就此回顾问助手」预置上下文入口(本计划 P0-4 的
    [问助手] 通用入口升级);
  - Lucent observed-metric 域迁移(target 2026 Q4):逐日覆盖桶、mood/symptom/meal/
    activity 维度入 dashboard、findings 证据引用与反馈通道——落地后本计划做一次
    Wave 2 客户端适配(替换 legacy scalar 趋势渲染、趋势空档可视化、证据展开、反馈)。
  - 完成后把 Wave 2 适配任务按「执行注意」从本清单删除,或拆分独立计划。

## 数据分层与契约(重要)

- **Wave 1(本期)= 纯客户端重组**,数据全部来自现有契约:
  `reviewCurrent/History`(事件)+ `reviewDashboard(last7/last30)`(metrics/trends/
  findings + observedMetric coverage)。不新增客户端网络层。
- **Wave 2(后置)= 覆盖率聚合契约成熟后适配**。期望 DTO 增量(供 Lucent 侧计划参考,
  以最终 openapi 为准):
  - 维度扩展:coverage buckets 支持 mood/symptom/meal/activity/medication/water/sleep;
  - 每维度逐日 presence:day-key 列表或每日 `recorded: bool`,使空档≠0 可渲染;
  - findings/patterns 增加证据引用(`recordIds`/日期列表)与反馈提交字段;
  - 生成侧门控与弃权语义已由后端规则/LangGraph 保证,客户端只渲染结构化实体。
  - Lucent 侧 contract 变化后:`pnpm export:openapi`(Lucent)→
    `dart run scripts/contract/bootstrap.dart`(Luminous)→ 按新实体改 mapper 与 UI。

## 代码影响清单(期望值)

| 路径 | 动作 |
|---|---|
| `review/presentation/pages/page.dart` | 重写装配:移除事件动作/建议历史/AI 摘要接线;周期开关与[问助手];新状态分支 |
| `review/presentation/widgets/views/review_view.dart` | 区块顺序与新状态机;删除 suggestion/ai 参数 |
| `review/presentation/widgets/sections/coverage_strip.dart` | 新增 |
| `review/presentation/widgets/sections/noteworthy.dart` | 新增 |
| `review/presentation/widgets/sections/active_event_card.dart` | 新增(compact 被动卡) |
| `review/presentation/widgets/sections/trend.dart` | 收口:覆盖率说明行/维度联动/移除主路径 7/30 pill |
| `review/presentation/widgets/views/skeleton_view.dart` | 镜像新区块 |
| `review/presentation/widgets/sections/{event_header,ai_summary,suggestion_history,preview_locked,what_happened,key_changes,completed_actions,next_step}.dart` | 保留;event_header 去动作(或仅详情页用);ai_summary/suggestion 按 P0-7 标注 |
| `review/domain/entities/dashboard.dart` | 大概率不变(复用);如需窗口/覆盖显示字段则小改 |
| `lib/l10n/src/review_{zh,en}.arb` | 文案增改 |
| `test/review/**`、`integration_test/review/*`、`integration_test/{shell,app}/*` | 按 P1-3/P1-4 更新 |
| `lib/features/review/README.md`、`docs/reference/localization.md` | 更新 |
| `docs/logs/migration-log/YYYY-MM-DD.md` | 执行当日 append |

## 已决边界与延期项

- 不增删 Tab、不改 shell 五键与 `shell-tab-report` 兼容;Record 内嵌迷你趋势
  (research 结论的阶段 1 另一半)**另立计划**,不在本计划。
- 就诊摘要/PDF/打印/分享管理/legacy 兼容页全部保持(默认折叠于「更多」)。
- `aiSummariesEnabled` 设置语义与周洞察通知(weeklyInsight 默认关)不因本计划改变。
- review 事件四段完整回顾仍以 `/review/:eventId` 详情承载;主 tab 只放紧凑卡/列表。
- 「去今日 check-in」不做跨页深链参数(避免契约扩散),由 Today 事件区块自身呈现当前态。

## 风险与缓解

- **移除 review 侧事件动作的回归风险**:Today 事件区块可达性需在 P0-6 用 widget/e2e
  锁定(事件创建→check-in→end 全程在 Today 完成);若发现 Today 无 active 事件时缺乏
  「开始观察」显式入口,在 Today 补一个入口(记入 P0-6 验收)。
- **dashboard legacy scalar 残留**:趋势空档语义本期不假装精确,一律带覆盖率说明,
  观察期结束随域迁移替换。
- **孤儿代码漂移**:ai_summary/suggestion 组件保留但主路径下线,务必文件头标注 +
  TODO 登记,避免被当「当前能力」断言(golden/widget 测试承接现状断言)。

## 跨计划依赖与顺序

1. 本计划 P0 主体可在 agentic P1-1 组件化前独立完成([问助手] 走既有 `/assistant`
   通用路由);P1-3 上下文入口与 review AI 数据层统一由 agentic 计划 P0-3/P1-1/P1-3
   承接。
2. Wave 2 依赖 Lucent observed-metric 域迁移(2026 Q4 目标)与 openapi 再导出。
3. 与 `2026-09-02-agentic-proactive-evolution.md` 共享 review 页宿主:若本计划先完成,
   agentic P1-3 的「主动复盘/起草调整计划」入口直接挂在重组后的「值得注意/趋势/
   [问助手]」之上。

## 验收标准

- 打开 review:默认周视角;无事件有数据 → 概览行 →(值得注意或弃权)→ 趋势 → 事件历史;
  无任何事件且数据过稀 → 记录引导,不出趋势结论、无「开始观察」动作。
- 有进行中事件:review 仅被动展示 + 「去今日 check-in」;start/check-in/end 在 Today
  全链路可用(review 页面不存在这些动作按钮)。
- 建议历史与 AI 摘要长文不在 review 主路径出现;legacy 兼容页入口行为不变。
- 覆盖率文案始终与数据一致(未记录≠0);切换 周|月 不出现整页骨架闪烁。
- `flutter analyze` + `flutter test` + 相关 e2e 全绿;review README/l10n 文档同步。

## 执行注意(仓库铁律)

- l10n:只改 `lib/l10n/src/` 分片 → `dart scripts/l10n/arb_tools.dart merge` →
  `flutter gen-l10n`,不碰生成物。
- LEGACY/被保留代码不顺手删除;孤儿需文件头标注 + TODO 登记。
- 迭代期窄命令;收尾跑 `flutter analyze`、`flutter test`、
  `dart run scripts/docs/verify.dart --warning-only`。
- 完成后:稳定结论进 feature README 与 docs;本计划不再驱动工作时删除,并将条目从
  `plans/README.md` 移除。
