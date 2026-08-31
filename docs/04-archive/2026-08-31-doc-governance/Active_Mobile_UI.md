---
status: active
owner: frontend
quadrant: reference
updated: 2026-08-13
---

# Active Mobile UI

Last updated: 2026-08-13

本文档是五个 Tab 页面状态的汇总入口。每个 Tab 的详情见子文件。

## App 启动流程

- `LuminousApp.initState` 的 postFrame 回调中执行两个操作：
  1. `authSessionProvider.notifier.restore()` — 恢复认证会话
  2. `ref.read(cacheCleanupProvider)` — 触发数据保留期缓存清理（ADR-0009）
- 缓存清理读取用户在设置页面配置的 `DataRetentionPeriod`，按保留期计算 cutoff 日期，调用 `DailyRecordDao.cleanup` 和 `MedicineDoseLogDao.cleanup`。forever 模式跳过清理，pending（未同步）行始终保留。

## 页面索引

- [[Active_UI_Today]] — Today
- [[Active_UI_Record]] — Record
- [[Active_UI_Medicine]] — Medicine
- [[Active_UI_Report]] — Report / Review（第五 Tab 用户任务已改为「回顾/Review」，`/report` 保留为兼容路由，含 Clinic Summary legacy）
- [[Active_UI_Mine_Settings]] — Mine / Settings

## 2026-08-13 更新（Review Experience 收口）

- 第五 Tab 用户可见任务名从「报告/Report」改为「回顾/Review」（Task 5，改 `tabReport` ARB key）；`/report` 路由路径与 `features/report` 目录保留为兼容，深链与既有行为不变。
- `/report` 主内容为事件优先 `ReviewView`（Task 6）：事件头部 + 四段（发生了什么/有什么变化/完成了什么/接下来怎么办）+ 历史筛选，六状态覆盖（loading/active/ended/partial/no-event/error-with-cache）；无综合评分、无整页 readiness 锁、无默认导出区。
- 导出与就诊摘要迁入「更多」sheet（Task 8）：就诊摘要/PDF/打印下载/历史报告四入口；旧 dashboard 仅经 `/report/legacy` 兼容页可达，代码保留未删除（LEGACY 标注）。
- 桌面/Web 未做功能对等：新增 UI 只保证手机端，桌面渲染同一移动端布局。
- 验证（Task 10）：`flutter analyze` 无问题；`flutter test` 全量 3067 passed / 1 skipped（既有跳过）；桌面 e2e 11 用例全绿；golden 四张 + a11y 语义顺序锁定主路径回归。

## 2026-07-28 更新

- Record 移动端 header 新增快速记录设置入口，与 NLP 入口并列。
- Record 快速记录区域 header 从动态排序控制改为 help affordance；动态排序和手动排序入口迁移到 `/record/quick-entry-settings`。
