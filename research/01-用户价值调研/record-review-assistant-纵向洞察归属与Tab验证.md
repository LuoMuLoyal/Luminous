---
status: active
owner: frontend
quadrant: explanation
updated: 2026-09-07
---

# 纵向洞察归属与 Tab 结构验证:Review 并入 Record + Assistant 一级化

> 范围:对一条产品改动提案做对抗性桌面研究验证——① Record 大翻新为「日期选择 +
> 一行类别 + 该类别 7 天/周月年折线图 + 该类别倒排记录」,统计/趋势从 Review 并入
> Record;② 原 Review Tab 换成 Assistant 页面,把洞察/AI 周报/建议历史/过去的总结
> 降级为 Assistant 的工具,由 agent 按用户需要产出总结与报告,并推进 GenUI。
>
> 方法:三路并行的桌面研究(个人信息学文献 / AI 摘要与周报接受度 / 竞品 IA 与
> GenUI-2025-2026 语料),证据逐条标注等级(研究数据 / 一手厂商 / 主流媒体 / 分析 /
> 传闻;不可核实项如实标注)+ 与本仓库现状文档对撞。
>
> 状态:这是「用户价值调研」的**前置输入与假设清单**,不是最终 IA 决策。产品信息
> 架构文档明确:五个 Tab 的长期职责/命名、Assistant 是否一级入口、纵向洞察如何承载,
> 均**等待用户价值调研完成后另行讨论**(`Luminous/docs/product/product-information-architecture.md`)。
> ROADMAP 的 User-Value Validation 一节与本研究同属该未决问题(注:其引用的
> `research/00-市场调研/05-长期健康伙伴用户价值验证.md` 已在调研文档清理时删除,
> 链接悬空,待重新落位)。

---

## 0. TL;DR:五个判断

| # | 提案论点 | 判定 | 一句话理由 |
|---|---|---|---|
| 1 | 「没人会主动点开一个 Tab 看事件专题回顾/纵向洞察」 | 部分对,但概念混淆 | 目的地式*被动内容*洞察确实参与度低(证据充分);但「事件专题回顾」是*任务型刚需*(生病期、就诊),慢病人群会反复回看,不能一刀切砍 |
| 2 | 「统计结果放到 Record」 | 方向对,应该做 | 「日期滚动记录中枢 + 内嵌迷你趋势」是 Oura/Fitbit/Garmin 的收敛形态,也符合「反思发生在记录当下」;但要以*增强记录页*为前提,不是以*消灭独立洞察目的地*为前提——后者无成功先例 |
| 3 | 「Review 换成 Assistant 页面」 | 证据整体反对「换成纯聊天 Tab」 | 用户要答案不要对话、聊天有结构性冷启动、AI 摘要常与旁边图表重复、AI 拒答/出错时无兜底;业界收敛是「结构化 Tab + AI 叠加层(Ask 入口)」,无一「删回顾 Tab 换 AI Tab」 |
| 4 | 「把周报/总结/建议历史降级为 agent 的工具」 | 方向正确 | 回顾需要外部触发、慢病患者要「一键给医生看的摘要」——AI 按需生成是对的;但触发应是「需要时一键」,产物应是可扫读的结构化组件,不是长对话 |
| 5 | 「推进 GenUI」 | 认同方向,形态校准 + 需显式解冻 | GenUI = agent 按意图生成*任务型结构化界面*,不是聊天页(FlowUI 提案卡已是雏形);MVP scope 明确冻结开放式 GenUI,推进 = 显式范围决策 |

---

## 1. 背景与问题定义

### 1.1 提案还原(按讨论时的原话语义)

- **Record 大翻新**:顶部日期选择 → 下一行快速记录类别(原 7 类 3×2+1 网格改一行)→
  该类别对应的七天折线图(可切周/月/年视图)→ 该类别按时间倒排的记录列表。
- **Review 改 Assistant**:原 Review Tab 变为 Assistant 页面,承载
  `Luminous/plans/2026-09-02-agentic-proactive-evolution.md` 的 Agentic 路线;
  原有洞察、AI 周报、建议历史、过去的总结等以**工具**形式交给 Assistant,
  agent 自行为用户需求产出总结/报告,「把自由还给用户」,并推进 GenUI。

### 1.2 仓库现状盘点(代码与文档事实)

**五个 Tab**:today / record / medicine / review / mine
(`Luminous/lib/features/shell/presentation/tab.dart`;review 保留 legacy key
`shell-tab-report`,report→review 已有一次改名先例)。

**record**(`Luminous/lib/features/record/README.md` + `presentation/`):
- 移动端页面 = `RecordDateBar`(日期条,已有日期选择器)→ `RecordQuickEntryPanel`
  (7 个默认快捷动作:symptom/medication/water/meal/sleep/mood/note,即 3×2+1)→
  `RecordMobileFilter`(类别过滤 chips)→ `RecordMobileTimeline`(所选日期的记录时间线)。
- 桌面端另有 `RecordMonthCalendarPanel` + `RecordSummaryGrid` + `RecordTimelinePanel`
  + `RecordNewEntryPanel`。
- 类型 palette 不止 7 个:另有 vitals/heartRate/weight/activity(见
  `domain/entities/type_mapping.dart`、`data/utils/record_static_data.dart`)。
- **月份日历/趋势区块仍是静态 mock,待后端聚合 API**(README「陷阱与决策」)。
- 快捷动作单击=记录+可撤销,长按=该类型设置。

**review**(`Luminous/lib/features/review/README.md`):
- 主路径 = 健康事件四段式回顾(发生了什么/关键变化/完成情况/下一步)+ 事件历史/详情
  + AI 摘要(SSE,尊重 `aiSummariesEnabled` 开关)+ 就诊摘要 clinic summary
  (预览/PDF/可撤销分享,入口在「更多」)。
- 旧 7/30 天 dashboard 只以 `LegacyDashboardCompatPage` 兼容页存在(LEGACY 标注),
  不在主路径装配。
- **注意:review 主路径已不是「AI 周报/建议历史页」**;AI 周报类内容在 legacy
  dashboard 兼容页与 weekly insight 通知链路(默认关闭)。

**assistant**(`Luminous/lib/features/assistant/README.md`):
- 全屏工作区路由 `/assistant`,在五个 Tab 之外;今天顶栏、命令面板、Ctrl/Cmd+Shift+A
  可进入;未登录可预览。
- SSE 流式对话 + 工具调用 + proposal 写操作确认(FlowUI 渲染),feature 内自洽,
  无 provider 级对外契约。

**agentic 计划**(`Luminous/plans/2026-09-02-agentic-proactive-evolution.md`):
- P0-3 统一 review/today 与 assistant 的 AI 数据层;P1-1 assistant 能力组件化
  (会话控制器 + SSE + proposal 卡片),P1-2/1-3/1-4 把 agent 会话嵌入 today/review/
  medicine;P2 proactive 推送承接「review 摘要推送」进 assistant 会话;Phase 3 探索
  「委托与复核」交互。
- **P1-3 的宿主就是 review 页**——若 review Tab 被删除,该条目需要改写宿主。

**既有产品文档立场**:
- `docs/product/product-vision.md`:「它不是等待用户来问的搜索框,也不是一份要求用户
  主动研究的健康周报」;核心交付面 = Today 主动建议 + Review 纵向洞察 +
  Assistant 个人上下文问答,共享同一事实底座。
- `docs/product/product-information-architecture.md`(2026-08-31):现行 Tab 结构是
  「现行结构说明,不作为最终信息架构决策」;Record 禁放「周报/趋势主视图」与
  「以 AI 为主角的通用聊天入口」;Review 长期承载「有覆盖率的日/周/月纵向洞察」;
  事件专题是「运行时事实而非长期层级决定」。
- `docs/product/product-mvp-scope.md`(2026-09-06):日/周/月纵向理解为 MVP 核心闭环;
  「开放式 GenUI:冻结,不在当前阶段推进;现有固定提案卡继续承担受控写入确认」;
  「当前五个 Tab 的长期职责和命名等待本轮调研后单独讨论」。
- `docs/reference/adr/0007-...(superseded)`:事件专题保留为运行时事实,是「纵向洞察中
  的一种专题」而非全部。
- `ROADMAP.md` User-Value Validation:改五个 Tab 前须用真实用户验证六问;研究设计
  文档链接悬空(见顶部注)。

---

## 2. 外部证据

> 证据标签:【研究数据】同行评审/日志/问卷;【一手】厂商官方;【媒体】主流科技媒体;
> 【分析】博客/分析语料;【传闻】论坛帖;【空白】无可靠公开数据。
> 样本总体偏北美/欧洲、英语、年轻与自我追踪爱好者,外推需谨慎。

### 2.1 用户是否会去看「回顾/洞察」目的地(个人信息学)

1. 【研究数据】主流个人信息学模型不假设「反思 = 事后打开回顾页」。Epstein 2015
   「生活化信息学」把采集/整合/反思视为「记录—行动」同步过程,反思常「在数据被采集
   的那一刻就发生」(援引 Choe 等)。Rooksby 2014:数据「经常按每日/短期目标使用解读」。
   ([Epstein 2015](https://pmc.ncbi.nlm.nih.gov/articles/PMC12435389/) ·
   [Rooksby 2014](https://eprints.gla.ac.uk/94944/))
2. 【研究数据】常态使用是「记录当下的一瞥式查看」,对事后回看兴趣低。Epstein 2015:
   24%(活动)/26%(财务)/36%(位置)受访者过去一周根本没打开过工具,3 个月内 44–45%
   弃用活动/位置工具。Gouveia 2015(Habito 10 个月野外日志):使用被 5 秒级一瞥会话
   主导,「用户对历史数据表现出真正的不感兴趣」;反而是记录当下呈现的**即时文字反馈**
   最能驱动参与与行为。
   ([Gouveia/Habito](https://ktisis.cut.ac.cy/entities/publication/2a871b74-f7f1-4c5a-a712-2ea4e22cc5c9))
3. 【研究数据】弃用是常态,主因是采集成本与「已学到足够」,不是「不看统计」。Epstein
   2016(193 人):停用六因之首是采集/整合成本;「一旦有了计划,Fitbit 就不再必要」;
   有人因反思时数据令其不适而放弃。Krebs & Duncan 2015:45.7% 停用过健康 App。
   Baumel 2019(93 款情绪/健康 App 面板):30 日留存中位 3.3–6.1%。
   ([Epstein 2016](https://pmc.ncbi.nlm.nih.gov/articles/PMC5428074/) ·
   [Krebs & Duncan 2015](https://pubmed.ncbi.nlm.nih.gov/26537656/) ·
   [Baumel 2019](https://pubmed.ncbi.nlm.nih.gov/31573916/))
4. 【研究数据/综述】「看图表 → 可行动洞察」整条链路证据薄弱:Kersten-van Dijk 2017
   从 6568 篇只筛出 24 项相关实证且含方法学问题;「反思 ≠ 查看数据」(Baumer 2015
   breakdown→inquiry→transformation;呈现方式决定反思质量,中等抽象度的语境化衍生
   指标优于孤立抽象分数,Bentvelzen 2023)。
   ([Kersten-van Dijk 2017](https://doi.org/10.1080/07370024.2016.1276456) ·
   [Baumer 2015](https://ericbaumer.com/2015/06/08/reflective-informatics-conceptual-dimensions-for-designing-technologies-of-reflection/) ·
   [Bentvelzen 2023](https://research.chalmers.se/en/publication/534349))
5. 【反证/方向性矛盾】一小部分「行为改变型/诊断式」用户会频繁采集并复查数据;
   论坛存在明确要求长周期图表的用户(MyFitnessPal/Fitbit,【传闻】级,双向信号:
   既有需求也说明可达性是问题)。**Apple/Fitbit/MFP 无公开功能级遥测**——没有任何
   数据能证明「删统计页无损」,也无法区分「用户不需要回顾」与「产品没把回顾做有价值」。
   ([MyFitnessPal 论坛](https://community.myfitnesspal.com/en/discussion/comment/48805849) ·
   [Fitbit 反馈](https://community.fitbit.com/t5/Product-Feedback/Make-all-data-graphs-axis-to-display-last-7-30-90-and-365-days/idc-p/5780203))

**含义**:「大多数人不会主动开一个 Tab 看洞察」成立;但解药是「把价值兑现挪到记录
当下 + 需要时一键生成」,而非「砍掉洞察」;删除会伤害深度复查/慢病子集,且无 A/B
数据背书。

### 2.2 AI 周报/自动摘要的接受度与痛点

- 【媒体】The Verge 实测批评 AI 摘要「显而易见的无用」:摘要通常就放在同一数据的图表
  旁边,把用户已能看到的内容换句话再说一遍;Oura Advisor 消化一年数据的时延「必然
  糟糕」;Strava 忽略其掌握的关键情境(受伤/高温),Whoop Coach 拒答并引导订阅。
  ([The Verge](https://www.theverge.com/fitness-trackers/694140/ai-summaries-fitness-apps-strava-oura-whoop-wearables))
- 【一手+媒体,需谨慎】厂商自报正面:Oura 称 60% 用户每周多次用 Advisor、20% 每日;
  Strava 称约 80% 反馈有帮助——非独立审计,不采信为强度证据。
- 【空白】冥想/情绪类 App 的 AI 报告接受度、push vs pull 偏好:无可靠公开数据。
- 【研究数据】回顾需要外部触发:Morris 2010 小样本中纵向回顾主要发生在被引导场景;
  JITAI 框架支持「当下/按需」而非「备而不用」。
  ([Morris 2010](https://pmc.ncbi.nlm.nih.gov/articles/PMC2885784/) ·
  [Nahum-Shani 2018 JITAI](https://pubmed.ncbi.nlm.nih.gov/27663578/))

### 2.3 慢病/就诊场景(回看与报告的真实需求)

- 【研究数据】约 2/3 双相患者把追踪数据用于门诊并明确要「医生可消化的摘要报告」
  (Murnane 2016, n=552;记录负担 × 记录失败引发羞耻感)。
- 【研究数据】Chung 2016 CSCW:医患协作中数据是「边界协商物(boundary negotiating
  artifacts)」;1,791 名风湿患者中约 38% 点名「记录症状并与医生分享」功能。
- 【含义】「一键生成就诊摘要」是真实高频需求;产品里就诊摘要导出是时敏、稳定、低摩擦
  动作,不宜唯一化为对话流。

### 2.4 竞品 IA:趋势/统计住在哪里

- 【一手+媒体】头部产品收敛形态 = 「日期滚动的今日/记录中枢 + 深度分析保留在独立
  目的地」,无一删除「回顾目的地」:
  - Oura(2025-10 改版):Today/Vitals/My Health;趋势/报告仍在左上 Trends/Reports
    ([Oura 官方](https://support.ouraring.com/hc/en-us/articles/360058599753-How-to-Use-the-Oura-App))。
  - Fitbit(2025-10 Gemini 版):Today/Fitness/Sleep/Health 四个结构化 Tab + 全局
    「Ask Coach」按钮([Trusted Reviews](https://www.trustedreviews.com/news/fitbit-health-coach-app))。
  - Garmin Connect(2024 首页化):今日活动 + In Focus + At a Glance
    ([Garmin 新闻稿](https://www.garmin.com/en-US/newsroom/press-release/wearables-health/garmin-connect-gets-a-new-look-simplified-design-provides-a-more-customized-experience/))。
  - Samsung Health:Home 卡片 + 分指标页内趋势,无独立统计 Tab(官方手册)。
  - Apple Health:Trends 在 Summary 内,Browse 承载分类详情。
  - Daylio/Bearable/Loop:采集低摩擦,统计/洞察独立成页。
- 【分析】「采集入口旁直接嵌趋势图/sparkline」几乎查不到可证实的主流先例(三星周期
  记录在录入页顶部给的是「常用项」而非趋势图)→ record 内嵌图表是差异化设计而非
  惯例,风险需自测。
- 【分析+一手】底部导航规范 3–5 项;iPhone 上限 5。「第 5 个 AI 助手 Tab」是上升中
  的少数模式:带 AI 助手/聊天的 App 占比 2023→2025 从 2.4% 升至 8.8%(健康/教育最早,
  语料 809 App/47578 截图);但入口形态多数**不是底栏 Tab**,而是 Ask Coach(叠在
  结构化 Tab 上)、Oura「+」、KakaoTalk 页内入口。
  ([Lazyweb 渗透率研究](https://www.lazyweb.com/research/how-fast-did-ai-assistant-screens-spread-in-apps) ·
  [Apple HIG Tab bars](https://developer.apple.com/design/human-interface-guidelines/tab-bars))
- 【媒体】「把回顾并入记录/删除仪表盘 Tab」没有可引用的成功先例;可观察到的只是
  底栏收敛或指标 Tab 化(2023 Fitbit、2024 Garmin、Samsung 两轮 Home 改版)。
- 【媒体】厂商 AI 助手仅 Premium(Fitbit Coach)被批评为付费墙;责任与护栏要先定。

### 2.5 GenUI / agentic UI(2025–2026)

- 【媒体/一手】GenUI 定义 = 让 AI 在运行时生成任务型界面(chat 作为前端、按输出流式
  渲染控件,Vercel v0/streamUI;学术侧「Software as Content」);
  已知代价:时延、准确率、一致性护栏(NN/g guardrails)、信任与法律成本下只产出
  「平庸但安全」的摘要。
  ([InfoWorld](https://www.infoworld.com/article/4110010/generative-ui-the-ai-agent-is-the-front-end.html) ·
  [NN/g GenUI](https://www.nngroup.com/articles/genui-buttons-and-checkboxes/))
- 【一手】领先实践 = 「agent 作为 App 内工具层 + 执行前人确认」,而非把功能页换成
  聊天气泡:Anthropic 工具即应用、权限分级、Plan Mode;OpenAI 口径「从回答问题到替
  你做事」且执行前暂停确认。
  ([Anthropic Trustworthy agents](https://www.anthropic.com/research/trustworthy-agents) ·
  [Anthropic Building effective agents](https://www.anthropic.com/engineering/building-effective-agents))
- 【一手】用户要答案不要对话:NN/g 实测「我们不闲聊……我只想拿到信息」;长流式回复
  加重过载;聊天有结构性冷启动(「我该问什么?」),逐条追问认知负担高;缓解靠结构化
  控件/chips。
  ([NN/g Less Chat, More Answer](https://www.nngroup.com/articles/less-chat-more-answer/) ·
  [NN/g AI Chat Is Not (Always) the Answer](https://www.nngroup.com/articles/ai-chat-not-the-answer/) ·
  [LukeW blank-slate](https://www.lukew.com/ff/entry.asp?2093))

---

## 3. 对抗性分析

### 3.1 论点 A:「没人会点开一个 Tab 看事件专题回顾/纵向洞察」

**成立的内核**:被动内容型洞察目的地(泛化周报、长期看板)参与度低——证据充分
(§2.1-2)。

**不成立的外推**:把两类任务混为一谈——
1. **事件专题回顾是任务型刚需**:服务「生病/短期观察」的密集介入模式(产品愿景对
   健康事件的定位)。事件期每天 check-in、看「发生了什么/关键变化/完成情况/下一步」,
   结束时给医生导出就诊摘要。用户「需要时不打开,不需要时不打开」是正常的
   *任务驱动*形态,与「没人看的内容页」不是一回事。
2. **慢病人群是反例**(§2.3):回看与就诊分享需求明确;产品第一阶段虽不主做慢病,
   但「短期不适/用药时继续用同一个伙伴」是明确场景。
3. **前提事实校正**:review 主路径已经不是 AI 周报/建议历史页(§1.2)。讨论针对的
   「没人用的 review」更多是旧 report 的记忆;先验证现状,再动刀。

### 3.2 论点 B:「统计结果放到 Record」

**支持面**(证据最强方向):
- 反思/价值兑现发生在记录当下(§2.1-1/2);内嵌短期趋势 = 最低到达成本。
- 「日期滚动记录中枢」是行业收敛形态(§2.4);仓库 Record 已有日期条 + 类别过滤 +
  时间线,骨架已经在了——真正的增量是把趋势 mock 变成真实(接后端聚合)。

**反对面**(执行假设错位):
- 「并入」≠「删除独立深度目的地」:无成功先例(§2.4);跨维/跨日模式(「本周 4 天凌晨
  2 点后睡」、睡眠↔情绪↔症状关联)在单类别折线里表达不出来,而那是纵向洞察的核心
  价值(产品愿景场景三)。
- 稀疏记录 vs 折线图语义冲突:产品铁律「未记录≠零」;趋势必须带覆盖天数,否则误导;
  7 天折线在只记 2 天时是空壳。这要求新后端聚合契约(覆盖率/来源/日值),成本被低估
  (record README 明说趋势区块 mock 待后端 API)。
- 记录页任务是「当日全类别速记」,分析页任务是「单类别长周期探查」——同屏叠加
  「日期 × 类别 × 周月年」三层选择器会很重;7 类一行放得下,但 palette 还有
  vitals/heartRate/weight/activity,一行即溢出。

### 3.3 论点 C:「Review 换成 Assistant 页面」

**支持面**:
- 回顾需要外部触发(§2.2),「周报」的价值在「需要的那一刻」——与 Agentic 计划 P0-3/
   P1-1/P2 一致:洞察 = proactive 触达 + assistant 会话,而不是没人读的固定页。
- 慢病/就诊证据支持「按需一键生成医生可消化的报告」(§2.3)。

**反对面**(核心对抗点):
- 「把洞察唯一化为对话」在机制上输了(§2.5):可扫读的日常回顾、被动消费形成的习惯
  回路、AI 出错/拒答时的兜底,聊天都给不了;健康头部无一「删结构化 Tab 上纯聊天页」,
  而是「结构化层 + AI 叠加入口(Ask Coach / Advisor)」。
- 仓库现状:assistant 已可经今天顶栏/命令面板/快捷键进入(§1.2),把它升为第 4 个 Tab
  要处理未登录 preview、desktop shell、重复入口,牵动 `shell-tab-report` 兼容 key、
  e2e、通知深链、`action_route_mapper`;且挤占 3–5 项名额。
- 就诊摘要导出(时敏、稳定、低摩擦)放聊天 = 每次「打字→等流式→审阅」,反而更差;
  应保留结构化路径,agent 只做加速器。
- Agentic 计划 P1-3 宿主是 review 页,删 Tab 需改写计划。

### 3.4 关于 GenUI

- GenUI 正确形态 = agent 按意图生成**任务型结构化 UI**(卡片/图表/报告预览/确认
  组件);现有 `flowui_adapter` + proposal 卡已是受控 GenUI 雏形——把洞察产物本身做成
  「结构化生成组件」,而不是把「洞察页搬进聊天」。
- `product-mvp-scope.md`(2026-09-06)把开放式 GenUI 冻结;推进需显式解冻决策(连同
  后端 agent runtime 责任边界:Lucent 已定自建 LangGraph + HITL 门控,客户端不引入
  运行时——见 agentic 计划「执行注意」)。

---

## 4. 与仓库现状/已定范围的对撞(实现约束清单)

- [IA 文档]Record 禁放「周报/趋势主视图」「AI 通用聊天入口」;但该文档自述为
  「现行说明,不作最终 IA 决策」,本提案 = 重开该题。
- [Vision]「它不是要求用户主动研究的健康周报」——要砍的固定洞察页与愿景不冲突;
  冲突的是「Review 变成只有用户去问才有输出的助手」。
- [MVP scope]开放式 GenUI 冻结;周/月纵向洞察为 MVP 核心闭环。
- [Agentic 计划]P1-3 宿主为 review 页;删 Tab 需改写;P2 才是「洞察主动触达」的正确
  载体。
- [数据契约]Record 趋势/日历为静态 mock;每类别 7 天/周月年聚合需新后端契约
  (覆盖率与来源语义);倒排记录跨日期列表需范围查询/pagination 支持(现为按日查询)。
- [导航/兼容]五个 tab key、review legacy `shell-tab-report`、e2e、通知深链、
  `action_route_mapper`、未登录 preview 语义——任何 Tab 手术都牵动这些。
- [ROADMAP]User-Value Validation 引用已删除的 `research/00-市场调研/05-...`(悬空)。

---

## 5. 推荐路径

### 阶段 1:不动 Tab 结构,先做证据最支持的部分

1. **Record 增强为「记录中枢」**:在日期条 + 快捷面板下,给当前选中类别加
   **7 天迷你折线 + 覆盖天数 + 与昨日/上周对比**(先内嵌轻量形态,兑现记录当下的
   价值;Habito 证明的杠杆)。
2. **Review 内容重组**:保持第 4 Tab,把内容从「事件四段 + AI 摘要文本」调整为
   「事件专题(任务台)+ 有覆盖率标注的单维/跨维周月洞察 + 更多(就诊摘要导出)」;
   泛化 AI 长文不再堆在页面上。
3. **Assistant 组件化挂到各结构化上下文**(Agentic 计划 P1-1/P1-3 载体):在
   review/record/today 加「就此上下文问助手 / 一键生成周报 / 生成就诊报告草稿」
   入口(Ask 式叠加),输出走 proposal / 结构化报告卡。

### 阶段 2:用户价值调研 + 埋点验证后再动 IA

待验证问题与指标:
- Review Tab 的**周活跃占比与用户分层**(事件期用户 vs 日常用户)——验证「事件专题
  没人用」是否属实。
- 记录当下 mini-trend 是否提升**次日回访 / 建议采纳 / 连续记录**。
- Assistant 使用是 **pull(主动问)还是 push(proactive 触发)** 驱动;「生成周报/
  就诊报告」入口使用率。
- 若数据证明「日常纵向洞察无高价值用户群」,才考虑把 review 内容合并进 today/record
  深链、空出第 4 槽给 Assistant——**但事件专题回顾与就诊导出必须保留稳定结构化路径**
  (可在 Assistant Tab 内做成「入口卡片 + 报告工作台」,而不是只活在对话气泡里)。
- 同步把「开放式 GenUI 冻结」作为显式解冻项评估。

---

## 6. 开放问题(给用户价值调研的输入)

1. 现网 review Tab 的真实使用:事件期 vs 日常的比例、事件专题回顾的完成率/重复率。
2. 记录当下的趋势反馈是否让用户「更愿意回来记录」(行为改变,而非功能数量)。
3. 用户对「每周自动 AI 报告」的真实态度(噪音 vs 价值)——本领域公开证据空白,须自测。
4. 就诊场景:用户何时需要就诊摘要、走结构化导出还是问助手。
5. 稀疏记录下折线图是否被误读(「没记的天 = 零」)——直接关系覆盖率 UI 设计。
6. Assistant 若升级为一级入口,是否挤占其他维度的到达(横切调研归因)。

---

## 7. 局限与证据诚实声明

- 证据几乎全部来自北美/欧洲、英语、年轻与自我追踪爱好者样本;中文市场、健康事件
  期与慢病场景需单独验证。
- AI 摘要/周报接受度:公开数据多为媒体实测与厂商自报,【空白】处未补写推断。
- Apple/Fitbit/MFP 无功能级遥测;「删统计页是否无损」无直接对照实验——本验证只能
  给出「证据最一致的形态」,最终取舍须埋点/访谈决定。
- 本仓库内引用以文档与代码现状为准(2026-09-07);review 主路径已在 2026-08 从
  report 重构为事件回顾,引用旧报告叙事需先核对现状。

---

## 8. 来源清单

### 个人信息学与行为证据
- Epstein et al. 2015, A Lived Informatics Model:
  https://pmc.ncbi.nlm.nih.gov/articles/PMC12435389/
- Rooksby et al. 2014, Personal Tracking as Lived Informatics:
  https://eprints.gla.ac.uk/94944/
- Gouveia et al. 2015, Habito 野外日志:
  https://ktisis.cut.ac.cy/entities/publication/2a871b74-f7f1-4c5a-a712-2ea4e22cc5c9
- Epstein et al. 2016, Beyond Abandonment to Next Steps:
  https://pmc.ncbi.nlm.nih.gov/articles/PMC5428074/
- Krebs & Duncan 2015: https://pubmed.ncbi.nlm.nih.gov/26537656/
- Baumel et al. 2019(93 款 App 留存): https://pubmed.ncbi.nlm.nih.gov/31573916/
- Kersten-van Dijk et al. 2017 综述: https://doi.org/10.1080/07370024.2016.1276456
- Baumer 2015, Reflective Informatics: https://ericbaumer.com/2015/06/08/reflective-informatics-conceptual-dimensions-for-designing-technologies-of-reflection/
- Bentvelzen et al. 2023: https://research.chalmers.se/en/publication/534349
- Morris et al. 2010, Mobile Therapy: https://pmc.ncbi.nlm.nih.gov/articles/PMC2885784/
- Nahum-Shani et al. 2018, JITAI: https://pubmed.ncbi.nlm.nih.gov/27663578/
- 论坛信号(传闻级): https://community.myfitnesspal.com/en/discussion/comment/48805849 ·
  https://community.fitbit.com/t5/Product-Feedback/Make-all-data-graphs-axis-to-display-last-7-30-90-and-365-days/idc-p/5780203

### AI 摘要接受度
- The Verge, AI fitness summaries 实测:
  https://www.theverge.com/fitness-trackers/694140/ai-summaries-fitness-apps-strava-oura-whoop-wearables

### 竞品 IA 与规范
- Oura 官方使用说明: https://support.ouraring.com/hc/en-us/articles/360058599753-How-to-Use-the-Oura-App
- Fitbit 新版(Trusted Reviews): https://www.trustedreviews.com/news/fitbit-health-coach-app
- Garmin Connect 改版新闻稿:
  https://www.garmin.com/en-US/newsroom/press-release/wearables-health/garmin-connect-gets-a-new-look-simplified-design-provides-a-more-customized-experience/
- Samsung Health 官方手册: https://doc.samsungmobile.com/SM-A236U1/025289221027/zho-cn.html
- Apple HIG Tab bars: https://developer.apple.com/design/human-interface-guidelines/tab-bars
- Lazyweb, AI assistant screens 渗透率:
  https://www.lazyweb.com/research/how-fast-did-ai-assistant-screens-spread-in-apps

### GenUI / Agentic
- Anthropic, Trustworthy agents in practice:
  https://www.anthropic.com/research/trustworthy-agents
- Anthropic, Building effective agents:
  https://www.anthropic.com/engineering/building-effective-agents
- InfoWorld, Generative UI: https://www.infoworld.com/article/4110010/generative-ui-the-ai-agent-is-the-front-end.html
- NN/g, Less Chat, More Answer: https://www.nngroup.com/articles/less-chat-more-answer/
- NN/g, AI Chat Is Not (Always) the Answer: https://www.nngroup.com/articles/ai-chat-not-the-answer/
- NN/g, GenUI Buttons and Checkboxes: https://www.nngroup.com/articles/genui-buttons-and-checkboxes/
- LukeW, Usable Chat Interfaces: https://www.lukew.com/ff/entry.asp?2093
