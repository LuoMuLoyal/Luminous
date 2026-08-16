# Luminous Plans

Use this directory for active, repo-local execution plans that are too detailed for
`docs/00-current/Next_Plan.md`.

## What Goes Here

- multi-step implementation plans
- review/handoff checklists for a specific Luminous task
- temporary task docs that are still actively driving work

## What Does Not Go Here

- current product facts: put those in `docs/00-current/Current_State.md`
- next work ordering for the repo as a whole: put that in `docs/00-current/Next_Plan.md`
- historical change logs: put those in `docs/03-logs/migration-log/YYYY-MM-DD.md`
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

- [`2026-07-10-legal-compliance-pages.md`](2026-07-10-legal-compliance-pages.md)
- [`2026-07-29-native-bridging-roadmap.md`](2026-07-29-native-bridging-roadmap.md)
- [`2026-08-01-ai-chat-redesign-plan.md`](2026-08-01-ai-chat-redesign-plan.md)
- [`2026-08-14-flutter-3.47-upgrade-plan.md`](2026-08-14-flutter-3.47-upgrade-plan.md)

### 功能盘点改造计划(2026-08-16,共 10 份)

来源:`research/02-功能盘点/` 十份调研文档(已审阅;内容以各文档「逐功能分析」为准改写,
速览表/结尾汇总仅作参考)。跨功能域共用的内容只在顺序靠前的计划里写全,靠后的计划只做引用;
桌面/Web 产品方向以已接受的 ADR-0012 为准：Flutter Desktop 与 PC Flutter Web 停止产品扩展；独立 Next.js + Tauri MVP 在 0.1.0 后启动。各计划末尾的「已决边界与延期项」记录对应范围。

已确定事项以 [`2026-08-16-remediation-decision-register.md`](2026-08-16-remediation-decision-register.md) 为准；它优先于各计划中尚未清理的旧「不确定点」表述。

全局执行顺序(靠前先执行;跨计划引用均指向顺序在前的文档):

1. [`2026-08-16-platform-notification-crosscutting-plan.md`](2026-08-16-platform-notification-crosscutting-plan.md)
   — 横切基建:F-7 高德天气 API 真实化与 F-6 health_sync 自动同步执行器(均 0.1.0 后);投递三通道落库、JPush 密钥已完成
2. [`2026-08-16-medicine-remediation-plan.md`](2026-08-16-medicine-remediation-plan.md)
   — 用药:药品详情页、依从性 ObservedMetric 口径统一、LocalNotificationGateway
3. [`2026-08-16-scan-search-remediation-plan.md`](2026-08-16-scan-search-remediation-plan.md)
   — 扫码/搜索:P0 识别出口断链修复、建档闭环
4. [`2026-08-16-today-remediation-plan.md`](2026-08-16-today-remediation-plan.md)
   — 今日建议:AI 摘要卡接线、建议反馈与升级通知执行器
5. [`2026-08-16-assistant-remediation-plan.md`](2026-08-16-assistant-remediation-plan.md)
   — AI 助手:P0 三大信任缺口(免责呈现、来源展示、信任分层)
6. [`2026-08-16-record-remediation-plan.md`](2026-08-16-record-remediation-plan.md)
   — 记录:vital 时间序列基建、饮水目标契约、摘要网格接线
7. [`2026-08-16-health-event-remediation-plan.md`](2026-08-16-health-event-remediation-plan.md)
   — 健康事件与档案:详情接线、事件升级通知、档案字段治理
8. [`2026-08-16-report-remediation-plan.md`](2026-08-16-report-remediation-plan.md)
   — 报告:纵向洞察生成器、legacy 打包改造(均在 0.1.0 前)
9. [`2026-08-16-mine-settings-remediation-plan.md`](2026-08-16-mine-settings-remediation-plan.md)
   — 个人中心与设置:PIN elevation 接线、假开关治理、support 接口清理
10. [`2026-08-16-engineering-backend-plan.md`](2026-08-16-engineering-backend-plan.md)
    — 工程与后端平台:基座保留、计划态投入暂缓及触发条件

The event-led product-loop program (`2026-08-07-product-loop-program.md`) and its
execution plan (`2026-08-07-visit-summary-and-product-measurement.md`) were
completed on 2026-08-14 and deleted (实施完毕文件已删).
