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
- [`2026-08-17-error-handling-reform-plan.md`](2026-08-17-error-handling-reform-plan.md)
  — 错误处理硬切：fpdart + LucentFailure + RFC 9457；2026-08-22 已进入冻结新功能的硬切窗口，0.1.0 后遗留工作不再阻塞
### 功能盘点改造计划(2026-08-16,共 10 份)

来源:`research/02-功能盘点/` 十份调研文档(已审阅;内容以各文档「逐功能分析」为准改写,
速览表/结尾汇总仅作参考)。跨功能域共用的内容只在顺序靠前的计划里写全,靠后的计划只做引用;
桌面/Web 产品方向以已接受的 ADR-0012 为准：Flutter Desktop 与 PC Flutter Web 停止产品扩展；独立 Next.js + Tauri MVP 在 0.1.0 后启动。各计划末尾的「已决边界与延期项」记录对应范围。

已确定事项以 [`2026-08-16-remediation-decision-register.md`](2026-08-16-remediation-decision-register.md) 为准；它优先于各计划中尚未清理的旧「不确定点」表述。2026-08-22 起，十份计划的 0.1.0 前工作视为完成并进入响应契约硬切窗口；保留的 0.1.0 后工作继续执行，但不与本次契约迁移混合。

全局执行顺序(靠前先执行;跨计划引用均指向顺序在前的文档):

1. [`2026-08-16-platform-notification-crosscutting-plan.md`](2026-08-16-platform-notification-crosscutting-plan.md)
   — 横切基建:F-7 高德天气 API 真实化与 F-6 health_sync 自动同步执行器(均 0.1.0 后);投递三通道落库、JPush 密钥已完成
2. [`2026-08-16-medicine-remediation-plan.md`](2026-08-16-medicine-remediation-plan.md)
   — 用药:本批任务全部完成(详情页/i18n/口径 P1/P2 收尾);剩余 F-5 P2 后端统计对象(0.1.0 前)与 F-2 停用/归档(0.1.0 后)
3. [`2026-08-16-scan-search-remediation-plan.md`](2026-08-16-scan-search-remediation-plan.md)
   — 扫码/搜索:本批任务全部完成(识别出口接建档闭环、预检即时化、去假置信度、候选去重合并);剩余 F-2 条码等值匹配(0.1.0 后)
4. [`2026-08-16-today-remediation-plan.md`](2026-08-16-today-remediation-plan.md)
   — 今日建议:0.1.0 前任务已完成(摘要卡接线、触发扩展与升级通知、skip_dose/静默刷新/重试/一键饮水/未读数/真实化等 13 项);剩余 F-8 `remainingCount` 退役(0.1.0 前)与 F-14 环境装配(0.1.0 后)
5. AI 助手改造计划（2026-08-16，实施完毕文件已删）
   — 本批任务全部完成(P0 三大信任缺口、F-2 会话重命名删除、F-5b 重生/断流补偿、F-9 记忆压缩、F-11/F-16 一致性、F-15 语料分层、P2 批次);剩余 F-14/F-15 来源条元数据后端投影与记忆擦除设置页入口(0.1.0 后)
6. [`2026-08-16-record-remediation-plan.md`](2026-08-16-record-remediation-plan.md)
   — 记录:0.1.0 前任务全部完成(摘要网格接线与饮水 ml 角标、饮水目标读 user-settings、详情页确认入口、静态残留清理、Today 联动验证);剩余 P1-3 餐食分层与 P1-4 vital 时间序列(0.1.0 后)、P2-3/P2-4 桌面高级能力冻结
7. [`2026-08-16-health-event-remediation-plan.md`](2026-08-16-health-event-remediation-plan.md)
   — 健康事件与档案:0.1.0 前任务全部完成(历史事件详情接线与触发记录展示、事件专属升级通知与 topic 补全、档案提醒真实化、单位制切换、完成度口径);剩余 H-4 kind 筛选、weightKg 时间序列、conditions 上下文(0.1.0 后)
8. [`2026-08-16-report-remediation-plan.md`](2026-08-16-report-remediation-plan.md)
   — 报告:0.1.0 前部分完成——就诊摘要六开关、历史翻页、纵向洞察服务端口径与移除综合评分已落地;剩余 Review 视图装配(R-3)、legacy 重装配 #19/#21/#22 与后端裁剪(R-4)、409 双保险(R-5)、文档漂移(R-6)
9. [`2026-08-16-mine-settings-remediation-plan.md`](2026-08-16-mine-settings-remediation-plan.md)
   — 个人中心与设置:PIN elevation 接线、假开关治理、support 接口清理
10. [`2026-08-16-engineering-backend-plan.md`](2026-08-16-engineering-backend-plan.md)
    — 工程与后端平台:基座保留、计划态投入暂缓及触发条件

The event-led product-loop program (`2026-08-07-product-loop-program.md`) and its
execution plan (`2026-08-07-visit-summary-and-product-measurement.md`) were
completed on 2026-08-14 and deleted (实施完毕文件已删).
