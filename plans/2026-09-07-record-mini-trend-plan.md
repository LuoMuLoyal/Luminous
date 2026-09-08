# Record 内嵌迷你趋势:记录当下的 7 天即时反馈(周/月切换)

Created: 2026-09-07

> 定位:Review 页重组计划(`2026-09-07-review-page-restructure.md`)的**另一半**——
> 把「记录当下的即时反馈」内嵌进 record 页:日期条与快捷面板之下,一行类别 + 该类别
> 7 天迷你折线(周|月切换)+ 覆盖率行 + 该类别记录摘要。深度洞察仍归 review,本计划
> 只做轻量、一瞥式、记录后立刻可感知的趋势反馈。
>
> 依据:`../research/01-用户价值调研/record-review-assistant-纵向洞察归属与Tab验证.md`
> 阶段 1 推荐:Record 增强为「记录中枢」,内嵌迷你趋势(Habito 类即时反馈是参与最大
> 杠杆;「反思发生在记录当下」)。与 review 计划的分工:**record = 当下的值/趋势感知,
> review = 周/月深度洞察与事件专题**;两端在后端聚合契约成熟后共享同一语义(Wave 2)。

## 已决决策(2026-09-07)

1. **数据口径 Wave 1 = 客户端聚合**:record 域内自建「范围聚合」能力,逐日复用
   `dailyRecordRepository.fetchRecords`(按日/按 kind),客户端把每类别的 7/30 天记录
   聚成日值 + 覆盖天数;**不跨 feature 消费 review 的 dashboard 契约**(架构铁律:
   data→data 禁止),待 Lucent 聚合契约成熟后切 Wave 2。
2. **周期 = 周 | 月**(映射近 7 天 / 近 30 天;与 review 计划口径一致);**年视图不做**
   (稀疏记录下年视图价值低、成本高,记延期项)。
3. **内嵌形态,不翻页**:不把 record 整页改成「类别钻取页」——保留现有
   date bar → quick entry → filter → timeline 主任务;迷你趋势作为 quick entry 之下
   的**一张可折叠卡**,选中类别就地展示,「看完整记录」走既有 filter 时间线与详情页。
4. **覆盖率语义**与 review/产品铁律一致:未记录的天=空档(不画 0、不进平均),卡头
   显示「本周已记录 X/7 天」;数据不足(<2 天)整卡灰态,不给趋势结论。

## 现状锚点(代码事实,2026-09-07)

- `recordDashboardProvider`(selectedDate + filter)经 `LucentRecordRepository
  .fetchDashboard` 装配:`timeline` 来自真实 `dailyRecordRepo.fetchRecords(dateStr,
  kind, pageSize:100)`,`summary` 来自 `fetchSummary(dateStr)`,但 **`monthDays` 与
  `trends` 仍是静态 mock**(`staticMonthDays` / `staticTrends`,
  `data/utils/record_static_data.dart`);trends 有实体 `RecordTrend`
  (kind=bloodSugar/hydration、points/bars/secondaryPoints…)但未被真实数据驱动。
- 按日查询能力:`dailyRecordListForDateProvider(date)`(fetchRecords pageSize:200)
  与 `LucentRecordRepository` 内的 fetchRecords 调用——**没有范围/多日聚合端点**。
- 刷新链路:`recordDashboardProvider` watch `dataChangeVersionProvider
  (DataChangeTopic.dailyRecords)`,新增/编辑/删除记录后自动重建;迷你趋势 provider
  必须同样挂这个 topic。
- 类型↔kind 映射唯一出处:`domain/entities/type_mapping.dart`
  (`RecordEntryType` ↔ `DailyRecordKind`,medication 永不落 daily record);类别共有
  11 个 `RecordEntryType`,快捷动作 7 个 + vitals/activity/heartRate/weight 在 palette。
- 数值口径:water=ml 累计、sleep=时长、meal=餐次、mood=值、symptom=条数、medication
  (走 dose log,record 侧无)、vital/weight/heartRate=最新值——聚合口径需按 kind 定义
  (见「数据口径」)。
- record 现有测试约 502 用例(test/record),l10n 分片 `record_{zh,en}.arb`;
  趋势相关 l10n key 已有(`trendBloodSugarTitle`/`trendHydrationTitle`/
  `range7Days`/`range30Days`),可扩展。
- 架构边界(record README):record 不 import 其他 feature 的 data/presentation
  providers;settings 只经 `UserSettingsRepository` domain 接口。

## 目标结构(移动端线框)

```
┌──────────────────────────────────────────┐
│ ← 记录                         [⋯]        │
│  (日期条:◀ 7月1日 周一 ▶)                 │ ← 现有 RecordDateBar(不动)
├──────────────────────────────────────────┤
│  快速记录: [症状][用药][饮水][餐食][睡眠]  │ ← 现有 quick entry(不动)
│            [心情][笔记]                    │
├──────────────────────────────────────────┤
│  📈 近 7 天(折叠可展开)          [周|月]  │ ← 新增:迷你趋势卡
│  ┌────────────────────────────────────┐  │
│  │ 类别行(横滑):💧饮水 4/7天  😴睡眠   │  │
│  │              😊心情 2/7天  …        │  │
│  │ ────────────────────────────────── │  │
│  │ 饮水 · 近7天         平均 1420ml/日 │  │
│  │  ╭╮     ╭─╮    ▁▁   折线+面积       │  │
│  │  ╯╰──╯ ╰─╯   ▔    空档=无记录       │  │
│  │  一二三四五六日(覆盖标线)             │  │
│  │  本周已记录 4/7 天 · 较上周 +10%     │  │
│  │  [查看完整记录]                      │  │
│  └────────────────────────────────────┘  │
├──────────────────────────────────────────┤
│  (类型) (全部) (今天)…  [筛选 chips]      │ ← 现有 filter(不动)
│  ┌─ 时间线 … ────────────────────────┐  │
│  └───────────────────────────────────┘  │ ← 现有 timeline(不动)
└──────────────────────────────────────────┘
```

交互:
- 默认折叠为一行摘要(各类别 7 天覆盖率小字),点击展开;
- 类别行选中 → 下方单类别折线(默认第一个有数据的类别);
- [周|月] 切换全局生效(近 7 / 近 30 天),切换不整页骨架(复用旧值 + 轻量加载);
- 数据不足(<2 天)类别灰态;全部不足 → 整卡替换为一行引导(「本周已记录 X/N 天,再记
  Y 天就能看到趋势」+ 去补记);
- 未登录 preview:该卡不请求(沿用 dashboard signed-out 空态)。

## 数据口径(Wave 1 客户端聚合)

| DailyRecordKind | 日聚合值 | 空档语义 |
|---|---|---|
| water | value 数值累计(ml) | 无记录=空档 |
| sleep | value 数值(时长)取当日记录 | 同上 |
| meal | 条数 | 同上 |
| mood | 当日记录数(或众数映射) | 同上 |
| symptom | 条数 | 同上 |
| note | 条数(不参与趋势结论,仅计数) | 同上 |
| vital/heartRate/weight | 当日最新值(或条数) | 同上 |
| medication | 不在 record 域(dose log),跳过 | — |

- 折线只画「有记录的天」的点;空档天在 x 轴标线表示「未记录」(视觉区分于 0)。
- 覆盖行:「X/7 天」= 该窗口内实际有记录的天数;均值 = 有记录天均值,卡头注明口径。
- 与 review Wave 2 共用后端契约后,以上口径收敛到服务端语义(见「契约分层」)。

## 任务清单

### P0 数据层:record 域范围聚合(不动 review)

- [ ] **P0-1 聚合模型与口径**
  - `domain/entities/trend_aggregate.dart`(新):`RecordTrendAggregate`(kind、窗口
    start/end、`List<RecordDailyPoint>`(dateKey/有记录 bool/聚合值 nullable)、
    recordedDays、覆盖天数、均值、较上一窗口 Δ);`kind → 聚合函数` 映射落在
    `application/usecases/` 或 `data/utils/`(单一出处,参考 type_mapping 约定)。
  - 口径测试先行:`test/record/` 覆盖 空档≠0、均值=有记录天均值、Δ 计算、全空窗口。
- [ ] **P0-2 范围取数**
  - `domain/repositories/daily.dart` 增补(或 record 域新增 use case)
    `fetchRecordsRange(start, end, {kind})`:`Future.wait` 逐日
    `fetchRecords(dateKey, kind, pageSize:200)` 并行取数(7/30 天;30 天并发 30 请求
    需节流/分批,建议分 3 批×10 或复用现有 repository 并发上限,记录在实现注)。
  - 失败降级:单日失败记 `appTalker` 并按「该日无数据」计入(与既有 dashboard
    degrade 产品行为一致),不整卡失败;全窗口失败 → provider error(走卡片错误态)。
  - 边界:不跨 feature import;只依赖 record 现有 repository 与核心 utils。
- [ ] **P0-3 迷你趋势 provider**
  - `presentation/providers/mini_trend.dart`(新,keepAlive):watch
    `dataChangeVersionProvider(DataChangeTopic.dailyRecords)` + `selectedRecordDate`
    相关窗口(以今天为锚或选中日期为锚,取近 7/30 天;锚点与 date bar 选中日期联动,
    见交互决定);`authGuarded` + 5s 超时 + signed-out 空态,行为对齐
    `recordDashboardProvider`。
  - 周期状态:新增 `RecordTrendPeriodNotifier`(week/month),或复用既有 range key
    状态(review 的 range provider 在 review 域,不可跨用——record 自建)。

### P1 UI:迷你趋势卡

- [ ] **P1-1 类别行 `widgets/sections/mini_trend/coverage_row.dart`**(新)
  - 数据:窗口内各 kind 的覆盖天数 + 汇总值;小卡样式对齐 quick entry 视觉 token
    (SemanticIcons / SemanticColor,不新增裸样式);<2 天灰态。
  - 类别集:默认快捷 7 类(有数据才出现,无数据的类别不占位?——决策:全部显示但
    无数据显示灰态「暂无记录」,避免版面跳动;实现时按产品取舍记录)。
- [ ] **P1-2 单类别折线 `widgets/sections/mini_trend/chart.dart`**(新)
  - 复用 `fl_chart`(`LineChart` + 面积,设计系统已约定);x 轴日期标线,
    无记录天视觉空档;tooltip 显示日期/值/来源条数。
  - 覆盖率行 + 均值 + Δ 文案;空档口径文案(l10n 新增)。
- [ ] **P1-3 卡壳 `widgets/sections/mini_trend/panel.dart`**(新)
  - 折叠/展开、周|月切换、数据不足引导态、错误态(单行 + 重试)、loading 骨架行;
  - 「查看完整记录」→ 设置 `selectedRecordFilterProvider` 为该类别并滚到时间线
    (复用既有 filter 机制,不新开路由)。
- [ ] **P1-4 装配 `dashboard_view.dart` / `page.dart`**
  - mobile:quick entry 与 filter 之间插入迷你趋势卡;desktop:放入
    `RecordSummaryGrid` 之下的右栏(或保持移动端单列约束——沿用 review 的桌面
    单列惯例,不做双栏新布局,记实现取舍)。
  - 组装新 provider 与 skeleton(更新 `skeleton_view.dart` 镜像新区块)。
- [ ] **P1-5 交互与状态收口**
  - 展开默认取第一个有数据类别;类别切换保留选中态(局部状态,不进路由);
  - 周|月切换期间显示旧数据 + 轻量加载(复用 review 同款「last cache」模式,record
    侧自建 last 缓存,不跨 feature)。

### P2 收尾

- [ ] **P2-1 l10n**:新增文案(迷你趋势/覆盖率/空档/引导/灰态等)全走
  `lib/l10n/src/record_{zh,en}.arb` → merge → gen-l10n;同步
  `docs/reference/localization.md`。
- [ ] **P2-2 测试**
  - 单元:聚合口径(空档/均值/Δ/并行降级)、provider 状态机(数据不足/错误/刷新);
  - Widget:coverage_row 灰态、chart 空档渲染、panel 折叠/切换/引导态;
  - 金样:新增区块后按仓库规则重生成受影响 goldens;
  - e2e:record 流程冒烟覆盖迷你趋势展开与「查看完整记录」跳转(如影响既有
    record e2e 选择器则一并更新)。
- [ ] **P2-3 文档**:更新 `lib/features/record/README.md`(职责与边界加迷你趋势;
  趋势区块从「静态 mock 待后端 API」改为「Wave 1 客户端聚合,Wave 2 接后端契约」);
  追加 `docs/logs/migration-log/YYYY-MM-DD.md`(执行当日,append)。
- [ ] **P2-4 全量验证**:`flutter analyze`、`flutter test`、
  `dart run scripts/docs/verify.dart --warning-only`;收尾按仓库命令。

## 契约分层(与 review 计划对齐)

- **Wave 1(本期)= 客户端聚合**,无后端契约变更;不动 review 的 dashboard 契约。
- **Wave 2(后置)= 与 review 计划同源的后端聚合契约**(Lucent observed-metric 域迁移,
  target 2026 Q4):范围聚合端点或 daily-records 聚合 DTO 需覆盖本计划的 8 类 kind、
  逐日 presence、窗口与 Δ;Lucent 侧 `export:openapi` → Luminous
  `dart run scripts/contract/bootstrap.dart` 后,record 的 mapper/provider 切换到
  服务端语义,客户端聚合口径退役(代码标注 LEGACY/deferred + TODO)。
- 本计划不新造与 review 重复的契约;两端共用同一后端聚合源,客户端各自消费本域
  repository(不跨 feature data 依赖)。

## 代码影响清单

| 路径 | 动作 |
|---|---|
| `record/domain/entities/trend_aggregate.dart` | 新增(聚合模型) |
| `record/application/usecases/` 或 `data/utils/aggregate.dart` | 新增(口径/聚合函数,单一出处) |
| `record/domain/repositories/daily.dart` + `data/repositories/lucent_daily.dart` | 增补范围取数(或 record 域新 use case) |
| `record/presentation/providers/mini_trend.dart` | 新增(provider + 周期状态) |
| `record/presentation/widgets/sections/mini_trend/{panel,coverage_row,chart}.dart` | 新增 |
| `record/presentation/widgets/views/dashboard_view.dart`、`skeleton_view.dart` | 装配新区块 |
| `record/presentation/providers/dashboard.dart` | 不动(或仅读周期状态) |
| `record/domain/entities/dashboard.dart`(`RecordTrend`/`RecordCopyKey`) | 大概率不动;如需沿用新增 key |
| `lib/l10n/src/record_{zh,en}.arb` | 文案增改 |
| `test/record/**`、`integration_test/**`(如涉及) | 新增/更新 |
| `lib/features/record/README.md`、`docs/reference/localization.md` | 更新 |
| `docs/logs/migration-log/YYYY-MM-DD.md` | 执行当日 append |

## 已决边界与延期项

- 不做「类别钻取页」整页重构(保留现有 timeline 主任务);不做年视图;不做跨维度
  关联(如睡眠↔心情)与 AI 解释(那归 review/assistant)。
- medication 类别在 record 域无数据(dose log),迷你趋势不显示该类别(或仅在有
  medicine 数据源时另行接入,记 TODO)。
- 未登录 preview 不请求趋势数据(与 dashboard 空态一致)。
- 桌面端沿用移动端单列布局(ADR-0008 冻结桌面扩展;不新增桌面专属双栏)。

## 风险与缓解

- **N+1 请求**:30 天窗口逐日请求量大 → P0-2 分批并发 + 失败按日降级;如实测过重,
  临时把月视图窗口定为近 14 天并记录(与产品确认后改,不静默)。
- **口径与 review 不一致**:Wave 1 客户端口径与 review/后端语义可能短期分叉 →
  卡头与图表内标注「近 7 天」「有记录天均值」;Wave 2 统一收敛,验收含口径对照测试。
- **类型↔kind 遗漏**:新增 kind 聚合必须走 type_mapping 单一出处并补测试,
  避免类别静默丢失。

## 跨计划依赖

- 与 `2026-09-07-review-page-restructure.md`:共享 Wave 2 后端聚合契约与覆盖率语义;
  本计划 Wave 1 不依赖 review 计划落地,可并行。
- 与 `2026-09-02-agentic-proactive-evolution.md`:无直接依赖(趋势解释/总结归
  assistant 的能力另由 agentic 承接,本计划不做)。

## 验收标准

- record 页在快捷面板下出现迷你趋势卡:默认折叠;展开后可见类别覆盖率行 +
  单类别折线;空档天不画 0、覆盖天数与均值口径与数据一致。
- 新增/编辑/删除一条记录后,迷你趋势在 DataChangeBus 驱动下自动刷新(无需手动)。
- 周|月切换不整页骨架(旧值 + 轻量加载);数据不足与全空窗口分别呈现灰态与引导态。
- 未登录 preview 不请求趋势;错误态单行重试可用。
- `flutter analyze` + `flutter test` 全绿;record README/l10n 文档同步;趋势区块
  不再自称「静态 mock」。

## 执行注意(仓库铁律)

- l10n 只改 `lib/l10n/src/` 分片 → merge → gen-l10n,不碰生成物。
- 不跨 feature 消费 data/presentation(record 不 import review 的 provider);类型↔kind
  映射只走 type_mapping 单一出处。
- 迭代期窄命令;收尾 `flutter analyze`、`flutter test`、
  `dart run scripts/docs/verify.dart --warning-only`。
- 完成后:稳定结论进 record README 与 docs;本计划不再驱动工作时删除,并从
  `plans/README.md` 移除条目。
