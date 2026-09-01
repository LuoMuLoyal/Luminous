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
- 文档治理改进计划（2026-08-31，实施完毕文件已删）
  — 四问审计与归档、docs 去编号重建、feature/core README 全量、可执行约束（七规则 CLI 包 + analysis_options 收紧 + 正文路径校验 + README ≤60 断言）与 doc-map 退役全部落地；两周观察期、七规则收敛与 IDE 插件集成等遗留项见 `docs/TODO.md`「2026-08-31 文档治理遗留」

- [`2026-08-22-medium-to-large-migration-inventory.md`](2026-08-22-medium-to-large-migration-inventory.md)
  — 中大型过渡迁移盘点：错误/合同、离线同步、架构门禁、构建配置、Forui、Riverpod、文件拆分与测试质量门
- [`2026-07-10-legal-compliance-pages.md`](2026-07-10-legal-compliance-pages.md)
  — 合规/法律页面补全：剩余 P2-1 ICP 备案信息 + About 页增强
- [`2026-07-29-native-bridging-roadmap.md`](2026-07-29-native-bridging-roadmap.md)
  — 原生桥接路线图：后台同步、推送通知、健康数据集成、生物识别、应用快捷方式、Live Activity、桌面热键
- [`2026-08-14-flutter-3.47-upgrade-plan.md`](2026-08-14-flutter-3.47-upgrade-plan.md)
  — Flutter 3.47 升级：已落地 refactor，测试被上游语义回归阻塞
- [`2026-08-14-product-surface-route.md`](2026-08-14-product-surface-route.md)
  — 产品表面路线：手机核心 + 桌面 SaaS 差异化 + Web 第三客户端（0.1.0 后启动）
- [`2026-08-16-remediation-decision-register.md`](2026-08-16-remediation-decision-register.md)
  — 功能盘点改造决策记录（十份计划共享，优先于各计划旧表述）

### 功能盘点改造计划(2026-08-16,共 8 份保留)

来源:`research/02-功能盘点/` 十份调研文档(已审阅;内容以各文档「逐功能分析」为准改写,
速览表/结尾汇总仅作参考)。跨功能域共用的内容只在顺序靠前的计划里写全,靠后的计划只做引用;
桌面/Web 产品方向以已接受的 ADR-0008 为准：Flutter Desktop 与 PC Flutter Web 停止产品扩展；独立 Next.js + Tauri MVP 在 0.1.0 后启动。各计划末尾的「已决边界与延期项」记录对应范围。

已确定事项以 [`2026-08-16-remediation-decision-register.md`](2026-08-16-remediation-decision-register.md) 为准；它优先于各计划中尚未清理的旧「不确定点」表述。2026-08-22 起，十份计划的 0.1.0 前工作视为完成并进入响应契约硬切窗口；保留的 0.1.0 后工作继续执行，但不与本次契约迁移混合。

全局执行顺序(靠前先执行;跨计划引用均指向顺序在前的文档):

1. [`2026-08-16-platform-notification-crosscutting-plan.md`](2026-08-16-platform-notification-crosscutting-plan.md)
   — 横切基建:F-7 高德天气 API 真实化与 F-6 health_sync 自动同步执行器(均 0.1.0 后);投递三通道落库、JPush 密钥已完成
2. [`2026-08-16-medicine-remediation-plan.md`](2026-08-16-medicine-remediation-plan.md)
   — 用药:剩余 F-5 P2 后端统计对象(0.1.0 前)与 F-2 停用/归档(0.1.0 后)
3. [`2026-08-16-scan-search-remediation-plan.md`](2026-08-16-scan-search-remediation-plan.md)
   — 扫码/搜索:本批任务全部完成;剩余 F-2 条码等值匹配(0.1.0 后)
4. [`2026-08-16-today-remediation-plan.md`](2026-08-16-today-remediation-plan.md)
   — 今日建议:剩余 F-8 `remainingCount` 退役(0.1.0 前)与 F-14 环境装配(0.1.0 后)
5. AI 助手改造计划（2026-08-16，实施完毕文件已删）
   — 剩余 F-14/F-15 来源条元数据后端投影与记忆擦除设置页入口(0.1.0 后)
6. [`2026-08-16-record-remediation-plan.md`](2026-08-16-record-remediation-plan.md)
   — 记录:剩余 P1-3 餐食分层与 P1-4 vital 时间序列(0.1.0 后)、P2-3/P2-4 桌面高级能力冻结
7. [`2026-08-16-health-event-remediation-plan.md`](2026-08-16-health-event-remediation-plan.md)
   — 健康事件与档案:剩余 H-4 kind 筛选、weightKg 时间序列、conditions 上下文(均 0.1.0 后)
8. [`2026-08-16-report-remediation-plan.md`](2026-08-16-report-remediation-plan.md)
   — 报告:R-3/R-4 已完成;剩余 409 双保险(R-5)与文档漂移(R-6)
9. [`2026-08-16-mine-settings-remediation-plan.md`](2026-08-16-mine-settings-remediation-plan.md)
   — 个人中心与设置:剩余 P1-3 图片质量/仅 Wi-Fi 同步(0.1.0 后)
10. [`2026-08-16-engineering-backend-plan.md`](2026-08-16-engineering-backend-plan.md)
    — 工程与后端平台:基座保留、计划态投入暂缓及触发条件

The event-led product-loop program (`2026-08-07-product-loop-program.md`) and its
execution plan (`2026-08-07-visit-summary-and-product-measurement.md`) were
completed on 2026-08-14 and deleted (实施完毕文件已删).
