# Product Loop Program Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (- [ ]) syntax for tracking.

**Goal:** 把 Luminous 从“通用记录 + 周/月报告”迁移为“健康事件期 + 稀疏记录 + 主动建议 + 事件回顾”的可验证产品闭环。

**Architecture:** 这是跨 `Lucent` 与 `Luminous` 的总控计划。所有写入先形成统一健康事件和稀疏数据合同，领域事件驱动服务端有界重算，Flutter 只读取已有结果并呈现陈旧/失败状态；第五个 Tab 保留现有 `/report` 路由兼容，但用户任务和读模型迁为“回顾”。桌面端与完整认证 Web 代码保留且冻结。

**Tech Stack:** NestJS 11、Prisma 7、PostgreSQL、Redis、EventEmitter、BullMQ、OpenAPI、Flutter、Riverpod、GoRouter、Freezed、Mockito/Jest、Flutter test。

---

## Program Pre-conditions

- [ ] 在 `Luminous/docs/00-current/Next_Plan.md` 把当前阶段切换到本计划。
- [ ] 分别运行 `git -C Luminous status --short` 与 `git -C Lucent status --short`，把与本计划无关的用户改动记录在实施日志中并保持不动。
- [ ] 读取根 `AGENTS.md`、`Luminous/AGENTS.md`、`Lucent/AGENTS.md` 以及 [ADR-0011](../docs/02-reference/adr/0011-event-led-sparse-record-product-loop.md)。
- [ ] 为本计划建立一个跨仓库 feature 分支；不在默认分支直接实施。

## Workstream Order

| Order | Plan | Outcome | Depends on |
| --- | --- | --- | --- |
| 1 | [Health Event Contract](2026-08-07-health-event-contract.md) | 可确认开始/结束、每日结果和关联记录的健康事件合同 | — |
| 2 | [Proactive Suggestion Runtime](2026-08-07-proactive-suggestion-runtime.md) | 写事件触发有界重算，GET 只读现有结果 | Workstream 1 |
| 3 | [Sparse Record Semantics](2026-08-07-sparse-record-semantics.md) | 服药槽位、饮水 ml、睡眠片段和 unknown 语义统一 | Workstream 1；与 2 的接口冻结后可并行 |
| 4 | [Review Experience](2026-08-07-review-experience.md) | 第五 Tab 成为事件优先“回顾”，取消综合评分和整页锁定 | Workstreams 1–3 |
| 5 | [Visit Summary and Product Measurement](2026-08-07-visit-summary-and-product-measurement.md) | 可选就诊摘要归位，闭环行为可被隐私克制地测量 | Workstream 4 |

## Cross-Workstream Invariants

- [ ] 所有 API 合同变更均先在 Lucent controller/DTO 中实现，运行 `pnpm export:openapi`，再在 Luminous 运行 `dart run scripts/bootstrap_generated_sources.dart`；不手写生成客户端。
- [ ] `missing`、`zero`、`unconfirmed`、`skipped`、`missed` 在数据库、DTO、Flutter domain entity 和 UI 文案中保持一一对应。
- [ ] 健康事件只能由用户确认开始或结束；系统建议不得直接写入疾病状态。
- [ ] Apple Health 与 Health Connect 只在实际验证过的设备、地区和开发者权限范围内启用；不得成为国内 Android 主流程的前置条件。
- [ ] 桌面端和完整认证 Web 不做功能对等；新增 UI 只保证手机端。已有代码不删除。
- [ ] 饮食、心情、普通笔记保留记录和回看，但不进入首阶段主动建议资格判断。
- [ ] 不引入跨维度综合健康评分，不把缺失数据补成零，不根据不完整记录作因果诊断。
- [ ] 每个 workstream 完成后更新两个仓库各自的 current-state、迁移日志和仍存在的任务；已完成条目按仓库规则直接删除。

## Program Checkpoints

### Checkpoint A — Contract Ready

- [ ] Health Event API contract、Prisma migration、Flutter repository 和事件开始/结束 UI 全部通过测试。
- [ ] OpenAPI diff 经人工检查，只包含计划中的新增/兼容变更。
- [ ] 用一个真实流程验证：开始“感冒观察” → 关联症状与短期药物 → 每日一次结果 → 用户确认结束。

### Checkpoint B — Proactive Runtime Ready

- [ ] 写入相关记录后，无需打开 Today 即可观察到服务端重算任务完成。
- [ ] 同一用户/日期的突发连续写入只形成一个有界重算窗口。
- [ ] Today GET 不调用规则生成或 LLM；无结果、陈旧、失败和正常结果均有明确合同。

### Checkpoint C — Semantics Ready

- [ ] 同一药品一天两次服用按两个槽位呈现，任一槽位确认不影响另一个。
- [ ] 零饮水、无饮水记录和覆盖不足是三种不同状态。
- [ ] 夜间睡眠与午睡作为独立片段保存和回顾，不被同日去重覆盖。

### Checkpoint D — Review Ready

- [ ] 第五 Tab 对用户显示“回顾”，现有 `/report` 深链仍可打开。
- [ ] 任一维度缺失不会锁住整个页面；事件事实、变化、完成情况和下一步仍可用。
- [ ] 通用分数、默认导出卡、默认医生分享和强制 7/30 天主视图不再占据首屏。

### Checkpoint E — Product Signal Ready

- [ ] 事件开始/结束、结果确认、建议曝光/处理、回顾打开、导出/分享动作均只在成功后记录。
- [ ] 事件属性不包含症状原文、药名、自由文本备注或其他健康内容。
- [ ] 就诊摘要使用真实范围、可隐藏字段和正确分享 URL；访问与撤销可以被观察。

## Program Verification

- [ ] 在 `Lucent` 运行 `pnpm lint:check`、`pnpm typecheck`、`pnpm test`、`pnpm build`、`pnpm export:openapi`、`pnpm docs:check`、`pnpm docs:verify`、`pnpm docs:links`。
- [ ] 在 `Luminous` 运行 `dart run scripts/bootstrap_generated_sources.dart`、`flutter analyze`、`flutter test`、`dart run scripts/run_daily_checks.dart`、`dart run scripts/check_doc_coverage.dart --warning-only`、`dart run scripts/check_doc_links.dart`。
- [ ] 在 Android 和 iOS 真机或模拟器各验证一次 Checkpoint A–E 的主路径；健康平台导入只在具备真实权限的设备上标记为已验证。
- [ ] 检查 `git -C Lucent diff --check` 和 `git -C Luminous diff --check` 无空白错误，两个仓库的 diff 均不含冻结桌面/Web 的机会主义重构。
- [ ] 更新 `Luminous/ROADMAP.md`、两个仓库的 current-state 与迁移日志；删除已经完成的计划条目，不保留完成标记。

## Rollout and Stop Conditions

- [ ] 首先只对内部测试账号启用健康事件、主动重算和回顾入口，保留旧 Report 读路径作为短期回退。
- [ ] 若重算任务持续失败、规则将 unknown 判为异常、或事件数据无法可靠关联，关闭新入口并保留数据，不继续扩大灰度。
- [ ] 若回顾打开率低，不立刻恢复通用报告；先检查事件是否成功开始/结束、建议是否在正确时机到达、结果确认是否过重。
- [ ] 完成内部验证后再提高 feature flag 覆盖率；不把桌面/Web 纳入放量门槛。
