# Luminous Plans

Use this directory for active, repo-local execution plans that are too detailed for
`docs/TODO.md`.

## What Goes Here

- multi-step implementation plans
- review/handoff checklists for a specific Luminous task
- temporary task docs that are still actively driving work

## What Does Not Go Here

- current product facts: no narrative docs — assert in tests, constrain in feature READMEs
- next work ordering for the repo as a whole: put that in `docs/TODO.md`
- historical change logs: put those in `docs/logs/migration-log/YYYY-MM-DD.md`
- completed plans that no longer drive work

## Naming

Use task-specific names such as:

```text
YYYY-MM-DD-short-task-name.md
```

## Lifecycle

1. Create or update the plan here while the task is active.
2. Execute the task and verify it.
3. Move stable decisions and outcomes into the owning docs.
4. Delete the plan file once it is no longer the active source of work.

## Current Plans

> 更新于 2026-10-18。每份计划的状态以文件自身头部的状态段为准；此处只列当前仍在驱动工作、
> 或已裁决暂缓但保留触发条件的计划。已执行完毕的计划按约定直接删除（文件已删），
> 历史记录见当日迁移日志。

| 计划 | 状态 | 备注 |
| --- | --- | --- |
| [`2026-10-18-assistant-chat-ui-migration.md`](2026-10-18-assistant-chat-ui-migration.md) | P0 已过（GO），进行中 | `flow_ui` → `flutter_gen_ai_chat_ui` 直接替换；P0 spike 已证「两套 Material 库」主题可接（U1 可解，子树内桥 framework `Theme`），继续 P1 |
| [`2026-10-17-copy-length-governance.md`](2026-10-17-copy-length-governance.md) | 改写完成，审计超限 0 | 按 Apple HIG / NN-g 定槽位长度阈值（实作比规范严 20%）；53 个 key 已改写；剩余 widget 测试断言同步与 41 条人工复核 |
| [`2026-09-15-review-remediation-plan.md`](2026-09-15-review-remediation-plan.md) | 进行中 | 09-08~09-14 审查报告逐条修复；剩余顺序 §3-5 → §3-9（合同级）→ §4 共 20 项 → §5-2/3/4 → §6 |
| [`2026-09-07-record-mini-trend-plan.md`](2026-09-07-record-mini-trend-plan.md) | 未开工 | Wave 1 客户端聚合，不跨 feature 消费 review；与已删除的 review 页重组计划构成阶段 1 的另一半 |
| [`2026-09-02-agentic-proactive-evolution.md`](2026-09-02-agentic-proactive-evolution.md) | Phase 0 起未开工 | 配套 `Lucent/plans/2026-09-02-agentic-proactive-evolution.md` |
| [`2026-08-22-medium-to-large-migration-inventory.md`](2026-08-22-medium-to-large-migration-inventory.md) | 八项 Task 均未开工 | Task 3（架构门禁）已由 `tool/luminous_lints` 的 `layered_import` 规则部分承接（warn 观察模式） |
| [`2026-08-16-remediation-decision-register.md`](2026-08-16-remediation-decision-register.md) | 已决事项权威源 | 优先于各 08-16 计划中尚未清理的旧「不确定点」表述 |

### 功能盘点改造计划（2026-08-16，共 8 份保留）

来源:`research/02-功能盘点/` 十份调研文档(已审阅;内容以各文档「逐功能分析」为准改写,
速览表/结尾汇总仅作参考)。跨功能域共用的内容只在顺序靠前的计划里写全,靠后的计划只做引用;
桌面/Web 产品方向以已接受的 ADR-0008 为准：Flutter Desktop 与 PC Flutter Web 停止产品扩展；
独立 Next.js + Tauri MVP 在 0.1.0 后启动。

2026-08-22 起，十份计划的 0.1.0 前工作视为完成并进入响应契约硬切窗口；保留的 0.1.0 后工作
继续执行，但不与本次契约迁移混合。全局执行顺序(靠前先执行)：

| 顺序 | 计划 | 剩余项 |
| --- | --- | --- |
| 1 | [`2026-08-16-platform-notification-crosscutting-plan.md`](2026-08-16-platform-notification-crosscutting-plan.md) | F-7 环境真实化、F-6 health_sync 自动同步（均 0.1.0 后）；投递三通道与 JPush 密钥已完成 |
| 2 | [`2026-08-16-medicine-remediation-plan.md`](2026-08-16-medicine-remediation-plan.md) | F-5 P2 后端统计对象（0.1.0 前）、F-2 停用/归档（0.1.0 后） |
| 3 | [`2026-08-16-scan-search-remediation-plan.md`](2026-08-16-scan-search-remediation-plan.md) | 本批任务全部完成；剩余 F-2 条码等值匹配（0.1.0 后） |
| 4 | [`2026-08-16-today-remediation-plan.md`](2026-08-16-today-remediation-plan.md) | F-8 `remainingCount` 退役（0.1.0 前）、F-14 环境装配（0.1.0 后） |
| 5 | [`2026-08-16-record-remediation-plan.md`](2026-08-16-record-remediation-plan.md) | P1-3 餐食分层、P1-4 vital 时间序列（0.1.0 后）；P2-3/P2-4 桌面高级能力冻结 |
| 6 | [`2026-08-16-health-event-remediation-plan.md`](2026-08-16-health-event-remediation-plan.md) | H-4 kind 筛选、weightKg 时间序列、conditions 上下文（均 0.1.0 后） |
| 7 | [`2026-08-16-report-remediation-plan.md`](2026-08-16-report-remediation-plan.md) | R-3/R-4 已完成；剩余 R-5 服务端 409 双保险（0.1.0 前）与 R-6 文档漂移 |
| 8 | [`2026-08-16-mine-settings-remediation-plan.md`](2026-08-16-mine-settings-remediation-plan.md) | P1-3 图片质量 / 仅 Wi-Fi 同步（0.1.0 后） |
| 9 | [`2026-08-16-engineering-backend-plan.md`](2026-08-16-engineering-backend-plan.md) | 基座保留；计划态投入（Worker 分离 / rnacos / SaaS / monorepo）暂缓，触发条件见 P2-A~D |
| 10 | [`2026-07-29-native-bridging-roadmap.md`](2026-07-29-native-bridging-roadmap.md) | 后台同步与推送两节已由通知横切计划接管；剩余 Live Activity / 快捷方式 / 桌面热键 |

### 方向性计划（非执行清单）

| 计划 | 状态 |
| --- | --- |
| [`2026-08-14-product-surface-route.md`](2026-08-14-product-surface-route.md) | 方向已决策（ADR-0008 accepted），0.1.0 后启动 |
| [`2026-08-14-flutter-3.47-upgrade-plan.md`](2026-08-14-flutter-3.47-upgrade-plan.md) | 配置类改动已落地（`refactor` 分支）；全量测试被上游 `flutter/flutter#191095` 阻塞 |
| [`2026-07-10-legal-compliance-pages.md`](2026-07-10-legal-compliance-pages.md) | 仅剩 P2-1（ICP 备案号 + About 公司信息），等备案号 |

## 已执行完毕、文件已删的计划

- `2026-10-16-client-capability-gaps.md`（深链 / OAuth 内嵌 WebView / 图片缩放 / 日历回写 / 许可清单）、`2026-09-07-review-page-restructure.md`（Review 页重组）、`2026-09-07-large-file-domain-splitting-plan.md`（大文件拆分）、`2026-09-06-account-profile-restructure.md`（账号体系重构）、`2026-08-31-doc-governance-overhaul-plan.md`（文档治理）、`2026-09-15-meal-analysis-rearchitecture.md`（餐食分析重构）、`2026-08-07-product-loop-program.md` 与 `2026-08-07-visit-summary-and-product-measurement.md`（事件主导产品闭环）、以及 08-16 那批里的「AI 助手改造计划」——结论已沉淀进 feature README、`docs/reference/` 与当日迁移日志。
