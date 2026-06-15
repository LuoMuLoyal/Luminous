# Goal

把当前已经能跑通的五 tab 基线收口成一个可信 MVP，优先补“用药安全可信入口”和“范围一致性”，而不是继续扩 AI 花活或补不关键的展示层。

## MVP Done Definition

这次按两个口径看：

1. **答辩/演示型 MVP**
   - 手机端五 tab 主闭环都能稳定演示。
   - 没有明显假按钮、假导出、假提醒历史在冒充真能力。
   - Today / Report AI 只在已授权且有数据时工作，失败路径稳定。
   - 至少一条真实报告导出链路可用。

2. **小范围试用型 MVP**
   - 除了上面的演示闭环，还要让“用药安全”足够可信。
   - 高风险提示必须来自固定规则、已审校来源或明确覆盖边界。
   - 提醒、导出、服务连接这些能力不能给出超出真实能力的承诺。

## Current Judgment

这是判断，不是精确测量：

- 按答辩/演示型 MVP 看，当前大约已经完成 `80%~85%`。
- 按小范围试用型 MVP 看，当前更接近 `65%~75%`。

差距不在“有没有五个 tab”，而在“可信入口是否够硬”和“剩余半真半假的表面是否收口”。

## Status Snapshot

- Slice 1 (Export/Reminder) ✅ 已完成：
  - 导出承诺已经收窄到真实可用的 `hospital + pdf + last_7_days`
  - reminder 的本地能力边界已经比之前清楚，不再把 worker / push / SMS 说成已交付 MVP
  - SMS 显式标注"未开通"
- Slice 2 (Medicine Safety) ✅ 已完成 (2026-06-15)：
  - 过敏匹配：从子串 → 成分 token 精确匹配 + 8 组中英双向映射
  - 特殊人群：年龄门控（儿科 <18 / 老年 >65），无警告时标记覆盖边界
  - 跨源重复：DrugBank 药品通过 `synonyms` 参与重复检测
  - 三展示面统一：`coverageSummary` 字段在风险页/工作区卡片/预检弹层一致展示
- Slice 3 (Red-Flag Rules) ⏸️ deferred：
  - 当前 decision：移出 MVP 关键路径
  - 后续若重启这条线，优先走 agent + 地图/附近资源发现，而不是把“学校官网完整度”当成前置条件
  - 现阶段只要求现有支持资源入口不冒充真能力
- Slice 4 (Monthly/Print Export) ✅ 已完成：
  - `monthly + pdf + last_30_days` 已接通真实 Lucent 导出请求
  - `print + pdf + last_7_days` 已接通真实 Lucent 导出请求
  - PDF 导出补了基础自动分页，避免月报内容直接写出单页底部
- 当前默认下一步：
  - 如果演示/测试发现 Slice 2 缺口：优先回补
  - 否则进入 MVP 收口验证：日常检查、全链路 lane、演示脚本和边界文案统一

## What Is Already Good Enough

- Auth、五 tab 主骨架、Record 主录入闭环、Today/Report AI 流式总结、Mine 基础设置、一个真实的 `hospital + pdf + last_7_days` 导出链路已经在位。
- Auth、五 tab 主骨架、Record 主录入闭环、Today/Report AI 流式总结、Mine 基础设置、三条真实 PDF 导出链路（`hospital` / `monthly` / `print`）已经在位。
- Lucent + Luminous 已经有四条真实 Android 模拟器全链路 lane，可以守住 auth / record / sleep / today-report 的主线稳定性。
- 现在不需要再做一轮大重构，也不需要把系统重新讲成“从零到一”。

## Execution Slices

下面这些 slice 是给后续开发直接落任务用的，不再保留“一个大方向里什么都能做”的模糊空间。

### Slice 1. Reminder And Export Scope Closure

目标：

- 先清掉还会制造错误承诺的表面能力。

只做：

- Reminder 相关页面、文案、状态里，把本地提醒 / worker history / push / SMS 的边界写清楚。
- Report export 继续只承诺 `hospital + pdf + last_7_days`。
- 文档、UI、合同说法一致。

不做：

- reminder worker
- push / SMS 真链路

成功信号：

- 用户看不到“像已开通但实际上没落地”的入口。

验证：

- Luminous 页面状态测试
- Lucent reminder/export contract sanity check

### Slice 2. Medicine Safety Rule Unification

目标：

- 先把已经存在的安全检查逻辑统一成一个更可信的最小规则边界。

只做：

- 统一以下场景的结果模型：
  - allergy
  - pregnancy / lactation / special-group
  - duplicate ingredient
  - missing-source / unknown / uncovered
- 让以下三个入口遵守同一套覆盖边界：
  - risk-check page
  - add-before-save precheck
  - workspace safety cards
- 明确输出：
  - 已覆盖
  - 未覆盖
  - 信息不足

不做：

- 全量跨来源归一化
- 未审校 interaction 扩展
- OCR / barcode / photo 识别

成功信号：

- 至少一条“新增药物 -> reviewed warning 或 explicit unknown”的路径稳定可演示。

验证：

- Lucent medicine risk-check 相关 tests
- Luminous medicine risk page / precheck / provider tests
- 本地演示路径验证

### Slice 3. Minimum Red-Flag Rules

目标：

- 落地最小红旗规则闭环，但坚持只用固定规则，不让 AI 自由分诊。

只做：

- 3 到 5 条固定红旗规则
- 审校过的固定 safety copy
- 真实 campus clinic / pharmacist / emergency resource 入口
- Today / Medicine / Mine 至少一个入口展示命中后的下一步动作

不做：

- 自由文本医疗判断
- AI 驱动分诊等级
- 大而全规则库

成功信号：

- 命中红旗时只出现规则驱动提示和线下资源，不出现看起来像医疗建议生成的内容。

验证：

- Lucent rule tests
- Luminous page-state tests
- 一条手动演示场景

### Slice 4. Optional Monthly / Print Export

这不是默认下一步，只在前面三块已经收住，而且 Lucent 真有明确合同/文件时再做。

只做：

- `monthly` / `print` 的真实合同、真实文件、真实 UI 状态

不做：

- 宽泛的“导出生态”
- 分享链接体系
- docx / 多模板扩张

### Slice 5. Web Report Preview Decision

这是决策项，不是默认开发项。

当前事实：

- `Luminous-site` 是竞赛/展示官网，不是登录后的真实报告预览页。

结论：

- 如果 MVP 只面向移动端演示和答辩，Web 继续保持展示站即可。
- 只有当你明确把“真实 Web 报告预览”写进 MVP 承诺时，才为它单独开一个 slice。

## Recommended Order

1. Slice 1: Reminder And Export Scope Closure
2. Slice 2: Medicine Safety Rule Unification
3. MVP closeout validation and demo hardening
4. Slice 3 only after MVP if support-discovery work is restarted
5. Slice 5 only if MVP promise changes

## What Should Stay In Maintenance Mode

- Today AI streaming
- Report AI streaming
- NLP candidate intake
- Mine support-resource polish

这些现在不是零价值，但也不是当前最缺的价值。除非稳定性回归，否则不要再把时间投到“AI 更顺一点”这种次级优化上。

## Observable Done State

- 用药安全不再只是窄覆盖演示，而是一个可解释、边界清楚的 MVP 入口。
- Report/Reminder 剩余入口不再制造错误承诺。
- `Next_Plan.md`、`TODO.md`、当前 UI 和 Lucent 合同对 MVP 说法一致。

## Out Of Scope For This Plan

- OCR / 条码 / 截图 / 处方识别
- 语音输入
- 全量跨来源药物归一化
- 未审校相互作用扩展
- 真正的分享链接生态
- FCM / APNs / SMS 全量通知体系
- 桌面端工作流
