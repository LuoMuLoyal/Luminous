# Report Contracts Plan

Last updated: 2026-06-12

## Goal

把当前 `Report` 从前端静态 mock 面板推进到真实合同驱动的第一阶段可用状态，为后续周报、月报、AI 总结和导出能力打基础。

第一阶段目标不是一次做完“完整智能报告”，而是先建立稳定的：

- Lucent 报告聚合合同
- Luminous 报告远端数据流
- 真实趋势/指标/发现的最小闭环

## Why Now

当前 `Report` 仍然完全依赖 `mock_report_repository.dart`，这是移动端五大 tab 中最明显的假能力。

如果继续跳过它直接做 AI：

- AI 会建立在假的汇总层之上
- 周报/月报会重复做一次聚合逻辑
- 导出、分享、隐私边界没有真实数据基础

所以 `Report` 应该先于正式 AI 实现。

## Scope Boundary

### In Scope

- 一个真实 Lucent 报告读取端点
- 一个明确的报告聚合时间范围，先做 `last_7_days`
- 三个真实核心指标：
  - medication adherence
  - water intake
  - sleep
- 最小趋势数据合同
- 最小 findings / pattern cards 规则化输出
- Luminous 用真实 repository 替换 mock repository
- 保留当前 UI 外形，优先替换数据来源而不是重做页面设计

### Out Of Scope

- AI 生成周报文案
- PDF/打印/真实导出文件
- 外部分享链接
- 复杂月报
- 图片/附件进入报告
- 自由配置图表维度
- 多周期对比（如 month vs previous month）

## Current Gaps

### Frontend

- `lib/features/report/data/repositories/mock_report_repository.dart` 仍然返回硬编码面板
- `ReportDashboard` 实体依赖大量 `ReportCopyKey`，不适合直接承接远端动态数据
- 当前 UI 文案和数值耦合，真实合同接入前需要先拆“动态值”和“静态标签”

### Backend

- Lucent 当前没有 `report` 模块
- 没有真实聚合：
  - 睡眠趋势
  - 饮水趋势
  - 用药完成率趋势
- 没有报告 findings / patterns 的规则化输出层
- 没有报告导出状态或快照模型

### Product / Data Boundary

- 睡眠合同还没稳定，这会限制 Report Phase 1 的“睡眠”真实性
- 因此 Report Phase 1 需要允许：
  - sleep 指标缺失时返回 `insufficient_data`
  - UI 展示“数据不足”而不是伪造数值

## Contract Direction

Recommended endpoint:

```text
GET /api/v1/user/reports/dashboard?range=last_7_days
```

Phase 1 only supports:

```text
range=last_7_days
```

Recommended response direction:

```json
{
  "code": 0,
  "message": "",
  "data": {
    "range": "last_7_days",
    "startDate": "2026-06-06",
    "endDate": "2026-06-12",
    "generatedAt": "2026-06-12T10:00:00.000Z",
    "score": {
      "value": 78,
      "maxValue": 100,
      "status": "stable",
      "summary": "本周记录较完整，用药保持较稳，饮水仍有提升空间。"
    },
    "metrics": [
      {
        "kind": "medication",
        "value": "93",
        "unit": "%",
        "status": "good",
        "delta": "9%",
        "direction": "up",
        "sparkline": [80, 88, 92, 89, 93, 88, 93]
      }
    ],
    "trends": [
      {
        "kind": "water",
        "unit": "L",
        "currentValue": "1.6",
        "values": [1.5, 1.9, 1.6, 1.9, 1.6, 1.6, 1.6]
      }
    ],
    "findings": [
      {
        "kind": "hydration",
        "title": "饮水仍偏少",
        "body": "近 7 天中有 4 天未达到目标饮水量。"
      }
    ],
    "patterns": [
      {
        "kind": "medication",
        "title": "用药依从性稳定",
        "status": "good",
        "body": "近 7 天按计划完成率较高。",
        "sparkline": [48, 50, 47, 52, 49, 51, 58]
      }
    ],
    "aiSummaryEnabled": false
  }
}
```

## Backend Design

Recommended Lucent module:

```text
src/modules/reports/
```

Suggested files:

```text
reports.module.ts
reports.controller.ts
reports.service.ts
reports-aggregation.service.ts
dto/report-dashboard-response.dto.ts
dto/report-metric.dto.ts
dto/report-trend.dto.ts
dto/report-finding.dto.ts
dto/report-pattern.dto.ts
```

### Aggregation Rules - Phase 1

#### Medication

- based on reminder schedule + dose logs
- if denominator is unavailable, mark as insufficient instead of fabricating %

#### Water

- based on daily records of water type
- aggregate per day
- current metric uses average daily intake over the selected range

#### Sleep

- only use real persisted sleep data when backend contract exists
- before sleep contract is ready:
  - return a stable “insufficient_data” status
  - do not synthesize placeholder sleep numbers

### Findings / Patterns

Phase 1 should be rule-derived, not AI-generated.

Examples:

- water below target on >= 4 days -> hydration finding
- medication completion >= threshold -> medication stability finding
- sleep insufficient-data -> sleep watch-state pattern

This keeps Report usable before AI and gives AI a stable upstream later.

## Frontend Design

### Data Layer

Replace:

```text
mock_report_repository.dart
```

with:

```text
report_remote_data_source.dart
lucent_report_repository.dart
```

### Entity Refactor

Current `ReportDashboard` is too localization-key-heavy for remote data.

Phase 1 should refactor it so:

- remote contract carries dynamic title/body/value/status data
- UI still owns purely presentational icon/color mapping
- localization remains for stable UI chrome, not for fake data sentences

This is the key frontend prerequisite before real Report can land cleanly.

### UI Strategy

Do not redesign the page.

Keep the current sections:

- score hero
- metrics
- trends
- findings
- summary area
- export area
- patterns

But change behavior:

- report fetches real remote dashboard data
- if some sections have insufficient data, show explicit empty/insufficient states
- export actions remain disabled/toast-only until export contracts exist

## Verification

### Lucent

- unit test report aggregation rules
- controller test authenticated success
- controller test signed-out unauthorized
- controller test unsupported range rejected
- `pnpm lint:check`
- `pnpm build`
- `pnpm test:ci`
- `pnpm export:openapi`

### Luminous

- repository/provider tests for remote report loading
- widget test for insufficient-data states
- `flutter analyze`
- `flutter test`

### Manual

- signed-in mobile app shows real report values
- signed-out state does not hit protected report API
- when sleep data is absent, report shows explicit missing-data state instead of fake sleep metric

## Milestones

### Phase 1 - Contract shape

- finalize Lucent report endpoint and response DTO shape
- refactor Luminous report entity away from hardcoded copy-key data model

### Phase 2 - Backend aggregation

- implement medication + water real aggregates
- implement sleep insufficient-data fallback
- implement rule-based findings/patterns

### Phase 3 - Frontend wiring

- replace mock repository with remote repository
- wire loading / error / insufficient-data states

### Phase 4 - Verification and docs

- export openapi
- regenerate Flutter client
- update `Current_State.md`, `Next_Plan.md`, and migration log

## After This

Only after Report contracts are real should the next major intelligence layer proceed:

1. Today AI analysis
2. weekly/monthly AI summary
3. natural language to candidate records
4. screenshot to candidate structured input
