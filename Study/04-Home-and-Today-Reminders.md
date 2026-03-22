# 04 首页与今日提醒

## 这个功能是干什么的

首页负责把健康小贴士、顶部色块、快捷入口和“今日提醒”汇总到同一屏。

## 用户从哪里进入 / 如何触发

- 冷启动默认第一页就是首页 Tab
- 下拉刷新会重新拉取今日提醒
- 点击快捷入口进入搜索、识别、提醒、打卡、安全辅助等功能

## 关键页面、组件、API、store、backend、native 文件

- 页面：`lib/pages/Home/home.dart`
- API：`lib/api/home_api.dart`
- 模型：`lib/viewmodels/home.dart`
- 本地今日提醒存储：`lib/stores/today_reminder_local_store.dart`
- 本地数据库：`lib/stores/app_database.dart`
- 用户态：`lib/stores/user_controller.dart`
- 顶部 UI：`lib/components/home.dart`
- 顶部配色：`lib/components/soft_banner.dart`

## 核心实现路径

### UI 入口

- `HomeView` 初始化时立即加载今日提醒
- 顶部色块展示启动期随机选中的小贴士
- “健康小贴士”支持点按切换、长按显示全部列表

### 状态来源

- 小贴士来自本地 `_localHealthTips`
- 今日提醒来自 `HomeApi.fetchTodayReminders()` 和 `TodayReminderStore`

### 网络 / 本地存储 / 后端流转

- 首页先请求 `today-reminders`
- 请求成功后，把完整结果覆盖到当天快照表 `today_reminder_snapshots`
- 然后通过 `TodayReminderLocalStore.loadTodaySnapshotItems()` 叠加 `checkins` 和 `checkin_overrides`，统一得到 UI 最终状态
- 请求失败时只回退到当天快照；如果当天快照也没有，才回退到首页内置 `_fallbackReminders`
- `reminders` 表现在只承担“提醒计划缓存”职责，不再参与首页当天展示真相

### 结果如何回到 UI

- `_reminders` 改变后，顶部“下一次提醒”和下方提醒列表同步刷新
- 返回提醒页和打卡页后，首页会再次触发 `_fetchTodayReminders()`

## 关键代码位置

- `lib/pages/Home/home.dart:47`
  首页组件入口，支持注入自定义 fetch/store，方便测试与解耦。
- `lib/pages/Home/home.dart:191`
  首页初始化时绑定用户变化并拉取提醒。
- `lib/pages/Home/home.dart:261`
  快捷入口点击分发。
- `lib/pages/Home/home.dart:328`
  今日提醒主数据流入口。
- `lib/pages/Home/home.dart:348`
  远端成功后覆盖当天快照。
- `lib/pages/Home/home.dart:357`
  从快照 + 本地状态读取最终提醒并映射成首页 UI。
- `lib/pages/Home/home.dart:440`
  点按切换健康小贴士。
- `lib/pages/Home/home.dart:463`
  长按展示全部小贴士列表。
- `lib/api/home_api.dart:13`
  今日提醒接口封装。
- `lib/stores/today_reminder_local_store.dart:68`
  用远端完整结果覆盖当天快照。
- `lib/stores/today_reminder_local_store.dart:103`
  读取今日 override。
- `lib/stores/today_reminder_local_store.dart:185`
  从“当天快照 + 本地打卡 / override”组装最终提醒。
- `lib/stores/app_database.dart:176`
  今日提醒快照表定义。

## 容易忽略的实现细节

- 小贴士随机值在文件级初始化时确定，整个冷启动会保持同一条
- 首页对提醒请求做了 `requestId` 防抖，避免旧请求覆盖新用户结果
- 成功路径和失败回退现在都统一走“当天快照”口径，这样旧 `reminders` 表不会再把远端新结果盖掉

## 如果以后要改，优先改哪里

- 改顶部卡片和小贴士逻辑：`lib/pages/Home/home.dart`
- 改今日提醒接口字段：`lib/api/home_api.dart` 和 `lib/viewmodels/home.dart`
- 改当天提醒数据源口径：`lib/stores/today_reminder_local_store.dart` + `lib/stores/app_database.dart`

## 相关测试在哪

- `test/home_top_section_test.dart:39`
  覆盖小贴士点击和长按行为。
- `test/home_today_reminders_test.dart:36`
  覆盖“远端成功后覆盖旧快照并渲染新提醒”。
