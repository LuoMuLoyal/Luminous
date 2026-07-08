# Luminous Mobile Tab UI Refresh Plan

## 目标

- 收窄 `Today / Record / Medicine / Report / Mine` 五个底部 Tab 的信息密度。
- 统一空状态、失败状态、未登录状态、数据不足状态的表达方式，避免一个页面同时暴露多个主状态。
- 把每个页面的首屏都收敛到一个明确主任务，减少“白卡片堆叠但没有主线”的问题。

## 前提与假设

- 本方案只覆盖移动端五个 Tab 根页，不包含子流程详情页、设置页、桌面侧边栏和营销站。
- `Mine` 页当前出现 `You are not signed in` 与 `Guest / Student / 2 medicines` 并存，是 **mock 数据前提**，当前不作为逻辑错误处理。
- 现有技术栈、Forui 主题族、GoRouter 路由结构保持不变；本轮只做信息架构和组件层级调整，不引入新依赖。
- 已完成的 Recent fixes 继续保留，尤其是 Today / Record / Report 的近期修复，不回退。

## 受影响文件

- `lib/features/today/presentation/pages/today_page.dart`
- `lib/features/record/presentation/pages/record_page.dart`
- `lib/features/medicine/presentation/pages/medicine_page.dart`
- `lib/features/report/presentation/pages/report_page.dart`
- `lib/features/mine/presentation/pages/mine_page.dart`
- `test/today/`
- `test/record/record_page_test.dart`
- `test/medicine/medicine_page_test.dart`
- `test/report/report_page_test.dart`
- `test/mine/mine_page_test.dart`
- `docs/00-current/Current_State.md`
- `docs/03-logs/migration-log/2026-07-07.md`

## 跨页面统一规则

### 1. 首屏只能有一个主任务

- 每个根页首屏只允许一个主 CTA 区块获得最高视觉权重。
- 其它区块降为次级信息，不与主任务抢同级标题、同级按钮样式、同级边框强调。

### 2. 状态机要单层表达

- 根页优先级统一为：
  1. `fatal error`
  2. `not signed in`
  3. `empty / insufficient data`
  4. `ready`
- 同一屏不再同时出现 “未登录 + 空数据 + 失败 + 不可用卡片 + 可点击导出” 这类混杂状态。
- `--`、`--:--`、`-- h` 这类裸占位统一替换为可理解文案，例如 `No data yet`、`Add records to unlock`、`Not set`。

### 3. 卡片层级统一

- 一级卡：主任务 / 主摘要，只保留 1 个。
- 二级卡：进度、次要入口、辅助说明。
- 三级内容：法律声明、说明性 AI、帮助型建议，尽量下沉到第二屏后半段。

### 4. CTA 统一

- 主 CTA 使用强调按钮，只保留一个。
- 次级动作使用 outline / text 风格。
- “Retry / Refresh / Sign in / Generate / Manage” 不再在同一首屏内同时出现多个强调色按钮。

### 5. 文案统一

- 不暴露实现机制，不解释 backend / mock / static layout。
- 所有空态都必须同时提供：
  - 当前为什么看不到内容
  - 下一步能做什么

## 页面方案

## Record

### 问题

- 顶部自然语言输入、AI、语音、拍照同时争夺入口权重，认知成本偏高。
- Quick record 网格权重过于平均，高频项没有突出。
- 底部 `Natural language` 浮动按钮压在 tip 卡上，层级关系不清。

### 改法

- 顶部输入条改为单主入口模型：
  - 文本自然语言记录为主入口
  - 语音、拍照保留为 trailing 辅助动作
  - `AI` 标签改为更弱的辅助标识，避免像单独 CTA
- Quick record 调整为“高频优先”：
  - 第一排固定 `Symptom / Medication / Water`
  - 第二排 `Meal / Sleep / Mood`
  - `Note` 继续保留全宽，但视觉降级为补充动作
- 当前筛选状态继续保留，但 chip 必须保证完整可读，不再截断。
- `Tip` 与 `Natural language` 合并成一个辅助区，取消遮挡式叠放。

### 预期可观察结果

- 用户能在首屏快速判断“直接记一条”与“自然语言记录”的区别。
- 快速记录区在小屏下不再抢占过高首屏空间。
- filter chip 在常见 360px~430px 宽度下无截断。

### 验证

- Widget test：快速入口排序、filter 激活、自然语言入口显隐。
- 小屏人工检查：`360x800`、`393x852` 下无重叠、无文字截断。

## Medicine

### 问题

- 无药物时，`My drugbox`、`Medication records`、安全提示会重复表达“还没有药物”，空态冗余。
- `Safe guard` 顶部概念露出较强，但与首屏主任务关系不够明确。

### 改法

- 无药物场景改为单一空态主线：
  1. `No medicines yet`
  2. 主 CTA：`Add your first medication`
  3. 次说明：添加后可以启用提醒、记录与安全检查
- `Medication actions` 保留，但次序调整为：
  - `Add med`
  - `Reminder setup`
  - `Log dose`
  - `Risk check`
- `Medication records` 在无药物时只保留轻量说明，不再重复大面积空卡。
- `Safe guard` 要么改为可进入的工作区入口，要么降级成说明性 badge；不要停在中间态。

### 预期可观察结果

- 无药物用户进入后不会连续看到两到三块重复空态。
- “先添加药物”成为清晰的单一路径。

### 验证

- Widget test：空药盒 / 已有药物 / 安全检查加载失败。
- 人工检查：空态首屏只出现一个主 CTA。

## Report

### 问题

- 当前是五页里状态最乱的一页：未登录、数据不足、不可导出、空图表、Unavailable 指标同时出现。
- 页面虽然信息多，但没有形成“为什么现在看不到报告、要怎么解锁”的清晰路径。

### 改法

- 把首屏重构为两段：
  1. `Report readiness`：当前是否可生成、还差哪些数据、是否需要登录
  2. `Unlock report`：登录 / 继续记录 / 生成报告的下一步动作
- 当未登录时，不再渲染完整报告骨架和大量 unavailable 卡片，只保留一套门控视图。
- 当已登录但数据不足时，展示“还差什么”而不是一堆 `--` 指标。
- 图表、key findings、export summary 仅在达到最小可用条件后显示；否则整体折叠或替换为简洁占位。

### 预期可观察结果

- 用户能分清楚“是没登录”还是“数据不够”，不会误判为页面坏了。
- 不满足条件时，报告页仍然清楚，但不会显得像半成品后台面板。

### 验证

- Widget test：未登录 / 已登录但不足 / 足够数据 / 导出受限。
- 人工检查：每种状态只出现一套主解释文案和一个主 CTA。

## Mine

### 问题

- 当前结构总体稳定，但首屏的登录提示卡、用户摘要卡、三张健康摘要卡在视觉上较平均，主次关系偏弱。
- 即使按 mock 数据前提看，页面首屏也略像“多个独立区块拼接”，缺少一条完整叙事线。

### 改法

- 保持 mock 数据前提不变，但重新梳理首屏顺序：
  1. 登录提示或同步价值卡
  2. Profile snapshot
  3. Health profile checklist
- 三张健康摘要卡改为“状态摘要条”而不是同权大卡，降低对个人档案主线的打断。
- `Health profile` 保持为主要编辑入口，并把 `Needs info` 这类风险提醒集中到档案条目里。
- 隐私政策卡下沉到首屏后半段，不与登录 / 档案完善抢注意力。

### 预期可观察结果

- 用户能先理解“我是谁 / 是否已同步”，再理解“我还缺什么资料”。
- 首屏重点从“很多块卡片”变成“账号状态 + 档案完善”。

### 验证

- Widget test：signed-out mock / signed-in / 档案缺失项存在。
- 人工检查：首屏主阅读顺序清晰，不需要来回扫视。

## 实施顺序

1. `Today`
2. `Report`
3. `Medicine`
4. `Record`
5. `Mine`

原因：

- `Today` 和 `Report` 的状态混杂最严重，先改收益最大。
- `Medicine` 空态收敛后，能稳定“用药安全入口”的主叙事。
- `Record` 和 `Mine` 主要是首屏层级与组件权重调整，风险相对更低。

## 验收标准

- 五个根页都能用一句话描述首屏主任务。
- 任一根页的首屏强调按钮不超过 1 个，最多 2 个。
- 不再出现标题重叠、chip 截断、空态重复表达。
- 未登录、空数据、失败、可用四种状态的优先级在五页中保持一致。
- 新增或更新的 widget test 能覆盖每页至少 1 个关键状态切换。

## 非目标

- 不在本轮引入全新视觉主题或品牌重绘。
- 不调整底部导航信息架构。
- 不扩展新的 AI 能力、导出能力或药品识别能力。
- 不把 mock 数据替换为真实后端流。

## 风险

- `ReportPage` 当前实现可能已经把多种状态揉在一个大 build 中，拆分门控视图时可能顺带触发结构重构。
- `TodayPage` 和 `RecordPage` 若 section 组件边界不清，可能需要先提取局部 widget 再改顺序。
- `MinePage` 在 mock / signed-out / local snapshot 三种语义间仍可能需要产品文案定稿，当前方案先按 UI 层级优化处理。
