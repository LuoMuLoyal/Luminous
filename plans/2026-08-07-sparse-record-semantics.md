# Sparse Record Semantics Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (- [ ]) syntax for tracking.

**Goal:** 让服药、饮水、睡眠和平台导入在 Today、建议、回顾与导出之间共享同一数据语义，并把不完整记录明确表示为 unknown 而不是零或失败。

**Architecture:** Lucent 负责标准化存储与 coverage 计算：服药以计划槽位为单位、饮水以 ml 为规范单位、睡眠以可重叠检查的 episode 表示。所有聚合 DTO 同时返回 value、coverage 和 source。Luminous 快速输入保持低负担，domain mapper 不再从记录数量推断健康值；健康平台导入在不能可靠执行时明确禁用自动同步，并用稳定指纹保留同日多条记录。

**Tech Stack:** NestJS、Prisma、OpenAPI、Jest、Flutter、Riverpod、Freezed、Drift/health adapter、Flutter tests。

---

**Start gate:** 只有[总计划](2026-08-07-product-loop-program.md)中 Health Event Contract 的 API seam 已冻结，才执行本文件。

## Shared Vocabulary

- `unknown`: 没有足够信息判断，不能参与分母或触发不足结论。
- `observedZero`: 用户明确确认值为零；与没有记录不同。
- `coverage`: `sufficient`、`partial`、`none`，每一指标独立计算。
- `source`: `manual`、`health_platform`、`reminder_plan`、`derived`；UI 必须可解释来源。
- `doseSlot`: `reminderId + scheduledFor + scheduledTime`；没有 reminder 的临时服药使用 dose-log ID 自身作为独立槽位。
- `sleepEpisode`: 起止时间、类型 `nightSleep|nap`、可选质量；不得仅以日期为唯一身份。
