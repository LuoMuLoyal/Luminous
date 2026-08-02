---
status: active
owner: frontend
quadrant: explanation
updated: 2026-08-02
---

# 同步失败详情设计

## 背景

Mine 页的 `MineSyncFailedBanner` 已经显示永久失败同步项数量，但点击“查看详情”只调用 Toast，既没有展示失败项，也没有真正执行永久失败项的重试。失败队列本身已经保存了实体类型、操作、记录 ID、重试次数和最近错误，缺少的是面向 UI 的读取与交互。

## 目标与范围

- 点击横幅的“查看详情”打开现有 Forui 对话框样式。
- 展示本地永久失败队列中的真实条目及最近错误。
- 支持将全部永久失败项重置为可重试状态并触发 `SyncWorker.flush()`。
- 保留失败项直到同步成功，不新增后端 API、数据库列或第三方依赖。
- 新增中英文文案、DAO/widget 回归测试和当前状态记录。

## 方案

`PendingSyncDao` 扩展 `PendingSyncEntry` 的 `lastError` 字段，提供永久失败条目查询和按 ID 重置重试状态的方法。Mine 详情组件直接通过 `pendingSyncDaoProvider` 读取这些条目；横幅点击时先异步加载条目，加载完成后调用共享 `showAppDialog` 展示列表。重试全部时先批量重置条目，再调用 `SyncWorker.flush()`，最后刷新 `syncFailedCountProvider`。

详情对话框只显示安全的本地诊断字段：实体类型、操作、记录 ID（若有）、`retryCount/maxRetry`、创建时间和 `lastError`。不解析或执行 payload，也不把内部请求 payload 暴露给用户。

## 错误处理

- 查询失败时关闭加载状态并显示已有通用错误反馈，不显示 Toast 作为成功的“查看详情”替代。
- 没有条目时关闭对话框或显示空态，避免计数与明细短暂不一致导致空白列表。
- 重试动作失败时保留对话框和失败条目，并显示失败反馈；成功触发 provider 刷新。

## 验证

- DAO 测试验证永久失败条目的读取、`lastError` 映射和重置后重新进入 ready 队列。
- Widget 测试验证点击横幅打开详情内容，不出现 Toast-only 行为；验证重试按钮调用重置/flush seam。
- 运行相关 Flutter tests、`flutter analyze`、格式检查和 `dart run scripts/check_doc_coverage.dart --warning-only`。
