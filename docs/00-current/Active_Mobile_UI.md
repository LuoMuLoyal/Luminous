# Active Mobile UI

Last updated: 2026-07-28

本文档是五个 Tab 页面状态的汇总入口。每个 Tab 的详情见子文件。

## App 启动流程

- `LuminousApp.initState` 的 postFrame 回调中执行两个操作：
  1. `authSessionProvider.notifier.restore()` — 恢复认证会话
  2. `ref.read(cacheCleanupProvider)` — 触发数据保留期缓存清理（ADR-0009）
- 缓存清理读取用户在设置页面配置的 `DataRetentionPeriod`，按保留期计算 cutoff 日期，调用 `DailyRecordDao.cleanup` 和 `MedicineDoseLogDao.cleanup`。forever 模式跳过清理，pending（未同步）行始终保留。

## 页面索引

- [[00-current/Active_UI_Today]] — Today
- [[00-current/Active_UI_Record]] — Record
- [[00-current/Active_UI_Medicine]] — Medicine
- [[00-current/Active_UI_Report]] — Report（含 Clinic Summary）
- [[00-current/Active_UI_Mine_Settings]] — Mine / Settings

## 2026-07-28 更新

- Record 移动端 header 新增快速记录设置入口，与 NLP 入口并列。
- Record 快速记录区域 header 从动态排序控制改为 help affordance；动态排序和手动排序入口迁移到 `/record/quick-entry-settings`。
