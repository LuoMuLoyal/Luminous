# Proactive Suggestion Runtime Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (- [ ]) syntax for tracking.

**Goal:** 让相关健康事实写入后主动触发有界重算，Today 打开时只读取已生成结果，并修复会让建议资格判断失真的基线、漏服时间和分析陈旧状态。

**Architecture:** Lucent 以领域事件为输入，把同一用户/自然日的突发写入合并为 BullMQ recompute job；worker 执行确定性采集、规则、仲裁与持久化，LLM 文案继续走独立低优先级队列。GET 返回 `ready/stale/pending/failed/empty` 的物化结果，不触发 pipeline。Today Analysis 使用同一失效版本和异步生成策略。Luminous 根据状态刷新，不靠进入页面触发首次生成。

**Tech Stack:** NestJS EventEmitter、BullMQ、Redis、Prisma、Jest fake timers、OpenAPI、Flutter/Riverpod、Flutter tests。

---

**Start gate:** 只有 Health Event Contract 已完成跨前后端合同、真实 PostgreSQL acceptance 和文档 checkpoint，才执行本文件。

## Runtime Invariants

- 记录写入事务成功后才发领域事件；监听器失败不得回滚源记录。
- 同一 `userId + localDate` 在 debounce window 内最多一个待执行 job，重复事件只更新原因集合。
- 规则和仲裁不调用 LLM；建议主卡先使用模板文案落库，LLM 改写异步补全。
- GET 不产生建议、不更新 baseline、不调用 LLM，只读取物化结果并返回状态。
- 过去日期的编辑只重算受影响日期和依赖窗口，不无界重放全部历史。
- `unconfirmed` 不是 `missed`；只有存在计划槽位、已超过宽限期且产品规则明确时才可生成漏服候选。
