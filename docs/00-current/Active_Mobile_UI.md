# Active Mobile UI

本文档汇总 Today / Record / Medicine / Report / Clinic Summary / Mine/Settings 的当前状态。每个 tab 的详情见子文件。

## App 启动流程

- `LuminousApp.initState` 的 postFrame 回调中执行两个操作：
  1. `authSessionProvider.notifier.restore()` — 恢复认证会话
  2. `ref.read(cacheCleanupProvider)` — 触发数据保留期缓存清理（ADR-0009）
- 缓存清理读取用户在设置页面配置的 `DataRetentionPeriod`，按保留期计算 cutoff 日期，调用 `DailyRecordDao.cleanup` 和 `MedicineDoseLogDao.cleanup`。forever 模式跳过清理，pending（未同步）行始终保留。

- [[00-current/Active_UI_Today]] — Today
- [[00-current/Active_UI_Record]] — Record
- [[00-current/Active_UI_Medicine]] — Medicine
- [[00-current/Active_UI_Report]] — Report
- [[00-current/Active_UI_Clinic_Summary]] — Clinic Summary
- [[00-current/Active_UI_Mine_Settings]] — Mine / Settings
